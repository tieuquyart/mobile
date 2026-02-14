package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.textfield.TextInputLayout;

import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.mk.autosecure.rest.reponse.BOOLResponse;
import com.mk.autosecure.ui.data.IntentKey;

import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ClearableEditText;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.viewmodels.fragment.ResetPasswordViewModel;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint({"CheckResult", "NonConstantResourceId"})
@RequiresFragmentViewModel(ResetPasswordViewModel.ViewModel.class)
public final class ResetPasswordFragment extends BaseFragment<ResetPasswordViewModel.ViewModel> {
    private static final String TAG = ResetPasswordFragment.class.getSimpleName();

    @BindView(R.id.email)
    EditText email;

    @BindView(R.id.btnForgotPw)
    Button resetPasswordButton;

    @BindView(R.id.progressBar)
    ProgressBar progressBar;

    @BindString(R.string.forget_password)
    String forgotPasswordString;
    @BindString(R.string.forgot_password_error)
    String errorMessageString;

    public static ResetPasswordFragment createInstance(String email) {
        ResetPasswordFragment fragment = new ResetPasswordFragment();
        Bundle args = new Bundle();
        args.putString(IntentKey.EMAIL, TextUtils.isEmpty(email) ? "" : email);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        String email = getArguments().getString(IntentKey.EMAIL, "");
        View view = inflater.inflate(R.layout.fragment_reset_password, container, false);

        ButterKnife.bind(this, view);
        //loginToolbar.setTitle(forgotPasswordString);

        viewModel.outputs.resetSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onResetSuccess(), new ServerErrorHandler());

        viewModel.outputs.isFormSubmitting()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormDisabled, new ServerErrorHandler());

        viewModel.outputs.isFormValid()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormEnabled, new ServerErrorHandler());

        viewModel.errors.resetError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onError, new ServerErrorHandler());

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> NetworkErrorHelper.handleCommonError(getActivity(), e), new ServerErrorHandler(TAG));

        viewModel.resetFailure()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread()).subscribe(this::onFailure, new ServerErrorHandler(TAG));

        setDataBase();

        return view;
    }

    private void setDataBase() {
        viewModel.inputs.email("");
        viewModel.inputs.account("");
        viewModel.inputs.phone("");
    }

    @OnTextChanged(R.id.email)
    void onEmailTextChanged(final @NonNull CharSequence email) {
        viewModel.inputs.email(email.toString());
    }

    @OnTextChanged(R.id.account)
    void onAccountTextChanged(final @NonNull CharSequence s) {
        viewModel.inputs.account(s.toString());
    }

    @OnTextChanged(R.id.phone)
    void onPhoneTextChanged(final @NonNull CharSequence s) {
        viewModel.inputs.phone(s.toString());
    }

    @OnClick(R.id.btnForgotPw)
    public void resetButtonOnClick() {
        progressBar.setVisibility(View.VISIBLE);
        viewModel.inputs.resetPasswordClick();
    }

    private void onResetSuccess() {
        progressBar.setVisibility(View.GONE);
        setFormEnabled(false);
        Toast.makeText(getActivity(), "Thay đổi mật khẩu thành công!\n Mật khẩu mới đã được gửi tới email của bạn", Toast.LENGTH_SHORT).show();
//        viewModel.inputs.backClick();
        new Handler().postDelayed(() -> {
            LoginActivity.launch(getActivity());
            getActivity().finish();
        }, 1000);
    }

    private void setFormEnabled(final boolean isEnabled) {
        resetPasswordButton.setEnabled(isEnabled);
    }

    private void setFormDisabled(final boolean isDisabled) {
        setFormEnabled(!isDisabled);
    }

    @OnClick(R.id.btnSignin)
    public void onBackClick() {
        viewModel.inputs.backClick();
    }

    private void onError(ErrorEnvelope error) {
        progressBar.setVisibility(View.GONE);
        try {
            Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
            Logger.t(TAG).d("%s", ex.getMessage());
        }
    }

    private void onFailure(BOOLResponse res) {
        progressBar.setVisibility(View.GONE);
        try {
            Toast.makeText(getActivity(), res.getMessage(), Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
            Logger.t(TAG).d("%s", ex.getMessage());
        }
    }
}
