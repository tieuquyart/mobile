package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.event.FormatSDCardEvent;
import com.mkgroup.camera.event.VdbReadyInfo;
import com.mkgroup.camera.event.VideoSpaceChangeEvent;
import com.mkgroup.camera.model.SpaceInfo;
import com.mkgroup.camera.model.VdbSpaceInfoEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.setting.SpaceInfoViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_SDCARD_FORMAT;

/**
 * Created by DoanVT on 2016/8/22.
 * Email: doanvt-hn@mk.com.vn
 */

@RequiresActivityViewModel(SpaceInfoViewModel.ViewModel.class)
public class SpaceInfoActivity extends BaseActivity<SpaceInfoViewModel.ViewModel> {

    private static final String TAG = SpaceInfoActivity.class.getSimpleName();

    private boolean isForeground;

    public static void launch(Activity activity, boolean guide) {
        Intent intent = new Intent(activity, SpaceInfoActivity.class);
        if (guide) {
            activity.startActivityForResult(intent, GUIDE_SDCARD_FORMAT);
        } else {
            activity.startActivity(intent);
        }
    }

    @BindView(R.id.tv_sd_card_status)
    TextView mTvSdCardStatus;

    @BindView(R.id.storage_progress_bar)
    ProgressBar mStorageProgressBar;

    @BindView(R.id.tv_storage_number)
    TextView mStorageNumber;

    @BindView(R.id.tv_storage_unit)
    TextView mStorageUnit;

    @BindView(R.id.tv_sd_card_volume)
    TextView mSdCardVolume;

    @BindView(R.id.tv_sd_card_available)
    TextView mSdCardAvailable;

    @BindView(R.id.tv_highlights)
    TextView mHighlight;

    @BindView(R.id.tv_video_buffer)
    TextView mVideoBuffer;

    @BindView(R.id.tv_otherFiles)
    TextView mTvOtherFiles;

