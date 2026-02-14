package com.mkgroup.camera;

import androidx.annotation.NonNull;

import com.orhanobut.logger.Logger;

import java.util.concurrent.PriorityBlockingQueue;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2018/1/16.
 * Email: doanvt-hn@mk.com.vn
 */
public class InfoMsgQueue {
    private static final String TAG = InfoMsgQueue.class.getSimpleName();

    public static final int E_SDCARD_ERROR = 0x00;
    public static final int E_NO_SDCARD_INSERT = 0x01;
    public static final int E_RECORD_ERROR = 0x02;

    public static final int W_SDCARD_SHOULD_FORMAT = 0x10;
    public static final int W_SDCARD_LOW_CAPACITY = 0x11;

    public static final int I_RECORD_STOPPED = 0x20;
    public static final int I_LOG_IN = 0x21;
    public static final int I_ADD_ACCOUNT = 0x22;
    public static final int I_SUBSCRIBE_PLAN = 0x23;

    private PriorityBlockingQueue<InfoMsg> internalQueue;

    private BehaviorSubject<InfoMsgQueue> subject = BehaviorSubject.create();

    public InfoMsgQueue() {
        internalQueue = new PriorityBlockingQueue<>();
    }

    public Observable<InfoMsgQueue> asObservable() {
        return subject.hide();
    }

    public InfoMsg peek() {
        return internalQueue.peek();
    }

    synchronized public void putMsg(int type) {
//        Logger.t(TAG).d("put msg = " + type);
        InfoMsg msg = new InfoMsg(type);
        for (InfoMsg im : internalQueue) {
            if (im.compareTo(msg) == 0) {
                return;
            }
        }
        InfoMsg before = internalQueue.peek();
        internalQueue.offer(msg);
        InfoMsg after = internalQueue.peek();
        if (before != after) {
            subject.onNext(this);
        }
    }

    public void clearMsg(int msgType) {
        Logger.t(TAG).d("clear msg = " + msgType);
        InfoMsg before = internalQueue.peek();
        for (InfoMsg im : internalQueue) {
            if (im.getType() == msgType) {
                internalQueue.remove(im);
            }
        }
        InfoMsg after = internalQueue.peek();
        if (before != after) {
            subject.onNext(this);
        }
    }

    public void clearAllMsg() {
        Logger.t(TAG).d("clear all msg");
        int originSize = internalQueue.size();
        if (originSize > 0) {
            internalQueue.clear();
            subject.onNext(this);
        }
    }

    public int size() {
        return internalQueue.size();
    }

    public static class InfoMsg implements Comparable<InfoMsg> {
        int type = -1;
        boolean isRead = false;

        public InfoMsg(int type) {
            this.type = type;
        }

        public int getType() {
            return this.type;
        }

        public boolean isRead() {
            return this.isRead;
        }

