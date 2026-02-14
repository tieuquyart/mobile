package com.mk.autosecure.ui.fragment;

import static com.mkgroup.camera.bean.CameraState.DRIVING_MODE;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;

import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Outline;
import android.graphics.drawable.AnimationDrawable;
import android.location.Location;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.view.animation.LinearInterpolator;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.activity.LocationMapActivity;
import com.mk.autosecure.ui.activity.WebPlanActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.tool.BatteryImageViewResHelper;
import com.mk.autosecure.ui.view.CustomPopWindow;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.ICameraWrapper;
import com.mkgroup.camera.InfoMsgQueue;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mkgroup.camera.event.LensChangeEvent;
import com.mkgroup.camera.event.PreviewChangeEvent;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipSet;
import com.mkgroup.camera.model.SpaceInfo;
import com.mkgroup.camera.model.rawdata.GpsData;
import com.mkgroup.camera.model.rawdata.RawDataBlock;
import com.mkgroup.camera.model.rawdata.RawDataItem;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.toolbox.ClipSetExRequest;
import com.mkgroup.camera.toolbox.LiveRawDataRequest;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.InfoMsgUtils;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.LocationResponse;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by DoanVT on 2017/8/29.
 * Email: doanvt-hn@mk.com.vn
 */

public class CameraFragment extends RxFragment {

    private static final String TAG = CameraFragment.class.getSimpleName();

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private InfoMsgQueue infoMsgQueue;

    private String sn;

    private CameraWrapper mCamera;

    private MjpegStream mMjpegStream;

    private InetSocketAddress mjpegAddress = null;

    private MD360BitmapTexture.Callback mCallback = null;

    private CustomPopWindow msgPopWindow;

    private MDVRLibrary mVRLibrary;

    private double latitude;

    private double longitude;

    private boolean isForeground;

    @BindView(R.id.gl_view)
    GLSurfaceView mGlView;

    @BindView(R.id.tv_cameraName)
    TextView tv_cameraName;

    @BindView(R.id.tv_curPlan)
    TextView tv_curPlan;

    LinearLayout llCameraEvents;

    TextView tvCameraEvents;

    @BindView(R.id.iv_gpsStatus)
    ImageView iv_gpsStatus;

    @BindView(R.id.iv_modeStatus)
    ImageView iv_modeStatus;

    @BindView(R.id.iv_batteryStatus)
    ImageView iv_batteryStatus;

    @BindView(R.id.iv_4gStatus)
    ImageView iv_4gStatus;

    @BindView(R.id.iv_noSignal)
    ImageView iv_noSignal;

    @BindView(R.id.tv_time)
    TextView tv_time;

    @BindView(R.id.ll_location)
    LinearLayout ll_location;

    @BindView(R.id.tv_location)
    TextView tv_location;

    @BindView(R.id.iv_cameraStatus)
    ImageView iv_cameraStatus;

    @BindView(R.id.iv_offlineShadow)
    ImageView iv_offlineShadow;

    @BindView(R.id.iv_clickGuide)
    ImageView iv_clickGuide;

    @BindView(R.id.image_view)
    ImageView iv_placeHolder;

    @OnClick(R.id.tv_curPlan)
    public void curPlan() {
        if (mCameraBean != null) {
            WebPlanActivity.launch(getActivity(), mCameraBean.sn, false);
        } else if (mCamera != null) {
            WebPlanActivity.launch(getActivity(), mCamera.getSerialNumber(), false);
        }
    }

    @OnClick(R.id.gl_view)
    public void onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked: " + sn + "--" + mCameraBean);
        PreviewChangeEvent changeEvent = null;
        if (mCamera != null) {
            changeEvent = new PreviewChangeEvent(mCamera);
        } else if (mCameraBean != null) {
            changeEvent = new PreviewChangeEvent(mCameraBean);
        } else if (mFleetCamera != null) {
            changeEvent = new PreviewChangeEvent(mFleetCamera);
        }

        if (changeEvent != null) {
            RxBus.getDefault().post(changeEvent);
        }

