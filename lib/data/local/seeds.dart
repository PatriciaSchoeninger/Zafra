import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/ingredient_master.dart';
import 'hive_boxes.dart';

const _u = Uuid();

Future<void> seedIfEmpty() async {
  final box = Hive.box<IngredientMaster>(Boxes.master);
  if (box.isNotEmpty) return;

  final seeds = <IngredientMaster>[
    IngredientMaster(
      id: _u.v4(), name: 'Farinha de trigo',
      synonyms: ['farinha', 'trigo comum'],
      defaultUnit: 'g', densityGPerMl: 0.5 * 240 / 240, // ~120g/xic
      tags: ['básico'],
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Açúcar',
      synonyms: ['açúcar refinado'],
      defaultUnit: 'g',
      tags: ['básico'],
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Leite',
      defaultUnit: 'ml', densityGPerMl: 1.03, tags: ['líquido'],
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Manteiga',
      defaultUnit: 'g', tags: ['gordura'],
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Ovos', defaultUnit: 'un', tags: ['básico'],
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Fermento químico',
      synonyms: ['fermento de bolo', 'royal'],
      defaultUnit: 'g',
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Sal', defaultUnit: 'g',
    ),
    IngredientMaster(
      id: _u.v4(), name: 'Óleo', defaultUnit: 'ml', densityGPerMl: 0.92,
    ),
  ];

  for (final m in seeds) {
    await box.add(m);
  }
}
