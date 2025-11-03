import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/widgets.dart'; // providers
import '../../data/data_models/recipe.dart';
import '../../data/data_models/ingredient_item.dart';

class RecipeEditPage extends ConsumerStatefulWidget {
  final String? recipeId;
  const RecipeEditPage({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends ConsumerState<RecipeEditPage> {
  Recipe? r;
  final titleCtrl = TextEditingController();
  final stepCtrl = TextEditingController();

  final Set<String> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    final repo = ref.read(recipeRepoProvider);
    r = widget.recipeId != null ? repo.getById(widget.recipeId!) : null;

    // ⚡ Garante que as listas sejam mutáveis
    if (r != null) { r!.photoPaths = List.from(r!.photoPaths);
    r!.steps = List.from(r!.steps);
    r!.ingredients = List.from(r!.ingredients);

    titleCtrl.text = r!.title;
    }
  }

  Future<void> _addPhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Adicionar foto'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Text('Tirar foto'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Text('Escolher da galeria'),
          ),
        ],
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          r!.photoPaths.add(picked.path);
        });
        final repo = ref.read(recipeRepoProvider);
        await repo.save(r!);
      }
    }
  }

  Future<void> _setAsCover(int index) async {
    if (index < 0 || index >= r!.photoPaths.length) return;
    final path = r!.photoPaths.removeAt(index);
    r!.photoPaths.insert(0, path); // move para capa
    final repo = ref.read(recipeRepoProvider);
    await repo.save(r!);
    setState(() {});
  }

  Future<void> _removePhoto(int index) async {
    if (index < 0 || index >= r!.photoPaths.length) return;
    r!.photoPaths.removeAt(index);
    final repo = ref.read(recipeRepoProvider);
    await repo.save(r!);
    setState(() {});
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    stepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(recipeRepoProvider);

    if (r == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar receita'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Receita não encontrada')),
      );
    }

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
              r!.title = titleCtrl.text.trim();
              await repo.save(r!);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Capa grande com ações (alterar/adc foto)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Builder(
                  builder: (_) {
                    if (r!.photoPaths.isNotEmpty) {
                      final path = r!.photoPaths.first;
                      final file = File(path);
                      if (file.existsSync()) {
                        return Image.file(file, fit: BoxFit.cover);
                      }
                    }
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.photo, size: 80),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Alterar capa',
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: () => _showCoverPicker(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Adicionar foto',
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                        icon: const Icon(Icons.add_a_photo, color: Colors.white),
                        onPressed: _addPhoto,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botão adicionar nova foto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FilledButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Adicionar foto"),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: titleCtrl,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Título da receita',
              ),
            ),
          ),

          // Steppers para infos rápidas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepper(
                  label: 'Porções',
                  value: r!.servings,
                  onChanged: (v) {
                    setState(() => r!.servings = v);
                    repo.save(r!);
                  },
                ),
                _buildStepper(
                  label: 'Preparo (min)',
                  value: r!.prepTimeMin,
                  onChanged: (v) {
                    setState(() => r!.prepTimeMin = v);
                    repo.save(r!);
                  },
                ),
                _buildStepper(
                  label: 'Cozimento (min)',
                  value: r!.cookTimeMin,
                  onChanged: (v) {
                    setState(() => r!.cookTimeMin = v);
                    repo.save(r!);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Galeria extra
          if (r!.photoPaths.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Galeria',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: r!.photoPaths.length - 1,
                      itemBuilder: (context, i) {
                        final index = i + 1; // pula capa
                        final path = r!.photoPaths[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              Image.file(File(path),
                                  width: 120, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'capa') {
                                      _setAsCover(index);
                                    } else if (value == 'remover') {
                                      _removePhoto(index);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'capa',
                                      child: Text('Definir como capa'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'remover',
                                      child: Text('Remover'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Ingredientes como checklist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredientes',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...r!.ingredients.map(
                  (i) => CheckboxListTile(
                    value: _checkedIngredients.contains(i.name),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _checkedIngredients.add(i.name);
                        } else {
                          _checkedIngredients.remove(i.name);
                        }
                      });
                    },
                    title: Text('${i.quantity} ${i.unit} • ${i.name}'),
                    subtitle: i.price != null
                        ? Text('R\$ ${i.price!.toStringAsFixed(2)}')
                        : null,
                    secondary: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        r!.ingredients.remove(i);
                        await repo.save(r!);
                        setState(() {});
                      },
                    ),
                  ),
                ),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Passos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modo de Preparo',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                                ReorderableListView.builder(
                  key: const PageStorageKey('steps-list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: r!.steps.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = r!.steps.removeAt(oldIndex);
                    r!.steps.insert(newIndex, item);
                    await repo.save(r!);
                    setState(() {});
                  },
                  itemBuilder: (context, i) {
                    return ListTile(
                      key: ValueKey('step_'+i.toString()),
                      leading: CircleAvatar(child: Text('')),
                      title: Text(r!.steps[i]),
                      onTap: () async {
                        final edited = await _dialogEditStep(context, r!.steps[i]);
                        if (edited != null && edited.trim().isNotEmpty) {
                          r!.steps[i] = edited.trim();
                          await repo.save(r!);
                          setState(() {});
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final edited = await _dialogEditStep(context, r!.steps[i]);
                              if (edited != null && edited.trim().isNotEmpty) {
                                r!.steps[i] = edited.trim();
                                await repo.save(r!);
                                setState(() {});
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              r!.steps.removeAt(i);
                              await repo.save(r!);
                              setState(() {});
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    );
                  },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: stepCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Novo passo...',
                  ),
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Custo total: R\$ ${r!.totalCost.toStringAsFixed(2)} • por porção: R\$ ${r!.costPerServing.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Stepper para porções/tempos
  Widget _buildStepper({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Text('$label: $value',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }

  Future<IngredientItem?> _dialogAddIngredient(BuildContext ctx) async {
    final name = TextEditingController();
    final qty = TextEditingController();
    final unit = TextEditingController(text: 'g');
    final price = TextEditingController();

    return showDialog<IngredientItem>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Ingrediente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: unit,
              decoration: const InputDecoration(
                  labelText: 'Unidade (g/ml/xic/un...)'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Preço (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final q = double.tryParse(qty.text.replaceAll(',', '.')) ?? 0;
              final p = double.tryParse(price.text.replaceAll(',', '.'));
              Navigator.pop(
                ctx,
                IngredientItem(
                  name: name.text.trim(),
                  quantity: q,
                  unit: unit.text.trim(),
                  price: p,
                ),
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCoverPicker() async {
    if (r == null || r!.photoPaths.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Escolher capa', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: r!.photoPaths.length,
                  itemBuilder: (c, i) {
                    final p = r!.photoPaths[i];
                    final file = File(p);
                    final exists = file.existsSync();
                    return GestureDetector(
                      onTap: () async {
                        if (i != 0) {
                          await _setAsCover(i);
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          exists
                              ? Image.file(file, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.photo, size: 40),
                                ),
                          if (i == 0)
                            Container(
                              color: Colors.black26,
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(4),
                              child: const Text(
                                'Capa atual',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
  Future<IngredientItem?> _dialogEditIngredient(
      BuildContext ctx, IngredientItem original) async {
    final name = TextEditingController(text: original.name);
    final qty = TextEditingController(text: original.quantity.toString());
    final unit = TextEditingController(text: original.unit);
    final price = TextEditingController(
        text: original.price != null ? original.price.toString() : '');

    return showDialog<IngredientItem>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Editar ingrediente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: unit,
              decoration:
                  const InputDecoration(labelText: 'Unidade (g/ml/xic/un...)'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Preço (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final q = double.tryParse(qty.text.replaceAll(',', '.')) ?? 0;
              final p = double.tryParse(price.text.replaceAll(',', '.'));
              Navigator.pop(
                ctx,
                IngredientItem(
                  masterId: original.masterId,
                  name: name.text.trim(),
                  quantity: q,
                  unit: unit.text.trim(),
                  price: p,
                  haveAtHome: original.haveAtHome,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }


