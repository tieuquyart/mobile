package com.mk.autosecure.ui.activity.settings;

import static com.mk.autosecure.ui.activity.settings.SetupFleetActivity.REQUEST_CALIB_CAMERA;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.media.SoundPool;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.data.DmsClient;
import com.mkgroup.camera.data.dms.BasicSocket;
import com.mkgroup.camera.data.dms.DataApi;
import com.mkgroup.camera.data.dms.DmsRequestQueue;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.fragment.DoCalibFragment;
import com.mk.autosecure.ui.fragment.FirstCalibFragment;
import com.mk.autosecure.ui.fragment.SecondCalibFragment;
import com.mk.autosecure.ui.fragment.ThirdCalibFragment;
import com.mk.autosecure.viewmodels.setting.CalibActivityViewModel;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

@RequiresActivityViewModel(CalibActivityViewModel.ViewModel.class)
public class CalibActivity extends BaseActivity<CalibActivityViewModel.ViewModel> {

    private final static String TAG = CalibActivity.class.getSimpleName();

    private final static int WIFI_SETTING = 1001;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.va_calib)
    ViewAnimator vaCalib;

    @BindView(R.id.vp_calib)
    CustomViewPager vpCalib;

    @BindView(R.id.rl_loading)
    RelativeLayout rlLoading;

    @OnClick(R.id.btn_connect)
    public void connect() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

    private MyFragmentStatePagerAdapter mCalibAdapter;

    private DmsRequestQueue mDmsRequestQueue;

    private CameraWrapper mCamera;

    private DoCalibFragment mDoCalibFragment;

    public static void launch(Activity activity, boolean guide) {
        Intent intent = new Intent(activity, CalibActivity.class);
        if (guide) {
            activity.startActivityForResult(intent, REQUEST_CALIB_CAMERA);
        } else {
            activity.startActivity(intent);
        }
    }

    @SuppressLint("CheckResult")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_calib);
        ButterKnife.bind(this);
        setToolbar();
        initViews();

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent);
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                CameraWrapper eventCamera = event.getVdtCamera();
                if (mCamera != null && eventCamera != null && mCamera.getPort() == eventCamera.getPort()) {
                    initViews();
                }
                break;
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_CONNECTED");
                initViews();
                break;
            default:
                break;
        }
    }

    @SuppressLint("CheckResult")
    @Override
    protected void onResume() {
        super.onResume();

        viewModel.outputs
                .nextStep()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> {
                    Logger.t(TAG).i("nextStep: " + integer);
                    if (integer < mCalibAdapter.getCount()) {
                        vpCalib.setCurrentItem(integer);
                    } else {
                        finish();
                    }
                }, new ServerErrorHandler());

        viewModel.outputs
                .showLoading()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> rlLoading.setVisibility(integer), new ServerErrorHandler());
    }

    private void setToolbar() {
        toolbar.setNavigationOnClickListener(v -> goBack());
    }

    private void initViews() {
        mCamera = VdtCameraManager.getManager().getCurrentCamera();

        if (mCamera != null) {
            initCalibFragments();
        } else {
            vaCalib.setDisplayedChild(0);
        }
    }

    private List<Fragment> getPagerFragments() {
        List<Fragment> fragments = new ArrayList<>();
        fragments.add(FirstCalibFragment.newInstance(viewModel, "", ""));
        fragments.add(SecondCalibFragment.newInstance(viewModel, "", ""));
        fragments.add(ThirdCalibFragment.newInstance(viewModel, "", ""));
        mDoCalibFragment = DoCalibFragment.newInstance(viewModel, "", "");
        fragments.add(mDoCalibFragment);
        return fragments;
    }

    public void setCalibParams(int x, int y, int z) {
        if (mDoCalibFragment != null) {
            mDoCalibFragment.setCalibParams(x, y, z);
        }
    }

    @Override
    protected void goBack() {
        if (vaCalib.getDisplayedChild() == 0) {
            super.goBack();
            return;
        }

        int currentItem = vpCalib.getCurrentItem();
        if (currentItem == 3 && mDoCalibFragment != null && mDoCalibFragment.isBackToAdjust()) {
            mDoCalibFragment.backToAdjust();
            return;
        }

        if (currentItem > 0) {
            vpCalib.setCurrentItem(--currentItem);
        } else {
            if (mCamera != null && mCamera.getRecordState() != VdtCamera.STATE_RECORD_RECORDING) {
                mCamera.startRecording();
            }

            super.goBack();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == WIFI_SETTING) {
            initViews();
        }
    }

    private void initCalibFragments() {
        mCalibAdapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());

        List<Fragment> fragments = getPagerFragments();
        for (Fragment fragment : fragments) {
            mCalibAdapter.addFragment(fragment);
        }

        vpCalib.setAdapter(mCalibAdapter);

        vaCalib.setDisplayedChild(1);
    }

    public void init(View view) {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);
        if (currentCamera != null) {
            HandlerThread handlerThread = new HandlerThread("DMS");
            handlerThread.start();
            Handler handler = new Handler(handlerThread.getLooper());
            handler.post(() -> {
                DmsClient client = new DmsClient(currentCamera.getHostString());
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
    }

    public void getVersion(View view) {
        if (mDmsRequestQueue == null) {
            return;
        }

        DataApi.getVersionInfoRx(mDmsRequestQueue)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe();
    }

    public void getAllFaces(View view) {
//        FaceList faceList = null;
//        try {
//            faceList = DataApi.getFaceList(mDmsRequestQueue);
//            Logger.t(TAG).d("faceList: " + faceList);
//        } catch (ExecutionException | InterruptedException e) {
//            e.printStackTrace();
//        }
    }

    public void addFaceWithID(View view) {
    }

    public void removeFaceWithID(View view) {
    }

    public void removeAllFaces(View view) {
    }

    public void doCalibWithX(View view) {
        if (mDmsRequestQueue == null) {
            return;
        }

        DataApi.doCalibrationRx(mDmsRequestQueue, 115, 45, 130)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe();
    }

    public void playAudio(View view) {
        SoundPool soundPool = new SoundPool.Builder().build();
        int soundID = soundPool.load(this, R.raw.countdown, 1);
        Logger.t(TAG).d("soundID: " + soundID);
        soundPool.setOnLoadCompleteListener((soundPool1, sampleId, status) -> {
            Logger.t(TAG).d("onLoadComplete: " + sampleId + " " + status);
            soundPool1.play(soundID, 1.0f, 1.0f, 1, 0, 1.0f);
        });
    }
}
