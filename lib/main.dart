import 'package:flutter/material.dart';
import 'core/app.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/seeds.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Boxes.init();
  await seedIfEmpty();
  runApp(const LivroReceitasApp());
}
