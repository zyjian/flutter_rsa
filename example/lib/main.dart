import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:voice_rsa/voice_rsa.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

const audioPath = 'test.mp3';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _voiceRsaPlugin = VoiceRsa();

  @override
  void initState() {
    super.initState();
    saveFileFromAssetsToCache('assets/$audioPath', audioPath).then((value) =>initPlatformState() );

  }

  Future<void> saveFileFromAssetsToCache(String assetFileName, String cacheFileName) async {
    // Read file from assets
    ByteData data = await rootBundle.load(assetFileName);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Get cache directory
    Directory cacheDir = await getTemporaryDirectory();
    String cacheFilePath = '${cacheDir.path}/$cacheFileName';

    // Write file to cache directory
    await File(cacheFilePath).writeAsBytes(bytes);
    print('File saved to cache: $cacheFilePath');
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      var isAuthorized = await _voiceRsaPlugin.getSpeechRecognitionAuthorized();
      print(isAuthorized);
      if(isAuthorized==false){
        var result = await _voiceRsaPlugin.requestAuthorization();
        print(result);
      }

      var result =
          await _voiceRsaPlugin.getVoiceAsr(audioPath);
      if(result != null){
        platformVersion = result['message']??'';
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
