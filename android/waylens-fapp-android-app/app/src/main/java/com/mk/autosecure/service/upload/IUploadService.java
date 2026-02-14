package com.mk.autosecure.service.upload;

import com.mk.autosecure.service.job.UploadDataResponse;

import io.reactivex.Observable;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Headers;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */


public interface IUploadService {

    //上传头像
    @PUT("/v.1.0/upload_avatar/{userId}/android")
    Call<UploadDataResponse> uploadAvatar(@Path("userId") String userId,
                                          @Query("file_sha1") String fileSha1,
                                          @Body RequestBody requestBody);

    //上传资源（如:mp4）
    @Headers({"Transfer-Encoding: chunked", "Connection: keep-alive"})
    @PUT("/v.1.0/upload_resource/{userId}/android")
    Observable<UploadDataResponse> uploadMp4(@Path("userId") String userId,
                                             @Query("moment_id") long momentId,
                                             @Query("file_sha1") String fileSha1,
                                             @Query("access_level") String accessLevel,
                                             @Query("resolution") long resolution,
                                             @Query("duration") long duration,
                                             @Body RequestBody requestBody);
}
