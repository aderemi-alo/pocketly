import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pocketly/core/core.dart';

/// Service for exporting user data from Pocketly in Klyro-compatible format.
class ExportDataService {
  final ApiClient _apiClient;

  ExportDataService(this._apiClient);

  /// Exports all user data and opens a share sheet to save/share the file.
  ///
  /// The export is performed server-side to ensure all data is captured
  /// with proper category mapping to Klyro format.
  ///
  /// Returns the file path if export succeeded, null otherwise.
  Future<String?> exportData() async {
    try {
      AppLogger.info('📦 Starting data export...');

      final response = await _apiClient.dio.get('/export');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final exportData = response.data['data'];

        // Write to temporary directory for sharing
        final jsonString = const JsonEncoder.withIndent(
          '  ',
        ).convert(exportData);
        final directory = await getApplicationDocumentsDirectory();
        final date = DateTime.now().toIso8601String().split('T').first;
        final fileName = 'pocketly_export_$date.json';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);

        AppLogger.info('✅ Export saved to: ${file.path}');

        // Open share sheet so user can save/share the file
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));

        return file.path;
      } else {
        AppLogger.error('❌ Export failed: ${response.data['message']}');
        return null;
      }
    } catch (e) {
      AppLogger.error('❌ Export error: $e');
      return null;
    }
  }
}

/// Provider for ExportDataService
final exportDataServiceProvider = Provider<ExportDataService>((ref) {
  return ExportDataService(locator<ApiClient>());
});
