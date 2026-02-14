package com.mkgroup.camera.utils;

/**
 * Created by DoanVT on 2017/9/28.
 * Email: doanvt-hn@mk.com.vn
 */

import static android.content.Context.DOWNLOAD_SERVICE;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.media.MediaScannerConnection;
import android.opengl.GLException;
import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.util.Log;

import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.log.CameraLogClient;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.opengles.GL10;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;


public class FileUtils {
    public static final String APP_NAME = "waylens";
    public static final String VIDEO_ORIGIN_PATH = "/waylens/" + APP_NAME + "/origin/";
    public static final String EXPORT_PATH = "/waylens/" + APP_NAME + "/exports/";
    public static final String VIDEO_EXPORT_PATH = "/waylens/" + APP_NAME + "/video/";
    public static final String CACHE_PATH = "/waylens/" + APP_NAME + "/cache/";
    private static final String FW_DOWNLOAD_PATH = "/waylens/" + APP_NAME + "/downloads/firmware/";
    public static final String LOG_PATH = "/waylens/" + APP_NAME + "/log/";
    public static final String CAMERA_LOG_PATH = "/waylens/" + APP_NAME + "/camera_log/";

    public static final String CAMERA_LOG_FILENAME = "camera_log.zip";
    public static final String CAMERA_DEBUGLOG_FILENAME = "camera_debug_log.zip";
    public static final String TEST_LOG_FILENAME = "camera_test_log.zip";
    public static final String DOANVT_FILENAME = "doanvt_log.zip";
    public static final String FEEDBACK_LOG_FILENAME = "FeedbackLog.zip";
    public static final String FEEDBACK_DEBUGLOG_FILENAME = "FeedbackDebugLog.zip";
    public static final String vehicleFleetFileName = "vehicleFleet.xlsx";
    public static final String vehicleSpeedFileName = "vehicleSpeed.xlsx";
    public static final String stopVehicleFileName = "stopVehicle.xlsx";
    public static final String drivingTimeFileName = "drivingTime.xlsx";
    public static final String overSpeedFileName = "overSpeed.xlsx";
    public static final String detailPictureTimeFileName = "detailPicture.xlsx";
    public static final String b51report = "b51.xlsx";
    public static final String b52report = "b52.xlsx";


    public static final String VIDEO_NAME_PREFIX = upperCase("waylens") + "_";

    private GLSurfaceView glSurfaceView; // findById() in onCreate
    private static Bitmap snapshotBitmap;

    public static String upperCase(String str) {
        char[] ch = str.toCharArray();
        if (ch[0] >= 'a' && ch[0] <= 'z') {
            ch[0] = (char) (ch[0] - 32);
        }
        return new String(ch);
    }

    public interface BitmapReadyCallbacks {
        void onBitmapReady(Bitmap bitmap);
    }

