package com.mkgroup.camera.preference;

import android.os.Build;
import android.text.TextUtils;
import android.util.Base64;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class EncryptUtil {

    private String key;
    private static EncryptUtil instance;
    private static final String TAG = EncryptUtil.class.getSimpleName();
    private static final String transformation = "AES/ECB/PKCS5Padding";

    private EncryptUtil() {
        String string = Build.MANUFACTURER + " Waylens";
        //加密随机字符串生成AES key
        key = SHA(string + "~!@#$%^&*()_+").substring(0, 16);
    }

    /**
     * 单例模式
     */
    public static EncryptUtil getInstance() {
        if (instance == null) {
            synchronized (EncryptUtil.class) {
                if (instance == null) {
                    instance = new EncryptUtil();
                }
            }
        }
        return instance;
    }

    /**
     * SHA加密
     *
     * @param strText 明文
     * @return
     */
    private String SHA(final String strText) {
        // 返回值
        String strResult = null;
        // 是否是有效字符串
        if (!TextUtils.isEmpty(strText)) {
            try {
                // SHA 加密开始
                MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
                // 传入要加密的字符串
                messageDigest.update(strText.getBytes());
                byte[] byteBuffer = messageDigest.digest();
                StringBuilder strHexString = new StringBuilder();
                for (byte b : byteBuffer) {
                    String hex = Integer.toHexString(0xff & b);
                    if (hex.length() == 1) {
                        strHexString.append('0');
                    }
                    strHexString.append(hex);
                }
                strResult = strHexString.toString();
            } catch (NoSuchAlgorithmException e) {
                e.printStackTrace();
            }
        }
        return strResult;
    }


    /**
     * AES128加密
     *
     * @param plainText 明文
     * @return
     */
    String encrypt(String plainText) {
        try {
            Cipher cipher = Cipher.getInstance(transformation);
            SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(), "AES");
            cipher.init(Cipher.ENCRYPT_MODE, keyspec);
            byte[] encrypted = cipher.doFinal(plainText.getBytes());
            return Base64.encodeToString(encrypted, Base64.NO_WRAP);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * AES128解密
     *
     * @param cipherText 密文
     * @return
     */
    String decrypt(String cipherText) {
        try {
            byte[] encrypted1 = Base64.decode(cipherText, Base64.NO_WRAP);
            Cipher cipher = Cipher.getInstance(transformation);
            SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(), "AES");
            cipher.init(Cipher.DECRYPT_MODE, keyspec);
            byte[] original = cipher.doFinal(encrypted1);
            return new String(original);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
