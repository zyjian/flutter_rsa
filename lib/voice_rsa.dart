
import 'package:voice_rsa/rsa_authorization.dart';

import 'voice_rsa_platform_interface.dart';

class VoiceRsa {

  Future<String?> getPlatformVersion() {
    return VoiceRsaPlatform.instance.getPlatformVersion();
  }

  Future<Map<String, dynamic>?> getVoiceAsr(String path) {
    return VoiceRsaPlatform.instance.getVoiceAsr(path);
  }
  Future<bool?> getSpeechRecognitionAuthorized() {
    return VoiceRsaPlatform.instance.getSpeechRecognitionAuthorized();
  }

  Future<RsaAuthorization> requestAuthorization() async {
    final result = await VoiceRsaPlatform.instance.requestAuthorization();
    if(result!=null){
      switch(result){
        case 0:
          return RsaAuthorization.agree;
        case 1:
          return RsaAuthorization.disagree;
        case 2:
          return RsaAuthorization.unAvailable;
        case 3:
          return RsaAuthorization.unknown;
      }
    }
    return RsaAuthorization.unknown;
  }

}
