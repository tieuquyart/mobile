package com.mk.autosecure;

import android.app.Application;
import android.content.Context;

import com.google.gson.Gson;
import com.mkgroup.camera.db.DaoMaster;
import com.mkgroup.camera.db.DaoSession;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.account.FleetInfo;

import java.util.concurrent.ExecutorService;

import javax.inject.Singleton;

import dagger.Component;

/**
 * Created by DoanVT on 2017/8/10.
 */

@Singleton
@Component(modules = {ApplicationModule.class})
public interface AppComponent {
    Context appContext();

    Application application();

    CurrentUser currentUser();

    ExecutorService backgroundThreadPool();

    Gson gson();

    EmailInfo emailInfo();

    FleetInfo fleetInfo();

    DaoSession daoSession();

    DaoMaster daoMaster();


}
