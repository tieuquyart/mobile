package com.mk.autosecure.libs.account;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.request.BindPushBody;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mkgroup.camera.preference.SharedPreferenceKey;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.UserProfile;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.request.LogInPostBody;
import com.mk.autosecure.rest_fleet.response.LogInResponse;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.preference.StringPreferenceType;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;


/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */


public class CurrentUser extends CurrentUserType {
    public static final String TAG = CurrentUser.class.getSimpleName();

    private final StringPreferenceType accessTokenPreference;

    //private final DeviceRegistrarType deviceRegistrar;

    private final StringPreferenceType userPreference;

    private final StringPreferenceType fleetUserPreference;

    private final StringPreferenceType userLoginPreference;

    private final StringPreferenceType devicesPreference;

    private final StringPreferenceType fleetDevicesPreference;

    private final StringPreferenceType profilePreference;

    private final Gson gson;

    private final BehaviorSubject<Optional<User>> user = BehaviorSubject.create();

//    private final BehaviorSubject<Optional<FleetUser>> fleetUser = BehaviorSubject.create();

    private final BehaviorSubject<Optional<UserLogin>> userLogin = BehaviorSubject.create();

    private final BehaviorSubject<Optional<UserProfile>> userProfile = BehaviorSubject.create();

    private final BehaviorSubject<Optional<ArrayList<CameraBean>>> devices = BehaviorSubject.create();

    private final BehaviorSubject<Optional<List<FleetCameraBean>>> fleetDevices = BehaviorSubject.create();

    public CurrentUser(final @NonNull StringPreferenceType accessTokenPreference,
                       final @NonNull StringPreferenceType userPreference,
                       final @NonNull StringPreferenceType fleetUserPreference,
                       final @NonNull StringPreferenceType userLoginPreference,
                       final @NonNull StringPreferenceType devicesPreference,
                       final @NonNull StringPreferenceType fleetDevicesPreference,
                       final @NonNull StringPreferenceType profilePreference,
                       final @NonNull Gson gson) {
        this.accessTokenPreference = accessTokenPreference;
        this.userPreference = userPreference;
        this.fleetUserPreference = fleetUserPreference;
        this.userLoginPreference = userLoginPreference;
        this.devicesPreference = devicesPreference;
        this.fleetDevicesPreference = fleetDevicesPreference;
        this.profilePreference = profilePreference;
        this.gson = gson;

        user.skip(1)
                .filter(user -> user.getIncludeNull() != null)
                .subscribe(user -> userPreference.set(gson.toJson(user.get(), User.class)),
                        new ServerErrorHandler(TAG));

//        fleetUser.skip(1)
//                .filter(fleetUser -> fleetUser.getIncludeNull() != null)
//                .subscribe(fleetUser ->
//                                fleetUserPreference.set(gson.toJson(fleetUser.get(), FleetUser.class)),
//                        new ServerErrorHandler());

        userLogin.skip(1)
                .filter(userLogin -> userLogin.getIncludeNull() != null)
                .subscribe(userLogin -> userLoginPreference.set(gson.toJson(userLogin.get(), UserLogin.class)),
                        new ServerErrorHandler(TAG));

        this.user.onNext(Optional.ofNullable(gson.fromJson(userPreference.get(), User.class)));

        this.userLogin.onNext(Optional.ofNullable(gson.fromJson(userLoginPreference.get(), UserLogin.class)));

        this.devices.onNext(Optional.ofNullable(getDevices()));

        this.fleetDevices.onNext(Optional.ofNullable(getFleetDevices()));

        if (Constants.isFleet()) {
            UserLogin userLogin = getUserLogin();
            if (userLogin == null) {
//                fetchProfile();
            } else {
                this.userLogin.onNext(Optional.ofNullable(userLogin));
            }
        } else {
            UserProfile profile = getProfile();
            if (profile == null) {
//                fetchProfile();
            } else {
                this.userProfile.onNext(Optional.ofNullable(profile));
            }
        }
    }

    @Override
    public @Nullable
    User getUser() {
        return user.getValue().getIncludeNull();
    }

//    @Override
//    public @Nullable
//    FleetUser getFleetUser() {
//        return fleetUser.getValue().getIncludeNull();
//    }

    @Override
    public @Nullable
    UserLogin getUserLogin() {
        return userLogin.getValue().getIncludeNull();
    }

    @Override
    public boolean exists() {
        if (Constants.isFleet()) {
            return getUserLogin() != null;
        } else {
            return getUser() != null;
        }
    }

