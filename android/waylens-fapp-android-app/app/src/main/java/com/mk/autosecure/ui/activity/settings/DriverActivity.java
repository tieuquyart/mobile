package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.mk.autosecure.HornApplication;
import android.widget.Toast;

import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.rest.ServerErrorHandler;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.request.CreateDriverBody;
import com.mk.autosecure.rest_fleet.request.EditDriverBody;

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

public class DriverActivity extends RxAppCompatActivity implements DatePickerDialog.OnDateSetListener {
    private static final String TAG = DriverActivity.class.getSimpleName();
    public static final String DRIVER_INFO = "Driver_Info";
    public static final String INFO = "info";
    private String licenceType = "";
    private String dateExpire = "";
    private static final String[] licenceTypes = new String[]{"A1", "A2", "A3", "A4", "B1", "B2", "C", "D", "E", "FB2", "FC", "FD", "FE"};

    private TimeZone mTimeZone = TimeZone.getDefault();

    SimpleDateFormat dateFormatShow = new SimpleDateFormat("dd-MM-yyyy");
    SimpleDateFormat dateFormatSend = new SimpleDateFormat("yyyy-MM-dd");
    private long utcDateTime;
    private DriverInfoBean infoBean;

    boolean isName, isId, isPhone, isLicence, isLicenceType, isEmployeeId;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolBarTitle;

    @BindView(R.id.et_driver_name)
    EditText etName;

    @BindView(R.id.sp_licenceType)
    Spinner spLicenceType;

    @BindView(R.id.et_phone_no)
    EditText etPhoneNo;


    @BindView(R.id.et_idNumber)
    EditText etIdNo;

    @BindView(R.id.et_driver_license)
    EditText etDriverLicense;

    @BindView(R.id.tv_expire_date)
    TextView tvExpireDate;

    @OnClick(R.id.tv_expire_date)
    public void datePicker() {
        Calendar date = DashboardUtil.getCalendar(mTimeZone, utcDateTime);

        DatePickerDialog dialog = new DatePickerDialog(this, DriverActivity.this, date.get(Calendar.YEAR), date.get(Calendar.MONTH), date.get(Calendar.DAY_OF_MONTH));

        dialog.show();
    }

    @Override
    public void onDateSet(DatePicker datePicker, int year, int month, int day) {
        dateExpire = String.format("%s-%s-%s", day < 10 ? "0" + day : day, (month + 1) < 10 ? ("0" + (month + 1)) : month + 1, year);
        tvExpireDate.setText(dateExpire);
    }

    @BindView(R.id.et_employeeId)
    EditText etEmployeeId;

    @BindView(R.id.btn_confirm_add)
    Button btnConfirmAdd;

