package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.DeviceListResponse;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

public class NetworkInfoActivity extends RxActivity {

    private final static String TAG = NetworkInfoActivity.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_iccid)
    TextView tv_iccid;

    @BindView(R.id.tv_cereg)
    TextView tv_cereg;

    @BindView(R.id.tv_band)
    TextView tv_band;

    @BindView(R.id.tv_signal)
    TextView tv_signal;

    @BindView(R.id.tv_ip)
    TextView tv_ip;

    @BindView(R.id.ll_iccid)
    LinearLayout ll_iccid;

    @BindView(R.id.ll_cereg)
    LinearLayout ll_cereg;

    @BindView(R.id.ll_ip)
    LinearLayout ll_ip;

    private String serialNumber;

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, NetworkInfoActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_network_info);
        ButterKnife.bind(this);

        serialNumber = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);

        setupToolbar();
        initView();
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.about_network_info));
        }
    }

    private void initView() {
        if (NetworkUtils.inHotspotMode()) {
            CameraWrapper cameraWrapper = VdtCameraManager.getManager().getCamera(serialNumber);
            if (cameraWrapper != null) {
                tv_iccid.setText(cameraWrapper.getIccid());
                try {
                    JSONObject jsonObject = new JSONObject(cameraWrapper.getLteStatus());
                    Logger.t(TAG).d("network: " + jsonObject.toString());

                    String cereg = jsonObject.getString("cereg");
                    int indexOf = cereg.indexOf(",");
                    if (indexOf != -1) {
                        cereg = cereg.substring(indexOf + 1);
                        switch (Integer.parseInt(cereg)) {
                            case 0:
                                cereg = getString(R.string.idle);
                                break;
                            case 1:
                                cereg = getString(R.string.ready);
                                break;
                            case 2:
                                cereg = getString(R.string.searching);
                                break;
                            case 3:
                                cereg = getString(R.string.refused);
                                break;
                            case 4:
                                cereg = getString(R.string.unknown);
                                break;
                            case 5:
                                cereg = getString(R.string.roaming);
                                break;
                        }
                        tv_cereg.setText(cereg);
                    }

                    String cellinfo = jsonObject.getString("cellinfo");
                    String[] cellinfos = cellinfo.split(",");
                    if (cellinfos.length > 3) {
                        cellinfo = cellinfos[3];
                    } else if (cellinfo.length() > 2) {
                        cellinfo = cellinfos[2];
                    }
                    tv_band.setText(cellinfo);

                    String signal = jsonObject.getString("signal");
                    String[] signals = signal.split(",");
                    if (signals.length > 2) {
                        String replace = signals[2]
                                .replace("[", "").replace("]", "")
                                .replace("\"", "");
                        signal = Math.round(Float.parseFloat(replace)) + " dBm";
                        tv_signal.setText(signal);
                    }

                    String ip = jsonObject.getString("ip");
                    String[] ipSplit = ip.split(",");
                    if (ipSplit.length > 1) {
                        ip = ipSplit[1];
                        tv_ip.setText(ip);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                requestRemoteInfo();
            }
        } else {
            requestRemoteInfo();
        }
    }

    private void requestRemoteInfo() {
        ll_iccid.setVisibility(View.GONE);
        ll_cereg.setVisibility(View.GONE);
        ll_ip.setVisibility(View.GONE);

        if (Constants.isFleet()) {
            CurrentUser currentUser = HornApplication.getComponent().currentUser();
            FleetCameraBean fleetCamera = currentUser.getFleetCamera(serialNumber);
//            if (fleetCamera != null && fleetCamera.getOnlineStatus() != null) {
//                tv_band.setText(fleetCamera.getOnlineStatus().getBand());
//                tv_signal.setText(String.format(Locale.getDefault(),
//                        "%d dBm", Math.round(fleetCamera.getOnlineStatus().getRSRP())));
//            }
        } else {
            ApiService.createApiService().getCameras()
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<DeviceListResponse>() {
                        @Override
                        protected void onHandleSuccess(DeviceListResponse data) {
                            for (CameraBean cameraItem : data.cameras) {
                                if (serialNumber.equals(cameraItem.sn)) {
                                    if (cameraItem._4gSignal != null) {
                                        tv_band.setText(cameraItem._4gSignal.Band);
                                        tv_signal.setText(String.format(Locale.getDefault(),
                                                "%d dBm", Math.round(cameraItem._4gSignal.RSRP)));
                                    }
                                }
                            }
                        }
                    });
        }
    }
}
