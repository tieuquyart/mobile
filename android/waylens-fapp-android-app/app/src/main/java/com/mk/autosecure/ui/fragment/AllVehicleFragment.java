package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.fragment.app.Fragment;

import com.mk.autosecure.R;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link AllVehicleFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class AllVehicleFragment extends Fragment {
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    public AllVehicleFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment AllVehicleFragment.
     */
    public static AllVehicleFragment newInstance(TrigVehicleActivityViewModel.ViewModel viewModel) {
        AllVehicleFragment fragment = new AllVehicleFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    private TrigVehicleActivityViewModel.ViewModel parentViewModel;

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
        return inflater.inflate(R.layout.fragment_all_vehicle, container, false);
    }
}
