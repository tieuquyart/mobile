package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.R;

import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/10/16.
 * Email: doanvt-hn@mk.com.vn
 */

public class NoConnectFragment extends Fragment {

    private static final String TAG = NoConnectFragment.class.getSimpleName();

    public static NoConnectFragment newInstance() {
        return new NoConnectFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_no_connect, container, false);
        ButterKnife.bind(this, view);
        return view;
    }
}
