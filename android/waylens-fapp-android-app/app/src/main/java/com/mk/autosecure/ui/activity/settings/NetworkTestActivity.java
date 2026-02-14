package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.alibaba.android.arouter.facade.annotation.Autowired;
import com.alibaba.android.arouter.facade.annotation.Route;
import com.alibaba.android.arouter.launcher.ARouter;
import com.google.gson.Gson;
import com.mk.autosecure.HornApplication;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.event.HotspotInfoEvent;
import com.mkgroup.camera.message.bean.HotspotInfoModel;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.operators.Operators;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.rest.request.ReportIdBody;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Action;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;

import static com.mkgroup.camera.CameraConstants.ES_MODEL;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_NETWORK_TEST;

@Route(path = "/ui/activity/settings/NetworkTestActivity")
public class NetworkTestActivity extends RxActivity {

    private final static String TAG = NetworkTestActivity.class.getSimpleName();
    private final static int WIFI_SETTING = 0;
    private final static int CHECK_SIM_CARD = 1;
    private final static int CHECK_DATA_PLAN = 2;
    private final static int CHECK_SIGNAL = 3;
    private final static int CHECK_SERVER = 4;

    //sim card
    private final static String ERROR_SIM_CARD_NOT_DETECTED = "ERROR_SIM_CARD_NOT_DETECTED";
    private final static String ERROR_SIM_CARD_WRONG_STATE = "ERROR_SIM_CARD_WRONG_STATE";
    private final static String ERROR_SIM_CARD_NOT_SUPPORTED = "ERROR_SIM_CARD_NOT_SUPPORTED";

    //data plan
    private final static String ERROR_DATA_PLAN_NOT_SUBSCRIBED = "ERROR_DATA_PLAN_NOT_SUBSCRIBED";
    private final static String ERROR_DATA_PLAN_EXPIRED = "ERROR_DATA_PLAN_EXPIRED";
    private final static String ERROR_DATA_PLAN_SUSPENDED = "ERROR_DATA_PLAN_SUSPENDED";

    //signal
    private final static String ERROR_CELLULAR_NETWORK_OUTAGE = "ERROR_CELLULAR_NETWORK_OUTAGE";
    private final static String ERROR_CELLULAR_NETWORK_ROAMING = "ERROR_CELLULAR_NETWORK_ROAMING";

