package com.mk.autosecure.ui.fragment;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_PLANE_FIT;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.SoundPool;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.tool.FastClickLimitUtil;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.ICameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.data.DmsClient;
import com.mkgroup.camera.data.dms.BasicSocket;
import com.mkgroup.camera.data.dms.DataApi;
import com.mkgroup.camera.data.dms.DmsRequestQueue;
import com.mkgroup.camera.model.rawdata.DmsData;
import com.mkgroup.camera.model.rawdata.DmsRect;
import com.mkgroup.camera.model.rawdata.RawDataItem;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.viewmodels.fragment.DoCalibFragmentViewModel;
import com.mk.autosecure.viewmodels.setting.CalibActivityViewModel;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.net.InetSocketAddress;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Action;
import io.reactivex.schedulers.Schedulers;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link DoCalibFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
@RequiresFragmentViewModel(DoCalibFragmentViewModel.ViewModel.class)
public class DoCalibFragment extends BaseFragment<DoCalibFragmentViewModel.ViewModel> {
    private final static String TAG = DoCalibFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private boolean mIsFirstVisible = true;
    private boolean isViewCreated = false;
    private boolean currentVisibleState = false;

    private CalibActivityViewModel.ViewModel parentViewModel;

    private Context mContext;

    private CameraWrapper mCamera;

    private MDVRLibrary mVRLibrary;
    private InetSocketAddress mjpegAddress;
    private MjpegStream mMjpegStream;
    private MD360BitmapTexture.Callback mCallback;

    private int mXRadio = 16;
    private int mYRadio = 9;

    private int x;
    private int y;
    private int z;

    private CountDownHandler mHandler;

    private DmsRequestQueue mDmsRequestQueue;

    private Bitmap mValidBmp;
    private Bitmap mUnvalidBmp;

