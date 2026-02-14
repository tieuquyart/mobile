package com.mk.autosecure;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import androidx.annotation.NonNull;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mkgroup.camera.db.DaoMaster;
import com.mkgroup.camera.db.DaoSession;
import com.mkgroup.camera.db.MySQLiteOpenHelper;
import com.mkgroup.camera.preference.SharedPreferenceKey;
import com.mkgroup.camera.preference.StringPreference;
import com.mkgroup.camera.preference.StringPreferenceType;
import com.mk.autosecure.libs.AutoParcelAdapterFactory;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.account.FleetInfo;
import com.mk.autosecure.libs.qualifiers.AccessTokenPreference;
import com.mk.autosecure.libs.qualifiers.DevicesPreference;
import com.mk.autosecure.libs.qualifiers.EmailPreference;
import com.mk.autosecure.libs.qualifiers.FleetDevicePreference;
import com.mk.autosecure.libs.qualifiers.FleetDevicesPreference;
import com.mk.autosecure.libs.qualifiers.FleetDriverPreference;
import com.mk.autosecure.libs.qualifiers.FleetUserPreference;
import com.mk.autosecure.libs.qualifiers.FleetVehiclePreference;
import com.mk.autosecure.libs.qualifiers.ProfilePreference;
import com.mk.autosecure.libs.qualifiers.UserLoginPreference;
import com.mk.autosecure.libs.qualifiers.UserPreference;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;


/**
 * Created by DoanVT on 2017/8/10.
 * Email: doanvt-hn@mk.com.vn
 */

@Module
public final class ApplicationModule {
    private final Application application;

    public ApplicationModule(final @NonNull Application application) {
        this.application = application;
    }

    @Provides
    @Singleton
    ExecutorService provideExecutorService() {
        return new ThreadPoolExecutor(0, 4, 30, TimeUnit.SECONDS, new SynchronousQueue<Runnable>());
    }

    @Provides
    @Singleton
    DaoSession provideDaoSession() {
        return provideDaoMaster().newSession();
    }

    @Provides
    @Singleton
    DaoMaster provideDaoMaster() {
//        MigrationHelper.DEBUG = true;
        MySQLiteOpenHelper helper = new MySQLiteOpenHelper(application, "camera.db", null);
        return new DaoMaster(helper.getWritableDatabase());
    }

    @Provides
    @Singleton
    Application provideApplication() {
        return application;
    }

    @Provides
    @Singleton
    Context provideApplicationContext() {
        return application;
    }

    @Provides
    @Singleton
    EmailInfo provideEmailInfo(@EmailPreference StringPreference emailPreference, Gson gson) {
        return new EmailInfo(emailPreference, gson);
    }

    @Provides
    @Singleton
    FleetInfo provideFleetInfo(@FleetVehiclePreference StringPreference vehiclePreference,
                               @FleetDevicePreference StringPreference devicePreference,
                               @FleetDriverPreference StringPreference driverPreference,
                               Gson gson) {
        return new FleetInfo(vehiclePreference, devicePreference, driverPreference, gson);
    }

    @Provides
    @Singleton
    CurrentUser provideCurrentUser(@AccessTokenPreference StringPreferenceType accessTokenPreference,
                                   @UserPreference StringPreferenceType userPreference,
                                   @FleetUserPreference StringPreferenceType fleetUserPreference,
                                   @DevicesPreference StringPreferenceType devicesPreference,
                                   @FleetDevicesPreference StringPreferenceType fleetDevicesPreference,
                                   @UserLoginPreference StringPreferenceType userLoginPreference,
                                   @ProfilePreference StringPreferenceType profilePreference, Gson gson) {
        return new CurrentUser(accessTokenPreference, userPreference, fleetUserPreference, devicesPreference, fleetDevicesPreference, userLoginPreference, profilePreference, gson);
    }

    @Provides
    @Singleton
    Gson provideGson() {
        return new GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .registerTypeAdapterFactory(new AutoParcelAdapterFactory())
                .create();
    }


    @Provides
    @Singleton
    SharedPreferences provideSharedPreferences() {
        return PreferenceManager.getDefaultSharedPreferences(application);
    }

    @Provides
    @Singleton
    @AccessTokenPreference
    StringPreferenceType provideAccessTokenPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.ACCESS_TOKEN);
    }

    @Provides
    @Singleton
    @UserPreference
    StringPreferenceType provideUserPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.USER);
    }

    @Provides
    @Singleton
    @FleetUserPreference
    StringPreferenceType provideFleetUserPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.FLEET_USER);
    }

    @Provides
    @Singleton
    @UserLoginPreference
    StringPreferenceType provideUserLoginPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, "user_login");
    }

    @Provides
    @Singleton
    @DevicesPreference
    StringPreferenceType provideDevicesPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.DEVICES);
    }

    @Provides
    @Singleton
    @FleetDevicesPreference
    StringPreferenceType provideFleetDevicesPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.FLEET_DEVICES);
    }


    @Provides
    @Singleton
    @ProfilePreference
    StringPreferenceType provideProfilePreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.PROFILE);
    }

    @Provides
    @Singleton
    @EmailPreference
    StringPreference provideEmailPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.EMAIL);
    }

    @Provides
    @Singleton
    @FleetVehiclePreference
    StringPreference provideFleetVehiclePreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.FLEET_VEHICLE);
    }

    @Provides
    @Singleton
    @FleetDevicePreference
    StringPreference provideFleetDevicePreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.FLEET_DEVICE);
    }

    @Provides
    @Singleton
    @FleetDriverPreference
    StringPreference providerFleetDriverPreference(final @NonNull SharedPreferences sharedPreferences) {
        return new StringPreference(sharedPreferences, SharedPreferenceKey.FLEET_DRIVER);
    }
}
