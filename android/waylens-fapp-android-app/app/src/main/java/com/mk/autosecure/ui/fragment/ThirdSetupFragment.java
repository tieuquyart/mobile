package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Outline;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.widget.AppCompatSpinner;

import com.mk.autosecure.ui.activity.CustomProjectionFactory;
import com.mk.autosecure.ui.activity.SpinnerHelper;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.LensChangeEvent;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.account.CameraSubscriber;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.SubscribeResponse;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;
import com.mk.autosecure.viewmodels.fragment.ThirdSetupViewModel;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

import static com.mk.autosecure.ui.fragment.ThirdSetupFragment.STATE.STATE_CONNECTED;
import static com.mk.autosecure.ui.fragment.ThirdSetupFragment.STATE.STATE_INITIAL;

/**
 * Created by DoanVT on 2017/8/25.
 * Email: doanvt-hn@mk.com.vn
 */

@RequiresFragmentViewModel(ThirdSetupViewModel.ViewModel.class)
public class ThirdSetupFragment extends BaseFragment<ThirdSetupViewModel.ViewModel> {

    public static final String TAG = ThirdSetupFragment.class.getSimpleName();

    public enum STATE {
        STATE_INITIAL,
        STATE_CONNECTED,
        //        STATE_NAMING,
        STATE_BIND
    }

    private MjpegStream mMjpegStream;

    private Bitmap mCurrentBitmap = null;

    private InetSocketAddress mjpegAddress = null;

    MD360BitmapTexture.Callback mCallback = null;

    private static final SparseArray<String> sProjectionMode = new SparseArray<>();

    static {
        sProjectionMode.put(MDVRLibrary.PROJECTION_MODE_DOME220_UPPER, "DOME 220 UPPER");
        sProjectionMode.put(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS, "CUSTOM DOUBLE DIRECTIONS");
    }

    private MDVRLibrary mVRLibrary;

    private CameraWrapper mCamera;

    private STATE state;

    private SetupActivityViewModel.ViewModel parentViewModel;

    @BindView(R.id.gl_view)
    GLSurfaceView mGlView;

    @BindView(R.id.et_camera_name)
    EditText et_cameraName;

    @BindView(R.id.progress)
    ProgressBar progressBar;

    @BindView(R.id.image_view)
    ImageView ivConnecting;

    @BindView(R.id.spinner_projection)
    AppCompatSpinner spinner;

    @BindView(R.id.btn_bind)
    Button btnBind;

    @BindView(R.id.tv_lens_tips)
    TextView tvLensTips;

    @OnClick(R.id.btn_bind)
    public void onBindCamera() {
        Logger.t(TAG).d("state = " + state);
        if (state == STATE_CONNECTED) {
//            transView(btnBind, 1, 0);
//            state = STATE_NAMING;
//            et_cameraName.setEnabled(true);

            btnBind.setEnabled(false);
            User user = viewModel.component.currentUser().getUser();
            if ((user == null || !user.verified())) {
                getActivity().setResult(Activity.RESULT_OK);
                getActivity().finish();
            } else {
                bindDevice(et_cameraName.getText().toString());
            }
            String name = et_cameraName.getText().toString();
            if (mCamera != null && !TextUtils.isEmpty(name)) {
                mCamera.setName(name);
            }
        }
//        else if (state == STATE_NAMING) {
//            btnBind.setEnabled(false);
//            User user = viewModel.component.currentUser().getUser();
//            if (user == null || !user.verified()) {
//                getActivity().finish();
//            } else {
//                bindDevice(et_cameraName.getText().toString());
//            }
//            String name = et_cameraName.getText().toString();
//            if (mCamera != null && !TextUtils.isEmpty(name)) {
//                mCamera.setName(name);
//            }
//        }
    }

    public static ThirdSetupFragment newInstance(SetupActivityViewModel.ViewModel viewModel) {
        ThirdSetupFragment fragment = new ThirdSetupFragment();
        fragment.parentViewModel = viewModel;
        Bundle bundle = new Bundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @SuppressLint("CheckResult")
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View v = inflater.inflate(R.layout.fragment_setup_three, container, false);
        ButterKnife.bind(this, v);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            Logger.t(TAG).d("set outline");
            mGlView.setClipToOutline(true);
            mGlView.setOutlineProvider(new ViewOutlineProvider() {
                @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
                @Override
                public void getOutline(View view, Outline outline) {
                    outline.setOval(0, 0, view.getHeight(), view.getHeight());

                }
            });
        }
        // init VR Library
        mVRLibrary = createVRLibrary();

        SpinnerHelper.with(getActivity())
                .setData(sProjectionMode)
                .setDefault(mVRLibrary.getProjectionMode())
                .setClickHandler((index, key, value) -> {
                    if (mVRLibrary != null) {
                        mVRLibrary.switchProjectionMode(getActivity(), key);
                    }
                })
                .init(spinner);