    @OnClick(R.id.btn_confirm_add)
    public void confirmAdd() {
        String name = etName.getText().toString().trim();
        String phone = etPhoneNo.getText().toString().trim();
        String idNo = etIdNo.getText().toString().trim();
        String license = etDriverLicense.getText().toString().trim();
        String dateStr = tvExpireDate.getText().toString().trim();
        Date date = null;
        try {
            date = dateFormatShow.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        if (date == null) {
            Toast.makeText(this, "Chọn ngày hết hạn giấy phép tài xế.", Toast.LENGTH_SHORT).show();
            return;
        }

        String expireDate = dateFormatSend.format(date);

        String employeeId = etEmployeeId.getText().toString().trim();
        if (!TextUtils.isEmpty(name) && !TextUtils.isEmpty(phone)
                && !TextUtils.isEmpty(idNo) && !TextUtils.isEmpty(license)
                && !TextUtils.isEmpty(expireDate)
                && !TextUtils.isEmpty(employeeId)
                && !TextUtils.isEmpty(licenceType)
                && !TextUtils.isEmpty(phone)
        ) {
            hideSoftInputWindow();
            showPop(name, phone, idNo, license, licenceType, expireDate, employeeId);
        } else {
            Toast.makeText(this, "Vui lòng nhập thông tin tài xế.", Toast.LENGTH_SHORT).show();
        }
    }

    @OnClick(R.id.btn_cancel_add)
    public void cancelAdd() {
        finish();
    }

    private void setResult() {
        Intent intent = new Intent();
        intent.putExtra(INFO, HornApplication.getComponent().fleetInfo().getDriverWithId(infoBean.getId()));
        setResult(RESULT_OK, intent);
        finish();
    }


    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, DriverActivity.class);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, DriverInfoBean bean) {
        Intent intent = new Intent(activity, DriverActivity.class);
        intent.putExtra(DRIVER_INFO, bean);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_driver);
        ButterKnife.bind(this);

        if (getIntent() != null) {
            infoBean = (DriverInfoBean) getIntent().getSerializableExtra(DRIVER_INFO);
        }

        initView();
    }

    private void checkEnableButton() {
        if (isName && isId && isPhone && isLicence && isEmployeeId) {
            btnConfirmAdd.setEnabled(true);
        } else {
            btnConfirmAdd.setEnabled(false);
        }
    }

    private int getPos(String key) {
        Logger.t(TAG).d("licenceType: " + key);
        for (int i = 0; i < licenceTypes.length; i++) {
            if (key.equals(licenceTypes[i])) {
                return i;
            }
        }

        return 0;
    }

    private void initView() {
        setToolbar();
        //dropdown
        checkEnableButton();
        utcDateTime = System.currentTimeMillis();
        dateExpire = dateFormatShow.format(utcDateTime);
        tvExpireDate.setText(dateExpire);

        ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(this, R.layout.item_simple_spinner, licenceTypes);
        spLicenceType.setAdapter(dropdownAdapter);
        spLicenceType.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                licenceType = licenceTypes[i];
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
                licenceType = licenceTypes[3];
            }
        });
        //edit-flow
        if (infoBean != null) {
            tvToolBarTitle.setText(getString(R.string.driver_edit));
            etDriverLicense.setText(infoBean.getName());
            //dropdown
            int pos = getPos(infoBean.getLicenseType());
            Logger.t(TAG).d("pos: " + pos);
            spLicenceType.setSelection(pos);
            //end
            etName.setText(infoBean.getName());
            etPhoneNo.setText(infoBean.getPhoneNo());
            etIdNo.setText(infoBean.getIdNumber());
            etDriverLicense.setText(infoBean.getLicense());
            String[] arrTime = infoBean.getDrivingYears().split("T");
            if (arrTime.length > 1) {
                tvExpireDate.setText(arrTime[0]);
            } else {
                tvExpireDate.setText(infoBean.getDrivingYears());
            }
//            tvExpireDate.setText(infoBean.getDrivingYears());
            etEmployeeId.setText(infoBean.getEmployeeId());
            etEmployeeId.setEnabled(false);
            etEmployeeId.setBackground(getDrawable(R.drawable.bg_uncheck_filter));
            isId = true;
            isName = true;
            isPhone = true;
            isLicence = true;
            isLicence = true;
            isEmployeeId = true;
            checkEnableButton();
        } else {
            tvToolBarTitle.setText(getString(R.string.add_new_driver));
        }

        //end
        etName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() == 0) {
                    isName = false;
                    etName.setError("Nhập thông tin tài xế");
                } else {
                    isName = true;
                }
                checkEnableButton();
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() == 0) {
                    isName = false;
                    etName.setError("Nhập tên tài xế");
                } else {
                    isName = true;
                }
                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {
                String textValidate = editable.toString();
                if (textValidate.length() == 0) {
                    isName = false;
                    etName.setError("Nhập tên tài xế");
                } else {
                    isName = true;
                }
                checkEnableButton();
            }
        });

        etIdNo.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() != 12) {
                    isId = false;
                    etIdNo.setError("Nhập số CCCD");
                } else {
                    isId = true;
                }
                checkEnableButton();
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() != 12) {
                    isId = false;
                    etIdNo.setError("Nhập số CCCD");
                } else {
                    isId = true;
                }
                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {
                String textValidate = editable.toString();
                if (textValidate.length() != 12) {
                    isId = false;
                    etIdNo.setError("Nhập số CCCD");
                } else {
                    isId = true;
                }
                checkEnableButton();
            }
        });

        etPhoneNo.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (StringUtils.isPhoneValid(textValidate)) {
                    isPhone = true;
                } else {
                    etPhoneNo.setError("Số điện thoại không đúng định dạng");
                    isPhone = false;
                }

                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

        etEmployeeId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() == 0) {
                    isEmployeeId = false;
                    etEmployeeId.setError("Nhập mã hiệu tài xế");
                } else {
                    isEmployeeId = true;
                }
                checkEnableButton();
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

        etDriverLicense.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                String textValidate = charSequence.toString();
                if (textValidate.length() == 0) {
                    isLicence = false;
                    etDriverLicense.setError("Nhập giấy phép lái xe");
                } else {
                    isLicence = true;
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
            imm.hideSoftInputFromWindow(etName.getWindowToken(), 0);
        }
    }

    @SuppressLint("CheckResult")
    private void showPop(String name, String phoneNo, String idNo, String license, String licenseType, String expireDate, String employee) {
        Observable
                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
                    View view = LayoutInflater.from(this).inflate(R.layout.pop_add_camera, null);
                    PopupWindow popupWindow = new PopupWindow(view,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
                            false);
                    popupWindow.setOutsideTouchable(false);

                    TextView textView = view.findViewById(R.id.tv_device_sn);
                    textView.setText(getString(R.string.notice));

                    TextView textContent = view.findViewById(R.id.tv_content);
                    if(infoBean != null){
                        textContent.setText(getString(R.string.are_you_sure_you_want_to_edit_driver));
                    }else{
                        textContent.setText(getString(R.string.are_you_sure_you_want_to_add_driver));
                    }

                    view.findViewById(R.id.btn_add_camera).setOnClickListener(v -> {
                        popupWindow.dismiss();

                        View loadingView = LayoutInflater.from(DriverActivity.this).inflate(R.layout.layout_loading_progress, null);
                        ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).addView(loadingView);

                        if (infoBean != null) {
                            EditDriverBody body = new EditDriverBody(infoBean.getId(), name, "", phoneNo, idNo, license, licenceType, expireDate, infoBean.getEmployeeId());

                            ApiClient.createApiService().editDriver(infoBean.getId(), body, HornApplication.getComponent().currentUser().getAccessToken())
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(booleanRes -> {
                                        if (booleanRes.isSuccess()) {
                                            Toast.makeText(DriverActivity.this, "Sửa thông tin tài xế thành công", Toast.LENGTH_SHORT).show();
//                                            HornApplication.getComponent().fleetInfo().refreshDriverInfo();
                                            handleFinish();
                                        } else {
                                            NetworkErrorHelper.handleExpireToken(DriverActivity.this, booleanRes);
                                        }
                                    });
                        } else {

                            CreateDriverBody body = new CreateDriverBody(name, "", phoneNo, idNo, license, licenseType, expireDate, employee);

                            ApiClient.createApiService().addNewDriver(body, HornApplication.getComponent().currentUser().getAccessToken())
                                    .compose(Transformers.switchSchedulers())
                                    .compose(bindToLifecycle())
                                    .doFinally(() -> ((FrameLayout) findViewById(Window.ID_ANDROID_CONTENT)).removeView(loadingView))
                                    .subscribe(boolResponse -> {
                                        boolean result = boolResponse.isSuccess();
                                        Logger.t(TAG).d("createDriver result: " + result);
                                        if (result) {
//                                            HornApplication.getComponent().fleetInfo().refreshDriverInfo();
                                            Toast.makeText(getApplicationContext(), "Thêm tài xế thành công", Toast.LENGTH_SHORT).show();

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

    public void handleFinish(){
        Intent intent = new Intent(IntentKey.RELOAD_LIST);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        finish();
    }
}
