import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/widgets.dart';
import '../../data/data_models/recipe.dart';
import '../../data/data_models/ingredient_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zafra'),
        actions: [
          IconButton(
            onPressed: () async {
              final title = await _dialogNewRecipe(context);
              if (title != null && title.trim().isNotEmpty) {
                final repo = ref.read(recipeRepoProvider);
                final r = await repo.create(title.trim());
                if (context.mounted) context.go('/edit/${r.id}');
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nova receita',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por título ou ingrediente...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),

      // ✅ Agora observa a box do Hive e atualiza automaticamente
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Recipe>('recipes').listenable(),
        builder: (context, Box<Recipe> box, _) {
          final all = box.values.toList();

          final items = _query.isEmpty
              ? all
              : all.where((r) =>
                  r.title.toLowerCase().contains(_query.toLowerCase()) ||
                  r.ingredients.any((i) =>
                      i.name.toLowerCase().contains(_query.toLowerCase()))
                ).toList();

          if (items.isEmpty) {
            return const Center(
                child: Text('Sem receitas ainda. Toque + para criar.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final r = items[i];
              return GestureDetector(
                onTap: () => context.go('/edit/${r.id}'),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: r.photoPaths.isNotEmpty
                            ? Image.file(
                                File(r.photoPaths.first),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.photo, size: 48),
                              ),
                      ),
                      ListTile(
                        title: Text(
                          r.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'R\$ ${r.costPerServing.toStringAsFixed(2)} por porção',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              r.favorite ? Icons.star : Icons.star_border,
                              color: r.favorite ? Colors.amber : null,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Excluir receita?'),
                                    content: Text('Tem certeza que deseja excluir "${r.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  // Snapshot para desfazer
                                  final snapshot = Recipe(
                                    id: r.id,
                                    title: r.title,
                                    photoPaths: List<String>.from(r.photoPaths),
                                    servings: r.servings,
                                    prepTimeMin: r.prepTimeMin,
                                    cookTimeMin: r.cookTimeMin,
                                    category: r.category,
                                    tags: List<String>.from(r.tags),
                                    ingredients: r.ingredients
                                        .map((i) => IngredientItem(
                                              masterId: i.masterId,
                                              name: i.name,
                                              quantity: i.quantity,
                                              unit: i.unit,
                                              price: i.price,
                                              haveAtHome: i.haveAtHome,
                                            ))
                                        .toList(),
                                    steps: List<String>.from(r.steps),
                                    favorite: r.favorite,
                                    source: r.source,
                                    notes: r.notes,
                                    createdAt: r.createdAt,
                                    updatedAt: r.updatedAt,
                                  );

                                  final repo = ref.read(recipeRepoProvider);
                                  await repo.delete(r);
                                  setState(() {});
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Receita excluída'),
                                        action: SnackBarAction(
                                          label: 'Desfazer',
                                          onPressed: () async {
                                            await repo.save(snapshot);
                                            if (context.mounted) setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _dialogNewRecipe(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova receita'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex.: Bolo de cenoura'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}




