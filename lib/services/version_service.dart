import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static const String _versionUrl =
      'https://excellencedigital.alwaysdata.net/api/app/version';

  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('❌ Erreur vérification version: $e');
    }
    return null;
  }

  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<bool> isUpdateAvailable() async {
    final data = await checkUpdate();
    if (data == null) return false;

    final serverVersion = data['android']?['version'];
    if (serverVersion == null) return false;

    final currentVersion = await getCurrentVersion();
    return _compareVersions(serverVersion, currentVersion) > 0;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final a = i < parts1.length ? parts1[i] : 0;
      final b = i < parts2.length ? parts2[i] : 0;
      if (a != b) return a - b;
    }
    return 0;
  }
}
