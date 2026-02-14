package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;

import com.afollestad.materialdialogs.GravityEnum;
import com.afollestad.materialdialogs.MaterialDialog;
import com.google.android.material.snackbar.Snackbar;
import com.google.android.material.textfield.TextInputEditText;
import com.mk.autosecure.HornApplication;
import android.widget.Toast;

import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.log.CameraLogClient;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.LogUtil;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.request.ReportFeedbackBody;
import com.mk.autosecure.ui.activity.LoginActivity;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnTextChanged;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.subjects.BehaviorSubject;
import okhttp3.MultipartBody;

/**
 * Created by DoanVT on 2017/11/29.
 * Email: doanvt-hn@mk.com.vn
 */


@SuppressLint("SimpleDateFormat")
public class FeedbackActivity extends RxActivity {
    public static final String TAG = FeedbackActivity.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_current_camera)
    TextView tv_current_camera;

    @BindView(R.id.feedback_content)
    EditText mFeedbackContent;

    @BindView(R.id.ll_cameras)
    LinearLayout ll_cameras;

    @BindView(R.id.rg_cameras)
    RadioGroup rg_cameras;

    @BindView(R.id.btn_send)
    Button mBtnSend;

    @BindView(R.id.cb_app_log)
    CheckBox mCbWithLog;

    @BindView(R.id.cb_camera_log)
    CheckBox mCbWithCameraLog;

    @BindView(R.id.tv_not_connect)
    TextView tv_not_connect;

    @BindView(R.id.ll_email_fleet)
    LinearLayout llEmailFleet;

    @BindView(R.id.feedback_email)
    TextInputEditText feedbackEmail;

    @OnTextChanged(R.id.feedback_email)
    public void email(final @NonNull CharSequence email) {
        mBtnSend.setEnabled(true);
    }

    CurrentUser currentUser;

    CameraWrapper mCamera;

    CameraBean mCameraBean;

    Handler handler;

    MaterialDialog mProgressDialog;

    private Disposable subscribe;

    BehaviorSubject<CameraLogClient.CopyLogStatus> status = BehaviorSubject.create();

    private List<CameraBean> cameraBeanList = new ArrayList<>();

    private List<RadioButton> radioButtonList = new ArrayList<>();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, FeedbackActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        activity.startActivity(intent);
    }

    @SuppressLint("CheckResult")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handler = new Handler(getMainLooper());
        initViews();

        logMediaCodec();

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(cameraOptional -> onCurrentCamera(cameraOptional.getIncludeNull()), new ServerErrorHandler(TAG));
    }

    private void initViews() {
        setContentView(R.layout.activity_feedback);
        ButterKnife.bind(this);
        setupToolbar();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        currentUser = HornApplication.getComponent().currentUser();

        mBtnSend.setOnClickListener(view -> {
            if (mCameraBean != null) {
                Logger.t(TAG).d("camera: " + mCameraBean.name);
            } else if (mCamera != null) {
                Logger.t(TAG).d("camera: " + mCamera.getName());
            }
            if (TextUtils.isEmpty(mFeedbackContent.getText())) {
                Snackbar.make(mFeedbackContent, getResources().getString(R.string.feedback_empty), Snackbar.LENGTH_SHORT).show();
            } else {
                if ("access2bcamera".equals(mFeedbackContent.getText().toString().trim().toLowerCase())) {
                    boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, Constants.isFleet());
                    PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOB_CAMERA, !aBoolean);
                    Toast.makeText(this,
                            aBoolean ? getString(R.string.unenable_access_2b) : getString(R.string.enable_access_2b),
                            Toast.LENGTH_LONG).show();
                    return;
                }
                if ("access2ccamera".equals(mFeedbackContent.getText().toString().trim().toLowerCase())) {
                    boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, !Constants.isFleet());
                    PreferenceUtils.putBoolean(PreferenceUtils.ACCESS_TOC_CAMERA, !aBoolean);
                    Toast.makeText(this,
                            aBoolean ? getString(R.string.unenable_access_2c) : getString(R.string.enable_access_2c),
                            Toast.LENGTH_LONG).show();
                    return;
                }
                if ("showvideoqualitysettings".equals(mFeedbackContent.getText().toString().trim().toLowerCase())) {
                    boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.SHOW_VIDEO_QUALITY, false);
                    PreferenceUtils.putBoolean(PreferenceUtils.SHOW_VIDEO_QUALITY, !aBoolean);
                    Toast.makeText(this,
                            aBoolean ? getString(R.string.unenable_video_quality) : getString(R.string.enable_video_quality),
                            Toast.LENGTH_LONG).show();
                    return;
                }
                if ("showdebugsettings".equals(mFeedbackContent.getText().toString().trim().toLowerCase())) {
                    boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.SHOW_DEBUG_SETTING, false);
                    PreferenceUtils.putBoolean(PreferenceUtils.SHOW_DEBUG_SETTING, !aBoolean);
                    Toast.makeText(this,
                            aBoolean ? getString(R.string.unenable_debug_setting) : getString(R.string.enable_debug_setting),
                            Toast.LENGTH_LONG).show();
                    return;
                }
                if (!preprocessed(mFeedbackContent.getText().toString())) {
                    Logger.t(TAG).d("appLog = " + mCbWithLog.isChecked() + ", cameraLog = " + mCbWithCameraLog.isChecked());
                    if (mCbWithCameraLog.isChecked() & mCamera != null) {

                        //check log
                        feedbackWithCameraLog();
//                        copyCameraLog("");
                    } else {
                        doReportFeedback();
                    }
                }
            }
        });
    }

    private void logMediaCodec() {
        try {
            MediaCodec decoderByType = MediaCodec.createDecoderByType("video/avc");
            printfCodec(decoderByType, "Decoder");

            MediaCodec encoderByType = MediaCodec.createEncoderByType("video/avc");
            printfCodec(encoderByType, "Encoder");
        } catch (IOException e) {
            Logger.t(TAG).e("logMediaCodec error: " + e.getMessage());
        }
    }

    private void printfCodec(MediaCodec mediaCodec, String type) {
        try {
            MediaCodecInfo codecInfo = mediaCodec.getCodecInfo();

            MediaCodecInfo.CodecCapabilities capabilitiesForType = codecInfo.getCapabilitiesForType("video/avc");
            MediaCodecInfo.VideoCapabilities videoCapabilities = capabilitiesForType.getVideoCapabilities();

            Logger.t(TAG).d(type + " codecInfo: "
                    + " SupportedWidths: " + videoCapabilities.getSupportedWidths()
                    + " SupportedHeights: " + videoCapabilities.getSupportedHeights()
                    + " SupportedFrameRatesFor: " + videoCapabilities.getSupportedFrameRatesFor(1920, 1080));
        } catch (Exception ex) {
            Logger.t(TAG).e("printfCodec error: " + ex.getMessage());
        }
    }

    private void onCurrentCamera(CameraWrapper cameraWrapper) {
        Logger.t(TAG).d("onCurrentCamera: " + cameraWrapper);
        mCamera = cameraWrapper;

        cameraBeanList.clear();
        ArrayList<CameraBean> devices = currentUser.getDevices();
        cameraBeanList.addAll(devices);

        radioButtonList.clear();
        rg_cameras.removeAllViews();

        if (mCamera != null) {
            RadioButton radioButton = createRadio(mCamera.getName());
            radioButtonList.add(radioButton);
            rg_cameras.addView(radioButton);
            radioButton.setChecked(true);

            showCameraLog();
            enableCameraLog();
            tv_current_camera.setText(getString(R.string.which_camera, mCamera.getName()));

            for (CameraBean bean : cameraBeanList) {
                if (mCamera.getSerialNumber().equals(bean.sn)) {
                    cameraBeanList.remove(bean);
                    break;
                }
            }

            initCameraList(true);
        } else {
            initCameraList(false);
        }

        rg_cameras.setOnCheckedChangeListener((group, checkedId) -> {
            RadioButton viewById = findViewById(checkedId);
            int index = radioButtonList.indexOf(viewById);
            if (mCamera != null && index == 0) {
                enableCameraLog();
                mCameraBean = null;
                tv_current_camera.setText(getString(R.string.which_camera, mCamera.getName()));
            } else {
                disableCameraLog();
                //排除已连接的相机
                mCameraBean = cameraBeanList.get(mCamera == null ? index : index - 1);
                tv_current_camera.setText(getString(R.string.which_camera, mCameraBean.name));
            }
        });
    }

    private void initCameraList(boolean isConnected) {
        if (cameraBeanList.size() > (isConnected ? 0 : 1)) {
            //显示相机选择栏
            ll_cameras.setVisibility(View.VISIBLE);
            for (CameraBean bean : cameraBeanList) {
                RadioButton radioButton = createRadio(bean.name);
                radioButtonList.add(radioButton);
                rg_cameras.addView(radioButton);
            }
            if (!isConnected) {
                defaultShowFirst();
                radioButtonList.get(0).setChecked(true);
            }
        } else {
            //不显示相机选择栏
            ll_cameras.setVisibility(View.GONE);
            if (!isConnected) {
                if (cameraBeanList.size() == 0) {
                    hideCameraLog();
                    tv_current_camera.setText(getString(R.string.which_camera,
                            Constants.isFleet() ? getString(R.string.fleet_app) : getString(R.string.secure360_app)));
                } else {
                    defaultShowFirst();
                }
            }
        }
    }

    private void defaultShowFirst() {
        showCameraLog();
        disableCameraLog();
        mCameraBean = cameraBeanList.get(0);
        tv_current_camera.setText(getString(R.string.which_camera, mCameraBean.name));
    }

    private RadioButton createRadio(String name) {
        RadioButton radioButton = new RadioButton(this);
        RadioGroup.LayoutParams params = new RadioGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(20), Gravity.CENTER_VERTICAL);
        params.setMargins(0, ViewUtils.dp2px(9), 0, ViewUtils.dp2px(9));
        radioButton.setLayoutParams(params);
        radioButton.setText(name);
        radioButton.setTextColor(getResources().getColor(R.color.colorPrimary));
        radioButton.setTextSize(14f);
        return radioButton;
    }

    private void hideCameraLog() {
        mCbWithCameraLog.setVisibility(View.GONE);
        tv_not_connect.setVisibility(View.GONE);
    }

    private void showCameraLog() {
        mCbWithCameraLog.setVisibility(View.VISIBLE);
    }

    private void enableCameraLog() {
        mCbWithCameraLog.setChecked(true);
        mCbWithCameraLog.setEnabled(true);
        tv_not_connect.setVisibility(View.GONE);
    }

    private void disableCameraLog() {
        mCbWithCameraLog.setChecked(false);
        mCbWithCameraLog.setEnabled(false);
        tv_not_connect.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (Constants.isManager()) {
            if (!currentUser.exists()) {
                LoginActivity.launch(this);
            }
        }
    }

    private boolean preprocessed(String text) {
        return false;
    }

    private void initDialog() {
        mProgressDialog = new MaterialDialog.Builder(this)
                .title(R.string.feedback_preparing)
                .customView(R.layout.dialog_central_progressbar, false)
                .contentGravity(GravityEnum.CENTER)
                .negativeText(R.string.cancel)
                .canceledOnTouchOutside(false)
                .onNegative((dialog, which) -> unSubscribe()).show();

        status.compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .doOnError(throwable -> dismissDialog())
                .subscribe(new BaseObserver<CameraLogClient.CopyLogStatus>() {
                    @Override
                    protected void onHandleSuccess(CameraLogClient.CopyLogStatus data) {
                        switch (data.status) {
                            case CameraLogClient.COPY_STATUS_DOWNLOADING:
                                mProgressDialog.setTitle(R.string.feedback_downloading);
                                break;
                            case CameraLogClient.COPY_STATUS_FINISH:
                                mProgressDialog.setTitle(R.string.feedback_sending);
                                break;
                            default:
                                break;
                        }
                    }
                });
    }

    private void unSubscribe() {
        mBtnSend.setEnabled(true);

        if (subscribe != null && !subscribe.isDisposed()) {
            subscribe.dispose();
        }
    }

    private Observable<Boolean> copyCameraLog() {
        return Observable.create(subscriber -> {
            if (mCamera != null) {
                try {
                    int ret = mCamera.prepareDebugLog().get();
                    Logger.t(TAG).d("prepareDebugLog = " + ret);
                    status.onNext(new CameraLogClient.CopyLogStatus(CameraLogClient.COPY_STATUS_DOWNLOADING));
                    if (ret > 0) {
                        CameraLogClient logClient = new CameraLogClient(mCamera, VdtCamera.COPY_DEBUGLOG_PORT);
                        boolean result = logClient.run(status, VdtCamera.COPY_DEBUGLOG_PORT);
                        Logger.t(TAG).d("logClient = " + result);
                        subscriber.onNext(result);
                    } else {
                        subscriber.onNext(false);
                    }
                } catch (InterruptedException | ExecutionException e) {
                    e.printStackTrace();
                }
            } else {
                subscriber.onNext(false);
            }
        });
    }

    private Observable<ReportFeedbackBody> collectInfo() {
        return Observable
                .create((ObservableOnSubscribe<StringBuffer>) subscriber -> {
                    if (mCbWithLog.isChecked()) {
                        StringBuffer stringBuffer = LogUtil.getDiskLog();
                        subscriber.onNext(stringBuffer);
                    } else {
                        subscriber.onNext(new StringBuffer());
                    }
                })
                .delay(3000, TimeUnit.MILLISECONDS)
                .map(stringBuffer -> {
                    ReportFeedbackBody reportFeedbackBody = new ReportFeedbackBody();
                    String emailStr = "";
                    if (Constants.isFleet()) {
                        if (currentUser.getUserLogin() != null) {
                            emailStr = currentUser.getUserLogin().getRealName().trim();
                        }
                        reportFeedbackBody.email = emailStr;
                    }
                    reportFeedbackBody.detail = mFeedbackContent.getText().toString();
                    reportFeedbackBody.agentHW = Build.MANUFACTURER + Build.MODEL;
                    reportFeedbackBody.agentOS = "android " + Build.VERSION.RELEASE;
                    reportFeedbackBody.appVersion = BuildConfig.VERSION_NAME;
                    Logger.t(TAG).d(mFeedbackContent.getText().toString());
                    if (mCamera != null) {
                        reportFeedbackBody.cameraSN = mCamera.getSerialNumber();
                        reportFeedbackBody.cameraHW = mCamera.getHardwareName();
                        reportFeedbackBody.cameraFW = mCamera.getBspFirmware();
                        reportFeedbackBody.mountHW = mCamera.getMountVersion().hw_version;
                        reportFeedbackBody.mountFW = mCamera.getMountVersion().sw_version;
                    } else if (mCameraBean != null) {
                        reportFeedbackBody.cameraSN = mCameraBean.sn;
                        reportFeedbackBody.cameraHW = mCameraBean.hardwareVersion;
                        reportFeedbackBody.cameraFW = mCameraBean.state.firmware;
                        reportFeedbackBody.mountHW = mCameraBean.state.mountInfo.mountHWVersion;
                        reportFeedbackBody.mountFW = mCameraBean.state.mountInfo.mountFWVersion;
                    }
                    if (stringBuffer != null) {
                        reportFeedbackBody.log = stringBuffer.toString();
                        //Logger.t(TAG).d(stringBuffer.toString());
                    }
                    return reportFeedbackBody;
                });
    }

    private void feedbackWithCameraLog() {
        mBtnSend.setEnabled(false);
        initDialog();
        subscribe = Observable
                .zip(copyCameraLog(), collectInfo(), (aBoolean, body) -> {
                    List<File> fileList = new ArrayList<>();// LogUtil.getLogFiles();
//                    String logPath = FileUtils.getCameraLogPath();
//                    File fileCameraLog;
//                    File testFile;
//                    if (logPath != null) {
//                        fileCameraLog = new File(logPath, FileUtils.CAMERA_DEBUGLOG_FILENAME);
//                        fileList.add(fileCameraLog);
//
//                        testFile = new File(logPath, FileUtils.TEST_LOG_FILENAME);
//                        fileList.add(testFile);
//                    }
                    File cameraLogsFile = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), "cameraDebugLogs.txt");
                    fileList.add(cameraLogsFile);
                    File zipFile = FileUtils.zipFiles(fileList, FileUtils.FEEDBACK_DEBUGLOG_FILENAME);
                    Logger.t(TAG).e("zipFiles: " + zipFile);
                    return LogUtil.createMultipartBody(body, zipFile);
                })
                .filter(multipartBody -> mProgressDialog != null && mProgressDialog.isShowing())
                .compose(Transformers.switchSchedulers())
                .doFinally(this::dismissDialog)
                .compose(bindToLifecycle())
                .subscribe(this::sendFeedbackMultipart, new ServerErrorHandler(TAG));
    }

    private void doReportFeedback() {
        mBtnSend.setEnabled(false);
        initDialog();

        subscribe = collectInfo()
                .map(body -> {
                    List<File> fileList = LogUtil.getLogFiles();
                    File zipFile = FileUtils.zipFiles(fileList, FileUtils.FEEDBACK_DEBUGLOG_FILENAME);
                    return LogUtil.createMultipartBody(body, zipFile);
                })
                .filter(multipartBody -> mProgressDialog != null && mProgressDialog.isShowing())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(this::sendFeedbackMultipart, new ServerErrorHandler(TAG));
    }

    private void sendFeedbackMultipart(MultipartBody body) {
        dismissDialog();
        Toast.makeText(this, "report finish", Toast.LENGTH_SHORT).show();

        Logger.t(TAG).d("body = " + ToStringUtils.toString(body));

        Observable<BooleanResponse> observable;
        if (Constants.isFleet()) {
            observable = ApiClient.createApiService().reportMultipart(body);
        } else {
            observable = ApiService.createApiService().reportMultipart(body);
        }

        observable
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .filter(multipartBody -> mProgressDialog != null && mProgressDialog.isShowing())
                .doFinally(this::dismissDialog)
                .doOnError(throwable -> {
                    mBtnSend.setEnabled(true);
                    NetworkErrorHelper.handleCommonError(this, throwable);
                })
                .subscribe(new BaseObserver<BooleanResponse>() {
                    @Override
                    protected void onHandleSuccess(BooleanResponse data) {
                        onFeedbackResponse(data);
                    }
                });
    }

    private void dismissDialog() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }

    private void onFeedbackResponse(BooleanResponse data) {
        Logger.t(TAG).d("reportMultipart: " + data.result);
        mBtnSend.setEnabled(true);
        Snackbar.make(mFeedbackContent, getResources().getString(R.string.feedback_success), Snackbar.LENGTH_LONG).show();
        handler.postDelayed(this::finish, 2500);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.report_issues));
        }
    }
}
