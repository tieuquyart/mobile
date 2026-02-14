package com.mkgroup.camera.event;

/**
 * Created by cloud on 2020/5/7.
 */
public class AppMismatchEvent {

    public enum App {
        Secure360, Fleet
    }

    private final App app;

    public AppMismatchEvent(App app) {
        this.app = app;
    }

    public App getApp() {
        return app;
    }
}
