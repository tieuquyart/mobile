package com.mk.autosecure.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.util.SparseArray;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.mk.autosecure.R;
import com.waylens.vrlib.MDVRLibrary;

/**
 * Created by DoanVT on 2017/7/25.
 */

public abstract class MD360PlayerActivity extends Activity {

    private static final String TAG = "MD360PlayerActivity";

    private static final SparseArray<String> sProjectionMode = new SparseArray<>();

    static {

        sProjectionMode.put(MDVRLibrary.PROJECTION_MODE_DOME220_UPPER,"DOME 220 UPPER");
        sProjectionMode.put(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS,"CUSTOM DOUBLE DIRECTIONS");

    }

    private MDVRLibrary mVRLibrary;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // no title
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        // full screen
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // set content view
        setContentView(R.layout.activity_md_using_surface_view);

        // init VR Library
        mVRLibrary = createVRLibrary();

        SpinnerHelper.with(this)
                .setData(sProjectionMode)
                .setDefault(mVRLibrary.getProjectionMode())
                .setClickHandler(new SpinnerHelper.ClickHandler() {
                    @Override
                    public void onSpinnerClicked(int index, int key, String value) {
                        mVRLibrary.switchProjectionMode(MD360PlayerActivity.this, key);
                    }
                })
                .init(R.id.spinner_projection);

    }

    abstract protected MDVRLibrary createVRLibrary();

    public MDVRLibrary getVRLibrary() {
        return mVRLibrary;
    }

    @Override
    protected void onResume() {
        super.onResume();
        mVRLibrary.onResume(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mVRLibrary.onPause(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mVRLibrary.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mVRLibrary.onOrientationChanged(this);
    }

    protected Uri getUri() {
        Intent i = getIntent();
        if (i == null || i.getData() == null){
            return null;
        }
        return i.getData();
    }

    public void cancelBusy(){
        findViewById(R.id.progress).setVisibility(View.GONE);
    }

    public void busy(){
        findViewById(R.id.progress).setVisibility(View.VISIBLE);
    }

}