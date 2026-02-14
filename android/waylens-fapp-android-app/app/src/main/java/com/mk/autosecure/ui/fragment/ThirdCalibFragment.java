package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.settings.CalibActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.viewmodels.setting.CalibActivityViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ThirdCalibFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ThirdCalibFragment extends Fragment {
    private final static String TAG = ThirdCalibFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private CalibActivityViewModel.ViewModel parentViewModel;

    private int mSide = -1;

    private int x = 115;
    private int y = 45;
    private int z = 130;

    @BindView(R.id.rg_input_side)
    RadioGroup rgInputSide;

    @BindView(R.id.rb_side_left)
    RadioButton rbSideLeft;

    @BindView(R.id.rb_side_right)
    RadioButton rbSideRight;

    @BindView(R.id.rg_choose_type)
    RadioGroup rgChooseType;

    @BindView(R.id.rb_type_truck)
    RadioButton rbTypeTruck;

    @BindView(R.id.rb_type_large)
    RadioButton rbTypeLarge;

    @BindView(R.id.rb_type_small)
    RadioButton rbTypeSmall;

    @OnClick(R.id.btn_input_next)
    public void next() {
        if (getActivity() instanceof CalibActivity) {
            ((CalibActivity) getActivity()).setCalibParams(x, y * mSide, z);
        }

        if (parentViewModel != null && parentViewModel.inputs != null) {
            parentViewModel.inputs.proceed(3);
        }
    }

    public ThirdCalibFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param viewModel
     * @param param1    Parameter 1.
     * @param param2    Parameter 2.
     * @return A new instance of fragment ThirdCalibFragment.
     */
    public static ThirdCalibFragment newInstance(CalibActivityViewModel.ViewModel viewModel, String param1, String param2) {
        ThirdCalibFragment fragment = new ThirdCalibFragment();
        fragment.parentViewModel = viewModel;
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
        View view = inflater.inflate(R.layout.fragment_third_calib, container, false);
        ButterKnife.bind(this, view);
        initViews();
        return view;
    }

    private void initViews() {
        rgInputSide.check(rbSideLeft.getId());
        rgInputSide.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == rbSideLeft.getId()) {
                mSide = -1;
            } else if (checkedId == rbSideRight.getId()) {
                mSide = 1;
            }
        });

        rgChooseType.check(rbTypeTruck.getId());
        rgChooseType.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == rbTypeTruck.getId()) {
                x = 115;
                y = 45;
                z = 130;
            } else if (checkedId == rbTypeLarge.getId()) {
                x = 125;
                y = 42;
                z = 110;
            } else if (checkedId == rbTypeSmall.getId()) {
                x = 105;
                y = 38;
                z = 88;
            }
        });
    }
}
