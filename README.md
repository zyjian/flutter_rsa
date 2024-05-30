# flutter_asr 语音文件识别 插件

flutter 语音文件 识别  (语音转文本) （英语）
- Android 端采用百度语音识别sdk（百度收费）
- iOS 端采用 系统语音识别功能（免费）
注意：格式 
- Android 端需要 pcm
- iOS mp3 或m4a 都行，pcm 无法识别
- 重要... 需要真机测试 模拟器报错


## 配置
### Android
1. 需要添加权限
```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```
示例
```
//百度识别需要录音权限 虽然是文件识别也需要否则报错
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

```

### iOS
ios info 配置权限 Privacy - Speech Recognition Usage Description
1. 检查是否有权限

示例：
```
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
```

