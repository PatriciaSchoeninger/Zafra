import 'package:flutter/material.dart';

class RecipeEditPage extends StatelessWidget {
  const RecipeEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Receita')),
      body: const Center(child: Text('Form de edição vem aqui')),
    );
  }
}
