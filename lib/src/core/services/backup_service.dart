import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../constants/db_constants.dart';
import '../../features/decisions/data/repositories/decision_repository.dart';
import '../../features/decisions/data/repositories/journal_repository.dart';

/// BackupService handles database backups and exports for Decision Vault.
class BackupService {
  BackupService._internal();

  static final BackupService instance = BackupService._internal();

  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory(join(directory.path, 'decision_vault_backups'));
    if (!await backupDirectory.exists()) {
      await backupDirectory.create(recursive: true);
    }
    return backupDirectory;
  }

  Future<Database> _openDatabase() async {
    final service = DatabaseService.instance;
    await service.init();
    return service.database;
  }

  Future<String> createBackup() async {
    final databasePath = await getDatabasesPath();
    final source = File(join(databasePath, AppDatabaseConstants.databaseName));
    if (!await source.exists()) {
      throw StateError('Database file was not found for backup.');
    }

    final backupDirectory = await _getBackupDirectory();
    final backupFileName = 'backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db';
    final backupFile = File(join(backupDirectory.path, backupFileName));
    await source.copy(backupFile.path);
    return backupFile.path;
  }

  Future<String> restoreLatestBackup() async {
    final backupDirectory = await _getBackupDirectory();
    if (!await backupDirectory.exists()) {
      throw StateError('No backup directory found.');
    }

    final backups = backupDirectory
        .listSync()
        .whereType<File>()
        .where((file) => extension(file.path).toLowerCase() == '.db')
        .toList();

    if (backups.isEmpty) {
      throw StateError('No backup files are available to restore.');
    }

    backups.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final latestBackup = backups.first;

    await DatabaseService.instance.close();
    final databasePath = await getDatabasesPath();
    final destination = File(join(databasePath, AppDatabaseConstants.databaseName));
    await latestBackup.copy(destination.path);

    await DatabaseService.instance.init();
    return latestBackup.path;
  }

  Future<String> exportToJson() async {
    final database = await _openDatabase();
    final decisionRepository = DecisionRepository(database);
    final journalRepository = JournalRepository(database);

    final decisions = await decisionRepository.getAll(includeArchived: true);
    final journals = await journalRepository.getAll(limit: 1000);

    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'decisions': decisions.map((d) => d.toMap()).toList(),
      'journal': journals.map((j) => j.toMap()).toList(),
    };

    final backupDirectory = await _getBackupDirectory();
    final fileName = 'decision_vault_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(join(backupDirectory.path, fileName));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(exportData));
    return file.path;
  }

  Future<String> exportToPdf() async {
    final pdfDocument = pw.Document();
    final database = await _openDatabase();
    final decisionRepository = DecisionRepository(database);
    final decisions = await decisionRepository.getAll(includeArchived: true);

    pdfDocument.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Decision Vault export'),
          pw.Paragraph(text: 'Export created on ${DateTime.now().toIso8601String()}.'),
          ...decisions.map(
            (decision) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(decision.title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                if (decision.description != null && decision.description!.isNotEmpty)
                  pw.Text(decision.description!),
                pw.Text('Priority: ${decision.priority}  Score: ${decision.weightedScore}'),
                if (decision.category != null) pw.Text('Category: ${decision.category}'),
                if (decision.pros.isNotEmpty) pw.Bullet(text: 'Pros: ${decision.pros.join(', ')}'),
                if (decision.cons.isNotEmpty) pw.Bullet(text: 'Cons: ${decision.cons.join(', ')}'),
                if (decision.tags.isNotEmpty) pw.Text('Tags: ${decision.tags.join(', ')}'),
                pw.SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );

    final backupDirectory = await _getBackupDirectory();
    final fileName = 'decision_vault_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf';
    final file = File(join(backupDirectory.path, fileName));
    await file.writeAsBytes(await pdfDocument.save());
    return file.path;
  }
}
