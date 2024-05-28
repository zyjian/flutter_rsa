package com.example.voice_rsa.core.util;

import com.baidu.speech.asr.SpeechConstant;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 为方便说明 apiKey 简称ak，secretKey简称 sk
 * ak sk为敏感信息，泄露后别人可使用ak sk 消耗你的调用次数，造成财产损失，请妥善保存
 * 建议你将ak sk保存在自己服务端，通过接口请求获得。
 * 如果暂时没有后端服务接口，建议将ak sk加密存储减少暴露风险。
 **/
public class AuthUtil {
    public static   String   getAk(){
        //todo 填入apiKey
        return "H4DeZw1Pim1xzfAhMOXwf5ex7ZcGjO96";
    }
    public static   String   getSk(){
        //todo 填入secretKey
        return  "jbeEKNLGN8C4NllfKGCYpzKHCVVGo2GY";
    }
    public static   String getAppId(){
        //todo 填入appId
        return  "8747719";
    }

    public static Map<String, Object> getParam(){
        Map<String, Object> params = new LinkedHashMap<String, Object>();
        params.put(SpeechConstant.APP_ID, getAppId()); // 添加appId
        params.put(SpeechConstant.APP_KEY, getAk()); // 添加apiKey
        params.put(SpeechConstant.SECRET, getSk()); // 添加secretKey
        return  params;
    }
}
