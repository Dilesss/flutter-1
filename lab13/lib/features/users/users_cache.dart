import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'user.dart';

/// The last good list, kept in a file in Documents (not Temporary:
/// the OS may delete Temporary whenever it wants).
class UsersCache {
  const UsersCache();

  static const fileName = 'users.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<void> save(List<User> users) async {
    if (kIsWeb) return; // the browser has no Documents folder
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
    } on FileSystemException catch (e) {
      log('could not save cache: $e', name: 'cache');
    }
  }

  /// null = there is no saved list (first run, or after a reinstall).
  Future<List<User>?> load() async {
    if (kIsWeb) return null;
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final data = jsonDecode(await file.readAsString()) as List;
      return [for (final e in data) User.fromJson(e as Map<String, dynamic>)];
    } on FileSystemException catch (e) {
      log('could not read cache: $e', name: 'cache');
      return null;
    } on FormatException catch (e) {
      log('cache is not JSON: $e', name: 'cache');
      return null;
    } on TypeError catch (e) {
      log('cache has a wrong shape: $e', name: 'cache');
      return null;
    }
  }
}
