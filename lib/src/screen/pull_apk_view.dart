import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../device_selector.dart';
import '../styles/styles.dart';

class PullApkView extends StatefulWidget {
  final String adbPath;

  const PullApkView({super.key, required this.adbPath});

  @override
  State<PullApkView> createState() => _PullApkViewState();
}

class _PullApkViewState extends State<PullApkView> {
  String? _selectedDevice;
  String? _folderPath;
  final _packageController = TextEditingController();
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

  Future<void> _pullApk() async {
    if (_selectedDevice == null ||
        _folderPath == null ||
        _packageController.text.isEmpty) {
      setState(() {
        _output = 'Please select device, folder and enter package name.';
      });
      return;
    }

    setState(() {
      _isRunning = true;
      _output = 'Pulling APK…';
    });

    final destPath =
        Directory('$_folderPath/${_packageController.text.trim()}');

// Create the directory if it does not exist yet
    if (!await destPath.exists()) {
      await destPath.create(recursive: true);
    }

    final cmd = '''
"${widget.adbPath}" -s $_selectedDevice shell pm path "${_packageController.text.trim()}" | sed 's/package://g' | while read -r apk; do "${widget.adbPath}" -s $_selectedDevice pull "\$apk" "${destPath.path}"; done
''';

    final result = await Process.run('/bin/bash', ['-c', cmd]);

    setState(() {
      _isRunning = false;
      _output = (result.stdout ?? '') + (result.stderr ?? '');
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
          TextField(
            controller: _packageController,
            decoration: InputDecoration(
              labelStyle: baseTextStyle,
              labelText: 'Package Name',
              hintText: 'e.g. com.instagram.android',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _folderPath ?? 'No folder selected',
                  style: baseTextStyle,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickFolder,
                child: Text(
                  'Select Folder',
                  style: baseTextStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isRunning ? null : _pullApk,
            child: Text(
              'Pull APK',
              style: baseTextStyle,
            ),
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
