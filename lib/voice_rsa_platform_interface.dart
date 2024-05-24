import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'voice_rsa_method_channel.dart';

abstract class VoiceRsaPlatform extends PlatformInterface {
  /// Constructs a VoiceRsaPlatform.
  VoiceRsaPlatform() : super(token: _token);

  static final Object _token = Object();

  static VoiceRsaPlatform _instance = MethodChannelVoiceRsa();

  /// The default instance of [VoiceRsaPlatform] to use.
  ///
  /// Defaults to [MethodChannelVoiceRsa].
  static VoiceRsaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VoiceRsaPlatform] when
  /// they register themselves.
  static set instance(VoiceRsaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> getVoiceAsr(String path) {
    throw UnimplementedError('getVoiceAsr() has not been implemented.');
  }

  Future<bool?> getSpeechRecognitionAuthorized() {
    throw UnimplementedError('getSpeechRecognitionAuthorized() has not been implemented.');
  }

  Future<int?> requestAuthorization() {
    throw UnimplementedError('requestAuthorization() has not been implemented.');
  }
}
