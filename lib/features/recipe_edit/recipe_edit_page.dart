import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repo/recipe_repo.dart';
import '../../data/models/recipe.dart';
import '../../shared/widgets.dart';

class RecipeEditPage extends ConsumerStatefulWidget {
  final String? recipeId;
  const RecipeEditPage({super.key, required this.recipeId});
  @override
  ConsumerState<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends ConsumerState<RecipeEditPage> {
  Recipe? r;
  final titleCtrl = TextEditingController();
  final servingsCtrl = TextEditingController(text: '1');
  final stepCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = ref.read(recipeRepoProvider);
    r = repo.list().firstWhere((x) => x.id == widget.recipeId);
    titleCtrl.text = r!.title;
    servingsCtrl.text = r!.servings.toString();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar receita'),
        actions: [
          IconButton(
            tooltip: 'Favorito',
            onPressed: () async {
              r!.favorite = !r!.favorite;
              await repo.save(r!);
              setState(() {});
            },
            icon: Icon(r!.favorite ? Icons.star : Icons.star_border),
          ),
          IconButton(
            tooltip: 'Salvar',
            onPressed: () async {
              r!
                ..title = titleCtrl.text.trim()
                ..servings = int.tryParse(servingsCtrl.text) ?? 1;
              await repo.save(r!);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: titleCtrl,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: servingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Porções'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tempo preparo (min)'),
                  onChanged: (v) => r!.prepTimeMin = int.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tempo cozimento (min)'),
                  onChanged: (v) => r!.cookTimeMin = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Passos', style: Theme.of(context).textTheme.titleMedium),
          ...List.generate(r!.steps.length, (i) => ListTile(
                leading: CircleAvatar(child: Text('${i+1}')),
                title: Text(r!.steps[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    r!.steps.removeAt(i);
                    await repo.save(r!);
                    setState(() {});
                  },
                ),
              )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: stepCtrl,
                  decoration: const InputDecoration(hintText: 'Novo passo...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  if (stepCtrl.text.trim().isEmpty) return;
                  r!.steps.add(stepCtrl.text.trim());
                  stepCtrl.clear();
                  await repo.save(r!);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Ingredientes (MVP: texto livre rápido)',
              style: Theme.of(context).textTheme.titleMedium),
          ...r!.ingredients.map((i) => ListTile(
                title: Text('${i.quantity} ${i.unit}  •  ${i.name}'),
                subtitle: i.price != null ? Text('R\$ ${i.price!.toStringAsFixed(2)}') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    r!.ingredients.remove(i);
                    await repo.save(r!);
                    setState(() {});
                  },
                ),
              )),
          FilledButton.tonal(
            onPressed: () async {
              final it = await _dialogAddIngredient(context);
              if (it != null) {
                r!.ingredients.add(it);
                await repo.save(r!);
                setState(() {});
              }
            },
            child: const Text('Adicionar ingrediente'),
          ),
          const SizedBox(height: 24),
          Text('Custo total: R\$ ${r!.totalCost.toStringAsFixed(2)} • '
               'por porção: R\$ ${r!.costPerServing.toStringAsFixed(2)}'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<IngredientItem?> _dialogAddIngredient(BuildContext ctx) async {
    final name = TextEditingController();
    final qty  = TextEditingController();
    final unit = TextEditingController(text: 'g');
    final price= TextEditingController();
    return showDialog<IngredientItem>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Ingrediente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade')),
            TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unidade (g/ml/xic/un...)')),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço (opcional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final q = double.tryParse(qty.text.replaceAll(',', '.')) ?? 0;
              final p = double.tryParse(price.text.replaceAll(',', '.'));
              Navigator.pop(ctx, IngredientItem(
                name: name.text.trim(), quantity: q, unit: unit.text.trim(), price: p,
              ));
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