    @BindView(R.id.btn_format)
    Button mBtnFormat;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_format_notification)
    TextView mTvFormatNotification;

    @BindView(R.id.tv_event_space)
    TextView tv_event_space;

    @BindView(R.id.ll_video_manage)
    LinearLayout ll_video_manage;

    private CameraWrapper mCamera;

    private AppCompatDialog mProgressDialog;

    @OnClick(R.id.btn_format)
    public void onFormatClicked() {
        if (mCamera != null) {
            DialogHelper.showFormatDialog(this, () -> {
                if (mCamera.getRecordState() == VdtCamera.STATE_RECORD_STOPPED
                        || mCamera.getRecordState() == VdtCamera.STATE_RECORD_RECORDING) {
                    if (mCamera.getRecordState() == VdtCamera.STATE_RECORD_RECORDING) {
                        mCamera.stopRecording();

                        new Handler().postDelayed(() -> {
                            if (mCamera.getRecordState() == VdtCamera.STATE_RECORD_STOPPED) {
                                mCamera.sendFormatSDCard();
                            } else {
                                Toast.makeText(SpaceInfoActivity.this, R.string.unknown_error, Toast.LENGTH_SHORT).show();
                                hideLoadingDialog();
                            }
                        }, 5000);
                    } else {
                        mCamera.sendFormatSDCard();
                    }
                    showLoadingDialog();
                }
            });
        }
    }

    @OnClick(R.id.ll_video_manage)
    public void toVideoManage() {
        if (mCamera != null) {
            VideoSpaceActivity.launch(this);
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_space_info);
        ButterKnife.bind(this);
        setupToolbar();
        initViews();
        initListener();
    }

    @SuppressLint("CheckResult")
    private void initListener() {
        viewModel.outputs.spaceInfoData()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updateSpaceInfo, new ServerErrorHandler(TAG));

        viewModel.outputs.spaceInfoError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> onQuerySpaceInfoError(), new ServerErrorHandler());

        viewModel.outputs.recordState()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updateRecordStateUI, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent);

        RxBus.getDefault().toObservable(VdbSpaceInfoEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(event -> updateSpaceInfo(event.getExtra()), new ServerErrorHandler());

        RxBus.getDefault().toObservable(VdbReadyInfo.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVdbReadyInfo, new ServerErrorHandler());

        RxBus.getDefault().toObservable(FormatSDCardEvent.class)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(formatSDCardEvent -> {
                    Logger.t(TAG).d("formatSDCardEvent: " + formatSDCardEvent.getResult());
                    String str = formatSDCardEvent.getResult() ?
                            getResources().getString(R.string.sdcard_format_success)
                            : getResources().getString(R.string.sdcard_format_failed);

                    Toast.makeText(SpaceInfoActivity.this, str, Toast.LENGTH_SHORT).show();
                    hideLoadingDialog();
                }, new ServerErrorHandler());

        RxBus.getDefault().toObservable(VideoSpaceChangeEvent.class)
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVideoSpaceChangeEvent, new ServerErrorHandler());
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;

        if (mCamera != null && !mCamera.isMarkSpaceSettingsAvailable()) {
            ll_video_manage.setVisibility(View.GONE);
        } else if (mCamera != null) {
            int markStorage = mCamera.getMarkStorage();
            Logger.t(TAG).d("markStorage: " + markStorage);
            String[] storageList = mCamera.getMarkStorageList();
            if (storageList != null && storageList.length != 0) {
                tv_event_space.setText(String.format("%sGB", storageList[markStorage]));
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
    }

    private void initViews() {
        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            viewModel.inputs.loadSpaceInfo();
        }
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                CameraWrapper eventCamera = event.getVdtCamera();
                if (mCamera != null && eventCamera != null && mCamera.getPort() == eventCamera.getPort()) {
                    finish();
                }
                break;
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_CONNECTED");
                initViews();
                break;
            default:
                break;
        }
    }

    private void updateSpaceInfo(SpaceInfo spaceInfo) {
        Logger.t(TAG).d("updateSpaceInfo: " + spaceInfo);

        mTvSdCardStatus.setText(R.string.sdcard_working);
        mSdCardVolume.setText(StringUtils.getSpaceString(spaceInfo.total));
        mHighlight.setText(StringUtils.getSpaceString(spaceInfo.marked));
        mVideoBuffer.setText(StringUtils.getSpaceString(spaceInfo.clip - spaceInfo.marked));
        mSdCardAvailable.setText(StringUtils.getSpaceString(spaceInfo.total - spaceInfo.used));
        mTvOtherFiles.setText(StringUtils.getSpaceString(spaceInfo.used - spaceInfo.clip));

        mStorageProgressBar.setMax(100);
        long marked = (spaceInfo.marked * 100) / spaceInfo.total;
        long buffered = (spaceInfo.used * 100) / spaceInfo.total;
        mStorageProgressBar.setProgress((int) marked);
        mStorageProgressBar.setSecondaryProgress((int) buffered);

        mStorageNumber.setText(StringUtils.getSpaceNumber(spaceInfo.used));
        mStorageUnit.setText(StringUtils.getSpaceUnit(spaceInfo.used));
    }

    private void onQuerySpaceInfoError() {
        // TODO: 2018/5/4  有时相机无法识别SD卡插入，不支持格式等情况
        if (mCamera != null) {
            mTvSdCardStatus.setText(R.string.sdcard_not_found);
            mBtnFormat.setEnabled(true);
        } else {
            mTvSdCardStatus.setText(R.string.sdcard_unknown);
            mBtnFormat.setEnabled(false);
        }
    }

    private void onVdbReadyInfo(VdbReadyInfo info) {
        Logger.t(TAG).d("onVdbReadyInfo ready: " + info.getIsReady());
        if (info.getIsReady()) {
            viewModel.inputs.loadSpaceInfo();
        } else {
            mTvSdCardStatus.setText(R.string.sdcard_not_found);
            mSdCardVolume.setText(R.string.unknown);
            mHighlight.setText(R.string.unknown);
            mVideoBuffer.setText(R.string.unknown);
            mSdCardAvailable.setText(R.string.unknown);
            mTvOtherFiles.setText(R.string.unknown);
            updateRecordStateUI(mCamera.getRecordState());
        }
    }

    private void updateRecordStateUI(int recordState) {
        Logger.t(TAG).d("%s", "record state = " + recordState);
        mBtnFormat.setEnabled(true);
        mTvFormatNotification.setVisibility(View.GONE);
    }

    private void showLoadingDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new AppCompatDialog(this);
            View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_progress, null);

            mProgressDialog.setCanceledOnTouchOutside(false);
            mProgressDialog.setOnDismissListener(dialog -> {

            });
            mProgressDialog.setContentView(dialogView);

            View view = (View) dialogView.getParent();
            if (view != null) {
                view.setBackgroundResource(android.R.color.transparent);
            }
        }
        if (isForeground) {
            mProgressDialog.show();
        }
    }

    @Override
    protected void onDestroy() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
            mProgressDialog = null;
        }
        super.onDestroy();
    }

    private void hideLoadingDialog() {
        if (mProgressDialog != null) {
            try {
                mProgressDialog.hide();
                mProgressDialog.dismiss();
                mProgressDialog = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("hideLoadingDialog error" + ex.getMessage());
            }
        }
    }

    private void setupToolbar() {
        if (toolbar != null) {
            TextView textView = toolbar.findViewById(R.id.tv_toolbarTitle);
            if (textView != null) {
                textView.setText(getResources().getString(R.string.sdcard_title));
            }
            toolbar.setNavigationOnClickListener((View v) -> finish());
        }
    }

    private void onVideoSpaceChangeEvent(VideoSpaceChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            int curSpaceIndex = event.getCurSpaceIndex();
            Logger.t(TAG).d("curSpaceIndex: " + curSpaceIndex);
            tv_event_space.setText(String.format("%sGB", mCamera.getMarkStorageList()[curSpaceIndex]));
        }
    }
}
