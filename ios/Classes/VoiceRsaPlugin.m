#import "VoiceRsaPlugin.h"
#import <Speech/Speech.h>

@implementation VoiceRsaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"voice_rsa"
            binaryMessenger:[registrar messenger]];
  VoiceRsaPlugin* instance = [[VoiceRsaPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"%@ %@",call.arguments,call.method);
  if ([@"getVoiceAsr" isEqualToString:call.method]) {
      NSString *path = call.arguments[@"path"];
      NSURL *localURL = [NSURL fileURLWithPath:path];
      [self recognizeSpeechFromURL:localURL completion:^(NSString *transcription, NSError *error) {
          if (error) {
              NSLog(@"There was an error: %@", error);
              result(@{
                  @"code": @1,
                  @"message":error.localizedDescription
              });
          } else {
              NSLog(@"Transcription: %@", transcription);
              result(@{
                  @"code": @0,
                  @"message": transcription
              });
              
          }
      }];
  }else if([@"getSpeechRecognitionAuthorized" isEqualToString:call.method]){
      BOOL res = [self isSpeechRecognitionAuthorized];
      result(@(res));
  }else if([@"requestAuthorization" isEqualToString:call.method]){
      [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
          switch (status) {
              case SFSpeechRecognizerAuthorizationStatusAuthorized:
                  NSLog(@"授权语音识别");
                  result(@(0));
                  break;
              case SFSpeechRecognizerAuthorizationStatusDenied:
                  NSLog(@"用户拒绝授权语音识别");
                  result(@(1));
                  break;
              case SFSpeechRecognizerAuthorizationStatusRestricted:
                  NSLog(@"设备不支持语音识别");
                  result(@(2));
                  break;
              case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                  NSLog(@"未决定是否授权语音识别");
                  result(@(3));
                  break;
          }
      }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}
- (BOOL)isSpeechRecognitionAuthorized {
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    return status == SFSpeechRecognizerAuthorizationStatusAuthorized;
}

- (void)recognizeSpeechFromURL:(NSURL *)url completion:(void (^)(NSString *, NSError *))completion {
    

    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            if (result.isFinal) {
                // This is the final result
                completion(result.bestTranscription.formattedString, nil);
            }
        }
    }];
}


@end
