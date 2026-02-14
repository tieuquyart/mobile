package com.mk.autosecure.libs.utils;

import android.text.TextUtils;
import android.util.Log;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.rest.request.ReportFeedbackBody;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;

/**
 * Created by DoanVT on 2017/10/23.
 * Email: doanvt-hn@mk.com.vn
 */


public class LogUtil {
    private static final String TAG = LogUtil.class.getSimpleName();
    private static final String LOG_FILE_NAME = "latest.log";
    private static final String processId = Integer.toString(android.os.Process
            .myPid());

    public static StringBuilder getLog() {

        StringBuilder builder = new StringBuilder();

        try {
            String[] command = new String[]{"logcat", "-d", "-v", "threadtime"};

            Process process = Runtime.getRuntime().exec(command);

            BufferedReader bufferedReader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = bufferedReader.readLine()) != null) {
                if (line.contains(processId)) {
                    builder.append(line);
                    builder.append("\n");
                }
            }
            //saveCrashInfo2File(builder);
        } catch (IOException ex) {
            Logger.e(TAG, "get Log failed", ex);
        }
        return builder;
    }

    public static StringBuilder getLatestLog() {
        StringBuilder builder = new StringBuilder();
        try {
            String fileName = LOG_FILE_NAME;
            String path = FileUtils.getLogPath(HornApplication.getContext());
            File log = new File(path + fileName);
            if (log.exists()) {
                BufferedReader bufferedReader = new BufferedReader(new FileReader(path + fileName));
                String line;
                while ((line = bufferedReader.readLine()) != null) {
                    builder.append(line);
                    builder.append("\n");
                }
            }
        } catch (Exception e) {
            Logger.t(TAG).d("%s", "an error occurred while writing file...", e);
        }
        return builder;
    }

    public static StringBuffer getDiskLog() {
        StringBuffer buffer = new StringBuffer();
        EvictingQueue<String> logQueue = EvictingQueue.create(300);

        String path = FileUtils.getLogPath(HornApplication.getContext());
        File rootFile = new File(path);
        File[] listFiles = rootFile.listFiles((dir, name) -> name.endsWith(".csv"));

        for (File listFile : listFiles) {
            try {
                if (listFile.exists()) {
                    BufferedReader bufferedReader = new BufferedReader(new FileReader(listFile));
                    String line;
                    while ((line = bufferedReader.readLine()) != null) {
                        logQueue.add(line + "\n");
                        Log.d("LOG file line = ", line);
                    }
                }
            } catch (Exception e) {
                Logger.t(TAG).d("an error occurred while reading file... : " + e.getMessage());
            }
        }
        for (String line : logQueue) {
            Logger.t(TAG).d("LOG queue = ", line);
            buffer.append(line);
        }
        return buffer;
    }

    public static List<File> getLogFiles() {
        List<File> fileList = new ArrayList<>();

        String path = FileUtils.getLogPath(HornApplication.getContext());
        File rootFile = new File(path);
        File[] listFiles = rootFile.listFiles((dir, name) -> name.endsWith(".csv"));

        for (File log : listFiles) {
            if (log.exists()) {
                fileList.add(log);
            }
        }
        return fileList;
    }

    public static MultipartBody createMultipartBody(ReportFeedbackBody body, File cameraLogFile) {
        MultipartBody.Builder builder = new MultipartBody.Builder();
        if (!TextUtils.isEmpty(body.detail)) {
            builder.addFormDataPart("detail", body.detail);
        }
        if (!TextUtils.isEmpty(body.agentHW)) {
            builder.addFormDataPart("agentHW", body.agentHW);
        }
        if (!TextUtils.isEmpty(body.agentOS)) {
            builder.addFormDataPart("agentOS", body.agentOS);
        }

        if (!TextUtils.isEmpty(body.appVersion)) {
            builder.addFormDataPart("appVersion", body.appVersion);
        }

        if (!TextUtils.isEmpty(body.cameraHW)) {
            builder.addFormDataPart("cameraHW", body.cameraHW);
        }
        if (!TextUtils.isEmpty(body.cameraFW)) {
            builder.addFormDataPart("cameraFW", body.cameraFW);
        }
        if (!TextUtils.isEmpty(body.cameraSN)) {
            builder.addFormDataPart("cameraSN", body.cameraSN);
        }
        if (!TextUtils.isEmpty(body.mountHW)) {
            builder.addFormDataPart("mountHW", body.mountHW);
        }
        if (!TextUtils.isEmpty(body.mountFW)) {
            builder.addFormDataPart("mountFW", body.mountFW);
        }

        if (!TextUtils.isEmpty(body.log)) {
//            builder.addFormDataPart("log", body.log);
        }

        if (!TextUtils.isEmpty(body.email)) {
            builder.addFormDataPart("email", body.email);
        }

        if (cameraLogFile != null && cameraLogFile.exists()) {
            RequestBody requestBody = RequestBody.create(MediaType.parse("application/octet-stream"), cameraLogFile);
            builder.addFormDataPart("file", "camera_log.zip", requestBody);
        }

        if (Constants.isFleet()) {
            builder.setType(MultipartBody.FORM);
        }

        return builder.build();
    }
}
