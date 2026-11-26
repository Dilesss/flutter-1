import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

/// A profile photo from the gallery or the camera — with every answer
/// the OS can give handled. Without a photo the app keeps working.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// "Take photo": ask at the moment of the tap — never in initState.
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _snack(
          'The camera is needed to take a profile photo. '
          'You can still choose one from the gallery.',
        );
      case PermissionStatus.restricted:
        _snack('The camera is restricted on this device.');
      case PermissionStatus.permanentlyDenied:
        await _showOpenSettingsDialog();
    }
  }

  /// The OS will never ask again — only the user can turn it back on.
  Future<void> _showOpenSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.no_photography),
        title: const Text('Camera is off for this app'),
        content: const Text(
          'You chose "Don\'t allow", so the phone will not ask again. '
          'To take a photo, open Settings → Permissions → Camera → Allow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) {
      await openAppSettings();
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return; // Cancel — not an error

      // Copy into Documents: the picker's file may live in a temp folder.
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/avatar.jpg';
      await File(picked.path).copy(path);
      await FileImage(File(path)).evict(); // same path, new picture
      if (!mounted) return;
      await context.read<SettingsModel>().setAvatarPath(path);
    } on PlatformException catch (e) {
      if (mounted) _snack('Could not get a photo: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final hasPhoto = path != null && !kIsWeb;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: hasPhoto ? FileImage(File(path)) : null,
                child: hasPhoto
                    ? null
                    : const Text('D', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              if (_busy) const CircularProgressIndicator(),
              if (kIsWeb)
                const Text('Photos work on a phone or an emulator.')
              else ...[
                FilledButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose photo'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _takePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Take photo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
