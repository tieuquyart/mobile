package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;

import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.setting.CalibActivityViewModel;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.lang.ref.SoftReference;
import java.net.InetSocketAddress;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

import static com.mkgroup.camera.CameraConstants.STATE_RECORD_RECORDING;
import static com.mkgroup.camera.CameraConstants.STATE_RECORD_STARTING;
import static com.mkgroup.camera.CameraConstants.STATE_RECORD_STOPPED;
import static com.mkgroup.camera.CameraConstants.STATE_RECORD_SWITCHING;
import static com.waylens.vrlib.MDVRLibrary.PROJECTION_MODE_PLANE_FIT;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link SecondCalibFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class SecondCalibFragment extends RxFragment {
    private final static String TAG = SecondCalibFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private CalibActivityViewModel.ViewModel parentViewModel;
    private View rootView;

    private CameraWrapper mCamera;

    private MDVRLibrary mVRLibrary;
    private InetSocketAddress mjpegAddress;
    private MjpegStream mMjpegStream;
    private MD360BitmapTexture.Callback mCallback;

    private int mXRadio = 16;
    private int mYRadio = 9;

    private boolean mDisableInvert = false;

    @BindView(R.id.media_window)
    FixedAspectRatioFrameLayout mMediaWindow;

    @BindView(R.id.iv_invert)
    ImageButton ivInvert;

    @OnClick(R.id.iv_invert)
    public void invert() {
        if (mDisableInvert) {
            Logger.t(TAG).d("camera is invert");
            return;
        }

        if (mCamera != null && mCamera instanceof EvCamera && mCamera.isVinMirrorAvailable()) {
            EvCamera mCamera = (EvCamera) this.mCamera;
            List<String> vinMirrorList = mCamera.getVinMirrorList();
            Logger.t(TAG).d("vinMirrorList: " + vinMirrorList);
            String s = vinMirrorList.get(vinMirrorList.size() - 1);
            Logger.t(TAG).d("dms mode: " + s);
            if ("normal".equals(s)) {
                s = "horz_vert";
            } else {
                s = "normal";
            }
            vinMirrorList.set(vinMirrorList.size() - 1, s);
            mCamera.setVinMirrorList(vinMirrorList);
        }
    }

    @OnClick(R.id.btn_invert_next)
    public void next() {
        if (parentViewModel != null && parentViewModel.inputs != null) {
            parentViewModel.inputs.proceed(2);
        }
    }

    public SecondCalibFragment() {
        // Required empty public constructor
        mCamera = VdtCameraManager.getManager().getCurrentCamera();
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
     * @return A new instance of fragment SecondCalibFragment.
     */
    public static SecondCalibFragment newInstance(CalibActivityViewModel.ViewModel viewModel, String param1, String param2) {
        SecondCalibFragment fragment = new SecondCalibFragment();
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
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.fragment_second_calib, container, false);
        ButterKnife.bind(this, rootView);
        initViews();
        return rootView;
    }

    @SuppressLint("CheckResult")
    private void initViews() {
        mVRLibrary = createBitmapVRLibrary();

        RxBus.getDefault()
                .toObservable(CameraStateChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onHandleCameraStateChangeEvent, new ServerErrorHandler(TAG));
    }

    private void onHandleCameraStateChangeEvent(CameraStateChangeEvent event) {
        int what = event.getWhat();
//        Logger.t(TAG).d("onHandleCameraStateChangeEvent: " + what);
        if (what == CameraStateChangeEvent.CAMERA_STATE_REC) {
            CameraWrapper cameraWrapper = event.getCamera();
            if (cameraWrapper != null) {
                int recordState = cameraWrapper.getRecordState();
                // 7 - 2 - 2- 3
                Logger.t(TAG).d("recordState: " + recordState);
                switch (recordState) {
                    case STATE_RECORD_SWITCHING:
                    case STATE_RECORD_STARTING:
                        mDisableInvert = true;
                        ivInvert.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor("#A7A7A7")));
                        break;
                    case STATE_RECORD_RECORDING:
                        mDisableInvert = false;
                        ivInvert.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor("#4A90E2")));
                        cameraWrapper.stopRecording();
                        break;
                    case STATE_RECORD_STOPPED:
                        Logger.t(TAG).i("Camera enter STATE_RECORD_STOPPED");
                        break;
                }
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mjpegAddress != null) {
            startStream(mjpegAddress);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        stopStream();
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
//                                Logger.t(TAG).d("%s", "loaded image, size:" + bitmap.getWidth() + "," + bitmap.getHeight());

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

    private Bitmap scaleImage(Bitmap bitmap) {
        return Bitmap.createBitmap(bitmap, 0, 0, 1280, 800);
    }

    private void changeVideoSize(int videoWidth, int videoHeight) {
        int divisor = getGreatestCommonDivisor(videoWidth, videoHeight);

        int tempX = videoWidth / divisor;
        int tempY = videoHeight / divisor;

//        Logger.t(TAG).d("changeVideoSize: " + divisor + " " + tempX + " " + tempY);

        if (tempX != mXRadio || tempY != mYRadio) {
            mXRadio = tempX;
            mYRadio = tempY;

            mMediaWindow.setRatio(mXRadio, mYRadio);
            mMediaWindow.post(() -> mVRLibrary.onTextureResize(videoWidth, videoHeight));
        } else {
            mVRLibrary.onTextureResize(videoWidth, videoHeight);
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
                .build((GLSurfaceView) rootView.findViewById(R.id.glView));
    }
}
