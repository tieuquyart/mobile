package com.mk.autosecure.rest_fleet;

import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.DriverStatusReportResponse;
import com.mk.autosecure.rest.reponse.LiveStatusResponse;
import com.mk.autosecure.rest.reponse.ResetPwdBody;
import com.mk.autosecure.rest.reponse.StringResponse;
import com.mk.autosecure.rest.request.CheckSerialBody;
import com.mk.autosecure.rest.request.FleetNewPostBody;
import com.mk.autosecure.rest.request.LiveStreamBody;
import com.mk.autosecure.rest.request.ResetPwdEmailBody;
import com.mk.autosecure.rest.request.SignUpPostBody;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.rest_fleet.bean.VideoUrlBean;
import com.mk.autosecure.rest_fleet.request.AddFenceBody;
import com.mk.autosecure.rest_fleet.request.AddFenceRuleBody;
import com.mk.autosecure.rest_fleet.request.BindCameraBody;
import com.mk.autosecure.rest_fleet.request.BindDriverBody;
import com.mk.autosecure.rest_fleet.request.BindPushBody;
import com.mk.autosecure.rest_fleet.request.CreateCameraBody;
import com.mk.autosecure.rest_fleet.request.CreateDriverBody;
import com.mk.autosecure.rest_fleet.request.CreateInstallerBody;
import com.mk.autosecure.rest_fleet.request.CreateVehicleBody;
import com.mk.autosecure.rest_fleet.request.DrivingTimeBody;
import com.mk.autosecure.rest_fleet.request.EditDriverBody;
import com.mk.autosecure.rest_fleet.request.EditVehicleBody;
import com.mk.autosecure.rest_fleet.request.LogInPostBody;
import com.mk.autosecure.rest_fleet.request.ModifyPwdBody;
import com.mk.autosecure.rest_fleet.request.PhoneNoBody;
import com.mk.autosecure.rest_fleet.request.SettingBody;
import com.mk.autosecure.rest_fleet.request.TotalExportBody;
import com.mk.autosecure.rest_fleet.request.UserBody;
import com.mk.autosecure.rest_fleet.request.UserRoleBody;
import com.mk.autosecure.rest_fleet.request.VehicleFleetBody;
import com.mk.autosecure.rest_fleet.response.ActivateResponse;
import com.mk.autosecure.rest_fleet.response.AddFenceResponse;
import com.mk.autosecure.rest_fleet.response.AddFenceRuleResponse;
import com.mk.autosecure.rest_fleet.response.AppLastVersionResponse;
import com.mk.autosecure.rest_fleet.response.AudioStreamResponse;
import com.mk.autosecure.rest_fleet.response.BillingDataResponse;
import com.mk.autosecure.rest_fleet.response.CameraEventsResponse;
import com.mk.autosecure.rest_fleet.response.CameraResponse;
import com.mk.autosecure.rest_fleet.response.DashDriverResponse;
import com.mk.autosecure.rest_fleet.response.DashFleetResponse;
import com.mk.autosecure.rest_fleet.response.DataUsageResponse;
import com.mk.autosecure.rest_fleet.response.DeviceInfoResponse;
import com.mk.autosecure.rest_fleet.response.DeviceListResponse;
import com.mk.autosecure.rest_fleet.response.DriverListResponse;
import com.mk.autosecure.rest_fleet.response.DriverPageResponse;
import com.mk.autosecure.rest_fleet.response.FenceListResponse;
import com.mk.autosecure.rest_fleet.response.FenceRuleListResponse;
import com.mk.autosecure.rest_fleet.response.FirmwareResponse;
import com.mk.autosecure.rest_fleet.response.FleetViewResponse;
import com.mk.autosecure.rest_fleet.response.InstallerResponse;
import com.mk.autosecure.rest_fleet.response.LastLocationResponse;
import com.mk.autosecure.rest_fleet.response.LogInResponse;
import com.mk.autosecure.rest_fleet.response.NotificationInfoResponse;
import com.mk.autosecure.rest_fleet.response.NotificationResponse;
import com.mk.autosecure.rest_fleet.response.NotificationV2Response;
import com.mk.autosecure.rest_fleet.response.RolesResponse;
import com.mk.autosecure.rest_fleet.response.StatisticResponse;
import com.mk.autosecure.rest_fleet.response.StreamBpsResponse;
import com.mk.autosecure.rest_fleet.response.TimelineResponse;
import com.mk.autosecure.rest_fleet.response.TracksResponse;
import com.mk.autosecure.rest_fleet.response.TripsResponse;
import com.mk.autosecure.rest_fleet.response.UnreadResponse;
import com.mk.autosecure.rest_fleet.response.UserListResponse;
import com.mk.autosecure.rest_fleet.response.VehicleInfoResponse;
import com.mk.autosecure.rest_fleet.response.VehicleListResponse;

