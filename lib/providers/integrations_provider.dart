import 'package:flutter/material.dart';
import '../services/gmail_service.dart';
import '../services/sheets_service.dart';

class IntegrationsProvider extends ChangeNotifier {
  final GmailService _gmailService;
  final SheetsService _sheetsService;

  IntegrationsProvider({
    required GmailService gmailService,
    required SheetsService sheetsService,
  })  : _gmailService = gmailService,
        _sheetsService = sheetsService;

  IntegrationStatus get gmailStatus => _gmailService.status;
  IntegrationStatus get sheetsStatus => _sheetsService.status;
  String get gmailAccount =>
      _gmailService.connectedAccount ?? 'partnerships@sumquiz.com';
  String get sheetName =>
      _sheetsService.activeSpreadsheetName ?? 'SumQuiz Creator Master Roster 2023';

  Future<void> toggleGmail() async {
    if (gmailStatus == IntegrationStatus.connected) {
      await _gmailService.disconnect();
    } else {
      await _gmailService.connect();
    }
    notifyListeners();
  }

  Future<void> toggleSheets() async {
    if (sheetsStatus == IntegrationStatus.connected) {
      // Disconnect
    } else {
      await _sheetsService.connectSpreadsheet('master_roster');
    }
    notifyListeners();
  }

  Future<void> syncSheetsNow() async {
    notifyListeners();
    await _sheetsService.syncExportMetrics();
    notifyListeners();
  }
}