package com.example.voice_rsa.core.inputstream;

import android.app.Activity;
import android.content.Context;
import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;

/**
 * Created by fujiayi on 2017/6/20.
 */

public class InFileStream {

    private static Context context;

    private static final String TAG = "InFileStream";

    private static volatile String filename;

    private static volatile InputStream is;

    // 以下3个setContext

    /**
     * 必须要先调用这个方法
     * 如之后调用create16kStream，使用默认的app/src/main/assets/outfile.pcm作为输入
     * 如之后调用createMyPipedInputStream， 见 InPipedStream
     *
     * @param context
     */
    public static void setContext(Context context) {
        InFileStream.context = context;
    }

    /**
     * 使用pcm文件作为输入
     *
     * @param context
     * @param filename
     */
    public static void setContext(Context context, String filename) {
        InFileStream.context = context;
        InFileStream.filename = filename;
    }

    public static void setContext(Context context, InputStream is) {
        InFileStream.context = context;
        InFileStream.is = is;
    }

    public static Context getContext() {
        return context;
    }

    public static void reset() {
        filename = null;
        is = null;
    }


    public static InputStream createMyPipedInputStream() {
        return InPipedStream.createAndStart(context);
    }

    /**
     * 默认使用必须要先调用setContext
     * 默认从createFileStream中读取InputStream
     *
     * @return
     */
    public static InputStream create16kStream() {
        if (is == null && filename == null) {
            // 没有任何设置的话，从createFileStream中读取
            return new FileAudioInputStream(createFileStream());
        }

        if (is != null) { // 默认为null，setInputStream调用后走这个逻辑
            return new FileAudioInputStream(is);
        } else if (filename != null) { //  默认为null， setFileName调用后走这个逻辑
            try {
                return new FileAudioInputStream(filename);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
        }

        return null;
    }

    private static InputStream createFileStream() {
        try {
            // 这里抛异常表示没有调用 setContext方法
            InputStream is = context.getAssets().open("outfile.pcm");
//            InputStream is = context.getAssets().open("test.wav");
//            MyLogger.info(TAG, "create input stream ok " + is.available());

//            InputStream is = context.getAssets().open("test.pcm");
//            File cacheDir = context.getCacheDir();
//            String path = cacheDir.getAbsolutePath() + "/test.pcm";
//            saveInputStreamToFile(m4a, path);
//            InputStream is = new FileAudioInputStream(path);

            return is;
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    public static File createTempFile(Context context, String fileName) throws IOException {
        File cacheDir = context.getCacheDir();
        File tempFile = new File(cacheDir, fileName);
        if (!tempFile.createNewFile()) {
            throw new IOException("Failed to create new file " + fileName);
        }
        return tempFile;
    }


    //
    public static void saveInputStreamToFile(InputStream inputStream, String outputFilePath) throws IOException {
        OutputStream outputStream = null;
        try {
            File outputFile = new File(outputFilePath);
            outputStream = new FileOutputStream(outputFile);
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }
            if (outputStream != null) {
                outputStream.close();
            }
        }
    }

    //m4a -> pcm
    public void decode(String inputPath, String outputPath) throws IOException {
        MediaExtractor extractor = new MediaExtractor();
        extractor.setDataSource(inputPath);
        MediaFormat format = extractor.getTrackFormat(0);
        String mime = format.getString(MediaFormat.KEY_MIME);
        if (!mime.startsWith("audio/")) {
            Log.e("TAG", "not an audio file");
            return;
        }
        extractor.selectTrack(0);
        MediaCodec codec = MediaCodec.createDecoderByType(mime);
        codec.configure(format, null, null, 0);
        codec.start();

        ByteBuffer[] codecInputBuffers = codec.getInputBuffers();
        ByteBuffer[] codecOutputBuffers = codec.getOutputBuffers();

        FileOutputStream fos = new FileOutputStream(new File(outputPath));
        MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();

        boolean sawInputEOS = false;
        boolean sawOutputEOS = false;
        while (!sawOutputEOS) {
            if (!sawInputEOS) {
                int inputBufIndex = codec.dequeueInputBuffer(10000);
                if (inputBufIndex >= 0) {
                    ByteBuffer dstBuf = codecInputBuffers[inputBufIndex];
                    int sampleSize = extractor.readSampleData(dstBuf, 0);
                    if (sampleSize < 0) {
                        sawInputEOS = true;
                        codec.queueInputBuffer(inputBufIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
                    } else {
                        codec.queueInputBuffer(inputBufIndex, 0, sampleSize, extractor.getSampleTime(), 0);
                        extractor.advance();
                    }
                }
            }

            int outputBufIndex = codec.dequeueOutputBuffer(info, 10000);
            if (outputBufIndex >= 0) {
                ByteBuffer outBuf = codecOutputBuffers[outputBufIndex];
                byte[] data = new byte[info.size];
                outBuf.get(data);
                fos.write(data);
                fos.flush();
                codec.releaseOutputBuffer(outputBufIndex, false);
                if ((info.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                    sawOutputEOS = true;
                }
            }
        }
        fos.close();
        codec.stop();
        codec.release();
        extractor.release();
    }

}