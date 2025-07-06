import 'dart:async';
import 'dart:io';

import 'package:apklab/src/styles/colors.dart';
import 'package:apklab/src/styles/styles.dart';
import 'package:flutter/material.dart';

import 'src/screen/pull_apk_view.dart';
import 'src/screen/push_apk_view.dart';

void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print("Error $error");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APK Lab',
      theme: ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: COLOR_ANDROID_GREEN, // button background color
            foregroundColor: Colors.white, // button text (and icon) color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: COLOR_ANDROID_GREEN, // text button text color
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: COLOR_ANDROID_GREEN, // outlined button text color
            side: BorderSide(color: COLOR_ANDROID_GREEN), // outlined border
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _adbPath;
  bool _adbLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _detectAdb();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _detectAdb() async {
    const knownPaths = [
      '/usr/local/bin/adb',
      '/opt/homebrew/bin/adb',
      '/usr/bin/adb',
    ];

    String? adb;
    for (final path in knownPaths) {
      if (await File(path).exists()) {
        adb = path;
        break;
      }
    }

    setState(() {
      _adbPath = adb;
      _adbLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'APK Lab',
          textAlign: TextAlign.center,
          style: baseTextStyle.copyWith(
              fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: COLOR_ANDROID_GREEN,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: COLOR_ANDROID_GREEN,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.green,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Text(
                    "Pull APK",
                    style: baseTextStyle,
                  ),
                ),
                Tab(
                  child: Text(
                    "Push APK",
                    style: baseTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _adbLoading
          ? const Center(child: CircularProgressIndicator())
          : _adbPath == null
              ? const Center(child: Text('❌ adb not found. Install adb.'))
              : Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: [
                        PullApkView(adbPath: _adbPath!),
                        PushApkView(adbPath: _adbPath!),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Text(
                        'Made with ❤️ by TheKeniLab',
                        style: baseTextStyle.copyWith(
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
