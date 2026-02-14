package com.mk.autosecure.libs.utils;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.FileUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by doanvt on 2019/1/11.
 * Email：doanvt-hn@mk.com.vn
 */

public class IjkPlayerLogUtil {

    private final static String TAG = IjkPlayerLogUtil.class.getSimpleName();

    private final static int MAX_LENGTH = 500 * 1024;

    public static void logIJKMEDIA() {
        try {
            Logger.t(TAG).d("logIJKMEDIA start");
            java.lang.Process p = Runtime.getRuntime().exec("logcat IJKMEDIA:V *:S");
            final InputStream is = p.getInputStream();
//            Logger.t(TAG).d("input: " + is.toString());

            Observable.create((ObservableOnSubscribe<Void>) emitter -> {
                FileOutputStream os = null;
                try {
                    File file = new File(FileUtils.getLogPath(HornApplication.getContext()), "logs_2.csv");
                    if (file.exists() && file.length() > MAX_LENGTH) {
                        Logger.t(TAG).d("logFile delete: " + file.delete());
                    }
                    os = new FileOutputStream(file, true);

                    int len;
                    byte[] buf = new byte[1024];
                    while ((len = is.read(buf)) != -1) {
                        os.write(buf, 0, len);
                        os.flush();
                    }
                } catch (Exception e) {
                    Logger.t(TAG).e("read logcat process failed. message: " + e.getMessage());
                } finally {
                    if (os != null) {
                        try {
                            os.close();
                        } catch (IOException e) {
                            Logger.t(TAG).e("close error: " + e.getMessage());
                        }
                    }
                }
            })
                    .subscribeOn(Schedulers.io())
                    .subscribe();
        } catch (Exception e) {
            Logger.t(TAG).e("open logcat process failed. message: " + e.getMessage());
        }
    }
}
