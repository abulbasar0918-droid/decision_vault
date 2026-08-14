import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  runApp(const DecisionVaultApp());
}
