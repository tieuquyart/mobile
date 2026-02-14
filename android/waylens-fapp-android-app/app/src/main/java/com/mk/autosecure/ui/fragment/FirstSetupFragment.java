package com.mk.autosecure.ui.fragment;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.TextView;

import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mk.autosecure.R;
import com.mk.autosecure.viewmodels.SetupActivityViewModel;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/24.
 */

public class FirstSetupFragment extends RxFragment {

    public static final String TAG = FirstSetupFragment.class.getSimpleName();

    private SetupActivityViewModel.ViewModel parentViewModel;

    @BindView(R.id.tv_tipTwo)
    TextView tv_tipTwo;

    @BindView(R.id.cb_confirm)
    CheckBox cb_confirm;

    @BindView(R.id.btn_continue)
    Button btn_continue;

    @BindString(R.string.setup_meet_problems)
    String stringMeetProblems;

    public static FirstSetupFragment newInstance(SetupActivityViewModel.ViewModel viewModel) {
        FirstSetupFragment fragment = new FirstSetupFragment();
        fragment.parentViewModel = viewModel;
        Bundle bundle = new Bundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View v1 = inflater.inflate(R.layout.fragment_setup_one, container, false);
        ButterKnife.bind(this, v1);
        tv_tipTwo.setText(Html.fromHtml(stringMeetProblems));
        cb_confirm.setOnCheckedChangeListener((buttonView, isChecked) -> btn_continue.setEnabled(isChecked));

        btn_continue.setOnClickListener(v -> {
            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.proceed(1);
            }
        });
        return v1;
    }
}