    // supporting methods
    public static void captureBitmap(GLSurfaceView glSurfaceView, Activity context, final BitmapReadyCallbacks bitmapReadyCallbacks) {
        glSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                EGL10 egl = (EGL10) EGLContext.getEGL();
                GL10 gl = (GL10)egl.eglGetCurrentContext().getGL();
                snapshotBitmap = createBitmapFromGLSurface(0, 0, glSurfaceView.getWidth(), glSurfaceView.getHeight(), gl);

                context.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        bitmapReadyCallbacks.onBitmapReady(snapshotBitmap);
                    }
                });

            }
        });

    }

    public static String getVideoExportPath() {
        return getExportPath(VIDEO_EXPORT_PATH);
    }

    public static String getOriginVideoPath() {
//        return getExportPath(VIDEO_ORIGIN_PATH);
        return getMoviesPath();
    }

    public static String getFirmwareDownloadPath(String url) {
        int lastSlash = url.lastIndexOf("/");
        String fileName = url.substring(lastSlash);
        return getExportPath(FW_DOWNLOAD_PATH) + fileName;
    }

    public static String geCachePath() {
        return getExportPath(CACHE_PATH);
    }


    public static List<File> getExportedFileList() {
        File downloadDir = new File(getVideoExportPath());
        File[] fileList = downloadDir.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File file, String s) {
                return !s.endsWith(".mp4.mp4") && s.endsWith(".mp4");
            }
        });

        List<File> exportFileList = new ArrayList<>();
        if (fileList != null) {
            exportFileList = Arrays.asList(fileList);

            Collections.sort(exportFileList, (left, right) -> {
                if (left.lastModified() < right.lastModified()) {
                    return 1;
                } else {
                    return -1;
                }
            });
        }

        return exportFileList;
    }

    public static String getLogPath(Context context) {
        if (context == null) {
            return "";
        }
        File fileDir = context.getFilesDir();
        return fileDir + LOG_PATH;
    }

    public static String getExportPath() {
        File fileDir = WaylensCamera.getInstance().getApplicationContext().getFilesDir();
        File cameraLogDir = new File(fileDir + EXPORT_PATH);
        if (!cameraLogDir.exists()) {
            boolean ret = false;
            ret = cameraLogDir.mkdirs();
            return ret ? fileDir + EXPORT_PATH : null;
        } else {
            return fileDir + EXPORT_PATH;
        }
    }

    public static String getCameraLogPath() {
        File fileDir = WaylensCamera.getInstance().getApplicationContext().getFilesDir();
        File cameraLogDir = new File(fileDir + CAMERA_LOG_PATH);
        if (!cameraLogDir.exists()) {
            boolean ret = false;
            ret = cameraLogDir.mkdirs();
            return ret ? fileDir + CAMERA_LOG_PATH : null;
        } else {
            return fileDir + CAMERA_LOG_PATH;
        }
    }

    public static String getExportPath(String subdir) {
        File sdCardDir = Environment.getExternalStoragePublicDirectory(DOWNLOAD_SERVICE);
        if (sdCardDir == null) {
            return null;
        }
        String dir = sdCardDir + subdir;
        File dirFile = new File(dir);
        dirFile.mkdirs();
        return dir;
    }

    /**
     * getExternalFilesDir(Environment.DIRECTORY_MOVIES)
     * /storage/sdcard0/Android/data/package/files/Movies
     * private video directory for app
     */
    public static String getMoviesPath() {
        File sdCardDir = WaylensCamera.getInstance().getApplicationContext().getExternalFilesDir(Environment.DIRECTORY_MOVIES);
        if (sdCardDir == null) {
            return null;
        }
        return sdCardDir + File.separator;
    }

    private static Bitmap createBitmapFromGLSurface(int x, int y, int w, int h, GL10 gl) {

        int[] bitmapBuffer = new int[w * h];
        int[] bitmapSource = new int[w * h];
        IntBuffer intBuffer = IntBuffer.wrap(bitmapBuffer);
        intBuffer.position(0);

        try {
            gl.glReadPixels(x, y, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, intBuffer);
            int offset1, offset2;
            for (int i = 0; i < h; i++) {
                offset1 = i * w;
                offset2 = (h - i - 1) * w;
                for (int j = 0; j < w; j++) {
                    int texturePixel = bitmapBuffer[offset1 + j];
                    int blue = (texturePixel >> 16) & 0xff;
                    int red = (texturePixel << 16) & 0x00ff0000;
                    int pixel = (texturePixel & 0xff00ff00) | red | blue;
                    bitmapSource[offset2 + j] = pixel;
                }
            }
        } catch (GLException e) {
            Log.e(CameraLogClient.TAG, "createBitmapFromGLSurface: " + e.getMessage(), e);
            return null;
        }

        return Bitmap.createBitmap(bitmapSource, w, h, Bitmap.Config.ARGB_8888);
    }

    public static File createDiskCacheFile(Context context, String uniqueName) {
        String cachePath;
        if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) || !Environment.isExternalStorageRemovable()) {
            File externalCacheDir = context.getExternalCacheDir();
            if (externalCacheDir != null) {
                cachePath = externalCacheDir.getPath();
            } else {
                cachePath = context.getCacheDir().getPath();
            }
        } else {
            cachePath = context.getCacheDir().getPath();
        }
        Logger.t(CameraLogClient.TAG).d("path:= "+cachePath);
        return new File(cachePath + File.separator + uniqueName);
    }

    public static String getFirmwareDirectory() {
        return getExportPath(FW_DOWNLOAD_PATH);
    }

    private static String composeFileName(String dir, String fn, int i) {
        if (i == 0) {
            return dir + fn + ".mp4";
        } else {
            return dir + fn + "-" + i + ".mp4";
        }
    }


    public static String genDownloadVideoFileName(int clipDate, long clipTimeMs) {
        try {
            String dir = getVideoExportPath();
            if (dir == null) {
                return null;
            }
            String fn = DateTime.toFileName(clipDate, clipTimeMs);
            for (int i = 0; ; i++) {
                String targetFile = composeFileName(dir, VIDEO_NAME_PREFIX + fn, i);
                File file = new File(targetFile);
                if (!file.exists()) {
                    return targetFile;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    public static String genDownloadVideoFileName(long clipDate) {
        try {
            String dir = getVideoExportPath();
            if (dir == null) {
                return null;
            }
            String fn = DateTime.toFileName(clipDate);
            for (int i = 0; ; i++) {
                String targetFile = composeFileName(dir, VIDEO_NAME_PREFIX + fn, i);
                File file = new File(targetFile);
                if (!file.exists()) {
                    return targetFile;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    public static String genOriginVideoFileName(int clipDate, long clipTimeMs) {
        try {
            String dir = getOriginVideoPath();
            if (dir == null) {
                return null;
            }
            String fn = DateTime.toFileName(clipDate, clipTimeMs);
            for (int i = 0; ; i++) {
                String targetFile = composeFileName(dir, VIDEO_NAME_PREFIX + fn, i);
                File file = new File(targetFile);
                if (!file.exists()) {
                    return targetFile;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    public static String genOriginVideoFileName(long clipDate) {
        try {
            String dir = getOriginVideoPath();
            if (dir == null) {
                return null;
            }
            String fn = DateTime.toFileName(clipDate);
            for (int i = 0; ; i++) {
                String targetFile = composeFileName(dir, VIDEO_NAME_PREFIX + fn, i);
                File file = new File(targetFile);
                if (!file.exists()) {
                    return targetFile;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    public static String genMomentCacheFileName(String fileName) {
        String dir = geCachePath();
        if (dir == null) {
            return null;
        }
        for (int i = 0; ; i++) {
            String targetFile = composeFileName(dir, fileName, i);
            File file = new File(targetFile);
            if (!file.exists()) {
                return targetFile;
            }
        }
    }


    public static void writeFile(InputStream inputStream, File file) throws IOException {
        if (!file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }
        if (file != null && file.exists()) {
            file.delete();
        }
        FileOutputStream out = null;
        try {
            out = new FileOutputStream(file);
            byte[] buffer = new byte[1024 * 128];
            int length = -1;
            while ((length = inputStream.read(buffer)) != -1) {
                out.write(buffer, 0, length);
            }
            out.flush();
            out.close();
            inputStream.close();
        } catch (IOException e) {
            Logger.t(FileUtils.class.getSimpleName()).d(e.getMessage());
        } finally {
            if (out != null) {
                out.close();
            }
            if (inputStream != null) {
                inputStream.close();
            }
        }
    }

    public static File zipFiles(List<File> srcFiles, String fileName) {
        File zipFile = createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), fileName);
        //File zipFile = new File(geCachePath(), FEEDBACK_LOG_FILENAME);
        if (zipFile.exists()) {
            zipFile.delete();
        }
        byte[] buf = new byte[4 * 1024];
        try {
            ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipFile));
            for (File oneFile : srcFiles) {
                FileInputStream in = new FileInputStream(oneFile);
                out.putNextEntry(new ZipEntry(oneFile.getName()));
                int len = 0;
                while ((len = in.read(buf)) > 0) {
                    out.write(buf, 0, len);
                }
                out.closeEntry();
                in.close();
            }
            out.flush();
            out.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return zipFile;
    }
    //
    private static final int BUFFER_SIZE = 4096;
    /**
     * Extracts a zip file specified by the zipFilePath to a directory specified by
     * destDirectory (will be created if does not exists)
     * @param filePath
     * @param destDirectory
     * @throws IOException
     */
    public static void unzip(String filePath, String destDirectory) throws IOException {
        File destDir = new File(destDirectory);
        if (!destDir.exists()) {
            destDir.mkdir();
        }
        ZipInputStream zipIn = new ZipInputStream(new FileInputStream(filePath));
        ZipEntry entry = zipIn.getNextEntry();
        // iterates over entries in the zip file
        while (entry != null) {
//            String filePath = getCameraLogPath();
            if (!entry.isDirectory()) {
                // if the entry is a file, extracts it
                Logger.e("doanvt-- extracts it");
                extractFile(zipIn, filePath);
            } else {
                // if the entry is a directory, make the directory
                Logger.e("doanvt-- mkdir it");
                File dir = new File(filePath);
                dir.mkdirs();
            }
            zipIn.closeEntry();
            entry = zipIn.getNextEntry();
        }
        zipIn.close();
    }
    /**
     * Extracts a zip entry (file entry)
     * @param zipIn
     * @param filePath
     * @throws IOException
     */
    private static void extractFile(ZipInputStream zipIn, String filePath) throws IOException {
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath));
        byte[] bytesIn = new byte[zipIn.available()];
        int read = 0;
        while ((read = zipIn.read(bytesIn)) != -1) {
            bos.write(bytesIn, 0, read);
        }
        Logger.t("doanvt").d(bytesIn);
        bos.close();
    }

    //

    //刷新媒体数据库
    public static void callMediaScanner(File file) {
        Observable.create((ObservableOnSubscribe<Optional<Void>>) emitter -> {
            Context context = WaylensCamera.getInstance().getApplicationContext();
            String[] paths = new String[]{context.getExternalFilesDir(Environment.DIRECTORY_MOVIES).toString()};
            MediaScannerConnection.scanFile(context, paths, null, null);

            if (file != null) {
                MediaScannerConnection.scanFile(context,
                        new String[]{file.getAbsolutePath()},
                        null,
                        (path, uri) -> {
                            Logger.t(FileUtils.class.getSimpleName()).d("media path = %s", path);
                            Logger.t(FileUtils.class.getSimpleName()).d("media uri = %s", uri);
                        });
            }
        })
                .subscribeOn(Schedulers.computation())
                .subscribe();
    }

    public static String getMimeType(String filePath) {
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        String mime = "text/plain";
        if (filePath != null) {
            try {
                mmr.setDataSource(filePath);
                mime = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE);
            } catch (RuntimeException e) {
                return mime;
            }
        }
        return mime;
    }
}
