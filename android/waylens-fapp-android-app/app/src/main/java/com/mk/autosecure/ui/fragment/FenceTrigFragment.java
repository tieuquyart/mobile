package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import com.mk.autosecure.ui.activity.settings.TrigVehicleActivity;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.request.AddFenceRuleBody;
import com.mk.autosecure.rest_fleet.response.AddFenceRuleResponse;
import com.mk.autosecure.viewmodels.setting.AddFenceActivityViewModel;
import com.mk.autosecure.viewmodels.setting.TrigVehicleActivityViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.functions.Action;
import io.reactivex.functions.Consumer;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FenceTrigFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FenceTrigFragment extends RxFragment {
    private final static String TAG = FenceTrigFragment.class.getSimpleName();
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    public FenceTrigFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment FenceTrigFragment.
     */
    public static FenceTrigFragment newInstance(AddFenceActivityViewModel.ViewModel viewModel) {
        FenceTrigFragment fragment = new FenceTrigFragment();
        fragment.fenceViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public static FenceTrigFragment newInstance(TrigVehicleActivityViewModel.ViewModel viewModel) {
        FenceTrigFragment fragment = new FenceTrigFragment();
        fragment.vehicleViewModel = viewModel;
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @BindView(R.id.ll_trig_type)
    LinearLayout llTrigType;

    @BindView(R.id.cb_trig_enter)
    CheckBox cbTrigEnter;

    @BindView(R.id.cb_trig_exit)
    CheckBox cbTrigExit;

    @BindView(R.id.rg_trig_vehicle)
    RadioGroup rgTrigVehicle;

    @BindView(R.id.rb_specific_vehicle)
    RadioButton rbSpecificVehicle;

    @BindView(R.id.rb_all_vehicle)
    RadioButton rbAllVehicle;

    @BindView(R.id.btn_next)
    Button btnNext;

    @SuppressLint("CheckResult")
    @OnClick(R.id.btn_next)
    public void next() {
        Logger.t(TAG).d("next: " + cbTrigEnter.isChecked() + " " + cbTrigExit.isChecked());

        if (fenceViewModel != null && !cbTrigEnter.isChecked() && !cbTrigExit.isChecked()) {
            Toast.makeText(mActivity, "Please choose enter or exit or all", Toast.LENGTH_SHORT).show();
            return;
        }

        List<String> typeList = new ArrayList<>();
        if (cbTrigEnter.isChecked()) typeList.add("enter");
        if (cbTrigExit.isChecked()) typeList.add("exit");

        if (rbSpecificVehicle.isChecked()) {
            if (fenceViewModel != null) {
                fenceViewModel.fenceType(typeList.toArray(new String[0]));
                fenceViewModel.fenceScope("specific");
            } else if (vehicleViewModel != null) {
                vehicleViewModel.fenceScope("specific");
            }
            if (mActivity != null) {
                if (mActivity instanceof AddFenceActivity) {
                    ((AddFenceActivity) mActivity).proceed(1);
                } else if (mActivity instanceof TrigVehicleActivity) {
                    ((TrigVehicleActivity) mActivity).proceed(1);
                }
            }
        } else if (rbAllVehicle.isChecked()) {
            AddFenceRuleBody body = new AddFenceRuleBody();

            if (fenceViewModel != null) {
                body.name = fenceViewModel.fenceName;
                body.fenceID = fenceViewModel.fenceID;
                body.type = typeList.toArray(new String[0]);
            } else if (vehicleViewModel != null) {
                body.name = vehicleViewModel.fenceName;
                body.fenceID = vehicleViewModel.fenceID;
                body.type = vehicleViewModel.fenceType;
            }

            body.scope = "all";

            if (fenceViewModel != null && fenceViewModel.ruleBean == null) {
                ApiClient.createApiService().addFenceRule(body)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(new Consumer<AddFenceRuleResponse>() {
                            @Override
                            public void accept(AddFenceRuleResponse response) throws Exception {
                                Logger.t(TAG).d("addFenceRule response: " + response);
                            }
                        }, new Consumer<Throwable>() {
                            @Override
                            public void accept(Throwable throwable) throws Exception {
                                Logger.t(TAG).e("addFenceRule throwable: " + throwable.getMessage());
                                Toast.makeText(mActivity, R.string.geo_fence_zone_failed_to_add_please_try_again, Toast.LENGTH_SHORT).show();
                            }
                        }, new Action() {
                            @Override
                            public void run() throws Exception {
                                proceed();
                            }
                        });
            } else if (fenceViewModel != null || (vehicleViewModel != null && vehicleViewModel.ruleBean != null)) {
                String fenceRuleID;
                if (fenceViewModel != null) {
                    fenceRuleID = fenceViewModel.ruleBean.getFenceRuleID();
                } else {
                    fenceRuleID = vehicleViewModel.ruleBean.getFenceRuleID();
                }
                if (fenceRuleID != null) {
                    ApiClient.createApiService().editFenceRule(fenceRuleID, body)
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(new Consumer<BooleanResponse>() {
                                @Override
                                public void accept(BooleanResponse response) throws Exception {
                                    Logger.t(TAG).d("editFenceRule response: " + response);
                                }
                            }, new Consumer<Throwable>() {
                                @Override
                                public void accept(Throwable throwable) throws Exception {
                                    Logger.t(TAG).e("editFenceRule throwable: " + throwable.getMessage());
                                    Toast.makeText(mActivity, "editFenceRule error: " + throwable.getMessage(), Toast.LENGTH_SHORT).show();
                                }
                            }, new Action() {
                                @Override
                                public void run() throws Exception {
                                    proceed();
                                }
                            });
                }
            }
        }
    }

    private void proceed() {
        if (mActivity != null) {
            if (mActivity instanceof AddFenceActivity) {
                ((AddFenceActivity) mActivity).proceed(2);
            } else if (mActivity instanceof TrigVehicleActivity) {
                ((TrigVehicleActivity) mActivity).proceed(2);
            }
        }
    }

    private Activity mActivity;
    private AddFenceActivityViewModel.ViewModel fenceViewModel;
    private TrigVehicleActivityViewModel.ViewModel vehicleViewModel;

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
        View view = inflater.inflate(R.layout.fragment_fence_trig, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
    }

    private void initView() {
        rgTrigVehicle.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                if (checkedId == rbSpecificVehicle.getId()) {
                    btnNext.setText(R.string.forget_password_next);
                } else if (checkedId == rbAllVehicle.getId()) {
                    btnNext.setText(R.string.done);
                }
            }
        });
        if (vehicleViewModel != null && vehicleViewModel.ruleBean != null) {
            Logger.t(TAG).d("vehicleViewModel ruleBean: " + vehicleViewModel.ruleBean);
            llTrigType.setVisibility(View.GONE);
            String fenceScope = vehicleViewModel.fenceScope;
            rgTrigVehicle.check("all".equals(fenceScope) ? rbAllVehicle.getId() : rbSpecificVehicle.getId());
        } else if (fenceViewModel != null && fenceViewModel.ruleBean != null) {
            Logger.t(TAG).d("fenceViewModel ruleBean: " + fenceViewModel.ruleBean);
            String[] fenceType = fenceViewModel.fenceType;
            for (String string : fenceType) {
                if ("enter".equals(string)) {
                    cbTrigEnter.setChecked(true);
                }
                if ("exit".equals(string)) {
                    cbTrigExit.setChecked(true);
                }
            }
            String fenceScope = fenceViewModel.fenceScope;
            rgTrigVehicle.check("all".equals(fenceScope) ? rbAllVehicle.getId() : rbSpecificVehicle.getId());
        } else {
            rgTrigVehicle.check(rbSpecificVehicle.getId());
        }
    }
}
