# flutter_rsa 语音文件识别 插件

flutter 语音文件 识别  (语音转文本) （英语）
- Android 端采用百度语音识别sdk（百度收费）
- iOS 端采用 系统语音识别功能（免费）

## 配置
### Android
1. 需要添加权限
```
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```
示例
```
//百度识别需要录音权限 虽然是文件识别也需要否则报错
if (await Permission.microphone.request().isGranted) {
  LogUtil.d('Microphone permission granted');
} else {
  ToastUtils.show('请在系统设置开启录音权限');
  return;
}

//path 是pcm 格式文件，路径是全路径  baiduAppId相关 百度识别后台查看
 var result = await voiceRsaPlugin.getVoiceAsr('', params: {
    'appid': baiduAppId,
    'key': baiduKey,
    'secret': baiduSecret,
    'infile': path,
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
  //ios 校验全选
  final voiceRsaPlugin = VoiceRsa();
  var result = await voiceRsaPlugin.requestAuthorization();
  switch (result) {
    case RsaAuthorization.agree:
      break;
    case RsaAuthorization.disagree:
      ToastUtils.show('请在设置中同意语音识别权限');
      return;
    case RsaAuthorization.unAvailable:
      ToastUtils.show('该设备不支持语音识别');
      return;
    case RsaAuthorization.unknown:
      ToastUtils.show('语音识别权限未知');
      return;
  }
  
  //test.m4a 这个是音频文件报错在临时目录下的语音文件，插件去临时目录找的
  /*
  Future<String> getTempDirectory() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return tempPath;
    }
  */
  var result = await voiceRsaPlugin.getVoiceAsr('test.m4a'});
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

