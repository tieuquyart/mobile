package com.mk.autosecure.ui.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.settings.TrigVehicleActivity;
import com.mk.autosecure.R;


/**
 * A simple {@link Fragment} subclass.
 */
public class NoVehicleFragment extends Fragment {

    public NoVehicleFragment() {
        // Required empty public constructor
    }

    private Activity mActivity;

    @Override
    public void onAttach(@NonNull Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_no_vehicle, container, false);
        view.findViewById(R.id.btn_add_vehicle).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mActivity != null && mActivity instanceof TrigVehicleActivity) {
                    ((TrigVehicleActivity) mActivity).proceed(1);
                }
            }
        });
        return view;
    }
}
