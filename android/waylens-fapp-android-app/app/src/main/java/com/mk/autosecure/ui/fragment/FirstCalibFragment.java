package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.fragment.app.Fragment;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;
import com.mk.autosecure.viewmodels.setting.CalibActivityViewModel;

import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FirstCalibFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FirstCalibFragment extends Fragment {
    private final static String TAG = FirstCalibFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private CalibActivityViewModel.ViewModel parentViewModel;
    private CameraWrapper mCamera;

    @OnClick(R.id.tv_installation_guide)
    public void guide() {
        // TODO: 2020/8/19 add installation guide
        Logger.t(TAG).d("installation guide");
    }

    @OnClick(R.id.btn_install_next)
    public void next() {
        if (parentViewModel != null && parentViewModel.inputs != null) {
            parentViewModel.inputs.proceed(1);
        }
    }

    public FirstCalibFragment() {
        // Required empty public constructor
        mCamera = VdtCameraManager.getManager().getCurrentCamera();

//        if (mCamera != null && mCamera instanceof EvCamera) {
//
//            String curRecordConfig = ((EvCamera) mCamera).getCurRecordConfig();
//            Logger.t(TAG).d("curRecordConfig: " + curRecordConfig);
//
//            List<RecordConfigListBean.ConfigListBean> recordConfigList = ((EvCamera) mCamera).getRecordConfigList();
//            Logger.t(TAG).d("recordConfigList: " + recordConfigList);
//
//            int index = -1;
//            for (int i = 0; i < recordConfigList.size(); i++) {
//                RecordConfigListBean.ConfigListBean listBean = recordConfigList.get(i);
//                if (curRecordConfig.equals(listBean.getName())) {
//                    index = i;
//                    break;
//                }
//            }
//            if (index != -1) {
//                ((EvCamera) mCamera).setHistoryRecordConfig(index);
//                ((EvCamera) mCamera).setCurRecordConfig(recordConfigList.size() - 1);
//            }
//        }

        if (mCamera != null && mCamera.getRecordState() != VdtCamera.STATE_RECORD_STOPPED) {
            mCamera.stopRecording();
        }
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment FirstCalibFragment.
     */
    public static FirstCalibFragment newInstance(CalibActivityViewModel.ViewModel parentViewModel, String param1, String param2) {
        FirstCalibFragment fragment = new FirstCalibFragment();
        fragment.parentViewModel = parentViewModel;
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
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
        View view = inflater.inflate(R.layout.fragment_first_calib, container, false);
        ButterKnife.bind(this, view);
        return view;
    }
}
