import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'voice_rsa_platform_interface.dart';

/// An implementation of [VoiceRsaPlatform] that uses method channels.
class MethodChannelVoiceRsa extends VoiceRsaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('voice_rsa');

  @override
  Future<Map<String, dynamic>?> getVoiceAsr(String path,{Map<String,dynamic>? params}) async {
    params=params??{};
    return methodChannel.invokeMapMethod<String,dynamic>('getVoiceAsr', {'path': path,...params});
  }

  @override
  Future<bool?> getSpeechRecognitionAuthorized() async {
    return methodChannel.invokeMethod<bool>('getSpeechRecognitionAuthorized');
  }

  @override
  Future<int?> requestAuthorization() async {
    return methodChannel.invokeMethod<int>('requestAuthorization');
  }

  Future<String?> getPlatformVersion() async{
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

}
