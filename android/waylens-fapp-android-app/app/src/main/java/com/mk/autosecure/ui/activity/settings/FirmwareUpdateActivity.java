package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSIONS_REQUESTCODE;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.PermissionChecker;

import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FirmwareBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.firmware.FirmwareDownloader;
import com.mkgroup.camera.firmware.FirmwareManager;
import com.mkgroup.camera.firmware.FirmwareWriter;
import com.mkgroup.camera.message.bean.TransferInfoBean;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DataCleanManager;
import com.mk.autosecure.libs.utils.FirmwareUpgradeHelper;
import com.mk.autosecure.libs.utils.HashUtils;
import com.mk.autosecure.libs.utils.Hex;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.rest.ServerErrorHandler;

import java.io.File;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by DoanVT on 2016/8/23.
 * Email: doanvt-hn@mk.com.vn
 */
public class FirmwareUpdateActivity extends RxActivity {
    private static final String TAG = FirmwareUpdateActivity.class.getSimpleName();
    private static final String EXTRA_FIRMWARE_INFO = "firmwareinfo";
    private static final String EXTRA_CAMERA_SN = "sn";

    private static final int UPGRADE_STATE_NONE = 0;
    private static final int UPGRADE_STATE_DOWNLOADED = 1;
    private static final int UPGRADE_STATE_UPLOADING = 2;
    private static final int UPGRADE_STATE_UPLOADED = 3;

    private Firmware mFirmware;

    private FirmwareBean mFleetFirmware;

    private int mUpgradeState = UPGRADE_STATE_NONE;

    private File mDownloadFirmware;

    private FirmwareManager mFirmwareManager;

    private CameraWrapper mCamera;

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private String url;

    private String md5;

    @BindView(R.id.tv_latest_version)
    TextView mTvLatestVer;

    @BindView(R.id.tv_update_tips)
    TextView mTvUpdateTips;

    @BindView(R.id.tv_latest_size)
    TextView mTvLatestSize;

    @BindView(R.id.tv_current_version)
    TextView mTvCurrentVer;

    @BindView(R.id.progress_bar)
    ProgressBar mProgressBar;

    @BindView(R.id.tv_uploading)
    TextView mTvUploading;

    @BindView(R.id.btn_action)
    Button mBtnAction;

    @BindView(R.id.tv_note_content)
    TextView mTvNoteContent;

    @BindView(R.id.btn_beta_tester)
    Button mBtnBetaTester;

    @BindView(R.id.va_firmware)
    ViewAnimator vaFirmware;

    @BindView(R.id.va_base)
    ViewAnimator vaBase;

