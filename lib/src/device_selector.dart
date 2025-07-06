import 'dart:io';

import 'package:apklab/src/styles/styles.dart';
import 'package:flutter/material.dart';

class DeviceSelector extends StatefulWidget {
  final String adbPath;
  final String? initialDevice;
  final ValueChanged<String?> onDeviceSelected;

  const DeviceSelector({
    super.key,
    required this.adbPath,
    this.initialDevice,
    required this.onDeviceSelected,
  });

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  List<String> _devices = [];
  String? _selectedDevice;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    setState(() {
      _loading = true;
    });

    final result = await Process.run(widget.adbPath, ['devices']);

    final lines = (result.stdout as String).split('\n');
    final devices = <String>[];

    for (final line in lines) {
      if (line.endsWith('device') && !line.startsWith('List')) {
        final parts = line.split('\t');
        if (parts.isNotEmpty) {
          devices.add(parts.first.trim());
        }
      }
    }

    setState(() {
      _devices = devices;
      if (_devices.isNotEmpty) {
        _selectedDevice = widget.initialDevice ?? _devices.first;
      } else {
        _selectedDevice = null;
      }
      _loading = false;
    });

    widget.onDeviceSelected(_selectedDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select device:',
              style: baseTextStyle,
            ),
            const Spacer(),
            IconButton(
              onPressed: _loading ? null : _refreshDevices,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh devices',
            ),
          ],
        ),
        const SizedBox(height: 8),
        _loading
            ? const CircularProgressIndicator()
            : _devices.isNotEmpty
                ? DropdownButton<String>(
                    value: _selectedDevice,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedDevice = value;
                      });
                      widget.onDeviceSelected(_selectedDevice);
                    },
                    items: _devices
                        .map(
                          (device) => DropdownMenuItem(
                            value: device,
                            child: Text(device),
                          ),
                        )
                        .toList(),
                  )
                : Text('No devices detected', style: baseTextStyle),
      ],
    );
  }
}
