package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.RequiresApi;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.mk.autosecure.HornApplication;

import android.widget.Toast;

import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.rest.ServerErrorHandler;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.CreateCameraBody;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;

public class AddCameraActivity extends RxAppCompatActivity implements DatePickerDialog.OnDateSetListener {

    private final static String TAG = AddCameraActivity.class.getSimpleName();
    private final static String CHECK_EDIT = "bean_edit";

    boolean isCameraSn = false;
    boolean isPassword = false;
    boolean isPhone = false;
    boolean isDate = false;
    private String dateSetup = "";
    private FleetCameraBean infoBean;
    private boolean isShowPassword = false;

    private TimeZone mTimeZone = TimeZone.getDefault();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
    private long utcDateTime;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.et_camera_password)
    EditText etCameraPassword;

    @BindView(R.id.et_camera_sn)
    EditText etSerialNumber;

    @BindView(R.id.et_camera_type)
    EditText etCameraType;

    @BindView(R.id.tv_setupDate)
    TextView tvSetupDate;

    @BindView(R.id.et_phone)
    EditText etPhone;

    @BindView(R.id.btn_confirm_add)
    Button btnConfirmAdd;

    @OnClick(R.id.tv_setupDate)
    public void datePicker() {
        Calendar date = DashboardUtil.getCalendar(mTimeZone, utcDateTime);

        DatePickerDialog dialog = new DatePickerDialog(this, AddCameraActivity.this, date.get(Calendar.YEAR), date.get(Calendar.MONTH), date.get(Calendar.DAY_OF_MONTH));

        dialog.show();
    }

    @Override
    public void onDateSet(DatePicker datePicker, int year, int month, int day) {
        dateSetup = String.format("%s-%s-%s", day < 10 ? "0" + day : day, (month + 1) < 10 ? ("0" + (month + 1)) : month + 1, year);
        tvSetupDate.setText(dateSetup);
        if (dateSetup != null) {
            isDate = true;
        } else {
            isDate = false;
        }
        checkEnableButton();
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @OnClick(R.id.btn_confirm_add)
    public void confirmAdd() {
        String password = etCameraPassword.getText().toString().trim();
        String sn = etSerialNumber.getText().toString().trim();
        SimpleDateFormat outPut = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        Date date = null;
        try {
            date = dateFormat.parse(tvSetupDate.getText().toString().trim());
        } catch (ParseException e) {
            e.printStackTrace();
        }
        if (date == null) {
            Toast.makeText(this, "Vui lòng chọn ngày cài đặt.", Toast.LENGTH_SHORT).show();
            return;
        }
        String setupDate = outPut.format(date);
        String cameraType = etCameraType.getText().toString().trim();
        String phone = etPhone.getText().toString().trim();
        Logger.t(TAG).d("add: " + sn + " " + password);
        if (!TextUtils.isEmpty(sn) && !TextUtils.isEmpty(password)
                && !TextUtils.isEmpty(setupDate)
                && !TextUtils.isEmpty(cameraType)
                && !TextUtils.isEmpty(phone)
        ) {
            hideSoftInputWindow();
            showPop(sn, password, cameraType, phone, setupDate);
        } else {
            Toast.makeText(this, "Vui lòng nhập thông tin camera.", Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.btn_cancel_add)
    public void cancelAdd() {
        finish();
    }


    public static void launch(Activity activity, FleetCameraBean bean) {
        Intent intent = new Intent(activity, AddCameraActivity.class);
        intent.putExtra(CHECK_EDIT, bean);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, AddCameraActivity.class);
        activity.startActivity(intent);
    }

    @SuppressLint({"UseCompatLoadingForDrawables", "ResourceAsColor"})
    private void checkEnableButton() {
        if (isCameraSn && isPassword && isPhone) {
            btnConfirmAdd.setEnabled(true);
        } else {
            btnConfirmAdd.setEnabled(false);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_camera);
        ButterKnife.bind(this);

        if (getIntent() != null) {
            infoBean = (FleetCameraBean) getIntent().getSerializableExtra(CHECK_EDIT);
        }

        isShowPassword = false;

        initView();
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    private void initView() {
        setToolbar();
        checkEnableButton();
        utcDateTime = System.currentTimeMillis();
        dateSetup = dateFormat.format(utcDateTime);
        tvSetupDate.setText(dateSetup);

        if (infoBean != null) {
            tvToolbarTitle.setText(getString(R.string.edit_camera));
            etSerialNumber.setText(infoBean.getSn());
            etSerialNumber.setEnabled(false);
            etSerialNumber.setBackground(getDrawable(R.drawable.bg_uncheck_filter));
            isCameraSn = true;
            isPassword = true;
            isPhone = true;
            checkEnableButton();

            etCameraPassword.setText(infoBean.getPassword());
            etCameraPassword.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
            etCameraType.setText(!StringUtils.isEmpty(infoBean.getCameraType()) ? infoBean.getCameraType() : "Không có dữ liệu");
            etPhone.setText(infoBean.getPhone());
            String dateInstallationStr = infoBean.getInstallationDate();
            Date dateInstallation = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                dateInstallation = sdf.parse(dateInstallationStr);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            if (dateInstallation != null) {
                Logger.t(TAG).d("dateStr: " + dateInstallationStr);
                Logger.t(TAG).d("date: " + dateInstallation.toString());
                Logger.t(TAG).d("dateConvert: " + dateFormat.format(dateInstallation));
                utcDateTime = dateInstallation.getTime();
                tvSetupDate.setText(dateFormat.format(dateInstallation));
            }
        } else {
            tvToolbarTitle.setText(getString(R.string.add_new_camera));
        }

        etCameraPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                etCameraPassword.setTransformationMethod(isShowPassword ? PasswordTransformationMethod.getInstance() : HideReturnsTransformationMethod.getInstance());
                isShowPassword = !isShowPassword;
            }
        });

        etSerialNumber.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();

                if (textValidate.length() == 8) {
                    if (textValidate.startsWith("6B")) {
                        isCameraSn = true;
                    } else {
                        etSerialNumber.setError("Nhập sai định dạng (6BXXXXXX)");
                        isCameraSn = false;
                    }
                } else {
                    etSerialNumber.setError("Nhập sai định dạng (6BXXXXXX)");
                    isCameraSn = false;
                }
                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });
        etCameraPassword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();

                if (textValidate.length() >= 8) {
                    isPassword = true;
                } else {
                    etCameraPassword.setError("Mật khẩu phải trên 8 ký tự");
                    isPassword = false;
                }

                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

        etPhone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                String regexStr = "^[+]?[0-9]{10,13}$";
                if (textValidate.matches(regexStr)) {
                    isPhone = true;
                } else {
                    etPhone.setError("Số điện thoại không đúng định dạng");
                    isPhone = false;
                }

                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });
    }

    private void setToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    private void hideSoftInputWindow() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(etSerialNumber.getWindowToken(), 0);
        }
    }

    @SuppressLint("CheckResult")
    private void showPop(String sn, String password, String cameraType, String phone, String setupDate) {
        Observable
                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                    View view = LayoutInflater.from(this).inflate(R.layout.pop_add_camera, null);
                    TextView textView = view.findViewById(R.id.tv_content);

                    if (infoBean != null) {
                        textView.setText(R.string.are_you_sure_you_want_to_edit);
                    } else {
                        textView.setText(R.string.are_you_sure_you_want_to_add);
                    }

                    PopupWindow popupWindow = new PopupWindow(view,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            false);
                    popupWindow.setOutsideTouchable(false);

//                    TextView textViewSn = view.findViewById(R.id.tv_device_sn);
//                    textViewSn.setText(String.format("S/N: %s", sn));

                    view.findViewById(R.id.btn_add_camera).setOnClickListener(v -> {
                        popupWindow.dismiss();

                        View loadingView = LayoutInflater.from(AddCameraActivity.this).inflate(R.layout.layout_loading_progress, null);
                        ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                        //fix sau --09/05/2022
                        CreateCameraBody body = new CreateCameraBody(sn, cameraType, password, phone, setupDate);

                        if (infoBean != null) {
                            ApiClient.createApiService().modifyCamera(infoBean.getId(), body, HornApplication.getComponent().currentUser().getAccessToken())
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(boolResponse -> {
                                        boolean result = boolResponse.isSuccess();
                                        Logger.t(TAG).d("editCamera result: " + result);
                                        if (result) {
//                                            HornApplication.getComponent().fleetInfo().refreshDeviceInfo();
                                            Toast.makeText(getApplicationContext(), "sửa camera thành công", Toast.LENGTH_SHORT).show();
                                            handleFinish();
                                        } else {
                                            NetworkErrorHelper.handleExpireToken(this, boolResponse);
                                        }
                                    }, throwable -> new ServerErrorHandler(TAG));
                        } else {
                            ApiClient.createApiService().addNewCamera(body, HornApplication.getComponent().currentUser().getAccessToken())
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(boolResponse -> {
                                        boolean result = boolResponse.isSuccess();
                                        Logger.t(TAG).d("createCamera result: " + result);
                                        if (result) {
//                                            HornApplication.getComponent().fleetInfo().refreshDeviceInfo();
                                            Toast.makeText(getApplicationContext(), "Thêm camera thành công", Toast.LENGTH_SHORT).show();
                                            handleFinish();
                                        } else {
                                            NetworkErrorHelper.handleExpireToken(this, boolResponse);
                                        }
                                    }, throwable -> new ServerErrorHandler(TAG));
                        }
                    });

                    view.findViewById(R.id.tv_cancel_add).setOnClickListener(v -> popupWindow.dismiss());

                    emitter.onNext(Optional.ofNullable(popupWindow));
                })
                .delay(100, TimeUnit.MILLISECONDS)
                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(windowOptional -> windowOptional.get().showAsDropDown(toolbar));
    }

    public void handleFinish() {
        Intent intent = new Intent(IntentKey.RELOAD_LIST);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        finish();
    }
}
