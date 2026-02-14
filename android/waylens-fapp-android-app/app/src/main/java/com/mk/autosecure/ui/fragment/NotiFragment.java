package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.R;

public class NotiFragment extends Fragment {
    public static NotiFragment newInstance() {
        
        Bundle args = new Bundle();
        
        NotiFragment fragment = new NotiFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.notifragment_layout, container, false);
        return view;
    }
}