    @OnClick({R.id.btn_beta_tester, R.id.ll_beta_tester})
    public void joinBeta() {
        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
        if (aBoolean) {
            //当前是beta模式
            DialogHelper.showBetaTesterDialog(this,
                    R.string.support_leave_title,
                    R.string.support_leave_content,
                    R.string.support_beta_leave,
                    () -> {
                        PreferenceUtils.putBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
                        init();
                    });
        } else {
            DialogHelper.showBetaTesterDialog(this,
                    R.string.support_join_title,
                    R.string.support_join_content,
                    R.string.support_beta_join,
                    () -> {
                        PreferenceUtils.putBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, true);
                        init();
                    });
        }
    }

    @OnClick(R.id.btn_action)
    public void onBtnRetryClicked() {
        switch (mUpgradeState) {
            case UPGRADE_STATE_NONE:
                downloadFirmware();
                break;
            case UPGRADE_STATE_DOWNLOADED:
                doSendFirmware2Camera();
                break;
            default:
                break;
        }
    }

    public static void launch(Activity activity, String sn, Firmware firmware) {
        Intent intent = new Intent(activity, FirmwareUpdateActivity.class);
        intent.putExtra(EXTRA_CAMERA_SN, sn);
        intent.putExtra(EXTRA_FIRMWARE_INFO, firmware);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, FirmwareUpdateActivity.class);
        intent.putExtra(EXTRA_CAMERA_SN, sn);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CameraBean cameraBean) {
        Intent intent = new Intent(activity, FirmwareUpdateActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, FleetCameraBean fleetCamera) {
        Intent intent = new Intent(activity, FirmwareUpdateActivity.class);
        intent.putExtra(IntentKey.FLEET_CAMERA, fleetCamera);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE}, PERMISSIONS_REQUESTCODE);
            } else {
                init();
            }
        } else {
            init();
        }
    }

    private void initViews() {
        setContentView(R.layout.activity_firmware_update);
        ButterKnife.bind(this);
        setupToolbar();

        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.BETA_FIRMWARE_TESTER, false);
        if (aBoolean) {
            mBtnBetaTester.setText(R.string.support_beta_tester_yes);
        } else {
            mBtnBetaTester.setText(R.string.support_beta_tester_no);
        }
    }

    protected void init() {
        mFirmware = (Firmware) getIntent().getSerializableExtra(EXTRA_FIRMWARE_INFO);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
        mFleetCamera = (FleetCameraBean) getIntent().getSerializableExtra(IntentKey.FLEET_CAMERA);
        String sn = getIntent().getStringExtra(EXTRA_CAMERA_SN);
        if (!TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent, new ServerErrorHandler());

        mFirmwareManager = VdtCameraManager.getManager().getFirmwareManager();
        mFirmwareManager.getDownloadSubject()
                .subscribeOn(Schedulers.io())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(createDownloadObserver());

        initViews();

        if (mFirmware != null) {
            url = mFirmware.url;
            md5 = mFirmware.md5;
            setLaterstFirmware();
            vaBase.setDisplayedChild(1);
            checkFirmwareDownloaded(mFirmware.url, mFirmware.md5);
        } else if (mCamera != null) {
            firmwareDownload(mCamera.getSerialNumber(), mCamera.getHardwareName(), mCamera.getApiVersion(), mCamera.getBspFirmware(), true);
        } else if (mCameraBean != null) {
            firmwareDownload(mCameraBean.sn, mCameraBean.hardwareVersion, mCameraBean.state.firmwareShort, mCameraBean.state.firmware, true);
        } else if (mFleetCamera != null) {
            firmwareDownload(mFleetCamera.getSn(), mFleetCamera.getHardwareVersion(), mFleetCamera.getFirmwareShort(), mFleetCamera.getFirmware(), true);
        }

        if (mCamera != null) {
            mTvCurrentVer.setText(getString(R.string.firmware_current_version, mCamera.getApiVersion(), mCamera.getBspFirmware()));
        } else if (mCameraBean != null) {
            showCurrentVersion(mCameraBean.hardwareVersion, mCameraBean.state.firmwareShort, mCameraBean.state.firmware);
        } else if (mFleetCamera != null) {
            showCurrentVersion(mFleetCamera.getHardwareVersion(), mFleetCamera.getFirmwareShort(), mFleetCamera.getFirmware());
        }
    }

    private void showCurrentVersion(String hardwareVerison, String apiVersion, String bspVersion) {
        if (FirmwareUpgradeHelper.isCameraValid(hardwareVerison, apiVersion, bspVersion)) {
            mTvCurrentVer.setText(getString(R.string.firmware_current_version, apiVersion, bspVersion));
        } else {
            vaBase.setDisplayedChild(1);
            vaFirmware.setDisplayedChild(1);
        }
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).d("VDT_CAMERA_CONNECTED");
                CameraWrapper camera = event.getVdtCamera();
                if (camera != null) {
                    if (mCamera != null
                            && mCamera.getSerialNumber().equals(camera.getSerialNumber())) {
                        mCamera = camera;
                    } else if (mCameraBean != null
                            && mCameraBean.sn.equals(camera.getSerialNumber())) {
                        mCamera = camera;
                    } else if (mFleetCamera != null) {
                        mCamera = camera;
                    }
                    updateUI();
                }
                break;
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).d("VDT_CAMERA_DISCONNECTED");
                if (mCamera != null) {
                    finish();
                }
                break;
            default:
                break;
        }
    }

    private void firmwareDownload(String sn, String hardwareName, String apiVersion, String bspVersion, boolean useCache) {
        FirmwareUpgradeHelper.getNewerFirmwareRx(sn, hardwareName, apiVersion, bspVersion, useCache)
                .subscribeOn(Schedulers.io())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(objectOptional -> dealFirmware(objectOptional.getIncludeNull(), apiVersion, bspVersion),
                        new ServerErrorHandler(TAG));
    }

