package com.example.voice_rsa;

import android.content.Context;
import android.os.Handler;

import androidx.annotation.NonNull;

import com.baidu.speech.EventListener;
import com.baidu.speech.EventManager;
import com.baidu.speech.EventManagerFactory;
import com.baidu.speech.asr.SpeechConstant;
import com.example.voice_rsa.core.recog.MyRecognizer;
import com.example.voice_rsa.core.recog.RecogResult;
import com.example.voice_rsa.core.recog.listener.IRecogListener;
import com.example.voice_rsa.core.recog.listener.MessageStatusRecogListener;
import com.example.voice_rsa.core.recog.listener.RecogEventAdapter;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** VoiceRsaPlugin */
public class VoiceRsaPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private EventManager asr;

  private Result result;
  private String recognitionResult = "";



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "voice_rsa");
    channel.setMethodCallHandler(this);


    Context context = flutterPluginBinding.getApplicationContext();
    asr = EventManagerFactory.create(context, "asr");

//    IRecogListener listener = new MessageStatusRecogListener(new Handler());
//    asr.registerListener(new RecogEventAdapter(listener));
    asr.registerListener(new EventListener() {
      @Override
      public void onEvent(String name, String params, byte[] data, int offset, int length) {
        String currentJson = params;
        String logMessage = "name:" + name + "; params:" + params;
        System.out.println(logMessage);
//        result.success(currentJson);
        if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_FINISH)) {
          // 识别结束
          RecogResult recogResult = RecogResult.parseJson(params);
          System.out.println(recogResult);
          if (recogResult.hasError()) {
            int errorCode = recogResult.getError();
            int subErrorCode = recogResult.getSubError();
//            listener.onAsrFinishError(errorCode, subErrorCode, recogResult.getDesc(), recogResult);
            Map<String, Object> res = new HashMap<>();
            res.put("code",1);
            res.put("message",recogResult.getDesc());
            result.success(res);
          } else {
            Map<String, Object> res = new HashMap<>();
            res.put("code",0);
            res.put("message",recognitionResult);
            result.success(res);
          }
        } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_PARTIAL)) {
          try {
            JSONObject jsonObject = new JSONObject(currentJson);
            String bestResult = jsonObject.getString("best_result");
            recognitionResult = bestResult;
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
      }
    });


    // 基于DEMO集成第1.1, 1.2, 1.3 步骤 初始化EventManager类并注册自定义输出事件
    // DEMO集成步骤 1.2 新建一个回调类，识别引擎会回调这个类告知重要状态和识别结果
//    IRecogListener listener = new MessageStatusRecogListener(handler);
//    // DEMO集成步骤 1.1 1.3 初始化：new一个IRecogListener示例 & new 一个 MyRecognizer 示例,并注册输出事件
//    myRecognizer = new MyRecognizer(context, listener);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("getVoiceAsr")){
      // SDK集成步骤 拼接识别参数
      Map<String, Object> params = new HashMap<>();
      Map args = call.arguments();
      params.put(SpeechConstant.APP_ID, args.get(SpeechConstant.APP_ID));
      params.put(SpeechConstant.APP_KEY, args.get(SpeechConstant.APP_KEY));
      params.put(SpeechConstant.SECRET, args.get(SpeechConstant.SECRET));
      params.put(SpeechConstant.IN_FILE, args.get(SpeechConstant.IN_FILE));
      params.put(SpeechConstant.PID, 1737);
      params.put(SpeechConstant.ACCEPT_AUDIO_VOLUME, false);
      String json = new JSONObject(params).toString();
      asr.send(SpeechConstant.ASR_START, json, null, 0, 0);
      this.result = result;
    }else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