        public void markRead() {
            this.isRead = true;
        }

//        public String getMessage(Context context) {
//            switch (type) {
//                case E_SDCARD_ERROR:
//                    return context.getResources().getString(R.string.camera_error_sdcardError);
//                case E_NO_SDCARD_INSERT:
//                    return context.getResources().getString(R.string.camera_error_sdcardNotDetected);
//                case E_RECORD_ERROR:
//                    return context.getResources().getString(R.string.camera_error_recordError);
//
//                case W_SDCARD_SHOULD_FORMAT:
//                    return context.getResources().getString(R.string.camera_warning_sdcardShouldFormat);
//                case W_SDCARD_LOW_CAPACITY:
//                    return context.getResources().getString(R.string.camera_warning_sdcardCapacityTooLow);
//
//                case I_RECORD_STOPPED:
//                    return context.getResources().getString(R.string.camera_information_recordStopped);
//                case I_LOG_IN:
//                    return context.getResources().getString(R.string.camera_information_logIn);
//                case I_ADD_ACCOUNT:
//                    return context.getResources().getString(R.string.camera_information_addAccount);
//                case I_SUBSCRIBE_PLAN:
//                    return context.getResources().getString(R.string.camera_information_subscribePlan);
//                default:
//                    return "";
//            }
//        }

//        private Drawable getBackground(Context context) {
//            switch (type & 0xF0) {
//                case 0x00:
//                    return context.getResources().getDrawable(R.drawable.ic_dialog_red_bg);
//                case 0x10:
//                    return context.getResources().getDrawable(R.drawable.ic_dialog_yellow_bg);
//                case 0x20:
//                    return context.getResources().getDrawable(R.drawable.ic_dialog_blue_bg);
//                default:
//                    return context.getResources().getDrawable(R.drawable.ic_dialog_blue_bg);
//            }
//        }

//        public int getColor(Context context) {
//            switch (type & 0xF0) {
//                case 0x00:
//                    return context.getResources().getColor(R.color.colorSettingHeavyHit);
//                case 0x10:
//                    return context.getResources().getColor(R.color.colorSettingHit);
//                case 0x20:
//                    return context.getResources().getColor(R.color.colorAccent);
//                default:
//                    return context.getResources().getColor(R.color.colorAccent);
//            }
//        }

//        public Drawable getIcon(Context context) {
//            switch (type & 0xF0) {
//                case 0x00:
//                    return context.getResources().getDrawable(R.drawable.icon_error_sdcard_timeline);
//                case 0x10:
//                    return context.getResources().getDrawable(R.drawable.icon_error_offline_timeline);
//                case 0x20:
//                    return context.getResources().getDrawable(R.drawable.icon_error_information);
//                default:
//                    return context.getResources().getDrawable(R.drawable.icon_error_information);
//            }
//        }

//        public String getAction(Context context) {
//            switch (type) {
//                case E_SDCARD_ERROR:
//                case W_SDCARD_SHOULD_FORMAT:
//                    return context.getResources().getString(R.string.camera_action_format_sdcard);
//                case I_RECORD_STOPPED:
//                    return context.getResources().getString(R.string.camera_action_start_record);
//                case I_LOG_IN:
//                    return context.getResources().getString(R.string.log_in);
//                case I_ADD_ACCOUNT:
//                    return context.getResources().getString(R.string.camera_action_add_account);
//                case I_SUBSCRIBE_PLAN:
//                    return context.getResources().getString(R.string.subscribe);
//                default:
//                    return "";
//            }
//        }

//        public void clickAction(Activity activity, String sn) {
//            switch (type) {
//                case E_SDCARD_ERROR:
//                case W_SDCARD_SHOULD_FORMAT:
//                    SpaceInfoActivity.launch(activity, false);
//                    break;
//                case I_RECORD_STOPPED:
//                    CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
//                    if (camera != null && camera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
//                        camera.startRecording();
//                    }
//                    break;
//                case I_LOG_IN:
//                    LoginActivity.launch(activity);
//                    break;
//                case I_ADD_ACCOUNT:
//                    BindDeviceBody deviceBody = new BindDeviceBody();
//                    deviceBody.name = VdtCameraManager.getManager().getCurrentCamera().getName();
//                    deviceBody.password = VdtCameraManager.getManager().getCurrentCamera().getPassword();
//                    deviceBody.sn = sn;
//
//                    Logger.t(TAG).e("I_ADD_ACCOUNT: " + deviceBody.password);
//
//                    ApiService.createApiService().bindDeviceRes(deviceBody)
//                            .compose(Transformers.switchSchedulers())
//                            .doOnError(throwable -> NetworkErrorHelper.handleCommonError(activity, throwable))
//                            .subscribe(new BaseObserver<Response<BindDeviceResponse>>() {
//                                @Override
//                                protected void onHandleSuccess(Response<BindDeviceResponse> data) {
//                                    boolean result = data.body().result;
//                                    Logger.t(TAG).d("bindDeviceRes: " + result);
//                                    if (result) {
//                                        LocalLiveActivity.launch(activity, true);
//                                    }
//                                }
//                            });
//                    break;
//                case I_SUBSCRIBE_PLAN:
//                    WebPlanActivity.launch(activity, sn, false);
//                    break;
//            }
//        }

//        public View getView(Context context) {
//            View view = LayoutInflater.from(context).inflate(R.layout.view_camera_msg, null);
//            view.setBackground(getBackground(context));
//            TextView tvContent = view.findViewById(R.id.tv_msgContent);
//            tvContent.setText(getMessage(context));
//            ImageView ivIcon = view.findViewById(R.id.iv_msgIcon);
//            ivIcon.setBackground(getIcon(context));
//            Button btn_action = view.findViewById(R.id.btn_action);
//            String action = getAction(context);
//            if (TextUtils.isEmpty(action)) {
//                btn_action.setVisibility(View.GONE);
//            } else {
//                btn_action.setText(action);
//                btn_action.setTextColor(getColor(context));
//                btn_action.setVisibility(View.VISIBLE);
//            }
//            return view;
//        }

        @Override
        public int compareTo(@NonNull InfoMsg o) {
            return this.type - o.type;
        }
    }
}
