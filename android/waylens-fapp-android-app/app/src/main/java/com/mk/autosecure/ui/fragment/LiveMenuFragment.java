package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.DevicesActivity;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.mk.autosecure.ui.activity.settings.CheckSimDataActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.viewmodels.LiveMenuFragmentViewModel;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.TCVNEvent;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.orhanobut.logger.Logger;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Create by doanvt - 23-12-2022
 * */

@SuppressLint("CheckResult")
@RequiresFragmentViewModel(LiveMenuFragmentViewModel.ViewModel.class)
public class LiveMenuFragment extends BaseFragment<LiveMenuFragmentViewModel.ViewModel> {
    private static final String TAG = LiveMenuFragment.class.getSimpleName();
    private Context context;
    private String serialNumber;
    public CameraWrapper mCamera;
    EvCamera evCamera;

    private LiveMenuFragmentInterface faceInterface;

    @BindView(R.id.ll_login_face)
    LinearLayout llLoginFace;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        this.context = context;
    }

    @OnClick(R.id.rl_setting)
    public void settingOnClick(){
        if (mCamera != null) {
            DevicesActivity.launch(getActivity(), mCamera.getSerialNumber());
        }
    }

    @SuppressLint("NewApi")
    @OnClick(R.id.ll_login_face)
    public void btnScreenShot() {
        if (faceInterface != null){
            faceInterface.onLoginFaceCallback(R.id.ll_login_face);
        }
    }

    @OnClick(R.id.rl_check_sim_card)
    public void checkSimCard(){
        if (faceInterface != null) faceInterface.onLoginFaceCallback(R.id.rl_check_sim_card);
    }

    @OnClick(R.id.rl_data_sdcard)
    public void onDataSdCard(){
        if (faceInterface != null) faceInterface.onLoginFaceCallback(R.id.rl_data_sdcard);
    }

    @OnClick(R.id.rl_base_info)
    public void onBaseInfo(){
        if (faceInterface != null) faceInterface.onLoginFaceCallback(R.id.rl_base_info);
    }

    @OnClick({R.id.rl_get_log})
    public void getLogs(){
        if(faceInterface != null) faceInterface.onLoginFaceCallback(R.id.rl_get_log);
    }

    @BindView(R.id.rl_config_login_face)
    RelativeLayout rlCfgLoginFace;

    @OnClick({R.id.rl_config_login_face})
    public void loginFaceCfg(){
        if(faceInterface != null) faceInterface.onLoginFaceCallback(R.id.rl_config_login_face);
//        Observable
//                .create((ObservableOnSubscribe<Optional<PopupWindow>>) emitter -> {
//                    View view = LayoutInflater.from(getActivity()).inflate(R.layout.popup_cfg_login_face, null);
//                    PopupWindow popupWindow = new PopupWindow(view,
//                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
//                            CoordinatorLayout.LayoutParams.MATCH_PARENT,
//                            false);
//                    popupWindow.setOutsideTouchable(true);
//
//                    view.findViewById(R.id.cl_outside).setOnClickListener(v -> popupWindow.dismiss());
//
//                    view.findViewById(R.id.btn_cfg_mobile).setOnClickListener(v -> {
//                        popupWindow.dismiss();
//                        evCamera.configMOC(true);
//
//                    });
//
//                    view.findViewById(R.id.btn_cfg_auto).setOnClickListener(v -> {
//                        popupWindow.dismiss();
//                        evCamera.configMOC(false);
//                    });
//
//                    emitter.onNext(Optional.ofNullable(popupWindow));
//                })
//                .filter(popupWindowOptional -> popupWindowOptional.getIncludeNull() != null)
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(windowOptional -> windowOptional.get().showAsDropDown(rlCfgLoginFace));
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.live_menu_fragment, container, false);
        ButterKnife.bind(this, view);

        serialNumber = getArguments() != null ? getArguments().getString(IntentKey.SERIAL_NUMBER) : "";

        if (TextUtils.isEmpty(serialNumber)) {
            mCamera = VdtCameraManager.getManager().getCurrentCamera();
        } else {
            mCamera = VdtCameraManager.getManager().getCamera(serialNumber);
        }

//        evCamera = (EvCamera) mCamera;

        return view;
    }

    public static LiveMenuFragment newInstance(String sn, LiveMenuFragmentInterface loginFaceInterface) {
        Bundle args = new Bundle();
        LiveMenuFragment fragment = new LiveMenuFragment();
        args.putString(IntentKey.SERIAL_NUMBER, sn);
        fragment.setArguments(args);
        fragment.faceInterface = loginFaceInterface;
        return fragment;
    }

    @SuppressLint("CheckResult")
    @Override
    public void onResume() {
        super.onResume();
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler());

        RxBus.getDefault().toObservable(TCVNEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(event -> {
                    Logger.t(TAG).d(event.getMOC());
                    if (event.getMOC().equals("mobile")){
                        llLoginFace.setVisibility(View.VISIBLE);
                    }else{
                        llLoginFace.setVisibility(View.GONE);
                    }
                }, throwable -> {
//                    Toast.makeText(getActivity(),throwable.getMessage(),Toast.LENGTH_SHORT).show();
                    new ServerErrorHandler(TAG);
                });
    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper cameraWrapper = camera.getIncludeNull();
        if (cameraWrapper != null) {
            onNewCamera(cameraWrapper);
            cameraWrapper.queryStorageState();
        } else {
            onDisconnectCamera();
        }
    }

    private void onNewCamera(CameraWrapper camera) {
        Logger.t(TAG).d("got one camera: " + camera.getSerialNumber());
        if (!TextUtils.isEmpty(serialNumber) && serialNumber.equals(camera.getSerialNumber())) {
            viewModel.currentCamera(camera);
        } else {
            onDisconnectCamera();
        }
    }

    private void onDisconnectCamera() {
    }

    public interface LiveMenuFragmentInterface{
        void onLoginFaceCallback(int id);
    }
}
