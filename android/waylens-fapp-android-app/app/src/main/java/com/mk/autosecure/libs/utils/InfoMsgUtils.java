package com.mk.autosecure.libs.utils;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.WebPlanActivity;
import com.mk.autosecure.ui.activity.settings.SpaceInfoActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.BindDeviceResponse;
import com.mk.autosecure.rest.request.BindDeviceBody;

import retrofit2.Response;

import static com.mkgroup.camera.InfoMsgQueue.E_NO_SDCARD_INSERT;
import static com.mkgroup.camera.InfoMsgQueue.E_RECORD_ERROR;
import static com.mkgroup.camera.InfoMsgQueue.E_SDCARD_ERROR;
import static com.mkgroup.camera.InfoMsgQueue.I_ADD_ACCOUNT;
import static com.mkgroup.camera.InfoMsgQueue.I_LOG_IN;
import static com.mkgroup.camera.InfoMsgQueue.I_RECORD_STOPPED;
import static com.mkgroup.camera.InfoMsgQueue.I_SUBSCRIBE_PLAN;
import static com.mkgroup.camera.InfoMsgQueue.W_SDCARD_LOW_CAPACITY;
import static com.mkgroup.camera.InfoMsgQueue.W_SDCARD_SHOULD_FORMAT;

/**
 * Created by cloud on 2021/3/7.
 */
public class InfoMsgUtils {

    private static final String TAG = InfoMsgUtils.class.getSimpleName();

    private static volatile InfoMsgUtils instance;

    public static InfoMsgUtils getInstance() {
        if (instance == null) {
            synchronized (InfoMsgUtils.class) {
                if (instance == null) {
                    instance = new InfoMsgUtils();
                }
            }
        }
        return instance;
    }

    public String getMessage(Context context, int type) {
        switch (type) {
            case E_SDCARD_ERROR:
                return context.getResources().getString(R.string.camera_error_sdcardError);
            case E_NO_SDCARD_INSERT:
                return context.getResources().getString(R.string.camera_error_sdcardNotDetected);
            case E_RECORD_ERROR:
                return context.getResources().getString(R.string.camera_error_recordError);

            case W_SDCARD_SHOULD_FORMAT:
                return context.getResources().getString(R.string.camera_warning_sdcardShouldFormat);
            case W_SDCARD_LOW_CAPACITY:
                return context.getResources().getString(R.string.camera_warning_sdcardCapacityTooLow);

            case I_RECORD_STOPPED:
                return context.getResources().getString(R.string.camera_information_recordStopped);
            case I_LOG_IN:
                return context.getResources().getString(R.string.camera_information_logIn);
            case I_ADD_ACCOUNT:
                return context.getResources().getString(R.string.camera_information_addAccount);
            case I_SUBSCRIBE_PLAN:
                return context.getResources().getString(R.string.camera_information_subscribePlan);
            default:
                return "";
        }
    }

    private Drawable getBackground(Context context, int type) {
        switch (type & 0xF0) {
            case 0x00:
                return context.getResources().getDrawable(R.drawable.ic_dialog_red_bg);
            case 0x10:
                return context.getResources().getDrawable(R.drawable.ic_dialog_yellow_bg);
            case 0x20:
                return context.getResources().getDrawable(R.drawable.ic_dialog_blue_bg);
            default:
                return context.getResources().getDrawable(R.drawable.ic_dialog_blue_bg);
        }
    }

    public int getColor(Context context, int type) {
        switch (type & 0xF0) {
            case 0x00:
                return context.getResources().getColor(R.color.colorSettingHeavyHit);
            case 0x10:
                return context.getResources().getColor(R.color.colorSettingHit);
            case 0x20:
                return context.getResources().getColor(R.color.colorAccent);
            default:
                return context.getResources().getColor(R.color.colorAccent);
        }
    }

    public Drawable getIcon(Context context, int type) {
        switch (type & 0xF0) {
            case 0x00:
                return context.getResources().getDrawable(R.drawable.icon_error_sdcard_timeline);
            case 0x10:
                return context.getResources().getDrawable(R.drawable.icon_error_offline_timeline);
            case 0x20:
                return context.getResources().getDrawable(R.drawable.icon_error_information);
            default:
                return context.getResources().getDrawable(R.drawable.icon_error_information);
        }
    }

    public String getAction(Context context, int type) {
        switch (type) {
            case E_SDCARD_ERROR:
            case W_SDCARD_SHOULD_FORMAT:
                return context.getResources().getString(R.string.camera_action_format_sdcard);
            case I_RECORD_STOPPED:
                return context.getResources().getString(R.string.camera_action_start_record);
            case I_LOG_IN:
                return context.getResources().getString(R.string.log_in);
            case I_ADD_ACCOUNT:
                return context.getResources().getString(R.string.camera_action_add_account);
            case I_SUBSCRIBE_PLAN:
                return context.getResources().getString(R.string.subscribe);
            default:
                return "";
        }
    }

    public void clickAction(Activity activity, String sn, int type) {
        switch (type) {
            case E_SDCARD_ERROR:
            case W_SDCARD_SHOULD_FORMAT:
                SpaceInfoActivity.launch(activity, false);
                break;
            case I_RECORD_STOPPED:
                CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
                if (camera != null && camera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
                    camera.startRecording();
                }
                break;
            case I_LOG_IN:
                LoginActivity.launch(activity);
                break;
            case I_ADD_ACCOUNT:
                BindDeviceBody deviceBody = new BindDeviceBody();
                deviceBody.name = VdtCameraManager.getManager().getCurrentCamera().getName();
                deviceBody.password = VdtCameraManager.getManager().getCurrentCamera().getPassword();
                deviceBody.sn = sn;

                Logger.t(TAG).e("I_ADD_ACCOUNT: " + deviceBody.password);

                ApiService.createApiService().bindDeviceRes(deviceBody)
                        .compose(Transformers.switchSchedulers())
                        .doOnError(throwable -> NetworkErrorHelper.handleCommonError(activity, throwable))
                        .subscribe(new BaseObserver<Response<BindDeviceResponse>>() {
                            @Override
                            protected void onHandleSuccess(Response<BindDeviceResponse> data) {
                                boolean result = data.body().result;
                                Logger.t(TAG).d("bindDeviceRes: " + result);
                                if (result) {
                                    LocalLiveActivity.launch(activity, true);
                                }
                            }
                        });
                break;
            case I_SUBSCRIBE_PLAN:
                WebPlanActivity.launch(activity, sn, false);
                break;
        }
    }

    public View getView(Context context, int type) {
        View view = LayoutInflater.from(context).inflate(R.layout.view_camera_msg, null);
        view.setBackground(getBackground(context, type));
        TextView tvContent = view.findViewById(R.id.tv_msgContent);
        tvContent.setText(getMessage(context, type));
        ImageView ivIcon = view.findViewById(R.id.iv_msgIcon);
        ivIcon.setBackground(getIcon(context, type));
        Button btn_action = view.findViewById(R.id.btn_action);
        String action = getAction(context, type);
        if (TextUtils.isEmpty(action)) {
            btn_action.setVisibility(View.GONE);
        } else {
            btn_action.setText(action);
            btn_action.setTextColor(getColor(context, type));
            btn_action.setVisibility(View.VISIBLE);
        }
        return view;
    }

}
