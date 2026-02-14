package com.mkgroup.camera.utils;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.orhanobut.logger.LogStrategy;
import com.orhanobut.logger.Logger;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Created by DoanVT on 2017/10/20.
 * Email: doanvt-hn@mk.com.vn
 */

public class CustomDiskLogStrategy implements LogStrategy {

    private final static String TAG = CustomDiskLogStrategy.class.getSimpleName();

    private final Handler handler;

    public CustomDiskLogStrategy(Handler handler) {
        this.handler = handler;
    }

    @Override
    public void log(int level, String tag, String message) {
        // do nothing on the calling thread, simply pass the tag/msg to the background thread
        handler.sendMessage(handler.obtainMessage(level, message));
    }

    static class WriteHandler extends Handler {

        private final String folder;
        private final int maxFileSize;
        private final int logFileCount = 2;

        WriteHandler(Looper looper, String folder, int maxFileSize) {
            super(looper);
            this.folder = folder;
            this.maxFileSize = maxFileSize;
        }

        @SuppressWarnings("checkstyle:emptyblock")
        @Override
        public void handleMessage(Message msg) {
            String content = (String) msg.obj;

            FileWriter fileWriter = null;
            File logFile = getLogFile(folder, "logs");

            try {
                //Log.d("Disk Log", "log exist() = " + logFile.exists());
                fileWriter = new FileWriter(logFile, true);

                writeLog(fileWriter, content);

                fileWriter.flush();
                fileWriter.close();
                //Log.d("Disk Log", "finish content = " + content);
            } catch (Exception e) {
                Logger.t(TAG).d("error" + e.getMessage());
                if (fileWriter != null) {
                    try {
                        fileWriter.flush();
                        fileWriter.close();
                    } catch (IOException e1) { /* fail silently */ }
                }
            }
        }

        /**
         * This is always called on a single background thread.
         * Implementing classes must ONLY write to the fileWriter and nothing more.
         * The abstract class takes care of everything else including close the stream and catching IOException
         *
         * @param fileWriter an instance of FileWriter already initialised to the correct file
         */
        private void writeLog(FileWriter fileWriter, String content) throws IOException {
            fileWriter.append(content);
        }

        private synchronized File getLogFile(String folderName, String fileName) {

            File folder = new File(folderName);
            if (!folder.exists()) {
                //TODO: What if folder is not created, what happens then?
                Logger.t(TAG).d("folder mkdirs = " + folder.mkdirs());
            }

            int newFileCount = 0;
            File newFile;
            File existingFile = null;

            newFile = new File(folder, String.format("%s_%s.csv", fileName, newFileCount));
            while (newFile.exists() && newFileCount < logFileCount) {
                existingFile = newFile;
                newFileCount++;
                newFile = new File(folder, String.format("%s_%s.csv", fileName, newFileCount));
            }

            if (existingFile != null) {
                if (existingFile.length() >= maxFileSize) {
                    if (newFileCount < logFileCount) {
                        return newFile;
                    } else {
                        File firstFile = new File(folder, String.format("%s_%s.csv", fileName, 0));
                        firstFile.delete();
                        for (int i = 1; i < logFileCount; i++) {
                            File oneFile = new File(folder, String.format("%s_%s.csv", fileName, i));
                            oneFile.renameTo(new File(folder, String.format("%s_%s.csv", fileName, i - 1)));
                        }
                        newFile = new File(folder, String.format("%s_%s.csv", fileName, logFileCount - 1));
                        return newFile;
                    }
                }
                return existingFile;
            }

            return newFile;
        }
    }
}