package com.mk.autosecure.service.job;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.utils.HashUtils;
import com.mk.autosecure.libs.utils.Hex;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.reponse.UploadAvatarServerResponse;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.service.upload.UploadAPI;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Locale;

import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.RequestBody;

/**
 * Created by DoanVT on 2017/11/3.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
public class UploadAvatarJob implements Runnable {
    private static final String TAG = UploadAvatarJob.class.getSimpleName();
    private final String file;
    private final String userId;

    public UploadAvatarJob(String file) {
        this.file = file;
        User user = HornApplication.getComponent().currentUser().getUser();
        userId = user != null ? user.id() : null;
    }

    @Override
    public void run() {
        if (TextUtils.isEmpty(userId)) {
            Logger.t(TAG).d("userId empty = " + TextUtils.isEmpty(userId));
            return;
        }
        if (TextUtils.isEmpty(file)) {
            Logger.t(TAG).d("on Run file: " + file);
            return;
        }

        ApiService.createApiService().getAvatarUploadServer()
                .subscribeOn(Schedulers.io())
                .observeOn(Schedulers.io())
                .subscribe(response -> {
                    UploadAvatarServerResponse.UploadServer uploadServer = response.uploadServer;
                    if (uploadServer == null) {
                        Logger.t(TAG).d("upload server is empty");
                        return;
                    }
                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_START));
                    Logger.t(TAG).d("getAvatarUploadServer: " + uploadServer.toString());

                    try {
                        String fileSha1 = Hex.encodeHexString(HashUtils.encodeSHA1(new File(file)));

                        SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyy hh:mm:ss", Locale.US);
                        String date = format.format(System.currentTimeMillis()) + " GMT";
                        String server = StringUtils.getHostNameWithoutPrefix(uploadServer.url);

                        final String authorization = AuthorizationHelper.getAuthorization(server,
                                userId + "/android",
                                fileSha1,
                                "upload_avatar",
                                date,
                                uploadServer.privateKey);
//                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_START));

                        UploadAPI uploadAPI = new UploadAPI(uploadServer.url + "/", date, authorization, -1);

                        RequestBody requestBody = RequestBody.create(MediaType.parse("image/jpeg"), new File(file));

                        //Response<UploadDataResponse> response = uploadAPI.uploadAvatarSync(requestBody, userId, fileSha1);

                        UploadDataResponse dataResponse = uploadAPI.uploadAvatarSyncOld(requestBody, userId, fileSha1);

                        Logger.t(TAG).d("response: " + dataResponse);
                        if (dataResponse != null) {
                            RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_FINISHED));
                        }
                    } catch (Exception e) {
                        Logger.t(TAG).e("exception: " + e.getMessage());
                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                    }
                }, throwable -> {
                    Logger.t(TAG).d("getAvatarUploadServer throwable: " + throwable.getMessage());
                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                });
    }
}
