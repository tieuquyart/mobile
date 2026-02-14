package com.mk.autosecure.ui.fragment;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.mk.autosecure.ui.activity.SetupActivity;
import com.mk.autosecure.R;

import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * Created by DoanVT on 2017/10/16.
 * Email: doanvt-hn@mk.com.vn
 */

public class NoCameraFragment extends Fragment {
//    private static final String TAG = NoCameraFragment.class.getSimpleName();

//    @BindView(R.id.media_window)
//    PercentRelativeLayout mMediaWindow;

    @OnClick(R.id.iv_add_camera)
    public void onAddCamera() {
        SetupActivity.launch(getActivity(), false);
    }

    public static NoCameraFragment newInstance() {
        return new NoCameraFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_no_camera, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

}
