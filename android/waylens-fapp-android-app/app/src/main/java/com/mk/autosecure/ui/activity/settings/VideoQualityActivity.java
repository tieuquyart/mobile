package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;

import android.widget.Toast;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.VideoQualityChangeEvent;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LocalLiveActivity;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

public class VideoQualityActivity extends RxAppCompatActivity {

    private final static String TAG = VideoQualityActivity.class.getSimpleName();

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.rl_subStream)
    RelativeLayout rlSubStream;

    @BindView(R.id.switch_subStream_only)
    Switch switchSubStreamOnly;

    @BindView(R.id.ll_main_stream)
    LinearLayout llMainStream;

    @BindView(R.id.tv_mainStream)
    TextView tvMainStream;

    @BindView(R.id.ll_sub_stream)
    LinearLayout llSubStream;

    @BindView(R.id.tv_subStream)
    TextView tvSubStream;

    @OnClick(R.id.ll_main_stream)
    public void onMain() {
        if (mCamera != null && mCamera instanceof VdtCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            final String[] items = new String[]{getString(R.string.super_high),
                    getString(R.string.high), getString(R.string.normal), getString(R.string.low)
                    , getString(R.string.super_low)
                    , getString(R.string.normal_5fps), getString(R.string.low_5fps), getString(R.string.super_low_5fps)};

            Logger.t(TAG).d("mMainIndex: " + mMainIndex);

            builder.setSingleChoiceItems(items, mMainIndex, (dialog, which) -> {
                Logger.t(TAG).d("setMainStreamQuality: " + which);

                if (which != mMainIndex) {
                    //暂时用quality改变就判定帧数改变
                    mFpsUpdate = true;
                    mMainIndex = which;
                }

                ((VdtCamera) mCamera).setStreamQuality(which, mSubIndex);
                judgeQuality(tvMainStream, which);
                dialog.dismiss();
            });

            builder.show();
        }
    }

    @OnClick(R.id.ll_sub_stream)
    public void onSub() {
        if (mCamera != null && mCamera instanceof VdtCamera) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            final String[] items = new String[]{getString(R.string.high), getString(R.string.normal), getString(R.string.low)};

            Logger.t(TAG).d("mSubIndex: " + mSubIndex);

            builder.setSingleChoiceItems(items, mSubIndex - 1, (dialog, which) -> {
                int i = which + 1;
                Logger.t(TAG).d("setSubStreamQuality: " + i);

                if (i != mSubIndex) {
                    //暂时用quality改变就判定帧数改变
                    mFpsUpdate = true;
                    mSubIndex = i;
                }

                ((VdtCamera) mCamera).setStreamQuality(mMainIndex, i);
                judgeQuality(tvSubStream, i);
                dialog.dismiss();
            });

            builder.show();
        }
    }

    private CameraWrapper mCamera;

    private boolean mSubStreamOnly = false; // 用户当前设置的打开/关闭

    private boolean initSubStreamOnly = false; // 界面初始化时的打开/关闭

    private boolean mFpsUpdate = false; // 帧率是否发生改变，需要重新开始录制

    private int mMainIndex;

    private int mSubIndex;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, VideoQualityActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_quality);
        ButterKnife.bind(this);

        initView();
        initEvent();
    }

    @SuppressLint("CheckResult")
    @Override
    protected void onResume() {
        super.onResume();
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));
    }

    @Override
    protected void onStop() {
        setStream();
        super.onStop();
    }

    private void setStream() {
        Logger.t(TAG).d("setStream initSubStreamOnly: " + initSubStreamOnly + " mSubStreamOnly: " + mSubStreamOnly
                + " mFpsUpdate: " + mFpsUpdate);
        //当单双路设置发生改变，或帧数发生改变时，重新开始录制
        if (mCamera != null && mCamera instanceof VdtCamera && (initSubStreamOnly != mSubStreamOnly || mFpsUpdate)) {
            ((VdtCamera) mCamera).setStreamSetting(mSubStreamOnly);
            initSubStreamOnly = mSubStreamOnly;
        }
    }

    private void onCurrentCamera(Optional<CameraWrapper> cameraOptional) {
        CameraWrapper includeNull = cameraOptional.getIncludeNull();
        Logger.t(TAG).d("onCurrentCamera: " + includeNull);
        if (includeNull != null) {
            mCamera = includeNull;
        } else {
            Logger.t(TAG).d("onDisconnectCamera");
            Toast.makeText(this, getString(R.string.camera_disconnected), Toast.LENGTH_SHORT).show();
            LocalLiveActivity.launch(this, true);
        }
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
//        RxBus.getDefault()
//                .toObservable(StreamRecordChangeEvent.class)
//                .compose(bindUntilEvent(ActivityEvent.STOP))
//                .compose(Transformers.switchSchedulers())
//                .subscribe(this::onStreamChangeEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(VideoQualityChangeEvent.class)
                .compose(bindUntilEvent(ActivityEvent.STOP))
                .compose(Transformers.switchSchedulers())
                .subscribe(this::onVideoQualityChangeEvent, new ServerErrorHandler(TAG));
    }

    private void onVideoQualityChangeEvent(VideoQualityChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int mainQualityIndex = event.getMainQualityIndex();
            mMainIndex = mainQualityIndex;
            Logger.t(TAG).d("onVideoQualityChangeEvent mainQualityIndex: " + mainQualityIndex);
            judgeQuality(tvMainStream, mainQualityIndex);

            int subQualityIndex = event.getSubQualityIndex();
            mSubIndex = subQualityIndex;
            Logger.t(TAG).d("onVideoQualityChangeEvent subQualityIndex: " + subQualityIndex);
            judgeQuality(tvSubStream, subQualityIndex);
        }
    }

