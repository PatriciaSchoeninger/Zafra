import 'dart:async';
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
  bool _onlyFavorites = false;
  Timer? _debounce;
  bool _loading = false;

  // Ordenação
  SortOption _sort = SortOption.recent;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
                if (!context.mounted) return;
                context.go('/edit/${r.id}');
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nova receita',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2.6),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    onChanged: (v) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        if (!mounted) return;
                        setState(() => _query = v);
                      });
                    },
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐ Somente favoritas'),
                          Switch(
                            value: _onlyFavorites,
                            onChanged: (v) => setState(() => _onlyFavorites = v),
                          ),
                        ],
                      ),
                      DropdownButton<SortOption>(
                        value: _sort,
                        onChanged: (v) => setState(() => _sort = v ?? SortOption.recent),
                        items: const [
                          DropdownMenuItem(value: SortOption.recent, child: Text('Atualizadas recentemente')),
                          DropdownMenuItem(value: SortOption.title, child: Text('Título A–Z')),
                          DropdownMenuItem(value: SortOption.favoritesFirst, child: Text('Favoritas primeiro')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Observa a box do Hive e atualiza automaticamente
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Recipe>('recipes').listenable(),
          builder: (context, Box<Recipe> box, _) {
            final all = box.values.toList();

            // Busca
            var items = _query.isEmpty
                ? all
                : all
                    .where((r) =>
                        r.title.toLowerCase().contains(_query.toLowerCase()) ||
                        r.ingredients
                            .any((i) => i.name.toLowerCase().contains(_query.toLowerCase())))
                    .toList();

            // Filtro favoritas
            if (_onlyFavorites) {
              items = items.where((r) => r.favorite).toList();
            }

            // Ordenação
            switch (_sort) {
              case SortOption.recent:
                items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                break;
              case SortOption.title:
                items.sort(
                    (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                break;
              case SortOption.favoritesFirst:
                items.sort((a, b) {
                  final fav = (b.favorite ? 1 : 0) - (a.favorite ? 1 : 0);
                  if (fav != 0) return fav;
                  return b.updatedAt.compareTo(a.updatedAt);
                });
                break;
            }

            if (_loading) {
              return const LinearProgressIndicator();
            }

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
                          child: Builder(
                            builder: (_) {
                              final String? firstPath =
                                  r.photoPaths.isNotEmpty ? r.photoPaths.first : null;
                              if (firstPath != null && File(firstPath).existsSync()) {
                                return Image.file(
                                  File(firstPath),
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.photo, size: 48),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          minVerticalPadding: 0,
                          visualDensity:
                              const VisualDensity(horizontal: -2, vertical: -2),
                          title: Text(
                            r.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'R\$ ${r.costPerServing.toStringAsFixed(2)} por porção',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  r.favorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: r.favorite ? Colors.amber : null,
                                ),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text('Atualizar favorito?'),
                                      content: Text(
                                          'Deseja ${r.favorite ? 'remover dos' : 'adicionar aos'} favoritos "${r.title}"?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancelar')),
                                        FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Confirmar')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    setState(() => _loading = true);
                                    final repo = ref.read(recipeRepoProvider);
                                    r.favorite = !r.favorite;
                                    await repo.save(r);
                                    if (!context.mounted) return;
                                    setState(() => _loading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Favoritos atualizado')),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Excluir receita?'),
                                      content: Text(
                                          'Tem certeza que deseja excluir "${r.title}"?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancelar')),
                                        FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Excluir')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    // Snapshot para desfazer (sem coverIndex)
                                    final snapshot = Recipe(
                                      id: r.id,
                                      title: r.title,
                                      photoPaths:
                                          List<String>.from(r.photoPaths),
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

                                    final repo =
                                        ref.read(recipeRepoProvider);
                                    await repo.delete(r);
                                    setState(() {});
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Receita excluída'),
                                        action: SnackBarAction(
                                          label: 'Desfazer',
                                          onPressed: () async {
                                            await repo.save(snapshot);
                                            if (context.mounted) {
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ),
                                    );
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
          decoration:
              const InputDecoration(hintText: 'Ex.: Bolo de cenoura'),
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

enum SortOption { recent, title, favoritesFirst }
