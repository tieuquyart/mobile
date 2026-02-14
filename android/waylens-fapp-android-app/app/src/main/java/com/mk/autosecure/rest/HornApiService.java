package com.mk.autosecure.rest;

import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FourGSignalResponse;
import com.mkgroup.camera.bean.SettingReportBody;
import com.mk.autosecure.rest.bean.NotificationSetting;
import com.mk.autosecure.rest.reponse.AlertListResponse;
import com.mk.autosecure.rest.reponse.AuthorizeResponse;
import com.mk.autosecure.rest.reponse.BPSResponse;
import com.mk.autosecure.rest.reponse.BindDeviceResponse;
import com.mk.autosecure.rest.reponse.ClipListResponse;
import com.mk.autosecure.rest.reponse.ClipListStatResponse;
import com.mk.autosecure.rest.reponse.DeviceListResponse;
import com.mk.autosecure.rest.reponse.DevicesGpsResponse;
import com.mk.autosecure.rest.reponse.EventResponse;
import com.mk.autosecure.rest.reponse.LiveStatusResponse;
import com.mk.autosecure.rest.reponse.LocationResponse;
import com.mk.autosecure.rest.reponse.NotificationListResponse;
import com.mk.autosecure.rest.reponse.ResetPwdBody;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest.reponse.UploadAvatarServerResponse;
import com.mk.autosecure.rest.reponse.UserProfileResponse;
import com.mk.autosecure.rest.request.AlterProfileBody;
import com.mk.autosecure.rest.request.BindDeviceBody;
import com.mk.autosecure.rest.request.CameraControlBody;
import com.mk.autosecure.rest.request.CameraNameBody;
import com.mk.autosecure.rest.request.ChangePwdBody;
import com.mk.autosecure.rest.request.LiveStreamBody;
import com.mk.autosecure.rest.request.ReportFeedbackBody;
import com.mk.autosecure.rest.request.ReportIdBody;
import com.mk.autosecure.rest.request.ResetPwdEmailBody;
import com.mk.autosecure.rest.request.SignInPostBody;
import com.mk.autosecure.rest.request.SignUpPostBody;
import com.mk.autosecure.rest.request.TokenBody;
import com.mk.autosecure.rest_fleet.response.AudioStreamResponse;
import com.mk.autosecure.uploadqueue.body.CreateMomentBody;
import com.mk.autosecure.uploadqueue.response.CreateMomentResponse;

import java.util.List;

import io.reactivex.Observable;
import okhttp3.MultipartBody;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;

/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */

public interface HornApiService {


    /*-------------------------------------------账户-------------------------------------------*/

    //注册
    @POST("api/v1.0/users/signup")
    Observable<Response<AuthorizeResponse>> signUp(@Body SignUpPostBody signUpPostBody);

    //登录
    @POST("api/v1.0/users/signin")
    Observable<Response<AuthorizeResponse>> signIn(@Body SignInPostBody signInPostBody);

    //登出
    @POST("api/v1.0/users/signout")
    Observable<BooleanResponse> signout();

    //刷新用于设备推送的token
    @POST("api/v1.0/users/me/device_token")
    Observable<BooleanResponse> refreshToken(@Body TokenBody tokenBody);

    //重发认证邮件
    @POST("api/v1.0/users/resend_verify_email")
    Observable<Response<BooleanResponse>> resendVerifyEmail();

    //获取上传头像地址
    @GET("api/v2.0/users/me/avatar_upload_address")
    Observable<UploadAvatarServerResponse> getAvatarUploadServer();

    //查看用户信息
    @GET("api/v1.0/users/me/profile")
    Observable<UserProfileResponse> getMyProfile();

    //查看用户信息
    @GET("api/v1.0/users/me/profile")
    Observable<Response<UserProfileResponse>> fetchMyProfile();

    //更新用户信息
    @POST("api/v1.0/users/me/profile")
    Observable<Response<BooleanResponse>> alterProfile(@Body AlterProfileBody alterProfileBody);