        et_cameraName.setFilters(StringUtils.DisableSpecialCharacters(StringUtils.CAMERA_NAME_MAX_LENGTH));

        initEvent();

        return v;
    }

    private void initEvent() {
        viewModel.errors.bindError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onBindCameraError, new ServerErrorHandler(TAG));

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLowLevelError, new ServerErrorHandler(TAG));

        viewModel.outputs.bindSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onBindCameraSuccess, new ServerErrorHandler(TAG));

        viewModel.outputs.reportSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onReportIccid, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(LensChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLensChangeEvent, new ServerErrorHandler(TAG));
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

    private void onBindCameraError(ErrorEnvelope error) {
        Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();

        new Handler(Looper.getMainLooper()).
                postDelayed(() -> {
                    try {
                        getActivity().finish();
                    } catch (Exception e) {
                        e.printStackTrace();
                        Logger.t(TAG).d("onBindCameraError: " + error.getErrorMessage());
                    }
                }, 2 * 1000);
    }

    private void onLowLevelError(Throwable e) {
        NetworkErrorHelper.handleCommonError(getActivity(), e);
        btnBind.setEnabled(true);
    }

    private void onBindCameraSuccess(int flag) {
        parentViewModel.inputs.bindSuccess();

        if (Constants.isFleet()) {
//            if (Constants.isDriver()) {
//                CurrentUser currentUser = viewModel.component.currentUser();
//                currentUser.refreshFleetDevices(SortUtil.sortFleet(currentUser.getFleetDevices()), false);
//            } else {
                getCameras();
//            }
        } else {
            ApiService.createApiService().getCameras()
                    .compose(Transformers.switchSchedulers())
                    .subscribe(new CameraSubscriber());
        }

        Toast.makeText(getActivity(), R.string.bind_camera_successfully, Toast.LENGTH_SHORT).show();

        reportID(mCamera);

        new Handler(Looper.getMainLooper()).
                postDelayed(() -> {
                    try {
                        //当正常绑定成功时，进入新手引导流程
                        if (flag == 0) {
                            //这里进入要进行全部流程
                            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, true);
                            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_DIRECT, true);
                            LocalLiveActivity.launchForGuide(getActivity());
                        }
                        getActivity().finish();
                    } catch (Exception e) {
                        Logger.t(TAG).d("error");
                    }
                }, 2 * 1000);
    }

    private List<FleetCameraBean> fleetCameraBeanList = new ArrayList<>();

    @SuppressLint("CheckResult")
    private void getCameras() {
        fleetCameraBeanList.clear();

//        ApiClient.createApiService().getCameras()
//                .compose(Transformers.switchSchedulers())
//                .subscribe(response -> {
//                    List<FleetCameraBean> cameras = response.getData();
//                    fleetCameraBeanList.addAll(cameras);
//
//                    HornApplication.getComponent().currentUser()
//                            .refreshFleetDevices(SortUtil.sortFleet(fleetCameraBeanList), false);
//                });
    }

    private void onReportIccid(SubscribeResponse response) {
        String status = response.getStatus();
        Logger.t(TAG).d("onReportIccid: " + status);

//        if (!"in_service".equals(status)) {
//            WebPlanActivity.launch(getActivity(), mCamera.getSerialNumber());
//        }
    }

    private void reportID(CameraWrapper mCamera) {
        if (!mCamera.getMountVersion().support_4g) {
            Logger.t(TAG).d("reportID: not support 4g");
        } else if (TextUtils.isEmpty(mCamera.getIccid())) {
            Logger.t(TAG).d("reportID: iccid is null");
//            Toast.makeText(getActivity(), "Please alert SIM Card!", Toast.LENGTH_LONG).show();
        } else {
            viewModel.inputs.reportIccid(mCamera.getSerialNumber(), mCamera.getIccid());
        }
    }

    public void refreshPipeline(CameraWrapper cameraWrapper) {
        mjpegAddress = new InetSocketAddress(cameraWrapper.getAddress(), 8081);
        loadMJPEG();
    }


    synchronized private void loadMJPEG() {
        try {
            if (mjpegAddress != null && mMjpegStream == null) {
                Logger.t(TAG).d("start stream:");
                startStream(mjpegAddress);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    protected MDVRLibrary createVRLibrary() {
        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        int projectionMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
        if (mCamera != null) {
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
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asBitmap(callback -> {
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

    public void startStream(final InetSocketAddress serverAddr) {
        mMjpegStream = new MjpegStream() {
            @Override
            protected void onBitmapReadyAsync(MjpegDecoder decoder, MjpegStream stream) {
                BitmapBuffer bb = stream.getOutputBitmapBuffer(decoder);
                if (bb != null) {
                    mCurrentBitmap = bb.getBitmap();
                    //Logger.d(TAG, "loaded image, size:" + mCurrentBitmap.getWidth() + "," + mCurrentBitmap.getHeight());
                    new Handler(Looper.getMainLooper()).post(() -> {
                        getVRLibrary().onTextureResize(mCurrentBitmap.getWidth(), mCurrentBitmap.getHeight());
                        // texture
                        if (mCallback != null) {
                            mCallback.texture(mCurrentBitmap);
                        }
                        cancelBusy();
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
        if (mMjpegStream != null) {
            mMjpegStream.stop();
            mMjpegStream = null;
        }
    }

    @SuppressLint("CheckResult")
    public void onSelected() {
        Logger.t(TAG).d("onSelected");
        busy();
//        btnBind.setText(R.string.setup_third_input_name);
//        if (Constants.isFleet() && !Constants.isDriver()) {
//            btnBind.setText(R.string.forget_password_next);
//        } else {
            btnBind.setText(R.string.setup_third_done);
//        }
        btnBind.setVisibility(View.INVISIBLE);
        et_cameraName.clearComposingText();
        et_cameraName.setEnabled(false);
        mCamera = null;
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNewCamera, new ServerErrorHandler());
        mVRLibrary.onResume(getActivity());
    }

    @SuppressLint("CheckResult")
    @Override
    public void onResume() {
        super.onResume();
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onNewCamera, new ServerErrorHandler());
        mVRLibrary.onResume(getActivity());
    }

    @Override
    public void onPause() {
        super.onPause();
        stopStream();
        mVRLibrary.onPause(getActivity());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopStream();
        if (mVRLibrary != null) {
            mVRLibrary.onDestroy();
        }
    }

    private void onNewCamera(Optional<CameraWrapper> cameraOptional) {
        CameraWrapper wrapper = cameraOptional.getIncludeNull();
        Logger.t(TAG).e("got one camera = %s", wrapper);
        if (wrapper != null) {
            mCamera = wrapper;
            Logger.t(TAG).d("on resume: " + wrapper.getAddress());
            wrapper.getPassword();
            refreshPipeline(wrapper);
            btnBind.setEnabled(true);
            btnBind.setVisibility(View.VISIBLE);
            changeView(btnBind, 0, 1);
            state = STATE_CONNECTED;
            String name = wrapper.getName();
            et_cameraName.setText(StringUtils.isEmail(name) ? getResources().getString(R.string.setup_default_name) : name);
            et_cameraName.setSelection(et_cameraName.getText().length());
            Logger.t(TAG).d("onNewCamera state = " + state);
        } else {
            mCamera = null;
            busy();
            btnBind.setEnabled(false);
            btnBind.setVisibility(View.INVISIBLE);
            state = STATE_INITIAL;
        }

        if (mCamera != null) {
            boolean needDewarp = mCamera.getNeedDewarp();
            if (needDewarp) {
                boolean supportUpsidedown = mCamera.getSupportUpsidedown();
                Logger.t(TAG).d("supportUpsidedown: " + supportUpsidedown);
                if (supportUpsidedown && Constants.isManager()) {
                    tvLensTips.setVisibility(View.VISIBLE);
                } else {
                    tvLensTips.setVisibility(View.INVISIBLE);
                }
            } else {
                tvLensTips.setVisibility(View.INVISIBLE);
            }
        }
    }

    public void cancelBusy() {
        progressBar.setVisibility(View.GONE);
        ivConnecting.setVisibility(View.INVISIBLE);

    }

    public void busy() {
        progressBar.setVisibility(View.VISIBLE);
        ivConnecting.setVisibility(View.VISIBLE);
    }

    private void bindDevice(String nickname) {
        String sn = "";
        String password = "";
        if (mCamera != null) {
            sn = mCamera.getSerialNumber();
            password = mCamera.getPassword();
        }
        if (!TextUtils.isEmpty(sn) && !TextUtils.isEmpty(password)) {
            viewModel.inputs.bindCamera(sn, nickname, password);
        } else {
            Toast.makeText(getActivity(), R.string.not_connect_camera, Toast.LENGTH_SHORT).show();
        }
    }

    public void changeView(View v, float fromAlpha, int toAlpha) {
//        Logger.t(TAG).d("alphaView targetAlpha = " + toAlpha);
        AlphaAnimation anim = new AlphaAnimation(fromAlpha, toAlpha);
        anim.setDuration(500);
        anim.setFillAfter(true);
        v.startAnimation(anim);
    }

    public void transView(View v, float fromAlpha, int toAlpha) {
        Logger.t(TAG).d("alphaView targetAlpha = " + toAlpha);
        AlphaAnimation anim = new AlphaAnimation(fromAlpha, toAlpha);
        anim.setDuration(500);
        anim.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                ((Button) v).setText(R.string.setup_third_done);
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
        anim.setRepeatMode(Animation.REVERSE);
        v.startAnimation(anim);
    }
}
