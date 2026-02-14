package com.mkgroup.camera.utils;

import com.google.gson.Gson;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import retrofit2.HttpException;

/**
 * Created by doanvt on 2015/9/22.
 */
public class ToStringUtils {
    private static final String TAG = ToStringUtils.class.getSimpleName();

    public static String getString(Object object) {
        try {
            if (null == object) {
                return null;
            } else {

                Field[] field = object.getClass().getDeclaredFields();
                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < field.length && field.length > 0; i++) {
                    Field oneField = field[i];
                    oneField.setAccessible(true);
                    if ((oneField.getModifiers() & Modifier.STATIC) != Modifier.STATIC) {
                        sb.append(oneField.getName() + ": " + oneField.get(object) + "\t");
                    }
                }
                return sb.toString();
            }
        } catch (SecurityException e) {
            e.printStackTrace();
            return null;
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return null;
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String toString(Object object) {
        return new Gson().toJson(object);
    }

    public static String getErrorString(Throwable th) {
        if (th instanceof HttpException) {
            HttpException ex = (HttpException) th;
            try {
                return ex.response().errorBody().string();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
        return th.getMessage();
    }


    /**
     * split to List
     */

    public static List<List<String>> splitToList(String[] input, int blockSize) {
        int blockCount = (input.length + blockSize - 1) / blockSize;
        List<List<String>> listString = new ArrayList<>();
        String[] range = new String[100];
        Logger.t(TAG).d("String - Count: " + blockCount);
        for (int i = 1; i < blockCount; i++) {
            int idx = (i - 1) * blockSize;
            range = Arrays.copyOfRange(input, idx, idx + blockSize);
            listString.add(Arrays.asList(range));
        }
        int end = -1;
        if (input.length % blockSize == 0) {
            end = input.length;
        } else {
            end = input.length % blockSize + blockSize * (blockCount - 1);
        }

        Logger.t(TAG).d("String - End: " + end);
        range = Arrays.copyOfRange(input, (blockCount - 1) * blockSize, end);
        listString.add(Arrays.asList(range));
        Logger.t(TAG).d("String - FullListSize: " + listString.size());

        return listString;
    }
}
