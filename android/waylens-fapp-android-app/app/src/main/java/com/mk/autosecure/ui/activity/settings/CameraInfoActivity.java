package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CameraSubscriber;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DebugHelper;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.request.CameraNameBody;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;
import retrofit2.Response;


/**
 * Created by DoanVT on 2017/11/23.
 * Email: doanvt-hn@mk.com.vn
 */


public class CameraInfoActivity extends RxActivity {

    private static final String TAG = CameraInfoActivity.class.getSimpleName();


    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.ll_camera_name)
    LinearLayout ll_cameraName;

    @BindView(R.id.tv_camera_name)
    TextView tv_cameraName;

    @BindView(R.id.iv_edit)
    ImageView ivEdit;

    @BindView(R.id.tv_serialNumber)
    TextView tv_serialNumber;

    @BindView(R.id.tv_hardwareMode)
    TextView tv_hardwareModel;

    @BindView(R.id.tv_firmwareVersion)
    TextView tv_firmwareVersion;

    @BindView(R.id.ll_mount_model)
    LinearLayout llMountModel;

    @BindView(R.id.tv_mountModel)
    TextView tv_mountModel;

    @BindView(R.id.ll_mount_version)
    LinearLayout llMountVersion;

    @BindView(R.id.tv_mountVersion)
    TextView tv_mountVersion;

    @BindView(R.id.ll_modem)
    LinearLayout ll_modem;

    @BindView(R.id.tv_modemVersion)
    TextView tv_modemVersion;

    @BindView(R.id.ll_modem_debug)
    LinearLayout ll_modem_debug;

    @BindView(R.id.tv_modemVersionDebug)
    TextView tv_modemVersionDebug;

    @BindView(R.id.et_camera_name)
    EditText et_cameraName;

    @BindView(R.id.ll_fourg_network)
    LinearLayout ll_fourg_network;

    @OnTextChanged(R.id.et_camera_name)
    void onNameTextChanged(final @NonNull CharSequence name) {
        MenuItem item = toolbar.getMenu().findItem(R.id.save);
        if (item != null) {
            item.setEnabled(!TextUtils.isEmpty(name));
        }
    }

    @OnClick(R.id.ll_camera_name)
    void editName() {
        if (!Constants.isFleet()) {
            ll_cameraName.setVisibility(View.GONE);
            et_cameraName.setVisibility(View.VISIBLE);
            et_cameraName.requestFocus();
        }
    }

    @OnClick(R.id.ll_fourg_network)
    public void network() {
        if (!TextUtils.isEmpty(serialNumber)) {
            NetworkInfoActivity.launch(this, serialNumber);
        } else if (mCameraBean != null) {
            NetworkInfoActivity.launch(this, mCameraBean.sn);
        } else if (mFleetCamera != null) {
            NetworkInfoActivity.launch(this, mFleetCamera.getSn());
        }
    }

    protected String serialNumber;
    protected CameraBean mCameraBean;
    protected FleetCameraBean mFleetCamera;
    protected CameraWrapper mCamera;

    // low level error, network etc.
    private PublishSubject<Throwable> llError = PublishSubject.create();

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, CameraInfoActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CameraBean cameraBean) {
        Intent intent = new Intent(activity, CameraInfoActivity.class);
        intent.putExtra(IntentKey.CAMERA_BEAN, cameraBean);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, FleetCameraBean fleetCamera) {
        Intent intent = new Intent(activity, CameraInfoActivity.class);
        intent.putExtra(IntentKey.FLEET_CAMERA, fleetCamera);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        serialNumber = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        mCameraBean = (CameraBean) getIntent().getSerializableExtra(IntentKey.CAMERA_BEAN);
        mFleetCamera = (FleetCameraBean) getIntent().getSerializableExtra(IntentKey.FLEET_CAMERA);
        init();
    }

    protected void init() {
        if (!TextUtils.isEmpty(serialNumber)) {
            mCamera = VdtCameraManager.getManager().getCamera(serialNumber);
        }

        initViews();
        setupToolbar();

        Logger.t(TAG).e("serialNumber: " + serialNumber);
        Logger.t(TAG).e("mCameraBean: " + mCameraBean);
        Logger.t(TAG).e("mCamera: " + mCamera);

        llError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLowLevelError, new ServerErrorHandler(TAG));
    }

    private void onLowLevelError(Throwable e) {
        NetworkErrorHelper.handleCommonError(this, e);
    }

    private void initViews() {
        setContentView(R.layout.activity_camera_info);
        ButterKnife.bind(this);

        if (Constants.isFleet()) {
            ivEdit.setVisibility(View.INVISIBLE);
        } else {
            toolbar.getMenu().clear();
            toolbar.inflateMenu(R.menu.username_save);
            toolbar.setOnMenuItemClickListener(item -> {
                switch (item.getItemId()) {
                    case R.id.save:
                        et_cameraName.clearFocus();
                        et_cameraName.setVisibility(View.GONE);
                        ll_cameraName.setVisibility(View.VISIBLE);
                        tv_cameraName.setText(et_cameraName.getText());

                        toolbar.getMenu().findItem(R.id.save).setEnabled(false);
                        saveCameraName();
                        break;
                    default:
                        break;
                }
                return false;
            });
        }

        et_cameraName.setOnEditorActionListener((v, actionId, event) -> {
            Logger.t(TAG).e("onEditorAction: " + actionId);
            if (actionId == KeyEvent.KEYCODE_ENDCALL) {
                et_cameraName.clearFocus();
            }
            return false;
        });

        et_cameraName.setOnFocusChangeListener((v, hasFocus) -> {
            InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
            if (imm != null) {
                if (hasFocus) {
                    imm.showSoftInput(v, 0);
                } else {
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                }
            }
        });

        if (mCamera != null) {
            tv_serialNumber.setText(mCamera.getSerialNumber());
            tv_hardwareModel.setText(mCamera.getHardwareName());

            tv_cameraName.setText(mCamera.getName());
            et_cameraName.setText(mCamera.getName());
            et_cameraName.setSelection(et_cameraName.getText().length());

            String apiVersion = mCamera.getApiVersion();
            tv_firmwareVersion.setText(apiVersion);

            if (DebugHelper.isInDebugMode()) {
                ll_modem_debug.setVisibility(View.VISIBLE);
            }

            if (mCamera.getMountVersion() != null && mCamera.getMountVersion().support_4g
                    && mCamera.isModemVersionAvailable()) {
                tv_modemVersion.setText(mCamera.getModemVersion());
                tv_modemVersionDebug.setText(mCamera.getModemVersionDebug());
            } else {
                ll_modem.setVisibility(View.GONE);
                ll_modem_debug.setVisibility(View.GONE);
            }

            if (mCamera.getMountVersion() != null) {
                tv_mountModel.setText(mCamera.getMountVersion().hw_version);
                tv_mountVersion.setText(mCamera.getMountVersion().sw_version);

                if (mCamera.getMountVersion().support_4g) {
                    ll_fourg_network.setVisibility(View.VISIBLE);
                }
            }

            tv_firmwareVersion.setOnClickListener(v -> {
                if (tv_firmwareVersion.getText().toString().equals(apiVersion)) {
                    tv_firmwareVersion.setText(mCamera.getBspFirmware());
                } else {
                    tv_firmwareVersion.setText(apiVersion);
                }
            });
        } else if (mCameraBean != null) {
            tv_cameraName.setText(mCameraBean.name);
            et_cameraName.setText(mCameraBean.name);
            et_cameraName.setSelection(et_cameraName.getText().length());

            tv_serialNumber.setText(mCameraBean.sn);
            tv_hardwareModel.setText(mCameraBean.hardwareVersion);

            if (mCameraBean.state != null) {
                String firmwareShort = mCameraBean.state.firmwareShort;
                tv_firmwareVersion.setText(firmwareShort);

                if (mCameraBean.is4G != null && mCameraBean.is4G
                        && StringUtils.compareToApiVersion(firmwareShort, "1.12.0") >= 0) {
                    tv_modemVersion.setText(mCameraBean.state.modem);
                } else {
                    ll_modem.setVisibility(View.GONE);
                }

                tv_firmwareVersion.setOnClickListener(v -> {
                    if (tv_firmwareVersion.getText().toString().equals(firmwareShort)) {
                        tv_firmwareVersion.setText(mCameraBean.state.firmware);
                    } else {
                        tv_firmwareVersion.setText(firmwareShort);
                    }
                });

                if (mCameraBean.state.mountInfo != null) {
                    tv_mountModel.setText(mCameraBean.state.mountInfo.mountHWVersion);
                    tv_mountVersion.setText(mCameraBean.state.mountInfo.mountFWVersion);
                }
            }

            if (mCameraBean.is4G != null && mCameraBean.is4G) {
                ll_fourg_network.setVisibility(View.VISIBLE);
            }
        } else if (mFleetCamera != null) {
            tv_cameraName.setText(mFleetCamera.getSn());
            et_cameraName.setText(mFleetCamera.getSn());
            et_cameraName.setSelection(et_cameraName.getText().length());

            tv_serialNumber.setText(mFleetCamera.getSn());
            tv_hardwareModel.setText(mFleetCamera.getHardwareVersion());

            String firmwareShort = mFleetCamera.getFirmwareShort();
            tv_firmwareVersion.setText(firmwareShort);

            ll_modem.setVisibility(View.GONE);
            llMountModel.setVisibility(View.GONE);
            llMountVersion.setVisibility(View.GONE);

            tv_firmwareVersion.setOnClickListener(v -> {
                if (tv_firmwareVersion.getText().toString().equals(firmwareShort)) {
                    tv_firmwareVersion.setText(mFleetCamera.getFirmware());
                } else {
                    tv_firmwareVersion.setText(firmwareShort);
                }
            });

            ll_fourg_network.setVisibility(View.VISIBLE);
        }

        MenuItem item = toolbar.getMenu().findItem(R.id.save);
        if (item != null) {
            item.setEnabled(false);
        }
    }

    private void saveCameraName() {
        String newCameraName = et_cameraName.getText().toString();
        if (mCamera != null) {
            CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(serialNumber);
            if (cameraItem != null) {
                cameraItem.setCameraName(newCameraName);
                LocalCameraDaoManager.getInstance().update(cameraItem);
            }
            mCamera.setName(newCameraName);
            uploadRemoteName(mCamera.getSerialNumber(), newCameraName);
        } else if (mCameraBean != null) {
            uploadRemoteName(mCameraBean.sn, newCameraName);
        } else if (mFleetCamera != null) {

        }
    }

    private void uploadRemoteName(String sn, String newCameraName) {
        CameraNameBody nameBody = new CameraNameBody();
        nameBody.name = newCameraName;
        ApiService.createApiService().setCameraName(sn, nameBody)
                .subscribeOn(Schedulers.io())
                .compose(Transformers.pipeErrorsTo(llError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<Response<BooleanResponse>>() {
                    @Override
                    protected void onHandleSuccess(Response<BooleanResponse> data) {
                        boolean result = data.body().result;
                        Logger.t(TAG).d("setCameraName: " + result);

                        if (result) {
                            ApiService.createApiService().getCameras()
                                    .compose(Transformers.switchSchedulers())
                                    .subscribe(new CameraSubscriber());
                        }
                    }
                });
    }

    private void setupToolbar() {
        toolbar = findViewById(R.id.toolbar);
        if (toolbar != null) {
            TextView textView = toolbar.findViewById(R.id.tv_toolbarTitle);
            if (textView != null) {
                textView.setText(getResources().getString(R.string.setting_item_about));
            }
            toolbar.setNavigationOnClickListener(v -> finish());
        }
    }
}
