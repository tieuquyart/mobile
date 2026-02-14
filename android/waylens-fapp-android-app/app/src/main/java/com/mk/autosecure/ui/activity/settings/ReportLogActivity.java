package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;

import com.afollestad.materialdialogs.GravityEnum;
import com.afollestad.materialdialogs.MaterialDialog;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.DialogUtils;
import com.mk.autosecure.model.LogTimeDrivingBean;
import com.mk.autosecure.model.LogTimeStopBean;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.opencsv.CSVReader;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.log.CameraLogClient;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.rest.BaseObserver;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/11/29.
 * Email: doanvt-hn@mk.com.vn
 */


@SuppressLint({"SimpleDateFormat", "checkResult"})
public class ReportLogActivity extends RxActivity implements DatePickerDialog.OnDateSetListener {
    public static final String TAG = ReportLogActivity.class.getSimpleName();
    private EvCamera mEVCamera = null;
    public CameraWrapper mCamera;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_current_camera)
    TextView tv_current_camera;

    @BindView(R.id.btn_send)
    Button mBtnSend;

    @BindView(R.id.ll_showBtn)
    LinearLayout llShowBtn;

    @BindView(R.id.btn_show_timeStop)
    Button mBtnShowTimeStop;

    @BindView(R.id.btn_show_timeDriving)
    Button mBtnShowTimeDriving;

    @BindView(R.id.btn_show_with_time)
    Button mBtnShowWithTime;

    @BindView(R.id.btn_send_with_date)
    Button mBtnSendWithDate;

    @BindView(R.id.tv_date_picker)
    TextView tvDatePicker;

    @BindView(R.id.spHours)
    Spinner spHours;

    @BindView(R.id.spMins)
    Spinner spMins;

    @BindView(R.id.spSeconds)
    Spinner spSeconds;

    private final TimeZone mTimeZone = TimeZone.getDefault();

    private String searchDate = "";

    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    private long utcDateTime;

    @OnClick(R.id.ll_date_picker)
    public void datePicker() {
        Calendar date = DashboardUtil.getCalendar(mTimeZone, utcDateTime);

        DatePickerDialog dialog = new DatePickerDialog(this, ReportLogActivity.this, date.get(Calendar.YEAR), date.get(Calendar.MONTH), date.get(Calendar.DAY_OF_MONTH));

        dialog.show();
    }

    @Override
    public void onDateSet(DatePicker datePicker, int year, int month, int day) {
        searchDate = String.format("%s-%s-%s", year, (month + 1) < 10 ? ("0" + (month + 1)) : month + 1, day < 10 ? "0" + day : day);
        tvDatePicker.setText(searchDate);
    }


    public enum TYPELOG {DEFAULT, TIME_DRIVING,}

    CurrentUser currentUser;

    CameraBean mCameraBean;

    Handler handler;

    MaterialDialog mProgressDialog;
    protected AppCompatDialog progress;

    List<String[]> dataRead = null;

    BehaviorSubject<CameraLogClient.CopyLogStatus> status = BehaviorSubject.create();

    private final List<CameraBean> cameraBeanList = new ArrayList<>();

    private final List<RadioButton> radioButtonList = new ArrayList<>();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, ReportLogActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        activity.startActivity(intent);
    }

    @OnClick(R.id.btn_show_timeStop)
    public void showTimeStop() {
        showDialogWithContent();
        String timeACCOffStr = "";
        String timeStopParking;
        List<LogTimeStopBean> timeStopBeans = new ArrayList<>();
        LogTimeStopBean timeStopBean;
        boolean check = false;
        if (dataRead != null && dataRead.size() != 0) {
            String[] line = null;
            double timeACCoff = 0;
            for (int i = 0; i < dataRead.size(); i++) {
                line = dataRead.get(i);
                if (!check && line[0].trim().equals("ACC_OFF")) {
                    Logger.t(TAG).e("time ACC_OFF:= " + line[1]);
                    timeACCoff = getTimeWithStr(line[1]);
                    timeACCOffStr = line[1];
                    check = true;
                } else if (check && line[0].trim().equals("STOP PARKING".trim())) {
                    Logger.t(TAG).e("time stop parking:= " + line[1]);
                    timeStopParking = line[1];
                    double timeStopCurrent = milisToMinutes(getTimeWithStr(timeStopParking) - timeACCoff);
                    Logger.t(TAG).e("timeAcc: %s, timeParking: %s, time stop: %s ", timeACCoff, getTimeWithStr(timeStopParking), timeStopCurrent);
                    check = false;
                    /*=========*/
                    timeStopBean = new LogTimeStopBean(timeACCOffStr, timeStopParking, timeStopCurrent);
                    timeStopBeans.add(timeStopBean);
                } else if (check && i == dataRead.size() - 1) {
                    Logger.t(TAG).e("time stop parking:= " + line[0]);
                    timeStopParking = line[0];
                    double timeStopCurrent = milisToMinutes(getTimeWithStr(timeStopParking) - timeACCoff);
                    Logger.t(TAG).e("timeAcc: %s, timeParking: %s, time stop: %s ", timeACCoff, getTimeWithStr(timeStopParking), timeStopCurrent);
                    check = false;
                    /*=========*/
                    timeStopBean = new LogTimeStopBean(timeACCOffStr, timeStopParking, timeStopCurrent);
                    timeStopBeans.add(timeStopBean);
                }
            }
            dismiss();
            if (timeStopBeans.size() != 0) {
                ViewLogActivity.launchTimeStop(ReportLogActivity.this, timeStopBeans, TYPELOG.DEFAULT);
            } else {
                Toast.makeText(ReportLogActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
            }
        } else {
            dismiss();
            Toast.makeText(ReportLogActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.btn_show_timeDriving)
    public void showTimeDriving() {
        showDialogWithContent();
        String timeStart = "";
        String timeACCoff;
        List<LogTimeDrivingBean> timeDrivingBeans = new ArrayList<>();
        LogTimeDrivingBean timeDrivingBean;
        String driverName = "";
        boolean check = false;
        if (dataRead != null && dataRead.size() != 0) {
            String[] line = null;
            double timeStartDriving = 0;
            for (int i = 0; i < dataRead.size(); i++) {
                line = dataRead.get(i);
                if (!check && line[0].trim().equals("START DRIVING".trim())) {
                    Logger.t(TAG).e("time START DRIVING:= " + line[1]);
                    timeStartDriving = getTimeWithStr(line[1]);
                    timeStart = line[1];
                    driverName = line[4];
                    Logger.t(TAG).d("driverName:= " + driverName);
                    check = true;
                } else if (check && line[0].trim().equals("ACC_OFF".trim())) {
                    Logger.t(TAG).e("time acc_off:= " + line[1]);
                    timeACCoff = line[1];
                    double timeDrivingCurrent = milisToMinutes(getTimeWithStr(timeACCoff) - timeStartDriving);
                    Logger.t(TAG).e("timeStart: %s, timeAccOff: %s, time driving: %s ", timeStart, getTimeWithStr(timeACCoff), timeDrivingCurrent);
                    check = false;
                    /*=========*/
                    timeDrivingBean = new LogTimeDrivingBean(driverName, timeStart, timeACCoff, timeDrivingCurrent);
                    timeDrivingBeans.add(timeDrivingBean);
                } else if (check && i == dataRead.size() - 1) {
                    Logger.t(TAG).e("time acc_off:= " + line[0]);
                    timeACCoff = line[0];
                    double timeDrivingCurrent = milisToMinutes(getTimeWithStr(timeACCoff) - timeStartDriving);
                    Logger.t(TAG).e("timeStart: %s, timeAccOff: %s, time driving: %s ", timeStart, getTimeWithStr(timeACCoff), timeDrivingCurrent);
                    check = false;
                    /*=========*/
                    timeDrivingBean = new LogTimeDrivingBean(driverName, timeStart, timeACCoff, timeDrivingCurrent);
                    timeDrivingBeans.add(timeDrivingBean);
                }
            }
            dismiss();
            if (timeDrivingBeans.size() != 0) {
                ViewLogActivity.launchTimeDriving(ReportLogActivity.this, timeDrivingBeans, TYPELOG.TIME_DRIVING);
            } else {
                Toast.makeText(ReportLogActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
            }
        } else {
            dismiss();
            Toast.makeText(ReportLogActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.btn_show_with_time)
    public void showWithTime() {
        if (dataRead != null && dataRead.size() != 0) {
            ViewLogWithTimeActivity.launch(this);
        } else {
            Toast.makeText(ReportLogActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
        }
    }

    private boolean checkAZ(String input) {
        Pattern pattern = Pattern.compile("[a-zA-Z]+");
        return pattern.matcher(input).find();
    }

    @SuppressLint("CheckResult")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handler = new Handler(getMainLooper());
        initViews();
        llShowBtn.setVisibility(View.GONE);
        logMediaCodec();

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(cameraOptional -> onCurrentCamera(cameraOptional.getIncludeNull()), new ServerErrorHandler(TAG));
    }

    private void initViews() {
        setContentView(R.layout.activity_reportlog);
        ButterKnife.bind(this);
        setupToolbar();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        currentUser = HornApplication.getComponent().currentUser();

        utcDateTime = System.currentTimeMillis();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        dateFormat.setTimeZone(mTimeZone);
        searchDate = dateFormat.format(utcDateTime);
        tvDatePicker.setText(searchDate);

        mBtnSend.setOnClickListener(view -> {
            if (mCameraBean != null) {
                Logger.t(TAG).d("camera: " + mCameraBean.name);
            } else if (mCamera != null) {
                Logger.t(TAG).d("camera: " + mCamera.getName());
            }
            if (mCamera != null) {
                feedbackWithCameraLog("");
            }
        });
        mBtnSendWithDate.setOnClickListener(view -> {
            if (mCameraBean != null) {
                Logger.t(TAG).d("camera: " + mCameraBean.name);
            } else if (mCamera != null) {
                Logger.t(TAG).d("camera: " + mCamera.getName());
            }
            if (mCamera != null) {
                Logger.t(TAG).d("selectDate:= " + searchDate);
                feedbackWithCameraLog(searchDate);
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
        mEVCamera = (EvCamera) mCamera;

        cameraBeanList.clear();
        ArrayList<CameraBean> devices = currentUser.getDevices();
        cameraBeanList.addAll(devices);

        radioButtonList.clear();

        if (mCamera != null) {
            tv_current_camera.setText("Báo cáo logs camera: " + mCamera.getSerialNumber());

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
    }

    private void initCameraList(boolean isConnected) {
        if (cameraBeanList.size() > (isConnected ? 0 : 1)) {
            if (!isConnected) {
                defaultShowFirst();
            }
        } else {
            if (!isConnected) {
                if (cameraBeanList.size() == 0) {
                    tv_current_camera.setText(getString(R.string.which_camera, getString(R.string.not_connect_camera)));
                } else {
                    defaultShowFirst();
                }
            }
        }
    }

    private void defaultShowFirst() {
        mCameraBean = cameraBeanList.get(0);
        tv_current_camera.setText(getString(R.string.which_camera, mCameraBean.name));
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
                                mProgressDialog.setTitle(R.string.feedback_reading);
                                break;
                            default:
                                break;
                        }
                    }
                });
    }

    private void unSubscribe() {
        mBtnSend.setEnabled(true);
    }


    @SuppressLint("SimpleDateFormat")
    private double getTimeWithStr(String dateStr) {
        try {
            Date date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr);
            assert date != null;
            return date.getTime();
        } catch (ParseException e) {
            e.printStackTrace();
            return 0;
        }
    }

    private double milisToMinutes(double mili) {
        Logger.t(TAG).d("mili:= " + mili);
        return (Math.floor((mili / 1000 / 60) * 100) / 100);
    }

    @SuppressLint("CheckResult")
    private void copyCameraLog(String date) {
        llShowBtn.setVisibility(View.GONE);
        Observable.create((ObservableOnSubscribe<Boolean>) subscriber -> {
                    if (mCamera != null) {
                        try {
                            int ret = mCamera.prepareLog(date).get();
                            if (ret > 0) {
                                status.onNext(new CameraLogClient.CopyLogStatus(CameraLogClient.COPY_STATUS_DOWNLOADING));
                                CameraLogClient logClient = new CameraLogClient(mCamera, VdtCamera.COPY_LOG_PORT);
                                boolean result = logClient.run(status, VdtCamera.COPY_LOG_PORT);
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
                })
                .compose(Transformers.switchSchedulers())
                .timeout(30, TimeUnit.SECONDS)
                .doFinally(this::dismissDialog)
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<Boolean>() {
                    @Override
                    protected void onHandleSuccess(Boolean data) {
                        if (data) {
                            File cameraLogsFile = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), "cameraLogs.txt");

                            try (CSVReader reader = new CSVReader(new FileReader(cameraLogsFile.getAbsoluteFile()))) {
                                dataRead = reader.readAll();
                            } catch (IOException e) {
                                dismissDialog();
                                llShowBtn.setVisibility(View.GONE);
                                Toast.makeText(ReportLogActivity.this, "Lỗi đọc dữ liệu: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                                e.printStackTrace();
                            }
                            if (dataRead != null && dataRead.size() != 0) {
                                llShowBtn.setVisibility(View.VISIBLE);
                            } else {
                                Toast.makeText(ReportLogActivity.this, "Không có dữ liệu - đọc ko có", Toast.LENGTH_SHORT).show();
                            }
                            dismissDialog();
                        } else {
                            dismissDialog();
                            Toast.makeText(ReportLogActivity.this, "Không có dữ liệu - do ghi lỗi", Toast.LENGTH_SHORT).show();
                            llShowBtn.setVisibility(View.GONE);
                        }
                    }
                });
    }


    private void feedbackWithCameraLog(String date) {
        mBtnSend.setEnabled(false);
        initDialog();
        copyCameraLog(date);
    }

    private void showDialogWithContent() {
        if (progress == null) {
            progress = DialogUtils.createProgressDialogWithMsg(this, "Vui lòng chờ...");
        }
        progress.show();
    }

    private void dismiss() {
        if (progress != null && progress.isShowing()) {
            try {
                progress.hide();
                progress.dismiss();
                progress = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }
    }


    private void dismissDialog() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
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
            tv_toolbarTitle.setText(getResources().getString(R.string.get_logs));
        }
    }
}
