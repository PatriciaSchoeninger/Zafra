// TODO: fila local com retry; quando online envia para Google Drive (drive.file)
class BackupQueue {
  void enqueueRecipeChanged(String recipeId) {
    // salvar um job local (ex: Hive/box separada) com timestamp
  }
  Future<void> processIfOnline() async {
    // tentar enviar; backoff exponencial
  }
}
