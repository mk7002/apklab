import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../device_selector.dart';
import '../styles/styles.dart';

class PushApkView extends StatefulWidget {
  final String adbPath;

  const PushApkView({super.key, required this.adbPath});

  @override
  State<PushApkView> createState() => _PushApkViewState();
}

class _PushApkViewState extends State<PushApkView> {
  String? _selectedDevice;
  String? _folderPath;
  String _output = '';
  bool _isRunning = false;

  Future<void> _pickFolder() async {
    final String? path = await getDirectoryPath(confirmButtonText: 'Select');
    if (path != null) {
      setState(() {
        _folderPath = path;
      });
    }
  }

  Future<void> _pushAllTogether() async {
    if (_selectedDevice == null || _folderPath == null) {
      setState(() {
        _output = 'Please select device and folder.';
      });
      return;
    }

    final dir = Directory(_folderPath!);
    if (!await dir.exists()) {
      setState(() {
        _output = 'Selected folder does not exist.';
      });
      return;
    }

    final apks = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.apk'))
        .toList();

    if (apks.isEmpty) {
      setState(() {
        _output = 'No APK files found in the selected folder.';
      });
      return;
    }

    setState(() {
      _isRunning = true;
      _output = 'Installing all APKs (${apks.length}) together…\n';
    });

    final args = [
      '-s',
      _selectedDevice!,
      'install-multiple',
      ...apks.map((f) => f.path),
    ];

    final result = await Process.run(widget.adbPath, args);

    setState(() {
      _isRunning = false;
      _output += (result.stdout ?? '') + (result.stderr ?? '') + '\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeviceSelector(
            adbPath: widget.adbPath,
            initialDevice: _selectedDevice,
            onDeviceSelected: (device) {
              setState(() {
                _selectedDevice = device;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(_folderPath ?? 'No folder selected',
                    style: baseTextStyle),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickFolder,
                child: Text('Select Folder', style: baseTextStyle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isRunning ? null : _pushAllTogether,
            child: Text('Push All APKs', style: baseTextStyle),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _output,
                style: baseTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
