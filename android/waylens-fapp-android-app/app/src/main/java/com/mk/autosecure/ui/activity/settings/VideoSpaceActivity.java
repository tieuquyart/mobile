package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.VideoSpaceChangeEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.ServerErrorHandler;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class VideoSpaceActivity extends RxActivity {

    private final static String TAG = VideoSpaceActivity.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.rg_space)
    RadioGroup rg_space;

    private CameraWrapper mCamera;
    private List<RadioButton> checkList;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, VideoSpaceActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_space);
        ButterKnife.bind(this);
        setToolbar();

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        initView();
        initEvent();
    }

    private void initEvent() {
        RxBus.getDefault().toObservable(VideoSpaceChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVideoSpaceChangeEvent, new ServerErrorHandler());
    }

    private void initView() {
        tv_toolbarTitle.setText(R.string.event_video_space);

        if (mCamera != null) {
            checkList = new ArrayList<>();
            String[] storageList = mCamera.getMarkStorageList();

            if (storageList != null && storageList.length != 0) {
                for (String aStorageList : storageList) {
                    RadioButton radioButton = new RadioButton(this);
                    RadioGroup.LayoutParams params = new RadioGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(48), Gravity.CENTER_VERTICAL);
                    radioButton.setLayoutParams(params);
                    radioButton.setText(aStorageList + "GB");

                    checkList.add(radioButton);
                    rg_space.addView(radioButton);
                }
                checkList.get(mCamera.getMarkStorage()).setChecked(true);
            }
        }

        rg_space.setOnCheckedChangeListener((group, checkedId) -> {
            RadioButton button = findViewById(checkedId);
            int indexOf = checkList.indexOf(button);
            Logger.t(TAG).e("indexOf: " + indexOf);
            if (mCamera != null) {
                mCamera.setMarkStorage(indexOf);
            }
        });
    }

    private void setToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    private void onVideoSpaceChangeEvent(VideoSpaceChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int curSpaceIndex = event.getCurSpaceIndex();
            com.orhanobut.logger.Logger.t(TAG).e("cur: " + curSpaceIndex);
            checkList.get(curSpaceIndex).setChecked(true);
        }
    }

}