//    private void onStreamChangeEvent(StreamRecordChangeEvent event) {
//        if (event != null && event.getVdtCamera().equals(mCamera)) {
//            boolean subStreamOnly = event.getSubStreamOnly();
//            Logger.t(TAG).d("onStreamChangeEvent subStreamOnly: " + subStreamOnly);
//            switchSubStreamOnly.setChecked(subStreamOnly);
//        }
//    }

    private void initView() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
        tvToolbarTitle.setText(R.string.video_quality);

        mCamera = VdtCameraManager.getManager().getCurrentCamera();

        if (mCamera != null && mCamera instanceof VdtCamera) {
            if (mCamera.isSubStreamOnlyAvailable()) {
                rlSubStream.setVisibility(View.VISIBLE);
                llSubStream.setVisibility(View.VISIBLE);

                initSubStreamOnly = mSubStreamOnly = ((VdtCamera) mCamera).getStreamSetting();
                Logger.t(TAG).d("currentStream: " + initSubStreamOnly);
                switchSubStreamOnly.setChecked(mSubStreamOnly);

                setMainEnable(initSubStreamOnly);

                mSubIndex = ((VdtCamera) mCamera).getSubStreamQuality();
                Logger.t(TAG).d("subStreamQuality: " + mSubIndex);
                judgeQuality(tvSubStream, mSubIndex);
            } else {
                rlSubStream.setVisibility(View.GONE);
                llSubStream.setVisibility(View.GONE);
            }

            mMainIndex = ((VdtCamera) mCamera).getMainStreamQuality();
            Logger.t(TAG).d("mainStreamQuality: " + mMainIndex);
            judgeQuality(tvMainStream, mMainIndex);
        }

        switchSubStreamOnly.setOnCheckedChangeListener((buttonView, isChecked) -> {
            Logger.t(TAG).d("onCheckedChanged: " + isChecked);
            this.mSubStreamOnly = isChecked;
            setMainEnable(isChecked);
        });

    }

    private void setMainEnable(boolean onlySub) {
        // 当只有一路时，main不可用
        llMainStream.setEnabled(!onlySub);
        llMainStream.setBackgroundResource(onlySub ? R.color.colorUnsetting : R.drawable.item_common_background);
    }

    private void judgeQuality(TextView textView, int videoQuality) {
        int resourceID;
        switch (videoQuality) {
            case VdtCamera.VIDEO_QUALITY_SUPPER:
                resourceID = R.string.super_high;
                break;
            case VdtCamera.VIDEO_QUALITY_HI:
                resourceID = R.string.high;
                break;
            case VdtCamera.VIDEO_QUALITY_MID:
                resourceID = R.string.normal;
                break;
            case VdtCamera.VIDEO_QUALITY_LOW:
                resourceID = R.string.low;
                break;
            case VdtCamera.VIDEO_QUALITY_SUPER_LOW:
                resourceID = R.string.super_low;
                break;
            case VdtCamera.VIDEO_QUALITY_MID_5FPS:
                resourceID = R.string.normal_5fps;
                break;
            case VdtCamera.VIDEO_QUALITY_LOW_5FPS:
                resourceID = R.string.low_5fps;
                break;
            case VdtCamera.VIDEO_QUALITY_SUPER_LOW_5FPS:
                resourceID = R.string.super_low_5fps;
                break;
            default:
                resourceID = R.string.high;
                break;
        }
        textView.setText(getString(resourceID));
    }
}