//    private void onlineDownload() {
//        FirmwareUpgradeHelper.getNewerFirmwareRx(mCamera, true)
//                .subscribeOn(Schedulers.io())
//                .compose(bindUntilEvent(ActivityEvent.DESTROY))
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(firmware -> dealFirmware(firmware.getIncludeNull(), mCamera.getApiVersion(), mCamera.getBspFirmware()),
//                        new ServerErrorHandler());
//    }

//    private void offlineDownload() {
//        FirmwareUpgradeHelper.getNewerFirmwareRx(mCameraBean, true)
//                .subscribeOn(Schedulers.io())
//                .compose(bindUntilEvent(ActivityEvent.DESTROY))
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(firmware -> dealFirmware(firmware.getIncludeNull(), mCameraBean.state.firmwareShort, mCameraBean.state.firmware),
//                        new ServerErrorHandler());
//    }

//    private void offlineFleetDownload() {
//        FirmwareUpgradeHelper.getNewerFirmwareRx(mFleetCamera, true)
//                .subscribeOn(Schedulers.io())
//                .compose(bindUntilEvent(ActivityEvent.DESTROY))
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribe(firmwareOptional -> dealFirmwareBean(firmwareOptional.getIncludeNull(), mFleetCamera.getFirmwareShort(), mFleetCamera.getFirmware()),
//                        new ServerErrorHandler(TAG));
//    }

    private void dealFirmware(Object object, String apiVersion, String bspVersion) {
        if (object == null) {
            vaBase.setDisplayedChild(1);
            vaFirmware.setDisplayedChild(1);
        }

        if (object instanceof Firmware) {
            mFirmware = (Firmware) object;
            url = ((Firmware) object).url;
            md5 = ((Firmware) object).md5;
            Logger.t(TAG).e("latestFirmware: " + ToStringUtils.getString(object));

            if (mFirmware.version.equals(apiVersion) && mFirmware.BSPVersion.equals(bspVersion)) {
                vaBase.setDisplayedChild(1);
                vaFirmware.setDisplayedChild(1);
            } else {
                setLaterstFirmware();
                vaBase.setDisplayedChild(1);
                checkFirmwareDownloaded(mFirmware.url, mFirmware.md5);
            }
        } else if (object instanceof FirmwareBean) {
            mFleetFirmware = (FirmwareBean) object;
            url = ((FirmwareBean) object).getFile();
            md5 = ((FirmwareBean) object).getMd5sum();
            Logger.t(TAG).e("latestFirmware: " + ToStringUtils.getString(object));

            if (mFleetFirmware.getFirmwareShort().equals(apiVersion)
                    && mFleetFirmware.getFirmware().equals(bspVersion)) {
                vaBase.setDisplayedChild(1);
                vaFirmware.setDisplayedChild(1);
            } else {
                setLatestFleetFirmware();
                vaBase.setDisplayedChild(1);
                checkFirmwareDownloaded(mFleetFirmware.getFile(), mFleetFirmware.getMd5sum());
            }
        }
    }

//    private void dealFirmware(Firmware firmware, String apiVersion, String bspVersion) {
//        if (firmware != null) {
//            mFirmware = firmware;
//            url = firmware.url;
//            md5 = firmware.md5;
//            Logger.t(TAG).e("latestFirmware: " + ToStringUtils.getString(firmware));
//
//            if (mFirmware.version.equals(apiVersion) && mFirmware.BSPVersion.equals(bspVersion)) {
//                vaBase.setDisplayedChild(1);
//                vaFirmware.setDisplayedChild(1);
//            } else {
//                setLaterstFirmware();
//                vaBase.setDisplayedChild(1);
//                checkFirmwareDownloaded(mFirmware.url, mFirmware.md5);
//            }
//        } else {
//            vaBase.setDisplayedChild(1);
//            vaFirmware.setDisplayedChild(1);
//        }
//    }

//    private void dealFirmwareBean(FirmwareBean firmwareBean, String apiVersion, String bspVersion) {
//        if (firmwareBean != null) {
//            mFleetFirmware = firmwareBean;
//            url = mFleetFirmware.getFile();
//            md5 = mFleetFirmware.getMd5sum();
//            Logger.t(TAG).e("latestFirmware: " + ToStringUtils.getString(firmwareBean));
//
//            if (mFleetFirmware.getFirmwareShort().equals(apiVersion)
//                    && mFleetFirmware.getFirmware().equals(bspVersion)) {
//                vaBase.setDisplayedChild(1);
//                vaFirmware.setDisplayedChild(1);
//            } else {
//                setLatestFleetFirmware();
//                vaBase.setDisplayedChild(1);
//                checkFirmwareDownloaded(mFleetFirmware.getFile(), mFleetFirmware.getMd5sum());
//            }
//        } else {
//            vaBase.setDisplayedChild(1);
//            vaFirmware.setDisplayedChild(1);
//        }
//    }

    private void setLaterstFirmware() {
        mTvLatestVer.setText(getString(R.string.firmware_latest_version, mFirmware.version, mFirmware.BSPVersion));
        mTvLatestSize.setText(String.format(Locale.US, "%d MB", mFirmware.size / 1000 / 1000));
        boolean isZh = Locale.getDefault().getLanguage().equals("zh");
        Logger.t(TAG).d("isZh: " + isZh + "--" + Locale.getDefault().getLanguage());
        if (mFirmware.description != null) {
            String description = isZh ? mFirmware.description.zh : mFirmware.description.en;
            if (!TextUtils.isEmpty(description)) {
                mTvNoteContent.setText(description);
            }
        }
    }

    private void setLatestFleetFirmware() {
        mTvLatestVer.setText(getString(R.string.firmware_latest_version, mFleetFirmware.getFirmwareShort(), mFleetFirmware.getFirmware()));
        mTvLatestSize.setText(String.format(Locale.US, "%d MB", mFleetFirmware.getSize() / 1000 / 1000));
        boolean isZh = Locale.getDefault().getLanguage().equals("zh");
        Logger.t(TAG).d("isZh: " + isZh + "--" + Locale.getDefault().getLanguage());
        if (mFleetFirmware.getDescription() != null) {
            String description = isZh ? mFleetFirmware.getDescription().zh : mFleetFirmware.getDescription().en;
            if (!TextUtils.isEmpty(description)) {
                mTvNoteContent.setText(description);
            }
        }
    }

    private FirmwareDownloader.DownLoadObserver createDownloadObserver() {
        return new FirmwareDownloader.DownLoadObserver() {
            int percentage = 0;
            Disposable disposable;

            @Override
            public void onError(Throwable e) {
                if (disposable != null && !disposable.isDisposed()) {
                    disposable.dispose();
                }
            }

            @Override
            public void onComplete() {
                if (disposable != null && !disposable.isDisposed()) {
                    disposable.dispose();
                }
            }

            @Override
            public void onSubscribe(Disposable d) {
                this.disposable = d;
            }

            @Override
            public void onNext(final FirmwareDownloader.DownloadInfo downloadInfo) {
//                Logger.t(TAG).e("download progress + " + downloadInfo.getProgress());
//                Logger.t(TAG).e("download total + " + downloadInfo.getTotal());

                if (!downloadInfo.getUrl().equals(url)) {
                    mFirmwareManager.cancelDownloadFirmware(url);
                    return;
                }

                final int progress = (int) ((double) downloadInfo.getProgress() * 100 / downloadInfo.getTotal());

                if (progress != mProgressBar.getProgress() || downloadInfo.getIsComplete() || downloadInfo.getError() != null) {
                    Logger.t(TAG).e("progress = " + progress);
                    runOnUiThread(() -> {
                        //设置进度
                        hideActionButton();
                        mProgressBar.setProgress(progress);

                        //下载完成
                        if (downloadInfo.getIsComplete()) {
                            mUpgradeState = UPGRADE_STATE_DOWNLOADED;
//                            mTvBottomText.setText(R.string.firmware_update_download_firmware_success);
                            updateUI();
                            mDownloadFirmware = new File(FileUtils.getFirmwareDownloadPath(url));
                            if (mDownloadFirmware.exists()) {
                                startFirmwareMd5Check(mDownloadFirmware);
                            }
                        }

                        //下载出错
                        if (downloadInfo.getError() != null) {
                            mUpgradeState = UPGRADE_STATE_NONE;
                            showActionButton(true);
                            alertError(R.string.firmware_update_error_download_firmware);
//                            mTvBottomText.setText(R.string.firmware_update_error_download_firmware);
                            mDownloadFirmware = new File(FileUtils.getFirmwareDownloadPath(url));
                            if (mDownloadFirmware.exists()) {
                                mDownloadFirmware.delete();
                            }
                        }
                    });
                }
                percentage = progress;
            }
        };
    }


    @SuppressLint("CheckResult")
    private void checkFirmwareDownloaded(String url, String md5) {
        //mBtnAction.setVisibility(View.GONE);
        Logger.t(TAG).e("downloadUrl: " + url + " md5: " + md5);

        Observable.create((ObservableOnSubscribe<Optional<FirmwareDownloader.DownloadInfo>>) subscriber -> {
            FirmwareDownloader.DownloadInfo downloadInfo = mFirmwareManager.checkFirmware(url, md5);
            subscriber.onNext(Optional.ofNullable(downloadInfo));
        })
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe((Optional<FirmwareDownloader.DownloadInfo> downloadInfoOptional) -> {
                    FirmwareDownloader.DownloadInfo downloadInfo = downloadInfoOptional.getIncludeNull();

                    if (downloadInfo == null) {
                        //check again
                        if (!mFirmwareManager.isDownloading(url)) {
                            DataCleanManager.clearCachedFirmware();
                            //downloadFirmware();
                            showActionButton(false);
                        }
                    } else {
                        if (downloadInfo.getUrl().equals(url) && downloadInfo.getIsComplete()) {
                            Logger.t(TAG).e("firmware is complete");
                            mUpgradeState = UPGRADE_STATE_DOWNLOADED;
                            updateUI();

                            mDownloadFirmware = new File(FileUtils.getFirmwareDownloadPath(url));
                            if (mDownloadFirmware.exists()) {
                                startFirmwareMd5Check(mDownloadFirmware);
                            }
                        } else if (!mFirmwareManager.isDownloading(url)) {
                            mUpgradeState = UPGRADE_STATE_NONE;
//                            mTvBottomText.setText(R.string.firmware_update_resume_download_firmware);
                            normalTips(R.string.firmware_update_resume_download_firmware);
                            hideActionButton();
                            downloadFirmware();
                            int progress = (int) ((double) downloadInfo.getProgress() * 100 / downloadInfo.getTotal());
                            mProgressBar.setProgress(progress);
                        }
                    }
                }, new ServerErrorHandler());
    }

    public void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        TextView toolbarTitle = toolbar.findViewById(R.id.tv_toolbarTitle);
        toolbarTitle.setText(R.string.firmware);
        toolbar.setNavigationOnClickListener(v -> {
            Logger.t(TAG).e("mUpgradeState: " + mUpgradeState);
            finish();
        });
    }

    private void downloadFirmware() {
        if (mFirmwareManager.isDownloading(url)) {
            Logger.t(TAG).e("already in downloading");
            return;
        }
        mBtnAction.setEnabled(false);
//        mTvBottomText.setText(R.string.firmware_update_start_download_firmware);
        Observable.create((ObservableOnSubscribe<Void>) emitter ->
                mFirmwareManager.downloadFirmware(url))
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .subscribe();
    }

    @SuppressLint("CheckResult")
    private void startFirmwareMd5Check(final File file) {
        Observable.create((ObservableOnSubscribe<Integer>) subscriber -> {
            subscriber.onNext(0);
            try {
                final String downloadFileMd5 = Hex.encodeHexString(HashUtils.encodeMD5(file));
                if (downloadFileMd5.equals(md5)) {
                    subscriber.onNext(1);
                } else {
                    if (mDownloadFirmware != null && mDownloadFirmware.exists()) {
                        mDownloadFirmware.delete();
                    }
                    DataCleanManager.clearCachedFirmware();
                    subscriber.onNext(-1);
                }
            } catch (IOException | NoSuchAlgorithmException e) {
                e.printStackTrace();
            }
        })
                .compose(Transformers.switchSchedulers())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(integer -> {
                    switch (integer) {
                        case 0:
//                            mTvBottomText.setText(R.string.firmware_update_check_firmware);
                            normalTips(R.string.firmware_update_check_firmware);
                            break;
                        case 1:
                            mUpgradeState = UPGRADE_STATE_DOWNLOADED;
                            updateUI();
                            break;
                        case -1:
//                            mTvBottomText.setText(R.string.firmware_update_check_firmware_failed);
                            alertError(R.string.firmware_update_check_firmware_failed);
                            showActionButton(false);
                            break;
                    }
                }, new ServerErrorHandler());
    }

    private void doSendFirmware2Camera() {
        if (mUpgradeState != UPGRADE_STATE_DOWNLOADED) {
            Logger.t(TAG).e("already in upgrade");
            return;
        }
        mUpgradeState = UPGRADE_STATE_UPLOADING;
        hideActionButton();
        if (mCamera != null) {
            if (mFirmware != null) {
                if (mCamera.getServerInfo().isVdtCamera) {
                    mCamera.sendNewFirmware((int) mFirmware.size, mFirmware.md5, versionListener);
                } else {
                    DialogHelper.showUpgradeFirmwareConfirmDialog(this,
                            () -> mCamera.sendNewFirmware((int) mFirmware.size, mFirmware.md5, versionListener),
                            () -> {
                                mUpgradeState = UPGRADE_STATE_DOWNLOADED;
                                showActionButton(false);
                            });
                }
            } else if (mFleetFirmware != null) {
                if (mCamera.getServerInfo().isVdtCamera) {
                    mCamera.sendNewFirmware(mFleetFirmware.getSize(), mFleetFirmware.getMd5sum(), versionListener);
                } else {
                    DialogHelper.showUpgradeFirmwareConfirmDialog(this,
                            () -> mCamera.sendNewFirmware(mFleetFirmware.getSize(), mFleetFirmware.getMd5sum(), versionListener),
                            () -> {
                                mUpgradeState = UPGRADE_STATE_DOWNLOADED;
                                showActionButton(false);
                            });
                }
            }
        }
    }

    private void handleTransfer(TransferInfoBean bean) {
        Logger.t(TAG).d("handleTransfer: " + bean);
        if (bean == null) {
            showActionButton(true);
            alertError(R.string.firmware_update_upgrade_failed);
            return;
        }

        switch (bean.getState()) {
            case "started":
                int size = bean.getSize();
                Logger.t(TAG).d("size: " + size);

                startTransferFirmware();
                break;
            case "transferring":
                int newProgress = bean.getProgress();
                int curProgress = mProgressBar.getProgress();
                Logger.t(TAG).d("curProgress: " + curProgress + " newProgress: " + newProgress);

                if (curProgress != newProgress) {
                    runOnUiThread(() -> mProgressBar.setProgress(newProgress));
                }
                break;
            case "checking":
                break;
            case "done":
                mUpgradeState = UPGRADE_STATE_UPLOADED;
                break;
            case "error":
                int errorCode = bean.getErrorCode();
                Logger.t(TAG).d("errorCode: " + errorCode);

                mUpgradeState = UPGRADE_STATE_DOWNLOADED;

                CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                if (currentCamera != null && currentCamera.getSerialNumber().equals(mCamera.getSerialNumber())) {
                    alertError(R.string.firmware_update_upgrade_failed);
                } else {
                    alertError(R.string.connect_camera_wifi_update);
                }
                showActionButton(true);
                break;
        }
    }

    private void handleFwVersionRetCode(int response) {
        Logger.t(TAG).e("response: " + response + "---Destroy: " + FirmwareUpdateActivity.this.isDestroyed());
        switch (response) {
            case 1:
                startUploadFirmware();
                break;
            case 0:
                doUpgradeFirmware();
                break;
            case -1:
                showActionButton(true);
                alertError(R.string.firmware_update_upgrade_failed);
//                mTvBottomText.setText(R.string.firmware_update_upgrade_failed);
                break;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    private void startTransferFirmware() {
        if (mCamera != null) {
            mCamera.transferFirmware(mDownloadFirmware);
        }
    }

    @SuppressLint("CheckResult")
    private void startUploadFirmware() {
//        mTvBottomText.setText(R.string.firmware_update_upload_firmware);
        Observable.create((ObservableEmitter<Integer> subscriber) -> {
            FirmwareWriter writer = new FirmwareWriter(mDownloadFirmware, mCamera, subscriber);
            writer.start();
            subscriber.onComplete();
        })
                .subscribeOn(Schedulers.io())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .observeOn(Schedulers.newThread())
                .subscribe(integer -> {
                    int progress = mProgressBar.getProgress();
                    final int newProgress = (int) (((long) integer * 100) / mDownloadFirmware.length());
                    Logger.t(TAG).e("progress = %d", newProgress);
                    if (progress != newProgress) {
                        runOnUiThread(() -> {
                            mProgressBar.setProgress(newProgress);
                        });
                    }
                }, throwable -> runOnUiThread(() -> {
                    Logger.t(TAG).e("startUploadFirmware throwable: " + throwable);
                    mUpgradeState = UPGRADE_STATE_DOWNLOADED;
                    CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
                    if (currentCamera != null && currentCamera.getSerialNumber().equals(mCamera.getSerialNumber())) {
//                        mTvBottomText.setText(R.string.firmware_update_upgrade_failed);
                        alertError(R.string.firmware_update_upgrade_failed);
                    } else {
//                        mTvBottomText.setText(R.string.firmware_update_upgrade_unconnect);
                        alertError(R.string.connect_camera_wifi_update);
                    }
                    showActionButton(true);
                }));
    }

    private void updateUI() {
        switch (mUpgradeState) {
            case UPGRADE_STATE_DOWNLOADED:
                mTvLatestSize.setText(R.string.downloaded);

                if (mCamera != null) {
                    normalTips(R.string.keep_camera_power);
                } else {
                    alertError(R.string.connect_camera_wifi_update);
                }

                mTvUploading.setVisibility(View.GONE);
                mProgressBar.setVisibility(View.GONE);
                mProgressBar.setProgress(0);

                mBtnAction.setText(getString(R.string.dialog_action_download));
                mBtnAction.setEnabled(mCamera != null);
                mBtnAction.setVisibility(View.VISIBLE);
                break;
            case UPGRADE_STATE_UPLOADING:
                break;
        }
    }

    private void normalTips(int resid) {
        mTvUpdateTips.setText(resid);
        mTvUpdateTips.setTextColor(getResources().getColor(R.color.colorNaviText));
        mTvUpdateTips.setVisibility(View.VISIBLE);
    }

    private void alertError(int resid) {
        mTvUpdateTips.setText(resid);
        mTvUpdateTips.setTextColor(getResources().getColor(R.color.colorRedWarn));
        mTvUpdateTips.setVisibility(View.VISIBLE);
    }

    private void showActionButton(boolean retry) {
        mTvUploading.setVisibility(View.GONE);
        mProgressBar.setVisibility(View.GONE);
        mProgressBar.setProgress(0);

        if (retry) mBtnAction.setText(R.string.retry);

        mBtnAction.setVisibility(View.VISIBLE);
        mBtnAction.setEnabled(true);
    }

    private void hideActionButton() {
        if (mUpgradeState == UPGRADE_STATE_NONE) {
            mTvUploading.setText(R.string.downloading);
        } else if (mUpgradeState == UPGRADE_STATE_UPLOADING) {
            mTvUploading.setText(R.string.uploading_point);
        }
        if (mTvUploading.getVisibility() != View.VISIBLE) {
            mTvUploading.setVisibility(View.VISIBLE);
        }
        if (mProgressBar.getVisibility() != View.VISIBLE) {
            mProgressBar.setVisibility(View.VISIBLE);
        }
        mBtnAction.setVisibility(View.INVISIBLE);
    }

    private void doUpgradeFirmware() {
        mUpgradeState = UPGRADE_STATE_UPLOADED;
        if (FirmwareUpdateActivity.this.isDestroyed()) {
            CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
            if (camera != null) {
                camera.upgradeFirmware();
            }
        } else {
            runOnUiThread(() -> DialogHelper.showUpgradeFirmwareConfirmDialog(FirmwareUpdateActivity.this,
                    () -> {
                        if (mCamera != null) {
                            mCamera.upgradeFirmware();
                        } else {
                            Logger.t(TAG).e("current camera is null !!!");
                        }
                    },
                    null));
        }
    }

    @Override
    public void onBackPressed() {
        Logger.t(TAG).e("onBackPressed: " + mUpgradeState);
        finish();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_REQUESTCODE) {
            if (grantResults.length > 0 &&
                    grantResults[0] == PermissionChecker.PERMISSION_GRANTED &&
                    grantResults[1] == PermissionChecker.PERMISSION_GRANTED) {

                // TODO: 2018/8/16  do something
                init();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE) ||
                            !shouldShowRequestPermissionRationale(Manifest.permission.READ_EXTERNAL_STORAGE);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(this,
                                () -> PermissionUtil.startAppSetting(FirmwareUpdateActivity.this),
                                this::finish);
                    } else {
                        finish();
                    }
                }
                Toast.makeText(this, getResources().getString(R.string.storage_must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED) {
                init();
            } else {
                finish();
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    VdtCamera.OnNewFwVersionListener versionListener = new VdtCamera.OnNewFwVersionListener() {
        @Override
        public void onNewVersion(int response) {
            handleFwVersionRetCode(response);
        }

        @Override
        public void onTransfer(TransferInfoBean bean) {
            handleTransfer(bean);
        }
    };
}