    public String getAccessToken() {
        return accessTokenPreference.get();
    }

    public List<FleetCameraBean> getFleetDevices() {
        List<FleetCameraBean> cameras = gson.fromJson(fleetDevicesPreference.get(),
                new TypeToken<List<FleetCameraBean>>() {
                }.getType());
        return cameras != null ? cameras : new ArrayList<>();
    }

    public ArrayList<CameraBean> getDevices() {
        ArrayList<CameraBean> cameras = gson.fromJson(devicesPreference.get(), new TypeToken<ArrayList<CameraBean>>() {
        }.getType());
        return cameras != null ? cameras : new ArrayList<>();
    }

    public boolean ownerDevice(String sn) {
        if (TextUtils.isEmpty(sn)) {
            return false;
        }

        if (Constants.isFleet()) {
            List<FleetCameraBean> fleetDevices = getFleetDevices();

            if (fleetDevices.size() != 0) {
                for (FleetCameraBean bean : fleetDevices) {
                    if (bean != null && bean.getSn().equals(sn)) {
                        return true;
                    }
                }
            }
        } else {
            ArrayList<CameraBean> devices = getDevices();

            if (devices.size() != 0) {
                for (CameraBean bean : devices) {
                    if (bean != null && bean.sn.equals(sn)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public CameraBean getCamera(String sn) {
        ArrayList<CameraBean> devices = getDevices();

        if (!TextUtils.isEmpty(sn) && devices.size() != 0) {
            for (CameraBean bean : devices) {
                if (bean != null && bean.sn.equals(sn)) {
                    return bean;
                }
            }
        }
        return null;
    }

    public FleetCameraBean getFleetCamera(String sn) {
        List<FleetCameraBean> fleetDevices = getFleetDevices();

        if (!TextUtils.isEmpty(sn) && fleetDevices.size() != 0) {
            for (FleetCameraBean bean : fleetDevices) {
                if (bean != null && bean.getSn().equals(sn)) {
                    return bean;
                }
            }
        }
        return null;
    }

    public void refreshFleetDevices(@NonNull List<FleetCameraBean> camerasBeans, boolean isForced) {
        //当本地相机名称与服务器相机名称不一致时，以服务器相机名称为准，并修改本地相机名称
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (currentCamera != null) {
//            for (CamerasInfoResponse.CamerasBean camera : camerasBeans) {
//                Logger.t("name").e("name: " + camera.getSerialNumber());
//                if (currentCamera.getSerialNumber().equals(camera.sn) && !currentCamera.getName().equals(camera.name)) {
//                    CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(camera.sn);
//                    if (cameraItem != null) {
//                        cameraItem.setCameraName(camera.name);
//                        LocalCameraDaoManager.getInstance().update(cameraItem);
//                    }
//                    Logger.t("name").e("setName: " + camera.name);
//                    currentCamera.setName(camera.name);
//                }
//            }
        }

        List<FleetCameraBean> oldCameras = getFleetDevices();
        fleetDevicesPreference.set(gson.toJson(camerasBeans, new TypeToken<List<FleetCameraBean>>() {
        }.getType()));
//        gps 坐标变化导致刷新camera item
        Logger.t(TAG).d("refreshFleetDevices: " + !oldCameras.containsAll(camerasBeans) + " isForced: " + isForced);
        if (oldCameras.size() != camerasBeans.size() || !oldCameras.containsAll(camerasBeans) || isForced) {
            fleetDevices.onNext(Optional.ofNullable(camerasBeans));
            Logger.t(TAG).d("refreshUser newCameras: " + camerasBeans);
        }
    }

    public void refreshDevices(@NonNull ArrayList<CameraBean> cameras, boolean isForced) {
        //当本地相机名称与服务器相机名称不一致时，以服务器相机名称为准，并修改本地相机名称
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (currentCamera != null) {
            for (CameraBean camera : cameras) {
                Logger.t("name").e("name: " + camera.name + "--" + camera.sn);
                if (currentCamera.getSerialNumber().equals(camera.sn) && !currentCamera.getName().equals(camera.name)) {
                    CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(camera.sn);
                    if (cameraItem != null) {
                        cameraItem.setCameraName(camera.name);
                        LocalCameraDaoManager.getInstance().update(cameraItem);
                    }
                    Logger.t("name").e("setName: " + camera.name);
                    currentCamera.setName(camera.name);
                }
            }
        }

        ArrayList<CameraBean> oldCameras = getDevices();
        devicesPreference.set(gson.toJson(cameras, new TypeToken<ArrayList<CameraBean>>() {
        }.getType()));
        //gps 坐标变化导致刷新camera item
        Logger.t(TAG).d("refreshDevices: " + !oldCameras.containsAll(cameras) + " isForced: " + isForced);
        if (oldCameras.size() != cameras.size() || !oldCameras.containsAll(cameras) || isForced) {
            devices.onNext(Optional.ofNullable(cameras));
            Logger.t(TAG).d("refreshUser Camera: " + cameras);
        }
    }

    public UserProfile getProfile() {
        return gson.fromJson(profilePreference.get(), new TypeToken<UserProfile>() {
        }.getType());
    }

//    public FleetUser getFleetProfile() {
//        return gson.fromJson(fleetUserPreference.get(), new TypeToken<FleetUser>() {
//        }.getType());
//    }

    public UserLogin getUserLoginProfile() {
        return gson.fromJson(userLoginPreference.get(), new TypeToken<UserLogin>() {
        }.getType());
    }

    public void refreshProfile(UserProfile profile) {
        if (profile != null && profile.userID != null && user.getValue() != null
                && profile.userID.equals(user.getValue().get().id())) {
            profilePreference.set(gson.toJson(profile, new TypeToken<UserProfile>() {
            }.getType()));
            userProfile.onNext(Optional.ofNullable(profile));

            User refreshUser = User.builder()
                    .id(profile.userID)
                    .name(profile.userName)
                    .avatar(profile.avatarUrl)
                    .displayName(profile.displayName)
                    .verified(profile.isVerified)
                    .build();
            userPreference.set(gson.toJson(refreshUser, User.class));
            user.onNext(Optional.ofNullable(refreshUser));
        }
    }

    public void refreshProfile(UserLogin user) {
        if (user != null) {
            userLoginPreference.set(gson.toJson(user, new TypeToken<UserLogin>() {
            }.getType()));
            userLogin.onNext(Optional.ofNullable(user));
        }
    }

    @Override
    public void login(final @NonNull User newUser, final @NonNull String accessToken) {
        Logger.t(TAG).d("login user: %s", newUser.name());
        userPreference.set(gson.toJson(newUser, User.class));
        accessTokenPreference.set(accessToken);
        user.onNext(Optional.ofNullable(newUser));

        boolean onceLoggedIn = PreferenceUtils.getOnceLoggedIn();
        if (!onceLoggedIn && newUser.verified()) {
            PreferenceUtils.setOnceLoggedIn(true);
        }

//        fetchProfile();
    }

    @Override
    public void login(@NonNull String accessToken) {

    }

    @Override
    public void login(@NonNull LogInResponse logInResponse) {

        if (logInResponse.isSuccess()) {
            UserLogin _userLogin = logInResponse.getUserLogin();
            Logger.t(TAG).d("login fleetUser: " + _userLogin.getToken());
            accessTokenPreference.set(_userLogin.getToken());

            boolean onceLoggedIn = PreferenceUtils.getOnceLoggedIn();
            if (!onceLoggedIn) {
                PreferenceUtils.setOnceLoggedIn(true);
            }
            String[] roles = _userLogin.getRoleNames();
            Logger.t(TAG).d("user roles: " + roles);

            if (roles != null && roles.length > 0) {
                PreferenceUtils.putString(Constants.AUTOSECURE_ROLES,roles[0]);
            }

            userLoginPreference.set(gson.toJson(_userLogin, new TypeToken<UserLogin>() {
            }.getType()));
            userLogin.onNext(Optional.ofNullable(_userLogin));
        }else{
            NetworkErrorHelper.handleExpireToken(HornApplication.getContext(),logInResponse);
        }
    }

    @SuppressLint("CheckResult")
    private void fetchProfile() {
        if (Constants.isFleet()) {
            LogInPostBody body = new LogInPostBody("doanvt", "doanvt");
            ApiClient.createApiService().logInFleet(body)
                    .subscribeOn(Schedulers.io())
                    .subscribe(response -> {
                        Logger.t(TAG).d("getUserInfo: " + response.body().getUserLogin().getUserName());
                        if(response.isSuccessful()){
                            PreferenceUtils.putBoolean(Constants.KEY_IS_LOGIN,true);
                            UserLogin _userLogin = response.body().getUserLogin();
                            accessTokenPreference.set(_userLogin.getToken());

                            boolean onceLoggedIn = PreferenceUtils.getOnceLoggedIn();
                            if (!onceLoggedIn) {
                                PreferenceUtils.setOnceLoggedIn(true);
                            }
                            if (_userLogin != null) {
                                String[] roles = _userLogin.getRoleNames();
                                Logger.t(TAG).d("user roles: " + roles);

                                if (roles != null && roles.length > 0) {
//                                    if (roles.equals(FLEET_ROLE_ADMIN)) {
//                                        PreferenceUtils.putString(PreferenceUtils.KEY_FLEET_ROLE, FLEET_ROLE_ADMIN);
//                                    } else if (roles.equals(FLEET_ROLE_USER)) {
//                                        PreferenceUtils.putString(PreferenceUtils.KEY_FLEET_ROLE, FLEET_ROLE_USER);
//                                    }
                                    PreferenceUtils.putString(Constants.AUTOSECURE_ROLES,roles[0]);
                                }

                                userLoginPreference.set(gson.toJson(response.body().getUserLogin(), new TypeToken<UserLogin>() {
                                }.getType()));
                                userLogin.onNext(Optional.ofNullable(response.body().getUserLogin()));
                            }
                        }
                    }, new ServerErrorHandler(TAG));
        } else {
            ApiService.createApiService().getMyProfile()
                    .subscribeOn(Schedulers.io())
                    .subscribe(data -> {
                        Logger.t(TAG).d("getMyProfile: " + data.toString());
                        profilePreference.set(gson.toJson(data, new TypeToken<UserProfile>() {
                        }.getType()));
                        userProfile.onNext(Optional.ofNullable(data));
                    }, new ServerErrorHandler(TAG));
        }
    }

    @SuppressLint("CheckResult")
    @Override
    public void logout() {
        logoutAfter();
        /*
        BindPushBody body = new BindPushBody("android", "doanvt-android");
        ApiClient.createApiService().bindPushDevice(body, HornApplication.getComponent().currentUser().getAccessToken())
                .subscribeOn(Schedulers.io())
                .subscribe(boolResponse -> {
                    Logger.t(TAG).d("bindPushToken res: " + boolResponse);
                    PreferenceUtils.putString("doanvt-android", SharedPreferenceKey.PUSH_DEVICE);

                    logoutAfter();
                }, throwable -> logoutAfter());*/

        //deviceRegistrar.unregisterDevice();
    }

    private void logoutAfter(){

        HornApplication.getComponent().fleetInfo().clearCache();
        PreferenceUtils.putBoolean(Constants.KEY_IS_LOGIN,false);
        Logger.t(TAG).d("Logout current user");
        userPreference.delete();
        profilePreference.delete();
        devicesPreference.delete();
        user.onNext(Optional.empty());
        userProfile.onNext(Optional.empty());
        devices.onNext(Optional.ofNullable(new ArrayList<>()));

        fleetUserPreference.delete();
        userLoginPreference.delete();
        fleetDevicesPreference.delete();
        userLogin.onNext(Optional.empty());
        fleetDevices.onNext(Optional.ofNullable(new ArrayList<>()));

        if (Constants.isFleet()) {
            Log.d(TAG, "Token:= " + getAccessToken());
            ApiClient.createApiService().logout(getAccessToken())
                    .subscribeOn(Schedulers.io())
                    .doFinally(accessTokenPreference::delete)
                    .subscribe(booleanRs->{
                        if (!booleanRs.isSuccess()){
                        }
                    }, throwable -> new ServerErrorHandler());
        } else {
            ApiService.createApiService().signout()
                    .subscribeOn(Schedulers.io())
                    .doFinally(accessTokenPreference::delete)
                    .subscribe();
        }
    }

    @Override
    public void refreshUser(final @NonNull User freshUser) {
        user.onNext(Optional.ofNullable(freshUser));
    }

    @Override
    public void refreshUserLogin(final @NonNull UserLogin user) {
        userLogin.onNext(Optional.ofNullable(user));
    }

    @NonNull
    public Observable<Optional<User>> observable() {
        return user;
    }

    @NonNull
    public Observable<Optional<UserLogin>> userLoginObservable() {
        return userLogin;
    }

    public Observable<Optional<ArrayList<CameraBean>>> devicesObservable() {
        return devices;
    }

    public Observable<Optional<List<FleetCameraBean>>> fleetDevicesObservable() {
        return fleetDevices;
    }

    public Observable<Optional<UserProfile>> profileObservable() {
        return userProfile;
    }
}
