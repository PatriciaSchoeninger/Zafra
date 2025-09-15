import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repo/recipe_repo.dart';
import '../../shared/widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepoProvider);
    final items = repo.list(search: _query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livro de Receitas da Mãe'),
        actions: [
          IconButton(
            onPressed: () async {
              final title = await _dialogNewRecipe(context);
              if (title != null && title.trim().isNotEmpty) {
                final r = await repo.create(title.trim());
                if (context.mounted) context.go('/edit?id=${r.id}');
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
      body: items.isEmpty
          ? const Center(child: Text('Sem receitas ainda. Toque + para criar.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 3/4,
              ),
              itemCount: items.length,
              itemBuilder: (c, i) {
                final r = items[i];
                return GestureDetector(
                  onTap: () => context.go('/edit?id=${r.id}'),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: r.photoPaths.isNotEmpty
                              ? Image.asset( // placeholder; depois trocamos pra FileImage
                                  'assets/placeholder.jpg', fit: BoxFit.cover)
                              : Container(
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  child: const Icon(Icons.photo, size: 48),
                                ),
                        ),
                        ListTile(
                          title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${r.costPerServing.toStringAsFixed(2)} por porção'),
                          trailing: Icon(
                            r.favorite ? Icons.star : Icons.star_border,
                            color: r.favorite ? Colors.amber : null,
                          ),
                        ),
                      ],
                    ),
                  ),
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
          controller: controller, autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex.: Bolo de cenoura'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Criar')),
        ],
      ),
    );
  }
}