    //发送密码重置邮件
    @POST("api/v2.0/users/me/send_passwordreset_email")
    Observable<Response<BooleanResponse>> sendResetPasswordEmail(@Body ResetPwdEmailBody resetPwdEmailBody);

    //设置新密码
    @POST("api/v2.0/users/me/reset_password")
    Observable<Response<BooleanResponse>> resetPassword(@Body ResetPwdBody resetPwdBody);

    //修改密码
    @POST("api/v2.0/users/me/change_password")
    Observable<Response<AuthorizeResponse>> changePassword(@Body ChangePwdBody changePwdBody);


    /*-------------------------------------------设备-------------------------------------------*/

    //绑定用户
    @POST("api/v2.0/devices")
    Observable<Response<BindDeviceResponse>> bindDeviceRes(@Body BindDeviceBody bindDeviceRequest);

    //解绑设备
    @DELETE("api/v1.0/devices/{sn}")
    Observable<Response<BooleanResponse>> unbindDevice(@Path("sn") String sn);

    //获取名下设备列表
    @GET("api/v1.0/devices")
    Observable<DeviceListResponse> getCameras();

    //获取单设备详情
    @GET("api/v1.0/devices/{sn}")
    Observable<Response<DevicesGpsResponse>> getDevicesGps(@Path("sn") String sn);

    //修改相机名
    @POST("api/v1.0/devices/{sn}/name")
    Observable<Response<BooleanResponse>> setCameraName(@Path("sn") String sn,
                                                        @Body CameraNameBody cameraNameBody);

    //远程控制相机  only for 4G
    @POST("api/v1.0/devices/{sn}/control")
    Observable<BooleanResponse> controlCamera(@Path("sn") String sn, @Body CameraControlBody settings);

    //上报相机信息
    @POST("api/v1.0/devices/{sn}/report")
    Observable<Response<BooleanResponse>> reportSetting(@Path("sn") String sn,
                                                        @Body SettingReportBody settingReportBody);


    /*-------------------------------------------Clip-------------------------------------------*/

    //拉取 Clip (视频、图片)列表
    @GET("api/v1.0/clips")
    Observable<ClipListResponse> getClipList(@Query("sn") String sn, @Query("cursor") Long cursor,
                                             @Query("count") Integer count,
                                             @Query("filterType") String filterType);

    //获取指定类型 Clip 总数
    @GET("api/v1.0/clips/number")
    Observable<ClipListStatResponse> getClipListStat(@Query("sn") String sn);

    //删除指定 Clip
    @DELETE("api/v1.0/clips/{clipID}")
    Observable<Response<BooleanResponse>> deleteClip(@Path("clipID") Long clipID);


    /*-------------------------------------------直播-------------------------------------------*/

    //开始/停止 直播
    @POST("api/v1.0/devices/{sn}/streaming")
    Observable<LiveStatusResponse> controlStream(@Path("sn") String sn,
                                                 @Body LiveStreamBody liveStreamBody);

    //拉取设备直播状态
    @GET("api/v1.0/devices/{sn}/streaming/status")
    Observable<LiveStatusResponse> getLiveStatus(@Path("sn") String sn);

    //获取4g状态（仅在有4g连接时可用）RSRP
    @GET("api/v1.0/devices/{sn}/streaming/4gsignal")
    Observable<Response<FourGSignalResponse>> get4Gsignal(@Path("sn") String sn);

    //获取相机上传bps（仅在有4g连接时可用）
    @GET("api/v1.0/devices/{sn}/streaming/bps")
    Observable<Response<BPSResponse>> getCameraBPS(@Path("sn") String sn);

    //直播时打 highlight
    @POST("api/v2.0/devices/{sn}/streaming/highlight")
    Observable<Response<BooleanResponse>> postHighlight(@Path("sn") String sn,
                                                        @Query("videoServer") String videoServer,
                                                        @Query("deviceID") String deviceID,
                                                        @Query("streamID") String streamID,
                                                        @Query("startTime") long startTime,
                                                        @Query("duration") long duration);


