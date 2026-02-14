package com.mk.autosecure.libs.utils;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.OpenableColumns;

import androidx.core.content.FileProvider;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.BuildConfig;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Locale;

/**
 * Created by DoanVT on 2017/11/3.
 * Email: doanvt-hn@mk.com.vn
 */


public class ImageUtils {

    private static final String TAG = ImageUtils.class.getSimpleName();

    public static Uri getPictureUri(Context context) {
        SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyyMMdd_hhmmss", Locale.getDefault());
        String date = sDateFormat.format(new java.util.Date());
        try {
            File image = File.createTempFile(date, ".jpg", context.getCacheDir());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R){
                ContentValues contentValues = new ContentValues();
                contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, image.getName());
                contentValues.put(MediaStore.Images.Media.MIME_TYPE, "image/*");
                contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES);
                return context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
            }else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                return FileProvider.getUriForFile(HornApplication.getContext(), BuildConfig.APPLICATION_ID + ".provider", image);
            }
            return Uri.fromFile(image);
        } catch (Exception e) {
            Logger.t(TAG).d(e.getMessage());
        }
        return null;
    }

    /**
     * 将uri转换为file
     * uri类型为file的直接转换出路径
     * uri类型为content的将对应的文件复制到沙盒内的cache目录下进行操作
     *
     * @param context 上下文
     * @param uri     uri
     * @return file
     */
    public static File uriToFile(Context context, Uri uri) {
        if (uri == null) {
            return null;
        }
        File file = null;
        if (uri.getScheme() != null) {
            if (uri.getScheme().equals(ContentResolver.SCHEME_FILE) && uri.getPath() != null) {
                //此uri为文件，并且path不为空(保存在沙盒内的文件可以随意访问，外部文件path则为空)
                file = new File(uri.getPath());
            } else if (uri.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
                //此uri为content类型，将该文件复制到沙盒内
                ContentResolver resolver = context.getContentResolver();
                @SuppressLint("Recycle")
                Cursor cursor = resolver.query(uri, null, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    String fileName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                    try {
                        InputStream inputStream = resolver.openInputStream(uri);
                        if (context.getExternalCacheDir() != null) {
                            //该文件放入cache缓存文件夹中
                            File cache = new File(context.getExternalCacheDir(), fileName);
                            FileOutputStream fileOutputStream = new FileOutputStream(cache);
                            if (inputStream != null) {
//                                FileUtils.copy(inputStream, fileOutputStream);
                                //上面的copy方法在低版本的手机中会报java.lang.NoSuchMethodError错误，使用原始的读写流操作进行复制
                                byte[] len = new byte[Math.min(inputStream.available(), 1024 * 1024)];
                                int read;
                                while ((read = inputStream.read(len)) != -1) {
                                    fileOutputStream.write(len, 0, read);
                                }
                                file = cache;
                                fileOutputStream.close();
                                inputStream.close();
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return file;
    }

    public static String getAvatarUrl(Context context) {
        File file = new File(Environment.getExternalStorageDirectory() + "/avatar/Images");
        if (!file.exists()) {
            boolean mkdirs = file.mkdirs();
            return mkdirs ? file.getAbsolutePath()
                    : context.getCacheDir().getAbsolutePath();
        }
        return file.getAbsolutePath();
    }

    public static String getStoragePath(Context context, String type) {
        return getStorageDir(context, type).getPath();
    }

    public static File getStorageDir(Context context, String type) {
        if (isExternalStorageReady()) {
            return new File(context.getExternalCacheDir(), type);
        } else {
            return new File(context.getCacheDir(), type);
        }
    }

    public static boolean isExternalStorageReady() {
//        return Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())
//                && Environment.getExternalStorageDirectory().canWrite();
        return Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) || !Environment.isExternalStorageRemovable();
    }


    public static String saveBitmap(Bitmap bmp, String fullPath) {
        int lastIndex = fullPath.lastIndexOf('/');
        if (lastIndex == -1) {
            return null;
        }
        String path = fullPath.substring(0, lastIndex);
        String name = fullPath.substring(lastIndex + 1);
        saveBitmap(bmp, path, name);
        return fullPath;
    }


    public static String saveBitmap(Bitmap bmp, String path, String name) {
        // File file = new File("mnt/sdcard/picture");
        File file = new File(path);
        String fullPath = null;
        if (!file.exists()) {
            file.mkdirs();
        }
        fullPath = file.getPath() + "/" + name;
        if (new File(path + name).exists()) {
            return fullPath;
        }

        try {
            FileOutputStream fileOutputStream = new FileOutputStream(fullPath);
            bmp.compress(Bitmap.CompressFormat.JPEG, 100, fileOutputStream);
            fileOutputStream.flush();
            fileOutputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return fullPath;
    }

    public static Bitmap zoomBitmap(Bitmap bitmap, int w, int h) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Matrix matrix = new Matrix();
        float scaleWidht = ((float) w / width);
        float scaleHeight = ((float) h / height);
        matrix.postScale(scaleWidht, scaleHeight);
        Bitmap newbmp = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
        return newbmp;
    }
}
