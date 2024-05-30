import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_rsa/rsa_authorization.dart';
import 'package:voice_rsa/voice_rsa.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';


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
  final voiceRsaPlugin = VoiceRsa();

  @override
  void initState() {
    super.initState();

    saveFileFromAssetsToCache('assets/test.${Platform.isAndroid?'pcm':'mp3'}');
  }


  Future<String> localPath() async {
    Directory cacheDir = await getTemporaryDirectory();
    String cacheFilePath = '${cacheDir.path}/test.${Platform.isAndroid?'pcm':'mp3'}';
    return cacheFilePath;
  }

  Future<void> saveFileFromAssetsToCache(String assetFileName) async {
    // Read file from assets
    ByteData data = await rootBundle.load(assetFileName);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // Get cache directory
    Directory cacheDir = await getTemporaryDirectory();
    String cacheFilePath = await localPath();
    var file = await File(cacheFilePath).writeAsBytes(bytes);
    print(file);
    print('File saved to cache: $cacheFilePath');

  }
  Future<void> requestPermission() async {
    if (await Permission.microphone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print('Microphone permission granted');
    } else {
      print('Microphone permission not granted');
    }
  }
  void onTest() async{
    if(Platform.isAndroid){

      await requestPermission();
      String cacheFilePath = await localPath();
      //path 是pcm 格式文件，路径是全路径  baiduAppId相关 百度识别后台查看
      var result = await voiceRsaPlugin.getVoiceAsr('', params: {
        'appid': 'baiduAppId',
        'key': 'baiduKey',
        'secret': 'baiduSecret',
        'infile': cacheFilePath,
      });
      if (result != null) {
        if (result['code'] == 0) {//识别正确的结果
          var message = result['message'] ?? '';
        } else {
          // 异常识别
          if (result['message'] == "No speech detected") {
            result['message'] = "未检测到语音";
          }
          throw result['message'] ?? '识别异常';
        }
      } else {
        throw '识别异常';
      }

    }else{
      //ios 校验全选
      var requestResult = await voiceRsaPlugin.requestAuthorization();
      switch (requestResult) {
        case RsaAuthorization.agree:
          break;
        case RsaAuthorization.disagree:
          // ToastUtils.show('请在设置中同意语音识别权限');
          return;
        case RsaAuthorization.unAvailable:
          // ToastUtils.show('该设备不支持语音识别');
          return;
        case RsaAuthorization.unknown:
          // ToastUtils.show('语音识别权限未知');
          return;
      }


      String cacheFilePath = await localPath();
      var result = await voiceRsaPlugin.getVoiceAsr(cacheFilePath);
      if (result != null) {
        if (result['code'] == 0) {//识别正确的结果
          var message = result['message'] ?? '';
        } else {
          // 异常识别
          if (result['message'] == "No speech detected") {
            result['message'] = "未检测到语音";
          }
          throw result['message'] ?? '识别异常';
        }
      } else {
        throw '识别异常';
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            TextButton(onPressed: onTest, child: const Text('测试点击'))
          ],
        ),
      ),
    );
  }
}