    /*------------------------------------------消息通知-------------------------------------------*/

    //打开／设置关闭推送
    @POST("api/v1.0/devices/{sn}/notifications")
    Observable<BooleanResponse> setNotify(@Path("sn") String sn, @Body NotificationSetting notification);

    //获取推送开关设置
    @GET("api/v1.0/devices/{sn}/notifications")
    Observable<NotificationSetting> getNotify(@Path("sn") String sn);

    //拉取所有推送
    @GET("api/v1.0/notifications")
    Observable<NotificationListResponse> getMessageList(@Query("cursor") Long cursor,
                                                        @Query("count") Integer count);

    //将用户全部推送置已读
    @POST("api/v1.0/notifications/mark_all_read")
    Observable<BooleanResponse> markAllMsgRead();

    //将用户指定推送置已读
    @POST("api/v1.0/notifications/{notificationID}/mark_read")
    Observable<BooleanResponse> markMsgRead(@Path("notificationID") Long notificationID);

    //将用户指定推送删除
    @DELETE("api/v1.0/notifications/{notifications}")
    Observable<BooleanResponse> deleteMsg(@Path("notifications") Long notifications);

    //拉取所有警报事件
    @GET("api/v1.0/events/alerts")
    Observable<AlertListResponse> getAlertList(@Query("cursor") Long cursor,
                                               @Query("count") Integer count);

    //将用户全部消息事件置已读
    @POST("api/v1.0/events/mark_all_read")
    Observable<EventResponse> markAllEventRead();

    //将用户指定消息事件置已读
    @POST("api/v1.0/events/{eventID}/mark_read")
    Observable<EventResponse> markEventRead(@Path("eventID") Long eventID);

    //将用户指定消息事件删除
    @DELETE("api/v1.0/events/{eventID}")
    Observable<EventResponse> deleteEvent(@Path("eventID") Long eventID);


    /*----------------------------------------用户反馈/举报-----------------------------------------*/

    @POST("api/v1.0/reports")
    Observable<BooleanResponse> report(@Body ReportFeedbackBody reportFeedbackBody);

    @POST("api/v2.0/reports")
    Observable<BooleanResponse> reportMultipart(@Body MultipartBody multipartBody);


    /*----------------------------------------地理位置-----------------------------------------*/

    //根据 GPS 查询具体地址信息
    @GET("api/v1.0/address")
    Observable<LocationResponse> getLocation(@Query("latitude") double latitude,
                                             @Query("longitude") double longitude);


    /*----------------------------------------firmware-----------------------------------------*/

    //获取firmware下载地址
    @GET("api/v1.0/firmwares")
    Observable<List<Firmware>> getFirmware();


    /*----------------------------------------流量套餐-----------------------------------------*/

    //获取指定设备最后订阅信息
    @GET("api/v1.0/devices/{sn}/current_subscription")
    Observable<SubscribeResponse> getCurrentSub(@Path("sn") String sn);

    //相机上报 iccid
    @POST("api/v1.0/devices/{sn}/report_iccid")
    Observable<Response<BooleanResponse>> reportID(@Path("sn") String sn, @Body ReportIdBody reportIdBody);//1


    /*--------------------------------------Waylens Share---------------------------------------*/

    @Headers("baseUrl:waylens")
    @POST("/api/users/signin")
    Observable<AuthorizeResponse> signinWaylens(@Body SignInPostBody signInPostBody);

    @Headers("baseUrl:waylens")
    @POST("/api/moments")
    Observable<CreateMomentResponse> createMoment(@Body CreateMomentBody createMomentBody);


    /*----------------------------------------语音-----------------------------------------*/

    //开始/停止 语音通话
    @POST("api/v1.0/devices/{sn}/audio")
    Observable<Response<AudioStreamResponse>> startAudio(@Path("sn") String sn, @Body LiveStreamBody body);

    //开始/停止 语音通话
    @POST("api/v1.0/devices/{sn}/audio")
    Observable<AudioStreamResponse> endAudio(@Path("sn") String sn, @Body LiveStreamBody body);

}
