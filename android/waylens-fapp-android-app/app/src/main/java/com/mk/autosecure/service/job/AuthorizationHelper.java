package com.mk.autosecure.service.job;

import com.mk.autosecure.libs.utils.HashUtils;
import com.mk.autosecure.libs.utils.Hex;
import com.orhanobut.logger.Logger;

import java.security.NoSuchAlgorithmException;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class AuthorizationHelper {
    private static final String TAG = AuthorizationHelper.class.getSimpleName();

    public static String getAuthorization(String host, String userId, String momentId, String content, String date, String privateKey) {
        try {
            String checkSum = computeCheckSum(host, userId, momentId, date);
            Logger.t(TAG).d("checkSum = " + checkSum);
            String stringToSign = "WAYLENS-HMAC-SHA256&waylens_cfs&" + content + "&" + checkSum;
            String signingKey = Hex.encodeHexString(HashUtils.encodeHMAC256(privateKey, "waylens_cfs&" + date));
            Logger.t(TAG).d("signingKey: " + signingKey);

            String signature = Hex.encodeHexString(HashUtils.encodeHMAC256(signingKey, stringToSign));
            Logger.t(TAG).d("signature: " + signature);
            return "WAYLENS-HMAC-SHA256 " + signature;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String getAuthorization(String host, String userId, long momentId, String fileSha1, String content, String date, String privateKey) {
        try {
            String checkSum = computeCheckSum(host, userId, Long.toString(momentId), fileSha1, date);
            Logger.t(TAG).d("checkSum = " + checkSum);
            String stringToSign = "WAYLENS-HMAC-SHA256&waylens_cfs&" + content + "&" + checkSum;
            String signingKey = Hex.encodeHexString(HashUtils.encodeHMAC256(privateKey, "waylens_cfs&" + date));
            Logger.t(TAG).d("signingKey: " + signingKey);

            String signature = Hex.encodeHexString(HashUtils.encodeHMAC256(signingKey, stringToSign));
            Logger.t(TAG).d("signature: " + signature);
            return "WAYLENS-HMAC-SHA256 " + signature;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static String computeCheckSum(String host, String userId, String momentId, String date) throws NoSuchAlgorithmException {
        String sum = host + userId + momentId + date;
        Logger.t(TAG).d("sum = " + sum);
        byte[] sumBytes = sum.getBytes();

        byte[] newSumByte = new byte[sumBytes.length];
        for (int i = 0; i < sumBytes.length; i++) {
            newSumByte[i] = (byte) (((int) sumBytes[i] * 7) % 256);
        }
        return Hex.encodeHexString(HashUtils.encodeMD5(newSumByte));
    }

    private static String computeCheckSum(String host, String userId, String momentId, String fileSha1, String date) throws NoSuchAlgorithmException {
        String sum = host + userId + momentId + fileSha1 + date;
        Logger.t(TAG).d("sum = " + sum);
        byte[] sumBytes = sum.getBytes();

        byte[] newSumByte = new byte[sumBytes.length];
        for (int i = 0; i < sumBytes.length; i++) {
            newSumByte[i] = (byte) (((int) sumBytes[i] * 7) % 256);
        }
        return Hex.encodeHexString(HashUtils.encodeMD5(newSumByte));
    }
}