import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repo/catalog_repo.dart';
import '../data/repo/recipe_repo.dart';

/// ✅ Provider do catálogo de ingredientes (anti-duplicados, sinônimos etc.)
final catalogRepoProvider = Provider<CatalogRepo>(
  (ref) => CatalogRepo(),
);

/// ✅ Provider principal para gerenciar receitas (CRUD, persistência Hive)
final recipeRepoProvider = Provider<RecipeRepo>(
  (ref) => RecipeRepo(),
);

/// 📌 Espaço reservado para futuros providers (exemplo):
/// - Backup automático no Google Drive
/// - Configurações do app
/// - Preferências do usuário
///
/// Basta criar o repo correspondente em `lib/data/repo/`
/// e adicionar um provider aqui.
/// Exemplo:
/// final settingsRepoProvider = Provider<SettingsRepo>((ref) => SettingsRepo());
