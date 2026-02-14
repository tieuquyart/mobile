package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.view.View;

import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;

import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.fragment.PreviewFragmentViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@RequiresFragmentViewModel(PreviewFragmentViewModel.ViewModel.class)
public class PreviewFragment extends BaseLazyLoadFragment<PreviewFragmentViewModel.ViewModel> {

    private final static String TAG = PreviewFragment.class.getSimpleName();

    @BindView(R.id.vp_cameras)
    ViewPager vp_cameras;

    private CameraWrapper mCamera;

    //加载不同状态fragment(2)
    private MyFragmentStatePagerAdapter mCameraAdapter;

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_preview;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        initView();
        initEvent();
    }

    private void initView() {
        mCameraAdapter = new MyFragmentStatePagerAdapter(getChildFragmentManager());
        vp_cameras.setAdapter(mCameraAdapter);
    }

    public void showCameraAt(int index) {
        vp_cameras.setCurrentItem(index, true);
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        if (Constants.isFleet()) {
            viewModel.getCurrentUser().fleetDevicesObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(arrayListOptional -> onFleetCameraList(arrayListOptional.get()), new ServerErrorHandler(TAG));
        } else {
            viewModel.getCurrentUser().devicesObservable()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(listOptional -> onCameraBeanList(listOptional.get()), new ServerErrorHandler(TAG));
        }

        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler(TAG));
    }

    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
        if (viewModel != null) {
            viewModel.refreshCamera(false);
        }
    }

    @Override
    protected void onFragmentFirstVisible() {
    }

    /**
     * handle after getCameraList
     * */
    private void onFleetCameraList(List<FleetCameraBean> camerasBeans) {
        Logger.t(TAG).d("onFleetCameraList: " + camerasBeans.size());
        ArrayList<FleetCameraBean> tempList = new ArrayList<>(camerasBeans);

        List<Fragment> fragments = new ArrayList<>();

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            Logger.t(TAG).d("currentCamera: " + mCamera.getSerialNumber());
        }

        for (CameraWrapper camera : VdtCameraManager.getManager().getConnectedCameras()) {
            fragments.add(CameraFragment.newInstance(camera.getSerialNumber(), null));
            FleetCameraBean fleetCamera = findCurrentFleetCamera(camera, tempList);
            Logger.t(TAG).d("findCurrentFleetCamera: " + (fleetCamera != null));
            if (fleetCamera != null) {
                tempList.remove(fleetCamera);
            }
        }

        for (FleetCameraBean camerasBean : tempList) {
            fragments.add(CameraFragment.newInstance(camerasBean));
        }

        if (fragments.size() == 0) {
            Logger.t(TAG).d("camera bean = null");
            fragments.add(NoCameraFragment.newInstance());
        }
        mCameraAdapter.clearFragments();
        for (int i = 0; i < fragments.size(); i++) {
            mCameraAdapter.addFragment(fragments.get(i));
        }
    }

    private void onCameraBeanList(ArrayList<CameraBean> cameraBeans) {
        Logger.t(TAG).d("onCameraBeanList: " + cameraBeans.size());
        ArrayList<CameraBean> tempList = new ArrayList<>(cameraBeans);

        List<Fragment> fragments = new ArrayList<>();

        mCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            Logger.t(TAG).d("currentCamera: " + mCamera.getSerialNumber());
        }

        for (CameraWrapper cameraWrapper : VdtCameraManager.getManager().getConnectedCameras()) {
            fragments.add(CameraFragment.newInstance(cameraWrapper.getSerialNumber(), null));
            CameraBean cameraBean = findCurrentCamera(cameraWrapper, tempList);
            Logger.t(TAG).d("findCurrentCamera: " + (cameraBean != null));
            if (cameraBean != null) {
                tempList.remove(cameraBean);
            }
        }

        for (CameraBean cameraBean : tempList) {
            fragments.add(CameraFragment.newInstance(null, cameraBean));
        }

        if (fragments.size() == 0) {
            Logger.t(TAG).d("camera bean = null");
            fragments.add(NoCameraFragment.newInstance());
        }
        mCameraAdapter.clearFragments();
        for (int i = 0; i < fragments.size(); i++) {
            mCameraAdapter.addFragment(fragments.get(i));
        }
    }

    private CameraBean findCurrentCamera(CameraWrapper cameraWrapper, List<CameraBean> cameraBeans) {
        for (CameraBean item : cameraBeans) {
            if (cameraWrapper.getSerialNumber().equals(item.sn)) {
                return item;
            }
        }
        return null;
    }

    private FleetCameraBean findCurrentFleetCamera(CameraWrapper cameraWrapper, List<FleetCameraBean> camerasBeans) {
        for (FleetCameraBean item : camerasBeans) {
            if (cameraWrapper.getSerialNumber().equals(item.getSn())) {
                return item;
            }
        }
        return null;
    }

    private void onCurrentCamera(Optional<CameraWrapper> cameraOptional) {
        CameraWrapper includeNull = cameraOptional.getIncludeNull();
        if (includeNull != null) {
            Logger.t(TAG).e("includeNull: " + includeNull.getSerialNumber());
        }
        if (mCamera != null) {
            Logger.t(TAG).e("mCamera: " + mCamera.getSerialNumber());
        }
        if (includeNull != mCamera) {
            new Handler().postDelayed(() -> {
                boolean isRrefesh1 = false, isRrefesh2 = false;
                if (includeNull != null) {
                    isRrefesh1 = includeNull.mIsShowCamera;
                    Logger.t(TAG).e("includeNull isRrefesh1: " + isRrefesh1);
                }
                if (mCamera != null) {
                    isRrefesh2 = mCamera.mIsShowCamera;
                    Logger.t(TAG).e("mCamera isRrefesh2: " + isRrefesh2);
                }
                if ((isRrefesh1 || isRrefesh2) && viewModel != null) {
                    //相机断连或切换时强制刷新首页
                    viewModel.refreshCamera(true);
                }
            }, 3000);
        }
    }

}
