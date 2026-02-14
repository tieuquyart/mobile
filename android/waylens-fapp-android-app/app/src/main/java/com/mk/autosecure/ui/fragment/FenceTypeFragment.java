package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FenceTypeFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FenceTypeFragment extends RxFragment {
    private final static String TAG = FenceTypeFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private Activity mActivity;

    private AddFenceActivityViewModel.ViewModel parentViewModel;

    public FenceTypeFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment FenceTypeFragment.
     */
    public static FenceTypeFragment newInstance(AddFenceActivityViewModel.ViewModel viewModel) {
        FenceTypeFragment fragment = new FenceTypeFragment();
        fragment.parentViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @BindView(R.id.et_fence_name)
    EditText etFenceName;

    @BindView(R.id.rg_fence_type)
    RadioGroup rgFenceType;

    @BindView(R.id.rb_circular)
    RadioButton rbCircular;

    @BindView(R.id.rb_polygonal)
    RadioButton rbPolygonal;

    @BindView(R.id.rb_reused)
    RadioButton rbReused;

    @BindView(R.id.tv_warning_tips)
    TextView tvWarningTips;

    @OnTextChanged(R.id.et_fence_name)
    public void onNameChanged(final @NonNull CharSequence name) {
        int length = name.length();
    }

    @OnClick(R.id.btn_next)
    public void next() {
        String name = etFenceName.getText().toString().trim();
        int length = name.length();
        Logger.t(TAG).d("next name length: " + length);
        if (length == 0 || length > 20) {
            Toast.makeText(mActivity, length == 0 ? R.string.input_fence_name_tips
                    : R.string.exceed_fence_name_tips, Toast.LENGTH_SHORT).show();
        } else {
            if (parentViewModel != null) {
                parentViewModel.fenceName(name);
            }
            if (mActivity != null && mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).setFenceName(name);
                ((AddFenceActivity) mActivity).proceed(1);
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
        View view = inflater.inflate(R.layout.fragment_fence_type, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
    }

    @SuppressLint("CheckResult")
    private void initView() {
        etFenceName.requestFocus();

        rgFenceType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                AddFenceActivity.FenceType fenceType = AddFenceActivity.FenceType.Circular;
                if (checkedId == rbCircular.getId()) {
                    Logger.t(TAG).d("rbCircular");
                    fenceType = AddFenceActivity.FenceType.Circular;
                    tvWarningTips.setText(R.string.on_the_next_page_you_need_to_do_the_following_steps_to_build_your_geo_fenceing_area_n_n1_select_the_central_point_on_the_map_n2_fill_in_the_range_of_the_geo_fencing_area);
                } else if (checkedId == rbPolygonal.getId()) {
                    Logger.t(TAG).d("rbPolygonal");
                    fenceType = AddFenceActivity.FenceType.Polygonal;
                    tvWarningTips.setText(R.string.on_the_next_page_you_need_to_do_the_following_steps_to_build_your_geo_fence_area_n_n1_tap_on_the_map_to_get_a_start_point_n2_build_the_area_by_adding_more_point_on_the_map_n3_tap);
                } else if (checkedId == rbReused.getId()) {
                    Logger.t(TAG).d("rbReused");
                    fenceType = AddFenceActivity.FenceType.Reused;
                    tvWarningTips.setText(R.string.on_the_next_page_you_need_to_select_a_existing_graph_to_build_your_geo_fence_area);
                }

                if (mActivity != null && mActivity instanceof AddFenceActivity) {
                    ((AddFenceActivity) mActivity).setFenceType(fenceType);
                }
            }
        });

        if (parentViewModel != null && parentViewModel.editMode) {
            etFenceName.setText(parentViewModel.fenceName);
            for (int i = 0; i < rgFenceType.getChildCount(); i++) {
                rgFenceType.getChildAt(i).setEnabled(false);
            }

            parentViewModel.detailBean()
                    .compose(bindToLifecycle())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::onDetailBean, new ServerErrorHandler(TAG));
        } else {
            rgFenceType.check(rbCircular.getId());
        }
    }

    private void onDetailBean(FenceDetailBean detailBean) {
        if (detailBean == null) {
            return;
        }
        rgFenceType.check(detailBean.getPolygon() != null ? rbPolygonal.getId() : rbCircular.getId());
    }
}