import io.reactivex.Observable;
import okhttp3.MultipartBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface FleetApiClient {

    //session
    @POST("api/sessions/login")
    Observable<Response<LogInResponse>> logInFleet(@Body LogInPostBody body);

    //logout - x-access-token
    @POST("api/sessions/logout")
    Observable<BOOLResponse> logout(@Header("x-access-token") String token);

    //pwdChange
    @POST("api/sessions/passwordchange")
    Observable<Response<BOOLResponse>> changePwd(@Header("x-access-token") String token, @Body ModifyPwdBody body);

    // Do not use
    @POST("users/passWord")
    Observable<Response<BooleanResponse>> modifyPwd(@Body ModifyPwdBody body);

    @POST("api/admin/fleet/createFleet")
    Observable<Response<BOOLResponse>> createFleet(@Body FleetNewPostBody fleetNewPostBody);

    @POST("api/admin/fleet-user/register")
    Observable<Response<BOOLResponse>> signUp(@Body SignUpPostBody signUpPostBody);

    @POST("api/admin/camera/checkserial")
    Observable<BOOLResponse> checkSerial(@Body CheckSerialBody serial);

    //resetpassForEmail
    @POST("users/send_passwordreset_email")
    Observable<Response<BooleanResponse>> sendResetPasswordEmail(@Body ResetPwdEmailBody body);

    //resetpass
    @POST("api/admin/fleet-user/resetpassword")
    Observable<Response<BOOLResponse>> resetPassword(@Body ResetPwdBody resetPwdBody);
    //end

    //获取车队相机信息列表
    @GET("api/admin/camera/list")
    Observable<CameraResponse> getCameras(@Header("x-access-token") String token);

    //get fleet-view page
    @GET("api/admin/fleet-view/page")
    Observable<FleetViewResponse> getFleetView(@Query("currentPage") int currentPage, @Query("orderRule") int orderRule, @Query("pageSize") int pageSize, @Query("searchDate") String searchDate, @Header("x-access-token") String token);

    //getTrips
    @GET("api/admin/fleet-view/{cameraSn}/trips")
    Observable<TripsResponse> getTrips(@Path("cameraSn") String cameraSn, @Query("searchDate") String searchDate, @Header("x-access-token") String token);

    //get all event for trips id.
    @GET("api/admin/fleet-view/trip/{tripId}/events")
    Observable<CameraEventsResponse> getAllEventsForOneTrip(@Path("tripId") String tripId, @Header("x-access-token") String token);

    //get track for tripId
    @GET("api/admin/fleet-view/{cameraSn}/{tripId}/track")
    Observable<TracksResponse> getTrack(@Path("cameraSn") String cameraSn, @Path("tripId") String tripId, @Header("x-access-token") String token);

    //get events
    @GET("api/admin/fleet-view/{cameraSn}/events")
    Observable<CameraEventsResponse> getEvents(@Path("cameraSn") String cameraSn, @Query("searchEndDate") String searchEndDate, @Query("searchStartDate") String searchStartDate, @Header("x-access-token") String token);


    //get temporary video link of one event
    @GET("api/admin/events/video/{id}")
    Observable<VideoUrlBean> getVideoUrl(@Path("id") int id, @Header("x-access-token") String token);


    //相机安装阶段，通过app上报rotate配置信息
    @POST("fleet/devices/{sn}/manual_configure")
    Observable<BooleanResponse> uploadRotate(@Path("sn") String sn, @Body SettingBody body);

    //start - live
    @GET("api/admin/fleet-view/{sn}/start-live")
    Observable<LiveStatusResponse> startLive(@Path("sn") String sn, @Header("x-access-token") String token);

    //live - status
    @GET("api/admin/fleet-view/{sn}/live-status")
    Observable<LiveStatusResponse> getLiveStatus(@Path("sn") String sn, @Header("x-access-token") String token);


    //upload-status
    @GET("api/admin/fleet-view/{sn}/live/upload-status")
    Observable<Response<StreamBpsResponse>> getCameraBPS(@Path("sn") String sn, @Header("x-access-token") String token);


    /*------------------------------------------Notification-------------------------------------------*/
    /*bind token push*/
    @POST("api/sessions/bindPushDevice")
    Observable<BOOLResponse>bindPushDevice(@Body BindPushBody body, @Header("x-access-token") String token);

    /*get list notification*/
    @GET("api/admin/user-notification/list")
    Observable<NotificationResponse> getNotificationList(@Header("x-access-token") String token);

    @GET("api/admin/user-notification/page")
    Observable<NotificationV2Response> getNotificationPage(@Query("page") int currentPage, @Query("size") int pageSize, @Header("x-access-token") String token);

    @GET("api/admin/user-notification/page/{category}")
    Observable<NotificationV2Response> getNotificationPageWithCategory(@Path("category") String category, @Query("page") int currentPage, @Query("size") int pageSize, @Header("x-access-token") String token);

    /*get info with id*/
    @GET("api/admin/user-notification/info/{notificationId}")
    Observable<NotificationInfoResponse>getInfoNotification(@Path("notificationId") String notificationId, @Header("x-access-token") String token);

    /*
    getAppLastVersion
    * */
    @GET("api/admin/user-notification/infoApp/android")
    Observable<AppLastVersionResponse>getAppLastVersion();

    /*----------------------------------------流量套餐-----------------------------------------*/

    //获取指定设备 当前套餐信息
    @GET("fleet/devices/{sn}/datausage")
    Observable<DataUsageResponse> getCurrentSub(@Path("sn") String sn);


    /*----------------------------------------firmware-----------------------------------------*/

    //获取相机固件升级信息
    @GET("fleet/devices/{sn}/manual_upgrade_firmware")
    Observable<FirmwareResponse> getFirmware(@Path("sn") String sn);


    /*----------------------------------------语音-----------------------------------------*/

    //开始/停止 语音通话
    @POST("fleet/devices/{sn}/audio")
    Observable<Response<AudioStreamResponse>> startAudio(@Path("sn") String sn, @Body LiveStreamBody body);

    //开始/停止 语音通话
    @POST("fleet/devices/{sn}/audio")
    Observable<AudioStreamResponse> endAudio(@Path("sn") String sn, @Body LiveStreamBody body);


    /*-------------------------------------Fleet v1.0---------------------------------------*/

    //（以driver为单位）获取车队车辆最后的状态和位置
    @GET("fleet/drivers/vehicle_last_location")
    Observable<LastLocationResponse> getLastLocation();

    /*-------------------------------------Dashboard---------------------------------------*/

    //获取车队整体的统计信息
    @GET("fleet/statistic/all")
    Observable<StatisticResponse> getAllDash(@Query("from") long from, @Query("to") long to,
                                             @Query("dstTime") long dstTime, @Query("dstOffset") long dstOffset);

    //按司机获取车队的统计信息列表
    @GET("fleet/statistic/list")
    Observable<DashFleetResponse> getDashFleet(@Query("from") long from, @Query("to") long to);

    //获取某个司机的的统计信息
    @GET("fleet/statistic/driver/{driverID}")
    Observable<DashDriverResponse> getDashDriver(@Path("driverID") String driverID,
                                                 @Query("from") long from, @Query("to") long to,
                                                 @Query("dstTime") long dstTime, @Query("dstOffset") long dstOffset);


    //getStatusReport
    @GET("api/admin/report/driver-status-report")
    Observable<DriverStatusReportResponse> getStatusReport(@Query("startTime") String startTime, @Query("endTime") String endTime, @Query("pageSize") int pageSize, @Query("currentPage") int currentPage, @Header("x-access-token") String token);

    @GET("api/admin/report/driver-status-report/{driverId}")
    Observable<DriverStatusReportResponse> getStatusReportWithDriverId(@Path("driverId") int driverId, @Query("startTime") String startTime, @Query("endTime") String endTime, @Query("pageSize") int pageSize, @Query("currentPage") int currentPage, @Header("x-access-token") String token);

    @POST("/api/admin/excel/vehicleFleet")
    Observable<Response<ResponseBody>> vehicleFleet(@Body VehicleFleetBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/vehicleSpeed")
    Observable<Response<ResponseBody>> vehicleSpeed(@Body VehicleFleetBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/stopVehicle")
    Observable<Response<ResponseBody>> stopVehicle(@Body VehicleFleetBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/drivingTime")
    Observable<Response<ResponseBody>> drivingTime(@Body DrivingTimeBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/overSpeed")
    Observable<Response<ResponseBody>> overSpeed(@Body VehicleFleetBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/detailPicture")
    Observable<Response<ResponseBody>> detailPicture(@Body VehicleFleetBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/b51")
    Observable<Response<ResponseBody>> b51Report(@Body TotalExportBody body, @Header("x-access-token") String token);

    @POST("/api/admin/excel/b52")
    Observable<Response<ResponseBody>> b52report(@Body TotalExportBody body, @Header("x-access-token") String token);

    /*-------------------------------------Timeline---------------------------------------*/

    //获取司机的timeline
    @GET("fleet/timeline/{driverID}")
    Observable<TimelineResponse> getTimeline(@Path("driverID") String driverID,
                                             @Query("from") long from, @Query("to") long to);

    //获取整个车队的通知列表
    @GET("fleet/notificationList")
    Observable<NotificationResponse> getNotificationList(@Query("from") long from, @Query("to") long to);

    //设置通知已读
    @POST("/api/admin/user-notification/read/{notificationId}")
    Observable<BOOLResponse> markReadNotification(@Path("notificationId") String notiId, @Header("x-access-token") String token);

    //获取登录账号在指定时间范围内未读消息个数
    @GET("/api/admin/user-notification/unread-total")
    Observable<UnreadResponse> getUnreadNotification(/*@Query("fromTime") String from, @Query("toTime") String to,*/ @Header("x-access-token") String token);


    /*-------------------------------------Personnel Management---------------------------------------*/

    //getAllRole
    @GET("api/admin/roles")
    Observable<RolesResponse> getRoles(@Header("x-access-token") String token);

    @PUT("api/admin/userroles/{userId}")
    Observable<BOOLResponse> updateUserRole(@Path("userId") int userId, @Body UserRoleBody body, @Header("x-access-token") String token);

    //add driver
    @POST("api/admin/driver")
    Observable<BOOLResponse> addNewDriver(@Body CreateDriverBody body, @Header("x-access-token") String token);

    //get driver list
    @GET("api/admin/driver/list")
    Observable<DriverListResponse> getDriverList(@Header("x-access-token") String token);

    @GET("api/admin/driver/page")
    Observable<DriverPageResponse> getDriverPageInfo(@Query("current") int current, @Query("size") int size, @Header("x-access-token") String token);

    //edit driver
    @PUT("api/admin/driver/{driverId}")
    Observable<BOOLResponse> editDriver(@Path("driverId") int driverId, @Body EditDriverBody body, @Header("x-access-token") String token);

    @DELETE("api/admin/driver/{driverId}")
    Observable<BOOLResponse> delDriver(@Path("driverId") int driverId, @Header("x-access-token") String token);

    //getAllUser
    @GET("api/admin/users")
    Observable<UserListResponse> getUserList(@Header("x-access-token") String token);

    @POST("api/admin/users")
    Observable<BOOLResponse> addUser(@Body UserBody body, @Header("x-access-token") String token);

    @PUT("api/admin/users/{userId}")
    Observable<BOOLResponse> updateUser(@Path("userId") int userId, @Body UserBody body, @Header("x-access-token") String token);

    @POST("api/admin/users/{userId}/passwordreset")
    Observable<StringResponse> resetPassWord(@Path("userId") int userId, @Header("x-access-token") String token);

    @DELETE("api/admin/users/{userId}")
    Observable<BOOLResponse> delUser(@Path("userId") int userId, @Header("x-access-token") String token);


    /*-------------------------------------Asset Management---------------------------------------*/

    //getVehiclePage
    @GET("api/admin/vehicle/page")
    Observable<VehicleInfoResponse> getVehiclePage(@Query("current") int current, @Query("size") int size, @Header("x-access-token") String token);

    //getVehicleList
    @GET("api/admin/vehicle/list")
    Observable<VehicleListResponse> getVehicleList(@Header("x-access-token") String token);

    //edit vehicle
    @PUT("api/admin/vehicle/{id}")
    Observable<BOOLResponse> editVehicle(@Path("id") int id, @Body EditVehicleBody body, @Header("x-access-token") String token);

    //add vehicle
    @POST("api/admin/vehicle")
    Observable<BOOLResponse> createVehicle(@Body CreateVehicleBody body, @Header("x-access-token") String token);


    //delete vehicle
    @DELETE("api/admin/vehicle/{id}")
    Observable<BOOLResponse> deleteVehicleInfo(@Path("id") int id, @Header("x-access-token") String token);
//

    //assign driver
    @POST("api/admin/vehicle/assign-driver/{id}")
    Observable<BOOLResponse> assignVehicleDriver(@Path("id") int id, @Body BindDriverBody body, @Header("x-access-token") String token);


    //assign camera
    @POST("api/admin/vehicle/associated-camera/{id}")
    Observable<BOOLResponse> assignVehicleCamera(@Path("id") int id, @Body BindCameraBody body, @Header("x-access-token") String token);


    //add camera
    @POST("api/admin/camera")
    Observable<BOOLResponse> addNewCamera(@Body CreateCameraBody body, @Header("x-access-token") String token);

    //get pageCamera
    @GET("api/admin/camera/pageInfo")
    Observable<DeviceInfoResponse> getDevicePageInfo(@Query("current") int current, @Query("size") int size, @Header("x-access-token") String token);

    //get pageCamera
    @GET("api/admin/camera/list")
    Observable<DeviceListResponse> getDeviceList(@Header("x-access-token") String token);

    //edit camera
    @PUT("api/admin/camera/{id}")
    Observable<BOOLResponse> modifyCamera(@Path("id") int cameraId, @Body CreateCameraBody body, @Header("x-access-token") String token);

    //delete camera
    @DELETE("api/admin/camera/{id}")
    Observable<BOOLResponse> deleteCamera(@Path("id") int cameraId, @Header("x-access-token") String token);

    //active camera
    @POST("api/admin/camera/register/{id}")
    Observable<BOOLResponse> activeCamera(@Path("id") int cameraId, @Header("x-access-token") String token);

    //绑定车辆和相机
    @POST("usersManagement/bind/vehicleCamera")
    Observable<BooleanResponse> bindVehicleCamera(@Body BindCameraBody body);

    //绑定车辆和相机
    @POST("usersManagement/bind/vehicleCamera")
    Call<BooleanResponse> bindVehicleCameraSync(@Body BindCameraBody body);

    //解绑车辆和相机
    @POST("usersManagement/unbind/vehicleCamera")
    Observable<BooleanResponse> unbindVehicleCamera(@Body BindCameraBody body);

    //activate camera's SIM card激活相机
    @POST("fleet/devices/{sn}/activatesim")
    Observable<ActivateResponse> activateSim(@Path("sn") String sn);

    //de-activate camera's SIM card 停用相机sim卡
    @POST("fleet/devices/{sn}/deactivatesim")
    Observable<ActivateResponse> deactivateSim(@Path("sn") String sn);

    //获取车队历史流量账单
    @GET("fleet/billing/invoices/history")
    Observable<BillingDataResponse> getHistoryDataBilling();

    //获取车队当前流量账单
    @GET("fleet/billing/invoices")
    Observable<BillingDataBean> getNowDataBilling();


    /*----------------------------------------用户反馈-----------------------------------------*/

    //上传log
    @POST("reports/upload")
    Observable<BooleanResponse> reportMultipart(@Body MultipartBody body);


    /*----------------------------------------geo-fencing-----------------------------------------*/

    //获取geofence图形列表
    @GET("fleet/geoFence/fenceList")
    Observable<FenceListResponse> getFenceList(@Query("type") String type);

    //获取geofence规则列表
    @GET("fleet/geoFence/fenceRuleList")
    Observable<FenceRuleListResponse> getFenceRuleList();

    //通过fenceID查询一个geofence的图形信息
    @GET("fleet/geoFence/fence/{fenceID}")
    Observable<FenceDetailBean> getFenceDetail(@Path("fenceID") String fenceID);

    //通过fenceRuleID获取geofence规则信息
    @GET("fleet/geoFence/fenceRule/{fenceRuleID}")
    Observable<FenceRuleBean> getFenceRuleDetail(@Path("fenceRuleID") String fenceRuleID);

    //添加 geofence 图形
    @POST("fleet/geoFence/fence")
    Observable<AddFenceResponse> addFence(@Body AddFenceBody body);

    //添加 geofence 规则
    @POST("fleet/geoFence/fenceRule")
    Observable<AddFenceRuleResponse> addFenceRule(@Body AddFenceRuleBody body);

    //删除 geoFence图形
    @DELETE("fleet/geoFence/fence/{fenceID}")
    Observable<BooleanResponse> deleteFence(@Path("fenceID") String fenceID);

    //删除 geoFence规则
    @DELETE("/fleet/geoFence/fenceRule/{fenceRuleID}")
    Observable<BooleanResponse> deleteFenceRule(@Path("fenceRuleID") String fenceRuleID);

    //编辑geoFence rule属性
    @POST("fleet/geoFence/fenceRule/{fenceRuleID}")
    Observable<BooleanResponse> editFenceRule(@Path("fenceRuleID") String fenceRuleID, @Body AddFenceRuleBody body);

    //创建installer
    @POST("usersManagement/installerInfo")
    Observable<InstallerResponse> createInstaller(@Body CreateInstallerBody body);

    //doanvt

    //update phone number to FMS
    @POST("api/admin/camera/updateMobile")
    Observable<BOOLResponse>updatePhoneNo(@Body PhoneNoBody body, @Header("x-access-token") String token);
}
