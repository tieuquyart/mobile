package com.mk.autosecure.ui.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import com.mk.autosecure.ui.activity.settings.TrigVehicleActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FenceAddedFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FenceAddedFragment extends Fragment {
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    public FenceAddedFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment FenceAddedFragment.
     */
    public static FenceAddedFragment newInstance(AddFenceActivityViewModel.ViewModel viewModel) {
        FenceAddedFragment fragment = new FenceAddedFragment();
        fragment.fenceViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public static FenceAddedFragment newInstance(TrigVehicleActivityViewModel.ViewModel viewModel) {
        FenceAddedFragment fragment = new FenceAddedFragment();
        fragment.vehicleViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    private Activity mActivity;
    private AddFenceActivityViewModel.ViewModel fenceViewModel;
    private TrigVehicleActivityViewModel.ViewModel vehicleViewModel;

    @BindView(R.id.tv_fence_tips)
    TextView tvFenceTips;

    @OnClick(R.id.btn_ok)
    public void ok() {
        if (mActivity != null) {
            if (mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).proceed(1);
            } else if (mActivity instanceof TrigVehicleActivity) {
                ((TrigVehicleActivity) mActivity).proceed(1);
            }
        }
    }

    @Override
    public void onAttach(@NonNull Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
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
        View view = inflater.inflate(R.layout.fragment_fence_added, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
    }

    private void initView() {
        if (fenceViewModel != null && fenceViewModel.ruleBean == null) {
            tvFenceTips.setText(R.string.geo_fence_zone_added_successfully);
        } else if (fenceViewModel != null || (vehicleViewModel != null && vehicleViewModel.ruleBean != null)) {
            tvFenceTips.setText(R.string.the_vehicles_trigger_this_geo_fence_has_been_updated_n_nwhen_the_vehicle_restarts_the_geo_fence_takes_effect);
        }
    }
}
