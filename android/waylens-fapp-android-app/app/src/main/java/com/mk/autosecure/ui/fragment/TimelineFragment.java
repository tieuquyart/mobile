package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.view.View;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.FragmentEvent;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.event.PreviewChangeEvent;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.fragment.TimelineFragmentViewModel;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.android.schedulers.AndroidSchedulers;

@SuppressLint("CheckResult")
@RequiresFragmentViewModel(TimelineFragmentViewModel.ViewModel.class)
public class TimelineFragment extends BaseLazyLoadFragment<TimelineFragmentViewModel.ViewModel> {

    private final static String TAG = TimelineFragment.class.getSimpleName();

    private CameraViewFragment mCameraFragment;

    private CloudViewFragment mCloudFragment;

    private CameraWrapper mCamera;

    @Override
    protected void onFragmentPause() {

    }
    @Override
    protected void onFragmentResume() {
        VdtCameraManager.getManager().currentCamera()
                .compose(bindUntilEvent(FragmentEvent.PAUSE))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));

        viewModel.getCurrentUser().devicesObservable()
                .compose(bindUntilEvent(FragmentEvent.PAUSE))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentDevice, new ServerErrorHandler(TAG));

        RxBus.getDefault().toObservable(PreviewChangeEvent.class)
                .compose(bindUntilEvent(FragmentEvent.PAUSE))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onPreviewChange, new ServerErrorHandler(TAG));
    }

    @Override
    protected void onFragmentFirstVisible() {

    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_timeline;
    }

    @Override
    protected void initView(View rootView) {
        clearChildFragment();
    }

    private void clearChildFragment() {
        mCameraFragment = null;
        mCloudFragment = null;

        List<Fragment> fragmentList = getChildFragmentManager().getFragments();
        //解决了fragment杀死重建时子fragment没有移除的问题
        if (fragmentList.size() != 0) {
            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            for (Fragment fragment : fragmentList) {
                transaction.remove(fragment);
            }
            //
            try {
                transaction.commitNow();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        }
    }

    private void onPreviewChange(PreviewChangeEvent changeEvent) {
//        Logger.t(TAG).d("onPreviewChange: " + changeEvent.getVdtCamera());
        CameraWrapper cameraWrapper = changeEvent.getCamera();
        if (cameraWrapper != null) {
            showCameraView(cameraWrapper);
        }

        CameraBean cameraBean = changeEvent.getCameraBean();
        if (cameraBean != null) {
            showCloudView(cameraBean);
        }

        FleetCameraBean fleetCameraBean = changeEvent.getFleetCameraBean();
        if (fleetCameraBean != null) {
            clearChildFragment();

            mCloudFragment = CloudViewFragment.newInstance(fleetCameraBean);
            FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
            //
            try {
                transaction.replace(R.id.frameLayout, mCloudFragment, CloudViewFragment.TAG).commitNow();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        }
    }

    private void onCurrentDevice(Optional<ArrayList<CameraBean>> optional) {
//        Logger.t(TAG).d("onCurrentDevice: " + mCamera);
        if (mCamera != null) {
            Logger.t(TAG).e("current connect camera");
            return;
        }
        //当前未连接相机
        ArrayList<CameraBean> cameraBeans = optional.getIncludeNull();
        Logger.t(TAG).e("cameraBeans: " + cameraBeans);
        if (cameraBeans == null || cameraBeans.size() == 0) {
            //当用户还未添加任何相机
            Fragment fragment;
            if (Constants.isFleet() && (Constants.isLogin() /*|| Constants.isDriver()*/)) {
                fragment = new NoConnectFragment();
            } else {
                fragment = new NoCameraFragment();
            }
            //
            try {
                getChildFragmentManager().beginTransaction().replace(R.id.frameLayout, fragment).commitNow();
            } catch (Exception ex) {
                Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
            }
        } else {
            CameraBean cameraBean = cameraBeans.get(0);
            if (cameraBean != null) {
                showCloudView(cameraBean);
            }
        }
    }

    private void onCurrentCamera(Optional<CameraWrapper> cameraOptional) {
        CameraWrapper camera = cameraOptional.getIncludeNull();
        Logger.t(TAG).e("onCurrentShowCamera mCamera: " + mCamera + " camera: " + camera);
        if (mCamera != camera) {
            mCamera = camera;
//            Logger.t(TAG).d("onCurrentCamera: " + mCamera);
            if (camera != null) {
                showCameraView(camera);
            }
        }
    }

    private void showCameraView(CameraWrapper cameraWrapper) {
        if (cameraWrapper != null) {
            Logger.t(TAG).e("showCameraView: " + cameraWrapper.getSerialNumber());
        }

        clearChildFragment();

        //当前已连接相机
        String serialNumber = cameraWrapper.getSerialNumber();
        mCameraFragment = CameraViewFragment.newInstance(serialNumber);
        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
        //
        try {
            transaction.replace(R.id.frameLayout, mCameraFragment, CameraViewFragment.TAG).commitNow();
        } catch (Exception ex) {
            Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
        }
    }

    public void showGuideCamera(CameraWrapper camera) {
        clearChildFragment();

        //当前已连接相机
        String serialNumber = camera.getSerialNumber();
        mCameraFragment = CameraViewFragment.newInstance(serialNumber, true);
        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
        //
        try {
            transaction.replace(R.id.frameLayout, mCameraFragment, CameraViewFragment.TAG).commitNow();
        } catch (Exception ex) {
            Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
        }
    }

    private void showCloudView(CameraBean cameraBean) {
        if (cameraBean != null) {
            Logger.t(TAG).e("showCloudView: " + cameraBean.sn);
        }

        clearChildFragment();

        mCloudFragment = CloudViewFragment.newInstance(cameraBean);
        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
        //
        try {
            transaction.replace(R.id.frameLayout, mCloudFragment, CloudViewFragment.TAG).commitNow();
        } catch (Exception ex) {
            Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
        }
    }
}