    @BindView(R.id.tv_calib_step)
    TextView tvCalibStep;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.glView)
    GLSurfaceView mGlView;

    @BindView(R.id.iv_calib_status)
    ImageView ivCalibStatus;

    @BindView(R.id.va_calib_step)
    ViewAnimator vaCalibStep;

    @BindView(R.id.btn_adjust_next)
    Button btnAdjustNext;

    @BindView(R.id.va_calib)
    ViewAnimator vaCalib;

    @BindView(R.id.tv_calib_tips)
    TextView tvCalibTips;

    @BindView(R.id.tv_countdown)
    TextView tvCountdown;

    @BindView(R.id.btn_calib_next)
    Button btnCalibNext;

    @OnClick(R.id.btn_adjust_next)
    public void doAdjustNext() {
        tvCalibStep.setText(R.string._5_calibrate_the_camera);
        vaCalibStep.setDisplayedChild(1);
//        if (parentViewModel != null && parentViewModel.inputs != null) {
//            parentViewModel.inputs.proceed(4);
//        }
    }

    public boolean isBackToAdjust() {
        return vaCalibStep.getDisplayedChild() == 1;
    }

    @OnClick(R.id.tv_back_adjust)
    public void backToAdjust() {
        tvCalibStep.setText(R.string._4_adjust_the_camera_position);
        vaCalibStep.setDisplayedChild(0);
//        if (parentViewModel != null && parentViewModel.inputs != null) {
//            parentViewModel.inputs.proceed(3);
//        }
    }

    @OnClick(R.id.btn_calib_next)
    public void doCalibNext() {
        vaCalib.setDisplayedChild(2);

        playAudio();

        if (mHandler == null) {
            mHandler = new CountDownHandler(this);
        }
        mHandler.sendEmptyMessage(3);
    }

    private void playAudio() {
        SoundPool soundPool = new SoundPool.Builder().build();
        int soundID = soundPool.load(getContext(), R.raw.countdown, 1);
        Logger.t(TAG).d("soundID: " + soundID);
        soundPool.setOnLoadCompleteListener((soundPool1, sampleId, status) -> {
            Logger.t(TAG).d("onLoadComplete: " + sampleId + " " + status);
            soundPool1.play(soundID, 1.0f, 1.0f, 1, 0, 1.0f);
        });
    }

    public DoCalibFragment() {
        // Required empty public constructor
        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("DoCalibFragment: mCamera=" + mCamera);

        if (mCamera != null) {
            mjpegAddress = new InetSocketAddress(mCamera.getAddress(), 8081);
        }
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param viewModel
     * @param param1    Parameter 1.
     * @param param2    Parameter 2.
     * @return A new instance of fragment FourthFragment.
     */
    public static DoCalibFragment newInstance(CalibActivityViewModel.ViewModel viewModel, String param1, String param2) {
        DoCalibFragment fragment = new DoCalibFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    private SoftReference<Activity> mSoftActivity;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mSoftActivity = new SoftReference<>(activity);
    }

    @Override
    public void onAttach(@NotNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        if (parentViewModel != null && parentViewModel.inputs != null) {
//            parentViewModel.inputs.proceed(1);
//        }
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        isViewCreated = true;

        if (!isHidden() && getUserVisibleHint()) {
            dispatchUserVisibleHint(true);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        isViewCreated = false;
        mIsFirstVisible = true;
    }

    private void initViews() {
        mVRLibrary = createBitmapVRLibrary();

        mValidBmp = scaleImage(R.drawable.icon_calib_valid);
        mUnvalidBmp = scaleImage(R.drawable.icon_calib_unvalid);

        ivCalibStatus.setImageBitmap(mUnvalidBmp);

        String string = getString(R.string.tap_calib_and_let_the_driver_maintain_the_current_position_and_look_forward_for_at_least);

        SpannableStringBuilder spannable = new SpannableStringBuilder(string);
        ForegroundColorSpan colorPrimary1 = new ForegroundColorSpan(getResources().getColor(R.color.colorPrimary));
        ForegroundColorSpan colorBaseFleet = new ForegroundColorSpan(getResources().getColor(R.color.colorBaseFleet));
        ForegroundColorSpan colorPrimary2 = new ForegroundColorSpan(getResources().getColor(R.color.colorPrimary));

        spannable.setSpan(colorPrimary1, 0, 88, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannable.setSpan(new AbsoluteSizeSpan((int) ViewUtils.sp2px(mContext, 14)), 0, 88, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        spannable.setSpan(colorBaseFleet, 88, 98, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannable.setSpan(new AbsoluteSizeSpan((int) ViewUtils.sp2px(mContext, 18)), 88, 98, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        spannable.setSpan(colorPrimary2, 98, string.length() - 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannable.setSpan(new AbsoluteSizeSpan((int) ViewUtils.sp2px(mContext, 14)), 98, string.length() - 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        tvCalibTips.setText(spannable);
    }

    public void setCalibParams(int x, int y, int z) {
        Logger.t(TAG).d("setCalibParams: " + x + " " + y + " " + z);
        this.x = x;
        this.y = y;
        this.z = z;
    }

    private void openLiveDmsData() {
        CameraWrapper cameraWrapper = mCamera;
        if (cameraWrapper != null && cameraWrapper.getRequestQueue() != null) {
            SnipeApi.getLiveDmsDataRx(true)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe();
            cameraWrapper.setOnRawDataItemUpdateListener(mRawDataUpdateHandler);
        }
    }

    private void closeLiveDmsData() {
        CameraWrapper vdtCamera = mCamera;
        if (vdtCamera != null && vdtCamera.getRequestQueue() != null) {
            SnipeApi.getLiveDmsDataRx(false)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe();
        }
    }

    private ICameraWrapper.OnRawDataUpdateListener mRawDataUpdateHandler = new ICameraWrapper.OnRawDataUpdateListener() {
        @Override
        public void OnRawDataUpdate(CameraWrapper camera, List<RawDataItem> itemList) {
            if (mCamera != camera || itemList == null) {
                return;
            }

            DmsData dmsData = null;
            DmsRect dmsRect = null;
            for (RawDataItem item : itemList) {
                if (item.getType() == RawDataItem.DATA_TYPE_DMS1) {
                    dmsData = (DmsData) item.data;

                    if (dmsData != null && dmsData.isDriverValid == 1) {
                        // check eyesight version
                        if (dmsData.version >= 5) {
                            if (dmsData.l1Output != null && dmsData.l1Output.isDriverValid == 1) {
                                dmsRect = dmsData.l1Output.headRect;
                                break;
                            }
                        } else {
                            if (dmsData.output != null && dmsData.output.isDriverValid == 1) {
                                dmsRect = dmsData.output.rect;
                                break;
                            }
                        }
                    } else {
                        return;
                    }
                }
            }

            if (dmsRect == null) {
                return;
            }

            Logger.t(TAG).d("dmsData: " + dmsData);

            float hRadio = dmsRect.height / dmsData.dms_height;
            float xRadio = (dmsRect.xc) / dmsData.dms_width;
            float yRadio = dmsRect.yc / dmsData.dms_height;

            Logger.t(TAG).d("hRadio: " + hRadio + " xRadio: " + xRadio + " yRadio: " + yRadio);

            if (hRadio >= 0.2 && hRadio <= 0.5
                    && xRadio >= 0.33 && xRadio <= 0.67
                    && (yRadio - hRadio / 2) >= 0.1 && (yRadio + hRadio / 2) <= 0.75) {
//                    && yRadio <= 0.5 && (yRadio - hRadio / 2) >= 0.1) {
                btnAdjustNext.setEnabled(true);
                ivCalibStatus.setImageBitmap(mValidBmp);
                if (vaCalib.getDisplayedChild() != 2) vaCalib.setDisplayedChild(1);
                btnCalibNext.setEnabled(true);
            } else {
                btnAdjustNext.setEnabled(false);
                ivCalibStatus.setImageBitmap(mUnvalidBmp);
                if (vaCalib.getDisplayedChild() != 2) vaCalib.setDisplayedChild(0);
                btnCalibNext.setEnabled(false);
            }
        }
    };

    private Bitmap scaleImage(int resourceID) {
        Bitmap srcBitmap = BitmapFactory.decodeResource(mContext.getResources(), resourceID);
        return Bitmap.createBitmap(srcBitmap, 0, 0, srcBitmap.getWidth(), srcBitmap.getHeight() * 5 / 6);
    }

    private Bitmap scaleImage(Bitmap bitmap) {
        return Bitmap.createBitmap(bitmap, 0, 0, 1280, 800);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isViewCreated) {
            if (isVisibleToUser && !currentVisibleState) {
                dispatchUserVisibleHint(true);
            } else if (!isVisibleToUser && currentVisibleState) {
                dispatchUserVisibleHint(false);
            }
        }
    }

    @Override
    public void onPause() {
        super.onPause();

        if (currentVisibleState && getUserVisibleHint()) {
            dispatchUserVisibleHint(false);
        }
    }

    protected void onFragmentPause() {
        stopStream();
        closeLiveDmsData();
        if (mVRLibrary != null) {
            mVRLibrary.onPause(mSoftActivity.get());
        }
    }

    private void dispatchUserVisibleHint(boolean visible) {
        currentVisibleState = visible;

        if (visible) {
            if (mIsFirstVisible) {
                mIsFirstVisible = false;
                onFragmentFirstVisible();
            }
            onFragmentResume();
        } else {
            onFragmentPause();
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        if (!mIsFirstVisible) {
            if (!isHidden() && !currentVisibleState && getUserVisibleHint()) {
                dispatchUserVisibleHint(true);
            }
        }
    }

    protected void onFragmentResume() {
        openLiveDmsData();
        if (mjpegAddress != null) {
            startStream(mjpegAddress);
        }
        if (mVRLibrary != null) {
            mVRLibrary.onResume(mSoftActivity.get());
        }
    }

    protected void onFragmentFirstVisible() {
        if (mCamera == null) {
            Logger.t(TAG).e("onFragmentFirstVisible: mCamera == null !!!");
        }

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("mCamera: " + mCamera);

        if (mCamera != null) {
            mjpegAddress = new InetSocketAddress(mCamera.getAddress(), 8081);
        }

        HandlerThread handlerThread = new HandlerThread("DMS");
        handlerThread.start();
        Handler handler = new Handler(handlerThread.getLooper());
        handler.post(() -> {
            DmsClient client = new DmsClient(mCamera.getHostString());
            try {
                client.connect();
            } catch (IOException e) {
                Logger.t(TAG).e("DmsClient connect timeout");
            }

            Logger.t(TAG).d("isConnected: " + client.isConnected());

            if (client.isConnected()) {
                BasicSocket socket = new BasicSocket(client);
                mDmsRequestQueue = new DmsRequestQueue(socket);
                mDmsRequestQueue.start();
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mVRLibrary != null) {
            mVRLibrary.onDestroy();
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_do_calib, container, false);
        ButterKnife.bind(this, view);
        initViews();
        return view;
    }

    private void startStream(final InetSocketAddress serverAddr) {
        mMjpegStream = new MjpegStream() {
            @Override
            protected void onBitmapReadyAsync(MjpegDecoder decoder, MjpegStream stream) {
                BitmapBuffer bb = stream.getOutputBitmapBuffer(decoder);
                if (bb != null) {
//                    Bitmap bitmap = bb.getBitmap();
                    Bitmap bitmap = scaleImage(bb.getBitmap());
                    //notify if size changed
                    mSoftActivity.get().runOnUiThread(() -> {
                        try {
                            if (bitmap != null) {
                                Logger.t(TAG).d("%s", "loaded image, size:" + bitmap.getWidth() + "," + bitmap.getHeight());
                                if (mVRLibrary != null) {
                                    changeVideoSize(bitmap.getWidth(), bitmap.getHeight());
                                }

                                if (mCallback != null) {
                                    mCallback.texture(bitmap);
                                }
                            }
                        } catch (Exception ex) {
                            //Activity may have been destroyed.
                            Logger.t(TAG).d("error = " + ex.getMessage());
                        }
                    });
                }
            }

            @Override
            protected void onEventAsync(MjpegDecoder decoder, MjpegStream stream) {

            }

            @Override
            protected void onIoErrorAsync(MjpegStream stream, int error) {
                mSoftActivity.get().runOnUiThread(() -> {
                    if (mMjpegStream != null) {
                        mMjpegStream.stop();
                        mMjpegStream = null;
                        startStream(serverAddr);
                    }
                });
            }
        };
        mMjpegStream.start(serverAddr);
    }

    private void changeVideoSize(int videoWidth, int videoHeight) {
        int divisor = getGreatestCommonDivisor(videoWidth, videoHeight);

        int tempX = videoWidth / divisor;
        int tempY = videoHeight / divisor;

//        Logger.t(TAG).d("changeVideoSize: " + divisor + " " + tempX + " " + tempY);

        if (tempX != mXRadio || tempY != mYRadio) {
            mXRadio = tempX;
            mYRadio = tempY;

            if (mMediaWindow != null) {
                mMediaWindow.setRatio(mXRadio, mYRadio);
                mMediaWindow.post(() -> {
                    if (mVRLibrary != null) {
                        mVRLibrary.onTextureResize(videoWidth, videoHeight);
                    }
                });
            }
        } else {
            if (mVRLibrary != null) {
                mVRLibrary.onTextureResize(videoWidth, videoHeight);
            }
        }
    }

    private int getGreatestCommonDivisor(int videoWidth, int videoHeight) {
        int max = Math.max(videoWidth, videoHeight);
        int min = Math.min(videoWidth, videoHeight);

        while (max % min != 0) {
            int temp = max % min;
            max = min;
            min = temp;
        }
        return min;
    }

    private void stopStream() {
        Logger.t(TAG).d("stop stream");
        if (mMjpegStream != null) {
            mMjpegStream.stop();
            mMjpegStream = null;
        }
    }

    private MDVRLibrary createBitmapVRLibrary() {
        return MDVRLibrary.with(mSoftActivity.get())
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asBitmap(callback -> mCallback = callback)
                .pinchEnabled(false)
                .projectionMode(PROJECTION_MODE_PLANE_FIT)
                .projectionFactory(new CustomProjectionFactory())
                .build(mGlView);
    }

    private void showPop(int layoutID, Action posAct, Action negaAct) {
        View view = LayoutInflater.from(mContext).inflate(layoutID, null);

        PopupWindow popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                false);
        popupWindow.setOutsideTouchable(false);

        view.findViewById(R.id.btn_positive).setOnClickListener(v -> {
            if (FastClickLimitUtil.isFastClick()) return;
            popupWindow.dismiss();
            if (posAct != null) {
                try {
                    posAct.run();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        if (negaAct != null) {
            view.findViewById(R.id.tv_negative).setOnClickListener(v -> {
                if (FastClickLimitUtil.isFastClick()) return;
                popupWindow.dismiss();
                try {
                    negaAct.run();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }

        popupWindow.showAsDropDown(btnCalibNext);
    }

    private void showCalibPop() {
        showPop(R.layout.pop_makesure_calib,
                this::showCalibSuccessPop, () -> {
                    Logger.t(TAG).d("Not sure");
                    vaCalib.setDisplayedChild(btnCalibNext.isEnabled() ? 1 : 0);
                });
    }

    @SuppressLint("CheckResult")
    private void doCalibration() {
        DataApi.doCalibrationRx(mDmsRequestQueue, x, y, z)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(result -> {
                    Logger.t(TAG).d("doCalibrationRx: " + result);
                    showCalibPop();
                }, throwable -> {
                    Logger.t(TAG).e("doCalibrationRx throwable: " + throwable.getMessage());
                    showCalibFailedPop();
                });
    }

    private void showCalibSuccessPop() {
        showPop(R.layout.pop_calib_done, () -> finish(true), null);
    }

    private void showCalibFailedPop() {
        showPop(R.layout.pop_calib_failed, this::doCalibration, () -> finish(false));
    }

    private void finish(boolean success) {
//        if (parentViewModel != null && parentViewModel.inputs != null) {
////            parentViewModel.inputs.proceed(5);
////        }

//        if (mCamera != null && mCamera instanceof EvCamera) {
//            String historyRecordConfig = ((EvCamera) mCamera).getHistoryRecordConfig();
//            Logger.t(TAG).d("historyRecordConfig: " + historyRecordConfig);
//
//            List<RecordConfigListBean.ConfigListBean> recordConfigList = ((EvCamera) mCamera).getRecordConfigList();
//            Logger.t(TAG).d("recordConfigList: " + recordConfigList);
//
//            int index = -1;
//            for (int i = 0; i < recordConfigList.size(); i++) {
//                RecordConfigListBean.ConfigListBean listBean = recordConfigList.get(i);
//                if (historyRecordConfig.equals(listBean.getName())) {
//                    index = i;
//                    break;
//                }
//            }
//
//            if (index == -1) {
//                return;
//            }
//
//            if (index == recordConfigList.size() - 1) {
//                index = 0;
//            }
//            ((EvCamera) mCamera).setCurRecordConfig(index);
//        }

        if (mCamera != null && mCamera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
            mCamera.startRecording();
        }

        Activity activity = mSoftActivity.get();
        if (activity != null) {
            activity.setResult(success ? RESULT_OK : RESULT_CANCELED);
            activity.finish();
        }
    }

    static class CountDownHandler extends Handler {

        private WeakReference<DoCalibFragment> mWeakRef;

        CountDownHandler(DoCalibFragment fragment) {
            mWeakRef = new WeakReference<>(fragment);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            DoCalibFragment fragment = mWeakRef.get();
            if (fragment != null) {
                int count = msg.what;

                if (fragment.tvCountdown != null) {
                    fragment.tvCountdown.setText(String.valueOf(count));
                }

                if (--count >= 0) {
                    sendEmptyMessageDelayed(count, 1000);
                } else {
                    fragment.doCalibration();
                }
            }
        }
    }
}