        boolean needGuide = PreferenceUtils.getBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_VIDEO_PAGE, true);
        if (needGuide) {
            PreferenceUtils.putBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_VIDEO_PAGE, false);
        }
    }

    public static CameraFragment newInstance(String sn, CameraBean cameraBean) {
        CameraFragment fragment = new CameraFragment();
        Bundle bundle = new Bundle();
        bundle.putString(IntentKey.SERIAL_NUMBER, sn);
        bundle.putSerializable(IntentKey.CAMERA_BEAN, cameraBean);
        fragment.setArguments(bundle);
        return fragment;
    }

    public static CameraFragment newInstance(FleetCameraBean camerasBean) {
        CameraFragment fragment = new CameraFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(IntentKey.FLEET_CAMERA, camerasBean);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view;
        if (Constants.isFleet()) {
            view = inflater.inflate(R.layout.fragment_camera_preview_fleet, container, false);
            tvCameraEvents = view.findViewById(R.id.tv_camera_events);
            llCameraEvents = view.findViewById(R.id.ll_camera_events);
            llCameraEvents.setOnClickListener(v -> {
                if (mCamera != null) {
                    VideosActivity.launch(getActivity(), sn, false);
                }
            });
        } else {
            view = inflater.inflate(R.layout.fragment_camera_preview, container, false);
        }
        ButterKnife.bind(this, view);

        Bundle bundle = getArguments();
        if (bundle != null) {
            sn = bundle.getString(IntentKey.SERIAL_NUMBER);
            mCameraBean = (CameraBean) bundle.getSerializable(IntentKey.CAMERA_BEAN);
            mFleetCamera = (FleetCameraBean) bundle.getSerializable(IntentKey.FLEET_CAMERA);
        }

        Logger.t(TAG).d("onCreateView: " + sn);
        if (!TextUtils.isEmpty(sn)) {
            mCamera = VdtCameraManager.getManager().getCamera(sn);
        }

        if (mCameraBean != null) {
            infoMsgQueue = new InfoMsgQueue();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            Logger.t(TAG).d("set outline");
            mGlView.setClipToOutline(true);
            mGlView.setOutlineProvider(new ViewOutlineProvider() {
                @Override
                public void getOutline(View view, Outline outline) {
                    outline.setOval(0, 0, view.getHeight(), view.getHeight());
                }
            });
        }

        Logger.t(TAG).d("onCreateView: " + mCameraBean);

        mVRLibrary = createVRLibrary();

        initEvent();

        return view;
    }

    private void initEvent() {
        RxBus.getDefault().toObservable(LensChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLensChangeEvent, new ServerErrorHandler(TAG));
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
//        Logger.t(TAG).d("setUserVisibleHint: " + isVisibleToUser + " " + (tv_cameraName != null ? tv_cameraName.getText().toString() : null));
        isForeground = isVisibleToUser;
        if (tv_cameraName != null) {
            tv_cameraName.setVisibility(isVisibleToUser ? View.VISIBLE : View.INVISIBLE);
        }
    }

    private void onLensChangeEvent(LensChangeEvent event) {
        if (event != null && event.getCamera().equals(mCamera)) {
            boolean lensNormal = event.isLensNormal();
            Logger.t(TAG).d("onLensChangeEvent: " + lensNormal);
            if (mVRLibrary != null) {
                mVRLibrary.switchProjectionMode(getContext(), lensNormal ?
                        CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN);
            }
        }
    }

    protected MDVRLibrary createVRLibrary() {
        int projectionMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;

        if (mCameraBean != null) {
            String rotate = mCameraBean.rotate;
            Logger.t(TAG).d("rotate: " + rotate);
            if (!TextUtils.isEmpty(rotate)) {
                projectionMode = LENS_NORMAL.equals(rotate) ?
                        CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
            }
        } else if (mCamera != null) {
            boolean needDewarp = mCamera.getNeedDewarp();
            if (needDewarp) {
                boolean upsidedown = mCamera.getSupportUpsidedown();
                Logger.t(TAG).d("supportUpsidedown: " + upsidedown);
                if (upsidedown) {
                    boolean lensNormal = mCamera.getIsLensNormal();
                    Logger.t(TAG).d("lensNormal: " + lensNormal);
                    projectionMode = lensNormal ?
                            CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
                }
            } else {
                projectionMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
            }
        }

        Logger.t(TAG).d("projectionMode: " + (projectionMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS));

        return MDVRLibrary.with(getActivity())
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_NONE)
                .asBitmap(callback -> {
//                    Logger.t(TAG).d("load image with max texture size:" + callback.getMaxTextureSize());
                    mCallback = callback;
                    loadMJPEG();
                })
                .projectionMode(projectionMode)
                .projectionFactory(new CustomProjectionFactory())
                .build(mGlView);
    }

    public MDVRLibrary getVRLibrary() {
        return mVRLibrary;
    }

    @Override
    public void onResume() {
        super.onResume();

        boolean needGuide = PreferenceUtils.getBoolean(PreferenceUtils.KEY_FIRST_GUIDE_TO_VIDEO_PAGE, true);
        if (needGuide) {
            iv_clickGuide.setVisibility(View.VISIBLE);
            scaleValueAnimator();
        } else {
            iv_clickGuide.setVisibility(View.GONE);
        }

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));

        if (mVRLibrary != null) {
            mVRLibrary.onResume(getActivity());
        }

    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper wrapper = camera.getIncludeNull();
        if (wrapper != null && sn != null) {
            mCamera = wrapper;
            checkSomeMsg(wrapper);
            onNewCamera(wrapper);
        } else if (mCameraBean != null) {
            checkSomeMsg(mCameraBean);
            onNewCamera(mCameraBean);
        } else if (mFleetCamera != null) {
            onNewFleetCamera(mFleetCamera);
        } else {
            onDisconnectCamera();
        }
    }

    private void checkSomeMsg(CameraWrapper camera) {
        Observable.create((ObservableOnSubscribe<Optional<SpaceInfo>>) emitter -> {
            try {
                SpaceInfo spaceInfo = SnipeApi.getSpaceInfo();
                Logger.t(TAG).d("spaceInfo: " + spaceInfo);
                emitter.onNext(Optional.ofNullable(spaceInfo));
            } catch (Exception e) {
                e.printStackTrace();
                emitter.onNext(Optional.empty());
            }
        })
                .filter(spaceInfoOptional -> spaceInfoOptional.getIncludeNull() != null)
                .subscribeOn(Schedulers.io())
                .flatMap(spaceInfoOptional -> {
                    SpaceInfo spaceInfo = spaceInfoOptional.get();
                    String spaceNumber = StringUtils.getSpaceNumber(spaceInfo.total);
                    Logger.t(TAG).d("spaceNumber: " + spaceNumber);

                    //16GB sdcard可能出现坏区，小于16，这里写15简单判断下
                    if (Double.parseDouble(spaceNumber) < 15) {
                        camera.getInfoMsgQueue().putMsg(InfoMsgQueue.W_SDCARD_LOW_CAPACITY);
                        return Observable.empty();
                    } else {
                        camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.W_SDCARD_LOW_CAPACITY);

                        if (Constants.isFleet()) {
                            camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_LOG_IN);
                            camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                        } else {
                            CurrentUser currentUser = HornApplication.getComponent().currentUser();
                            Logger.t(TAG).d("currentUser: " + currentUser.getUser());
                            if (currentUser.getUser() == null) {
                                camera.getInfoMsgQueue().putMsg(InfoMsgQueue.I_LOG_IN);
                                return Observable.empty();
                            } else {
                                camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_LOG_IN);

                                ArrayList<CameraBean> devices = currentUser.getDevices();
                                boolean isAdded = false;
                                for (CameraBean item : devices) {
                                    if (item.sn.equals(camera.getSerialNumber())) {
                                        isAdded = true;
                                        break;
                                    }
                                }
                                Logger.t(TAG).d("isAdded: " + isAdded);
                                if (!isAdded) {
                                    camera.getInfoMsgQueue().putMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                                    return Observable.empty();
                                } else {
                                    camera.getInfoMsgQueue().clearMsg(InfoMsgQueue.I_ADD_ACCOUNT);
                                }
                            }
                        }
                    }
                    if (camera.getMountVersion() != null && camera.getMountVersion().support_4g) {
                        return ApiService.createApiService().getCurrentSub(camera.getSerialNumber());
                    } else {
                        return Observable.empty();
                    }
                })
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<SubscribeResponse>() {
                    @Override
                    protected void onHandleSuccess(SubscribeResponse data) {
                        onHandleDataPlan(data);
                    }
                });
    }

    private void checkSomeMsg(CameraBean cameraBean) {
        Boolean is4G = cameraBean.is4G;
        if (is4G) {
            ApiService.createApiService().getCurrentSub(cameraBean.sn)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<SubscribeResponse>() {
                        @Override
                        protected void onHandleSuccess(SubscribeResponse data) {
                            onHandleDataPlan(data);
                        }
                    });
        }
    }

    private void onHandleDataPlan(SubscribeResponse data) {
        Logger.t(TAG).d("getCurrentSub: " + data.getStatus());
        InfoMsgQueue infoMsgQueue = null;
        if (mCamera != null) {
            infoMsgQueue = mCamera.getInfoMsgQueue();
        } else if (mCameraBean != null) {
            infoMsgQueue = this.infoMsgQueue;
        }

        if ("in_service".equals(data.getStatus()) || "paid".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);

            SubscribeResponse.CurrentSubCycleBean currentSubCycle = data.getCurrentSubCycle();
            int usageInKB = currentSubCycle.getCtdDataUsageInKB();
            int totalQuotaInKB = currentSubCycle.getTotalQuotaInKB();
            float radio = usageInKB / (float) totalQuotaInKB;
            Logger.t(TAG).d("usage/total radio: " + radio);
            if (radio > 0.9) {
                tv_curPlan.setTextColor(getResources().getColor(R.color.colorRed));
            } else {
                tv_curPlan.setTextColor(getResources().getColor(R.color.colorAccent));
            }
            int temp = (totalQuotaInKB - usageInKB) > 0 ? (totalQuotaInKB - usageInKB) : 0;
            String plan = temp / 1024 / 1024 > 0 ? String.format(getString(R.string.camera_plan_gb), temp / 1024 / 1024)
                    : String.format(getString(R.string.camera_plan_mb), temp / 1024);
            tv_curPlan.setText(plan);
        } else if ("none".equals(data.getStatus())) {
            if (infoMsgQueue != null) infoMsgQueue.putMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);
        } else {
            if (infoMsgQueue != null) infoMsgQueue.clearMsg(InfoMsgQueue.I_SUBSCRIBE_PLAN);

            tv_curPlan.setTextColor(getResources().getColor(R.color.colorRed));
            if ("suspended".equals(data.getStatus()))
                tv_curPlan.setText(R.string.suspended);
            if ("expired".equals(data.getStatus()))
                tv_curPlan.setText(R.string.expired);
        }
    }

    private void onNewCamera(CameraWrapper wrapper) {
        Logger.t(TAG).d("onNewVdtCamera: " + wrapper);
        tv_cameraName.setText(wrapper.getName());
        tv_cameraName.setVisibility(isForeground ? View.VISIBLE : View.INVISIBLE);

        iv_cameraStatus.setImageResource(R.drawable.icon_live_video);
        iv_offlineShadow.setVisibility(View.INVISIBLE);
        iv_placeHolder.setVisibility(View.INVISIBLE);

        //4g相机显示信号强度，wifi相机不显示
        if (wrapper.getMountVersion() != null && wrapper.getMountVersion().support_4g) {
            parseCameraSignal(wrapper);
        }

        openLiveViewData();
        if (wrapper instanceof VdtCamera) ((VdtCamera) wrapper).refreshBatteryInfo();
        refreshPipeline(wrapper);
        if (Constants.isFleet()) {
            filterEvents(wrapper);
        }

        mCamera.getInfoMsgQueue().asObservable()
                .subscribeOn(Schedulers.io())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onInfoMsgQueue, new ServerErrorHandler(TAG));

        mCamera.cameraStatus()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updateLocalCameraInfo, new ServerErrorHandler());
    }

    //过滤最近24小时内的事件
    @SuppressLint("CheckResult")
    private void filterEvents(CameraWrapper cameraWrapper) {
        Observable.create((ObservableEmitter<Integer> emitter) -> {
            try {
                List<Clip> newClipList = new ArrayList<>();

                int flag = ClipSetExRequest.FLAG_CLIP_EXTRA | ClipSetExRequest.FLAG_CLIP_DESC
                        | ClipSetExRequest.FLAG_CLIP_ATTR | ClipSetExRequest.FLAG_CLIP_SCENE_DATA
//                        | ClipSetExRequest.FLAG_CLIP_RAW_FCC | ClipSetExRequest.FLAG_CLIP_VIDEO_TYPE
                        | ClipSetExRequest.FLAG_CLIP_VIDEO_DESCR;

                boolean isVdtCamera = cameraWrapper.getServerInfo().isVdtCamera;
                if (!isVdtCamera) {
                    flag = flag | ClipSetExRequest.FLAG_CLIP_RAW_FCC | ClipSetExRequest.FLAG_CLIP_VIDEO_TYPE;
                }

                VdbRequestFuture<ClipSet> futureMarked = VdbRequestFuture.newFuture();

                ClipSetExRequest requestMarked = new ClipSetExRequest(Clip.TYPE_MARKED, flag, 0, futureMarked, futureMarked);

                VdbRequestQueue requestQueue = cameraWrapper.getRequestQueue();
                Logger.t(TAG).e("requestQueue exist: " + (requestQueue != null));

                if (requestQueue != null) {
                    requestQueue.add(requestMarked);
                    ClipSet clipSetMarked = futureMarked.get(5000, TimeUnit.MILLISECONDS);
                    if (clipSetMarked != null) {
                        Logger.t(TAG).e("TYPE_MARKED clipSet size: " + clipSetMarked.getCount());
                        newClipList.addAll(clipSetMarked.getClipList());
                    }
                }

                int eventNum = 0;

                for (Clip clip : newClipList) {
                    if (clip.videoType != VideoEventType.TYPE_HIGHLIGHT) {
                        long sub = System.currentTimeMillis() - clip.getStartTimeMsAbs();
                        if (sub < 60 * 60 * 24 * 1000) {
                            eventNum++;
                        }
                    }
                }

                Logger.t(TAG).e("eventNum: " + eventNum);
                emitter.onNext(eventNum);

            } catch (Exception ex) {
                Logger.t(TAG).d("filterEvents error " + ex.getMessage());
                emitter.onNext(0);
            }
        })
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(integer -> {
                    if (integer == 0) {
                        llCameraEvents.setVisibility(View.GONE);
                        return;
                    }
                    tvCameraEvents.setText(String.valueOf(integer));
                    llCameraEvents.setVisibility(View.VISIBLE);
                }, new ServerErrorHandler(TAG));
    }

    private void parseCameraSignal(CameraWrapper cameraWrapper) {
        String lteStatus = cameraWrapper.getLteStatus();
        Logger.t(TAG).d("lteStatus: " + lteStatus);
        int resource = R.drawable.fourg_no_signal;
        try {
            JSONObject jsonObject = new JSONObject(lteStatus);
            String signal = jsonObject.getString("signal");
            Logger.t(TAG).d("signal: " + signal);
            if (!TextUtils.isEmpty(signal)) {
                String[] signals = signal.split(",");
                if (signals.length > 2) {
                    String replace = signals[2].replace("[", "").replace("]", "");
                    resource = onHandleSignal(Float.parseFloat(replace));
                }
            }
        } catch (JSONException e) {
            Logger.t(TAG).e("parseCameraSignal ex = " + e.getMessage());
        } finally {
            iv_4gStatus.setVisibility(View.VISIBLE);
            iv_4gStatus.setImageResource(resource);
        }
    }

    private void onNewCamera(CameraBean cameraBean) {
        Logger.t(TAG).d("onNewCameraBean: " + cameraBean);
        tv_cameraName.setText(cameraBean.name);
        tv_cameraName.setVisibility(isForeground ? View.VISIBLE : View.INVISIBLE);

        fetchThumbnail(cameraBean);

        if (mCameraBean.state != null) {
            String mode = mCameraBean.state.mode;
            if (!TextUtils.isEmpty(mode)) {
                iv_modeStatus.setVisibility(View.VISIBLE);
                iv_modeStatus.setImageResource(mode.equals(DRIVING_MODE)
                        ? R.drawable.icon_camera_driving : R.drawable.icon_camera_parking);
            }

            boolean batteryCharging = mCameraBean.state.batteryCharging;
            int batteryRemaining = mCameraBean.state.batteryRemaining;
            int batteryVol = mCameraBean.state.batteryVol;

            iv_batteryStatus.setVisibility(View.VISIBLE);
            iv_batteryStatus.setImageResource(BatteryImageViewResHelper.getBatteryViewRes(batteryRemaining / 20 - 1,
                    batteryCharging ? VdtCamera.STATE_BATTERY_CHARGING : -1, batteryVol));
        }

        if (cameraBean.isOnline != null && cameraBean.isOnline) {
            iv_offlineShadow.setVisibility(View.INVISIBLE);
            iv_cameraStatus.setImageResource(R.drawable.icon_home_4g_live);

            if (cameraBean._4gSignal != null) {
                int i = onHandleSignal(cameraBean._4gSignal.RSRP);
                iv_4gStatus.setVisibility(View.VISIBLE);
                iv_4gStatus.setImageDrawable(getResources().getDrawable(i));
            }
        } else {
            iv_offlineShadow.setVisibility(View.VISIBLE);
            iv_cameraStatus.setImageResource(R.drawable.icon_offline_n);
        }

        if (cameraBean.is4G != null && cameraBean.is4G) {

            Logger.t(TAG).d("camera gps: " + cameraBean.gps);
            Logger.t(TAG).d("camera " + cameraBean.sn + " location: " + cameraBean.location);

            if (cameraBean.gps != null && cameraBean.gps.longitude != 0 && cameraBean.gps.latitude != 0) {
                ll_location.setVisibility(View.VISIBLE);

                if (cameraBean.location != null && !TextUtils.isEmpty(cameraBean.location.route)) {
                    tv_location.setText(cameraBean.location.route);

                    ll_location.setOnClickListener(v -> LocationMapActivity.launch(getActivity(),
                            cameraBean.gps.latitude, cameraBean.gps.longitude, cameraBean.location.address));
                } else {
                    String lat = String.format(Locale.ENGLISH, "%.6f", cameraBean.gps.latitude);
                    String lng = String.format(Locale.ENGLISH, "%.6f", cameraBean.gps.longitude);
                    tv_location.setText(String.format("%s, %s", lat, lng));

                    ll_location.setOnClickListener(v -> LocationMapActivity.launch(getActivity(),
                            cameraBean.gps.latitude, cameraBean.gps.longitude, null));
                }
            }
        }

        //本地缓存最近一次连接时间和服务器接口相机最近一次上线时间做对比
        CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(cameraBean.sn);
        long lastConnectingTime = 0;
        if (cameraItem != null) {
            lastConnectingTime = cameraItem.getLastConnectingTime();
        }
        if (cameraBean.thumbnailTime != null || cameraBean.onlineStatusChangeTime != null || lastConnectingTime != 0) {
            long time = Math.max(cameraBean.thumbnailTime != null ? cameraBean.thumbnailTime : 0,
                    cameraBean.onlineStatusChangeTime != null ? cameraBean.onlineStatusChangeTime : 0);
            time = Math.max(time, lastConnectingTime);
            if (cameraBean.is4G != null && cameraBean.is4G && !cameraBean.isOnline && time != 0) {
                tv_time.setText(StringUtils.getFormattedTime(HornApplication.getContext(), time));
            } else {
                tv_time.setText("");
            }
        }
    }

    private void onNewFleetCamera(FleetCameraBean camerasBean) {
        Logger.t(TAG).d("onNewFleetCamera: " + camerasBean);
        tv_cameraName.setText(camerasBean.getSn());
        tv_cameraName.setVisibility(isForeground ? View.VISIBLE : View.INVISIBLE);


        CameraItem cameraItem = LocalCameraDaoManager.getInstance().getCameraItem(camerasBean.getSn());
        long lastConnectingTime = 0;
        if (cameraItem != null) {
            lastConnectingTime = cameraItem.getLastConnectingTime();
        }
    }

    private int onHandleSignal(float rsrp) {
        int resource;
        if (rsrp < -112) {
            resource = R.drawable.icon_4g_4_n;
        } else if (rsrp < -105) {
            resource = R.drawable.icon_4g_4_n;
        } else if (rsrp < -96) {
            resource = R.drawable.icon_4g_3_n;
        } else if (rsrp < -88) {
            resource = R.drawable.icon_4g_2_n;
        } else {
            resource = R.drawable.icon_4g_1_n;
        }
        return resource;
    }

    private void fetchThumbnail(CameraBean camera) {
        Observable.create((ObservableOnSubscribe<Optional<Bitmap>>) emitter -> {
            try {
                Logger.t(TAG).d("fetchThumbnail: " + camera.thumbnailUrl);
                if (!TextUtils.isEmpty(camera.thumbnailUrl)) {
                    Bitmap bitmap = Glide.with(HornApplication.getContext())
                            .load(camera.thumbnailUrl)
                            .asBitmap()
                            .centerCrop()
                            .diskCacheStrategy(DiskCacheStrategy.ALL)
                            .into(1024, 1024)
                            .get();
                    emitter.onNext(Optional.ofNullable(bitmap));
                } else {
                    emitter.onNext(Optional.empty());
                }
            } catch (Exception e) {
                Logger.t(TAG).e("fetchThumbnail error: " + e.getMessage());
                emitter.onNext(Optional.empty());
            }
        })
                .filter(bitmapOptional -> bitmapOptional.getIncludeNull() != null)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribe(bitmapOptional -> {
                    Bitmap bitmap = bitmapOptional.get();

                    getVRLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight());
                    // texture
                    if (mCallback != null) {
                        if (iv_placeHolder.getVisibility() == View.VISIBLE) {
                            iv_placeHolder.setVisibility(View.INVISIBLE);
                        }
                        mCallback.texture(bitmap);
                    }
                }, new ServerErrorHandler(TAG));
    }

    public void refreshPipeline(CameraWrapper camera) {
        mjpegAddress = new InetSocketAddress(camera.getAddress(), 8081);
        // init VR Library
        loadMJPEG();
    }

    synchronized private void loadMJPEG() {
        try {
            if (mjpegAddress != null && mMjpegStream == null) {
                Logger.t(TAG).d("start stream");
                startStream(mjpegAddress);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    private void onInfoMsgQueue(InfoMsgQueue imq) {
        InfoMsgQueue.InfoMsg msg = imq.peek();
        if (msgPopWindow != null) {
            msgPopWindow.dissmiss();
        }
        if (msg == null) {
            tv_cameraName.setTextColor(getResources().getColor(R.color.colorPrimary));
            tv_cameraName.setOnClickListener(null);
        } else {
            Logger.t(TAG).d("msg isRead = " + msg.isRead());

            boolean setup = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, !Constants.isFleet());
            Logger.t(TAG).d("setup: " + setup);

            //新手引导过程中、当前页面不可见时不显示弹窗
            LocalLiveActivity activity = (LocalLiveActivity) getActivity();
            Fragment parentFragment = getParentFragment();
            if ((activity != null && activity.tourGuide) || setup) {
                //do sth
            } else if (!msg.isRead() && (parentFragment != null && parentFragment.getUserVisibleHint())) {
                showPopBottom(msg);
            }
            tv_cameraName.setTextColor(InfoMsgUtils.getInstance().getColor(getContext(), msg.getType()));
            tv_cameraName.setOnClickListener(v -> showPopBottom(msg));
        }
    }

    private void updateLocalCameraInfo(CameraWrapper cameraWrapper) {
        iv_modeStatus.setVisibility(View.VISIBLE);
        iv_modeStatus.setImageResource(cameraWrapper.getMonitorMode() == VdtCamera.MONITOR_MODE_PARK
                ? R.drawable.icon_camera_parking : R.drawable.icon_camera_driving);

        iv_batteryStatus.setVisibility(View.VISIBLE);
        iv_batteryStatus.setImageResource(BatteryImageViewResHelper.getBatteryViewRes(cameraWrapper.getBatteryLevel(),
                cameraWrapper.getBatteryState(), cameraWrapper.getVoltageNow()));

        iv_gpsStatus.setVisibility(View.VISIBLE);

        if (cameraWrapper instanceof VdtCamera) {
            boolean gpsState = ((VdtCamera) cameraWrapper).getGpsState();
            if (gpsState) {
                iv_gpsStatus.setImageResource(R.drawable.icon_gps_3);
            } else {
                if (iv_gpsStatus.getDrawable() instanceof AnimationDrawable) {
                    AnimationDrawable drawable = (AnimationDrawable) iv_gpsStatus.getDrawable();
                    drawable.start();
                }
            }
        }
    }

    private void onDisconnectCamera() {
        Logger.t(TAG).d("onDisconnectCamera");
        mCamera = null;

        if (Constants.isFleet()) {
            llCameraEvents.setVisibility(View.GONE);
        }
        iv_cameraStatus.setImageResource(R.drawable.icon_home_offline);
        iv_offlineShadow.setVisibility(View.VISIBLE);
        iv_batteryStatus.setVisibility(View.GONE);
        iv_modeStatus.setVisibility(View.GONE);
        iv_gpsStatus.setVisibility(View.GONE);

        closeLiveRawData();
        stopStream();
    }

    public void startStream(final InetSocketAddress serverAddr) {
        mMjpegStream = new MjpegStream() {
            @Override
            protected void onBitmapReadyAsync(MjpegDecoder decoder, MjpegStream stream) {
                BitmapBuffer bb = stream.getOutputBitmapBuffer(decoder);
                if (bb != null) {
                    Bitmap bitmap = bb.getBitmap();
                    // Logger.d(TAG, "loaded image, size:" + mCurrentBitmap.getWidth() + "," + mCurrentBitmap.getHeight());
                    // notify if size changed
                    new Handler(Looper.getMainLooper()).post(() -> {
                        getVRLibrary().onTextureResize(bitmap.getWidth(), bitmap.getHeight());
                        // texture
                        Activity activity = getActivity();
                        if (activity != null && isAdded()) {
                            tv_time.setText(StringUtils.getFormattedTime(HornApplication.getContext(), System.currentTimeMillis())
                                    .replace(getResources().getString(R.string.today) + "\n", ""));
                        }
                        if (mCallback != null) {
                            mCallback.texture(bitmap);
                        }
                    });
                }
            }

            @Override
            protected void onEventAsync(MjpegDecoder decoder, MjpegStream stream) {
            }

            @Override
            protected void onIoErrorAsync(MjpegStream stream, final int error) {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        if (mMjpegStream != null) {
                            mMjpegStream.stop();
                            mMjpegStream = null;
                            startStream(serverAddr);
                        }
                    });
                }
            }
        };
        mMjpegStream.start(serverAddr);
    }

    public void stopStream() {
        Logger.t(TAG).d("stop stream");
        if (mMjpegStream != null) {
            mMjpegStream.stop();
            mMjpegStream = null;
        }
    }

    private void openLiveViewData() {
        CameraWrapper cameraWrapper = mCamera;
        if (cameraWrapper != null && cameraWrapper.getRequestQueue() != null) {
            LiveRawDataRequest request = new LiveRawDataRequest(RawDataBlock.F_RAW_DATA_GPS,
                    response -> Logger.t(TAG).d("LiveRawDataResponse: " + response),
                    error -> Logger.t(TAG).e("LiveRawDataResponse error: " + error));
            cameraWrapper.getRequestQueue().add(request);
            cameraWrapper.setOnRawDataItemUpdateListener(mRawDataUpdateHandler);
        }
    }

    private void closeLiveRawData() {
        CameraWrapper vdtCamera = mCamera;
        if (vdtCamera != null && vdtCamera.getRequestQueue() != null) {
            LiveRawDataRequest request = new LiveRawDataRequest(0,
                    response -> Logger.t(TAG).d("LiveRawDataResponse: " + response),
                    error -> Logger.t(TAG).e("LiveRawDataResponse error" + error));
            vdtCamera.getRequestQueue().add(request);
        }
    }

    private ICameraWrapper.OnRawDataUpdateListener mRawDataUpdateHandler = new ICameraWrapper.OnRawDataUpdateListener() {
        @Override
        public void OnRawDataUpdate(CameraWrapper camera, List<RawDataItem> itemList) {
            if (mCamera != camera) {
                return;
            }

            GpsData.Coord coord = null;
            for (RawDataItem item : itemList) {
                if (item.getType() == RawDataItem.DATA_TYPE_GPS) {
                    GpsData gpsData = (GpsData) item.data;

                    if (gpsData != null) {
                        coord = gpsData.coord;
                        break;
                    } else {
                        return;
                    }
                }
            }

            iv_gpsStatus.setVisibility(View.VISIBLE);

            if (coord == null) {
                if (iv_gpsStatus.getDrawable() instanceof AnimationDrawable) {
                    AnimationDrawable drawable = (AnimationDrawable) iv_gpsStatus.getDrawable();
                    drawable.start();
                }
                return;
            }

            iv_gpsStatus.setImageResource(R.drawable.icon_gps_3);

            GpsData.Coord finalCoord = coord;
            if (finalCoord.lat != 0 && finalCoord.lng != 0) {

                float[] results = new float[1];
                Location.distanceBetween(latitude, longitude, finalCoord.lat, finalCoord.lng, results);
//                Logger.t(TAG).d("distanceBetween: " + results[0]);

                if (results[0] > 50) {
                    try {
                        latitude = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", finalCoord.lat));
                        longitude = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", finalCoord.lng));

                        ApiService.createApiService().getLocation(latitude, longitude)
                                .compose(Transformers.switchSchedulers())
                                .doFinally(() -> ll_location.setVisibility(View.VISIBLE))
                                .compose(bindToLifecycle())
                                .subscribe(response -> {
//                                    Logger.t(TAG).d("getLocation: " + response.getAddress());
                                    LocationResponse.AddressBean address = response.getAddress();

                                    if (address != null && !TextUtils.isEmpty(address.getRoute())) {
                                        tv_location.setText(address.getRoute());
                                        ll_location.setOnClickListener(v -> LocationMapActivity.launch(getActivity(),
                                                latitude, longitude, address.getAddress()));
                                    } else {
                                        tv_location.setText(String.format("%s, %s", latitude, longitude));

                                        ll_location.setOnClickListener(v -> LocationMapActivity.launch(getActivity(),
                                                latitude, longitude, null));
                                    }
                                }, throwable -> {
                                    Logger.t(TAG).e("getLocation throwable: " + throwable.getMessage());
                                    tv_location.setText(String.format("%s, %s", latitude, longitude));

                                    ll_location.setOnClickListener(v -> LocationMapActivity.launch(getActivity(),
                                            latitude, longitude, null));
                                });
                    } catch (Exception ex) {
                        Logger.t(TAG).d("ex: " + ex.getMessage());
                    }
                }
            }
        }
    };

    public void scaleValueAnimator() {
        PropertyValuesHolder mPropertyValuesHolderScaleX = PropertyValuesHolder.ofFloat("scaleX", 1.0f, 0.7f);
        PropertyValuesHolder mPropertyValuesHolderScaleY = PropertyValuesHolder.ofFloat("scaleY", 1.0f, 0.7f);
        ValueAnimator mAnimator = ValueAnimator.ofPropertyValuesHolder(mPropertyValuesHolderScaleX, mPropertyValuesHolderScaleY);
        mAnimator.addUpdateListener(animation -> {
            float animatorValueScaleX = (float) animation.getAnimatedValue("scaleX");
            float animatorValueScaleY = (float) animation.getAnimatedValue("scaleY");
            iv_clickGuide.setScaleX(animatorValueScaleX);
            iv_clickGuide.setScaleY(animatorValueScaleY);
        });
        mAnimator.setInterpolator(new LinearInterpolator());
        mAnimator.setDuration(1000);
        mAnimator.setRepeatCount(5);
        mAnimator.setRepeatMode(ValueAnimator.REVERSE);
        mAnimator.setTarget(iv_clickGuide);
        mAnimator.start();
    }

    private void showPopBottom(InfoMsgQueue.InfoMsg infoMsg) {
        infoMsg.markRead();
        if (msgPopWindow != null) {
            msgPopWindow.dissmiss();
        }
        msgPopWindow = new CustomPopWindow.PopupWindowBuilder(getActivity())
                .setView(InfoMsgUtils.getInstance().getView(getActivity(), infoMsg.getType()))
                .setFocusable(true)
                .setOutsideTouchable(true)
                .create();
        msgPopWindow.getContentView().findViewById(R.id.iv_msgIcon)
                .setOnClickListener(v -> msgPopWindow.dissmiss());
        msgPopWindow.getContentView().findViewById(R.id.btn_action)
                .setOnClickListener(v -> {
                    if (mCamera != null && getActivity() != null) {
                        InfoMsgUtils.getInstance().clickAction(getActivity(), mCamera.getSerialNumber(), infoMsg.getType());
                    }
                    msgPopWindow.dissmiss();
                });
        msgPopWindow.showAsDropDown(tv_cameraName,
                -(msgPopWindow.getPopupWindow().getWidth() - tv_cameraName.getWidth()) / 2,
                10);
    }

    @Override
    public void onPause() {
        super.onPause();
        closeLiveRawData();
        stopStream();
        if (mVRLibrary != null) {
            mVRLibrary.onPause(getActivity());
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mVRLibrary != null) {
            mVRLibrary.onDestroy();
        }
    }

}