    //server
    private final static String ERROR_CAMERA_CLIENT_FAILURE = "ERROR_CAMERA_CLIENT_FAILURE";
    private final static String ERROR_SERVER_NOT_REACHABLE = "ERROR_SERVER_NOT_REACHABLE";

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.layout_select_camera)
    View layoutSelectCamera;

    @BindView(R.id.rg_select_camera)
    RadioGroup rgSelectCamera;

    @BindView(R.id.rb_camera_normal)
    RadioButton rbCameraNormal;

    @BindView(R.id.rb_camera_es)
    RadioButton rbCameraEs;

    @BindView(R.id.va_network)
    ViewAnimator vaNetwork;

    @BindView(R.id.va_network_es)
    ViewAnimator vaNetworkEs;

    //display 0
    @BindView(R.id.tv_prompt)
    TextView tv_prompt;
    @BindView(R.id.btn_connect)
    Button btn_connect;

    //display 1
    @BindView(R.id.iv_show_status)
    ImageView iv_show_status;

    @BindView(R.id.tv_show_status)
    TextView tv_show_status;
    @BindView(R.id.tv_current_status)
    TextView tv_current_status;

    @BindView(R.id.ll_sim_card)
    LinearLayout ll_sim_card;
    @BindView(R.id.pb_sim)
    ProgressBar pb_sim;
    @BindView(R.id.iv_sim_result)
    ImageView iv_sim_result;
    @BindView(R.id.tv_sim)
    TextView tv_sim;

    @BindView(R.id.ll_data_plan)
    LinearLayout ll_data_plan;
    @BindView(R.id.pb_data)
    ProgressBar pb_data;
    @BindView(R.id.iv_data_result)
    ImageView iv_data_result;
    @BindView(R.id.tv_data)
    TextView tv_data;

    @BindView(R.id.ll_signal)
    LinearLayout ll_signal;
    @BindView(R.id.pb_signal)
    ProgressBar pb_signal;
    @BindView(R.id.iv_signal_result)
    ImageView iv_signal_result;
    @BindView(R.id.tv_signal)
    TextView tv_signal;

    @BindView(R.id.ll_server)
    LinearLayout ll_server;
    @BindView(R.id.pb_server)
    ProgressBar pb_server;
    @BindView(R.id.iv_server_result)
    ImageView iv_server_result;
    @BindView(R.id.tv_server)
    TextView tv_server;

    @BindView(R.id.ll_report_issue)
    LinearLayout llReportIssue;

    @BindView(R.id.btn_action)
    Button btn_action;

    @BindView(R.id.tv_feedback)
    TextView tv_feedback;

    @BindView(R.id.et_hotspot_ssid)
    EditText etHotspotSsid;

    @BindView(R.id.et_hotspot_password)
    EditText etHotspotPassword;

    @BindView(R.id.rl_loading)
    RelativeLayout rlLoading;

    @OnClick(R.id.btn_select_next)
    public void selectNext() {
        layoutSelectCamera.setVisibility(View.GONE);
        vaNetwork.setVisibility(isSecureES ? View.GONE : View.VISIBLE);
        vaNetworkEs.setVisibility(isSecureES ? View.VISIBLE : View.GONE);

        if (isSecureES) {
            checkEsLink();
        } else {
            checkLink();
        }
    }

    @OnClick({R.id.btn_connect, R.id.btn_es_connect})
    public void connect() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

    @OnClick(R.id.btn_action)
    public void action() {
        if (getString(R.string.network_action_continue).equals(btn_action.getText().toString())) {
            setResult(RESULT_OK);
            finish();
        } else {
            btn_action.setVisibility(View.INVISIBLE);
            tv_feedback.setVisibility(View.INVISIBLE);
            checkLink();
        }
    }

    @OnClick(R.id.tv_feedback)
    public void feedback() {
        if (getString(R.string.forget_password_next).equals(tv_feedback.getText().toString())) {
            setResult(RESULT_CANCELED);
            finish();
        } else {
            finish();
            FeedbackActivity.launch(this);
        }
    }

    @OnClick(R.id.tv_report_issue)
    public void reportIssue() {
        finish();
        FeedbackActivity.launch(this);
    }

    @OnClick(R.id.btn_es_network)
    public void setNetwork() {
        String ssid = etHotspotSsid.getText().toString().trim();
        String password = etHotspotPassword.getText().toString().trim();

        if (TextUtils.isEmpty(ssid) || TextUtils.isEmpty(password)) {
            Toast.makeText(this, "SSID or Password can't be empty!", Toast.LENGTH_SHORT).show();
            return;
        }

        if (mCamera != null) {
            rlLoading.setVisibility(View.VISIBLE);
            mCamera.setHotspotInfo(ssid, password);
        }
    }

    private CameraWrapper mCamera;

    private JSONObject jsonObject;

    private Gson gson;

    private PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();
    private PublishSubject<Throwable> networkError = PublishSubject.create();

    private boolean isSecureES = false;

    @Autowired
    String skipSelect;

    public static void launch(Activity activity, boolean guide) {
        Intent intent = new Intent(activity, NetworkTestActivity.class);
        if (guide) {
            activity.startActivityForResult(intent, GUIDE_NETWORK_TEST);
        } else {
            activity.startActivity(intent);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ARouter.getInstance().inject(this);
        setContentView(R.layout.activity_network_test);
        ButterKnife.bind(this);

        gson = HornApplication.getComponent().gson();

        setupToolbar();
        initView();

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(HotspotInfoEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHotspotInfoEvent, new ServerErrorHandler(TAG));

        apiError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleApiError, new ServerErrorHandler(TAG));

        networkError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));
    }

    private void onHotspotInfoEvent(HotspotInfoEvent event) {
        rlLoading.setVisibility(View.GONE);
        if (event != null) {
            HotspotInfoModel model = event.getModel();
            Logger.t(TAG).i("onHotspotInfoEvent: " + model);
            if (model != null) {
                showPop(R.layout.pop_es_network_true, () -> {
                    setResult(RESULT_OK);
                    finish();
                });
            } else {
                showPop(R.layout.pop_es_network_false, () -> {
                });
            }
        }
    }

    private void handleApiError(ErrorEnvelope error) {
        Logger.t(TAG).d("handleApiError: " + error.getErrorMessage());
        Toast.makeText(this, error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void handleNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(this, throwable);
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                CameraWrapper cameraWrapper = event.getVdtCamera();
                if (mCamera != null && cameraWrapper != null
                        && mCamera.getPort() == cameraWrapper.getPort()) {
                    if (isSecureES) {
                        vaNetworkEs.setDisplayedChild(0);
                    } else {
                        vaNetwork.setDisplayedChild(0);
                    }
                }
                break;
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_CONNECTED");
                mCamera = event.getVdtCamera();
                if (isSecureES) {
                    vaNetworkEs.setDisplayedChild(1);
                } else {
                    vaNetwork.setDisplayedChild(1);
                }
                selectNext();
                break;
            default:
                break;
        }
    }

    private void initView() {
        if (Constants.isFleet()) {
            ll_data_plan.setVisibility(View.GONE);
//            if (Constants.isInstaller() /*|| Constants.isDriver()*/) {
//                tv_feedback.setText(R.string.forget_password_next);
//            }

            rgSelectCamera.setOnCheckedChangeListener((group, checkedId) -> {
                if (checkedId == rbCameraNormal.getId()) {
                    isSecureES = false;
                } else if (checkedId == rbCameraEs.getId()) {
                    isSecureES = true;
                }

                rbCameraEs.setTextColor(isSecureES ?
                        getResources().getColor(R.color.colorAccent) : getResources().getColor(R.color.colorPrimary));
                rbCameraNormal.setTextColor(isSecureES ?
                        getResources().getColor(R.color.colorPrimary) : getResources().getColor(R.color.colorAccent));
            });
            rgSelectCamera.check(rbCameraNormal.getId());
        }

        if (!TextUtils.isEmpty(skipSelect)) {
            if ("SecureES".equals(skipSelect)) {
                isSecureES = true;
            } else if ("Secure360".equals(skipSelect)) {
                isSecureES = false;
            }
            selectNext();
        }
    }

    private void checkLink() {
        if (NetworkUtils.inHotspotMode()) {
            mCamera = VdtCameraManager.getManager().getCurrentCamera();
            if (mCamera != null) {
                Logger.t(TAG).e("checkLink: " + mCamera.getSerialNumber());
                checkSupport4G();
            } else {
                setPrompt(R.string.network_connect_prompt, false);
            }
        } else {
            setPrompt(R.string.network_connect_prompt, false);
        }
    }

    private void checkEsLink() {
        if (NetworkUtils.inHotspotMode()) {
            mCamera = VdtCameraManager.getManager().getCurrentCamera();
            if (mCamera != null) {
                Logger.t(TAG).i("checkEsLink: " + mCamera.getSerialNumber());
                String hardwareName = mCamera.getHardwareName();
                if (hardwareName.contains(ES_MODEL)) {
                    vaNetworkEs.setDisplayedChild(1);
                    etHotspotSsid.requestFocus();
                }
            }
        }
    }

    private void checkSupport4G() {
        boolean support_4g = mCamera.getMountVersion().support_4g;
        if (support_4g) {
            checkFWVersion();
        } else {
            setPrompt(R.string.network_support_prompt, true);
        }
    }

    private void checkFWVersion() {
        String apiVersion = mCamera.getApiVersion();
        Logger.t(TAG).e("version: " + apiVersion);
        boolean networkTestDiagnosisAvailable = mCamera.isNetworkTestDiagnosisAvailable();
        Logger.t(TAG).e("isNetworkTestDiagnosisAvailable: " + networkTestDiagnosisAvailable);
        if (!networkTestDiagnosisAvailable) {
            setPrompt(R.string.network_fw_prompt, true);
        } else {
            checkLogin();
        }
    }

    private void checkLogin() {
        if (Constants.isFleet()) {
            vaNetwork.setDisplayedChild(1);
            resetUI();
            checkSIM();
        } else {
            User user = HornApplication.getComponent().currentUser().getUser();
            if (user == null) {
                setPrompt(R.string.network_login_prompt, true);
            } else {
                checkBind();
            }
        }
    }

    private void checkBind() {
        CurrentUser currentUser = HornApplication.getComponent().currentUser();
        if (currentUser.exists()) {
            ArrayList<CameraBean> devices = currentUser.getDevices();
            boolean isOwner = false;
            for (CameraBean bean : devices) {
                if (mCamera.getSerialNumber().equals(bean.sn)) {
                    isOwner = true;
                    break;
                }
            }
            if (isOwner) {
                vaNetwork.setDisplayedChild(1);
                resetUI();
                checkSIM();
            } else {
                setPrompt(R.string.network_bind_prompt, true);
            }
        }
    }

    private void resetUI() {
        iv_show_status.setImageResource(R.drawable.icon_network_check);
        tv_show_status.setText(R.string.network_status_checking);
        tv_current_status.setText(R.string.network_checking_des);
        tv_current_status.setTextColor(Color.parseColor("#99A0A9"));
        pb_sim.setVisibility(View.VISIBLE);
        iv_sim_result.setVisibility(View.INVISIBLE);
        pb_data.setVisibility(View.INVISIBLE);
        iv_data_result.setVisibility(View.INVISIBLE);
        pb_signal.setVisibility(View.INVISIBLE);
        iv_signal_result.setVisibility(View.INVISIBLE);
        pb_server.setVisibility(View.INVISIBLE);
        iv_server_result.setVisibility(View.INVISIBLE);
        tv_sim.setTextColor(Color.parseColor("#344254"));
        tv_data.setTextColor(Color.parseColor("#344254"));
        tv_signal.setTextColor(Color.parseColor("#344254"));
        tv_server.setTextColor(Color.parseColor("#344254"));
        llReportIssue.setVisibility(View.INVISIBLE);
    }

    private void setPrompt(int id, boolean isConnected) {
        vaNetwork.setDisplayedChild(0);
        tv_prompt.setText(id);
        btn_connect.setVisibility(isConnected ? View.GONE : View.VISIBLE);
    }

    private void showCurrentError(String error) {
        switch (error) {
            case ERROR_SIM_CARD_NOT_DETECTED:
                tv_current_status.setText(R.string.network_error_sim_card_not_detected);
                break;
            case ERROR_SIM_CARD_NOT_SUPPORTED:
                if (Constants.isFleet()/* && (Constants.isInstaller() /*|| Constants.isDriver()*/) {
                    tv_current_status.setText(R.string.contact_supplier_for_network_error);
                } else {
                    tv_current_status.setText(R.string.network_error_sim_card_not_supported);
                }
                break;
            case ERROR_SIM_CARD_WRONG_STATE:
                if (Constants.isFleet()/* && (Constants.isInstaller() /*|| Constants.isDriver()*/) {
                    tv_current_status.setText(R.string.contact_supplier_for_network_error);
                } else {
                    tv_current_status.setText(R.string.network_error_sim_card_wrong_state);
                }
                break;

            case ERROR_DATA_PLAN_EXPIRED:
                tv_current_status.setText(R.string.network_error_data_plan_expired);
                break;
            case ERROR_DATA_PLAN_NOT_SUBSCRIBED:
                tv_current_status.setText(R.string.network_error_data_plan_not_subscribed);
                break;
            case ERROR_DATA_PLAN_SUSPENDED:
                tv_current_status.setText(R.string.network_error_data_plan_suspended);
                break;

            case ERROR_CELLULAR_NETWORK_OUTAGE:
                if (Constants.isFleet()/* && (Constants.isInstaller() /*|| Constants.isDriver()*/) {
                    tv_current_status.setText(R.string.make_sure_signal_try_again);
                } else {
                    tv_current_status.setText(R.string.network_error_signal_outage);
                }
                break;
            case ERROR_CELLULAR_NETWORK_ROAMING:
                tv_current_status.setText(R.string.network_error_signal_roaming);
                break;

            case ERROR_CAMERA_CLIENT_FAILURE:
                if (Constants.isFleet()/* && (Constants.isInstaller() /*|| Constants.isDriver()*/) {
                    llReportIssue.setVisibility(View.VISIBLE);
                }
                tv_current_status.setText(R.string.network_error_server_client_failure);
                break;
            case ERROR_SERVER_NOT_REACHABLE:
                if (Constants.isFleet()/* && (Constants.isInstaller() /*|| Constants.isDriver()*/) {
                    llReportIssue.setVisibility(View.VISIBLE);
                }
                tv_current_status.setText(R.string.network_error_server_not_reachable);
                break;
            default:
                tv_current_status.setText(R.string.unknown_error);
                break;
        }
    }

    /**
     * {"sim" : "READY","cereg" : "0,1","creg" : "0,1","cgreg" : "0,1","cops" : "0,0,[CHN-CT],7","network" : "[LTE],[PS_ONLY],[FDD]","band" : "LTE: 2,4,5,12,17","signal" : "271,2452,[-115.30]","csq" : "15,99","cellinfo" : "","apns" : "1,[IP],[waylens.iot.com.attz],[0.0.0.0],0,0,0,0  2,[IPV4V6],[ims],[0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0],0,0,0,0  3,[IPV4V6],[sos],[0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0],0,0,0,1","ping8888" : "yes","connected" : "no","iccid" : "89860318740211144091","ip" : "IPV4, 100.103.122.140, 100.103.122.141, 222.66.251.8, 116.236.159.8"}, p2=
     */

    /**
     * {"sim" : "SIM failure","cereg" : "","creg" : "","cgreg" : "","cops" : "","network" : "","band" : "LTE: 2,4,5,12","signal" : "","csq" : "","cellinfo" : "","apns" : "","ping8888" : "no","connected" : "no","iccid" : "no","ip" : ""}, p2=
     */

    private void checkSIM() {
        tv_sim.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));

        Message message = handler.obtainMessage();
        message.what = CHECK_SIM_CARD;
        try {
            jsonObject = new JSONObject(mCamera.getLteStatus());
            String sim = jsonObject.getString("sim");
            Logger.t(TAG).d("sim status: " + sim);


            if ("READY".equals(sim)) {

                if (Constants.isFleet()) {
                    message.obj = "yes";
                    handler.sendMessageDelayed(message, 1500);
                    return;
                }

                ReportIdBody reportIdBody = new ReportIdBody();
                reportIdBody.reportIccid = mCamera.getIccid();

                ApiService.createApiService().reportID(mCamera.getSerialNumber(), reportIdBody)
                        .lift(Operators.apiError(gson))
                        .subscribeOn(Schedulers.io())
                        .compose(Transformers.pipeApiErrorsTo(apiError))
                        .compose(Transformers.pipeErrorsTo(networkError))
                        .compose(Transformers.neverError())
                        .compose(bindToLifecycle())
                        .subscribe((BooleanResponse response) -> {
                            boolean successful = response.result;
                            Logger.t(TAG).d("reportID: " + successful);
                            if (!successful) {
                                message.obj = ERROR_SIM_CARD_NOT_SUPPORTED;
                            } else {
                                message.obj = "yes";
                            }
                            handler.sendMessageDelayed(message, 1500);
                        });

            } else if ("SIM failure".equals(sim)) {
                message.obj = ERROR_SIM_CARD_NOT_DETECTED;
                handler.sendMessageDelayed(message, 1500);
            } else {
                message.obj = ERROR_SIM_CARD_WRONG_STATE;
                handler.sendMessageDelayed(message, 1500);
            }
        } catch (JSONException e) {
            message.obj = ERROR_SIM_CARD_WRONG_STATE;
            handler.sendMessageDelayed(message, 1500);
            e.printStackTrace();
        }
    }

    private void checkDataPlan() {
        tv_data.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));

        if (Constants.isFleet()) {
            Message message = handler.obtainMessage();
            message.what = CHECK_DATA_PLAN;
            message.obj = "yes";
            handler.sendMessageDelayed(message, 1000);
            return;
        }

        ApiService.createApiService().getCurrentSub(mCamera.getSerialNumber())
                .subscribeOn(Schedulers.io())
                .compose(Transformers.pipeErrorsTo(networkError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<SubscribeResponse>() {
                    @Override
                    protected void onHandleSuccess(SubscribeResponse data) {
                        currentPlan(data);
                    }
                });
    }

    private void currentPlan(SubscribeResponse response) {
        Logger.t(TAG).d("currentPlan: " + response.toString());
        String status = response.getStatus();
        Message message = handler.obtainMessage();
        message.what = CHECK_DATA_PLAN;

        if ("in_service".equals(status) || "paid".equals(status)) {
            message.obj = "yes";
        } else if ("expired".equals(status)) {
            message.obj = ERROR_DATA_PLAN_EXPIRED;
        } else if ("suspended".equals(status)) {
            message.obj = ERROR_DATA_PLAN_SUSPENDED;
        } else {
            message.obj = ERROR_DATA_PLAN_NOT_SUBSCRIBED;
        }
        handler.sendMessageDelayed(message, 1000);
    }

    private void checkSignal() {
        tv_signal.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));

        Message message = handler.obtainMessage();
        message.what = CHECK_SIGNAL;
        try {
            jsonObject = new JSONObject(mCamera.getLteStatus());
            String cereg = jsonObject.getString("cereg");
            Logger.t(TAG).d("cereg: " + cereg);

            if (TextUtils.isEmpty(cereg)) {
                message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
            } else {
                int i = cereg.indexOf(",");

                if (i == -1) {
                    message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
                } else {
                    cereg = cereg.substring(i + 1);
                    Logger.t(TAG).d("cereg substring: " + cereg);

                    if ("3".equals(cereg)) {
                        message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
                    } else if ("5".equals(cereg)) {
                        message.obj = "yes";
//                        message.obj = ERROR_CELLULAR_NETWORK_ROAMING;
                    } else {
                        message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
                    }

                    if ("1".equals(cereg)) {
                        String ip = jsonObject.getString("ip");
                        Logger.t(TAG).d("ip: " + ip);
                        String[] split = ip.split(",");
                        if (split.length > 2 && !TextUtils.isEmpty(split[0])
                                && !TextUtils.isEmpty(split[1]) && !TextUtils.isEmpty(split[2])) {
                            message.obj = "yes";
                        } else {
                            message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
                        }
                    }
                }
            }
        } catch (JSONException e) {
            message.obj = ERROR_CELLULAR_NETWORK_OUTAGE;
            Logger.t(TAG).e("checkSignal exception: " + e.getMessage());
        } finally {
            handler.sendMessageDelayed(message, 1500);
        }
    }

    private void checkServer() {
        tv_server.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));

        Message message = handler.obtainMessage();
        message.what = CHECK_SERVER;
        try {
            jsonObject = new JSONObject(mCamera.getLteStatus());
            String connected = jsonObject.getString("connected");
            String ping8888 = jsonObject.getString("ping8888");
            Logger.t(TAG).e("connected: " + connected + "--ping8888: " + ping8888);
            if ("yes".equals(connected)) {
                message.obj = "yes";
            } else if ("no".equals(ping8888)) {
                message.obj = ERROR_CAMERA_CLIENT_FAILURE;
            } else {
                message.obj = ERROR_SERVER_NOT_REACHABLE;
            }
        } catch (JSONException e) {
            message.obj = ERROR_CAMERA_CLIENT_FAILURE;
            e.printStackTrace();
        } finally {
            handler.sendMessageDelayed(message, 1500);
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.support_network_test));
        }
    }

    private void showPop(int layoutID, Action action) {
        View view = LayoutInflater.from(this).inflate(layoutID, null);

        PopupWindow popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                false);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.btn_ok).setOnClickListener(v -> {
            popupWindow.dismiss();
            if (action != null) {
                try {
                    action.run();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        popupWindow.showAsDropDown(rlLoading);
    }

    private void updateCurrentStep(boolean result, ImageView currentIv, TextView currentTv) {
        btn_action.setVisibility(View.VISIBLE);
        if (result) {
            currentIv.setImageResource(R.drawable.network_item_success);
            currentIv.setVisibility(View.VISIBLE);

            iv_show_status.setImageResource(R.drawable.icon_network_success);
            tv_show_status.setText(R.string.network_status_finish);
            tv_current_status.setText(R.string.network_finish);

            btn_action.setText(R.string.network_action_continue);
            tv_feedback.setVisibility(View.INVISIBLE);
        } else {
            currentIv.setImageResource(R.drawable.network_item_fail);
            currentIv.setVisibility(View.VISIBLE);
            currentTv.setTextColor(Color.parseColor("#DD4250"));

            iv_show_status.setImageResource(R.drawable.icon_network_error);
            tv_show_status.setText(R.string.network_status_error);
            tv_current_status.setTextColor(Color.parseColor("#DD4250"));

            btn_action.setText(R.string.try_again);
            tv_feedback.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == WIFI_SETTING) {
            selectNext();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    private MyHandler handler = new MyHandler(this);

    class MyHandler extends Handler {

        private WeakReference<Context> mRef;

        MyHandler(Context context) {
            mRef = new WeakReference<>(context);
        }

        @Override
        public void handleMessage(Message msg) {
            Context context = mRef.get();
            if (context == null) {
                return;
            }
            switch (msg.what) {
                case CHECK_SIM_CARD:
                    tv_sim.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    pb_sim.setVisibility(View.INVISIBLE);

                    if ("yes".equals(msg.obj.toString())) {
                        iv_sim_result.setImageResource(R.drawable.network_item_success);
                        iv_sim_result.setVisibility(View.VISIBLE);

                        if (Constants.isFleet()) {
                            pb_signal.setVisibility(View.VISIBLE);
                            checkSignal();
                        } else {
                            pb_data.setVisibility(View.VISIBLE);
                            checkDataPlan();
                        }
                    } else {
                        showCurrentError(msg.obj.toString());
                        updateCurrentStep(false, iv_sim_result, tv_sim);
                    }
                    break;
                case CHECK_DATA_PLAN:
                    tv_data.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    pb_data.setVisibility(View.INVISIBLE);

                    if ("yes".equals(msg.obj.toString())) {
                        iv_data_result.setImageResource(R.drawable.network_item_success);
                        iv_data_result.setVisibility(View.VISIBLE);
                        pb_signal.setVisibility(View.VISIBLE);
                        checkSignal();
                    } else {
                        showCurrentError(msg.obj.toString());
                        updateCurrentStep(false, iv_data_result, tv_data);
                    }
                    break;
                case CHECK_SIGNAL:
                    tv_signal.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    pb_signal.setVisibility(View.INVISIBLE);

                    if ("yes".equals(msg.obj.toString())) {
                        iv_signal_result.setImageResource(R.drawable.network_item_success);
                        iv_signal_result.setVisibility(View.VISIBLE);
                        pb_server.setVisibility(View.VISIBLE);
                        checkServer();
                    } else {
                        showCurrentError(msg.obj.toString());
                        updateCurrentStep(false, iv_signal_result, tv_signal);
                    }
                    break;
                case CHECK_SERVER:
                    tv_server.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    pb_server.setVisibility(View.INVISIBLE);

                    if ("yes".equals(msg.obj.toString())) {
                        updateCurrentStep(true, iv_server_result, null);
                    } else {
                        showCurrentError(msg.obj.toString());
                        updateCurrentStep(false, iv_server_result, tv_server);
                    }
                    break;
            }
        }
    }
}
