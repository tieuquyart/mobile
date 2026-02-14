package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.response.LogInResponse;
import com.mk.autosecure.ui.activity.ForgetPwdActivity;
import com.mk.autosecure.ui.activity.SignUpActivity;
import com.mk.autosecure.ui.view.ClearableEditText;
import com.mk.autosecure.viewmodels.fragment.LoginFragmentViewModel;
import com.orhanobut.logger.Logger;

import java.util.Objects;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/14.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint({"CheckResult", "NonConstantResourceId"})
@RequiresFragmentViewModel(LoginFragmentViewModel.ViewModel.class)
public class LoginFragment extends BaseFragment<LoginFragmentViewModel.ViewModel> {
    private static final String TAG = LoginFragment.class.getSimpleName();

    public final static String KEY_EMAIL = "email";
    public final static String KEY_ACCOUNT = "account";
    public final static String KEY_PW = "password";
    public final static String KEY_CHECKED = "checked";
    public final static int LOGIN_FLOW = 0x0001f;
    protected @BindView(R.id.account)
    ClearableEditText accountEditText;
    protected @BindView(R.id.resetpw_button)
    Button resetpw_button;
    protected @BindView(R.id.login_button)
    Button loginButton;
    protected @BindView(R.id.password)
    EditText passwordEditText;

    protected @BindView(R.id.textInputLayoutAccount)
    LinearLayout textInputLayoutAccount;

    protected @BindView(R.id.textInputLayoutPassword)
    LinearLayout textInputLayoutPassword;

    protected @BindString(R.string.login_buttons_forgot_password_html)
    String forgotPasswordString;
    protected @BindString(R.string.login_errors_does_not_match)
    String loginDoesNotMatchString;
    protected @BindString(R.string.login_errors_unable_to_log_in)
    String unableToLoginString;
    protected @BindString(R.string.log_in)
    String loginString;
    protected @BindString(R.string.waylens_agreement_underline)
    String agreementString;

    @BindView(R.id.progressBar)
    ProgressBar progressBar;

    @BindView(R.id.checkRemember)
    CheckBox checkRemember;

    @OnClick(R.id.resetpw_button)
    public void onForgotPwdClick() {
        ForgetPwdActivity.launch(getActivity(), accountEditText.getText().toString());
    }


    @OnCheckedChanged(R.id.checkRemember)
    public void onCheckRemember(boolean isChecked) {

    }

    @BindView(R.id.swMOC)
    Switch swMOC;

//    @OnCheckedChanged(R.id.swMOC)
    public void onUseMoc(){
        if (!swMOC.isChecked()){
            swMOC.setChecked(true);
            isUseMoc = true;
        }else{
            swMOC.setChecked(false);
            isUseMoc = false;
        }

        Logger.t(TAG).d("isUse: "+isUseMoc + "isChecked: "+swMOC.isChecked());
    }

    public boolean isUseMoc = false;

    @Override
    public @Nullable
    View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view;
        if (Constants.isFleet()) {
            view = inflater.inflate(R.layout.fragment_login_fleet, container, false);
            view.findViewById(R.id.btnSignup)
                    .setOnClickListener(v -> {
                        AlertDialog.Builder alertSignup = new AlertDialog.Builder(getActivity())
                                .setCancelable(false)
                                .setMessage("Bạn có muốn tạo Fleet không?")
                                .setNegativeButton("Có", (dialog, which) -> SignUpActivity.launch(getActivity(), true))
                                .setPositiveButton("Không", (dialog, which) -> SignUpActivity.launch(getActivity(), false));
                        alertSignup.show();
                    });
        } else {
            view = inflater.inflate(R.layout.fragment_login, container, false);
            view.findViewById(R.id.signup_text_view)
                    .setOnClickListener(v -> {
                        SignUpActivity.launch(getActivity());
                        Objects.requireNonNull(LoginFragment.this.getActivity()).finish();
                    });
        }
        ButterKnife.bind(this, view);

        swMOC.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                swMOC.setChecked(isChecked);
                isUseMoc = isChecked;
                Logger.t(TAG).d("isUse: "+isUseMoc + " - isChecked: "+swMOC.isChecked());
            }
        });

        resetpw_button.setText(Html.fromHtml(forgotPasswordString));

        viewModel.inputs.getAccount();

        viewModel.outputs.loginSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onSuccess(), new ServerErrorHandler());

        viewModel.outputs.loginFailure()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onFail, new ServerErrorHandler());

        viewModel.outputs.prefillEmailFromPasswordReset()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(accountEditText::setText, new ServerErrorHandler());

        viewModel.outputs.showResetPasswordSuccessDialog()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(showAndEmail -> {
                    final boolean show = showAndEmail.first;
                    final String email = showAndEmail.second;
                }, new ServerErrorHandler());

        viewModel.outputs.setLoginButtonIsEnabled()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setLoginButtonEnabled, new ServerErrorHandler());

        viewModel.errors.loginError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onLoginError, new ServerErrorHandler());

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> {
                    progressBar.setVisibility(View.GONE);
                    NetworkErrorHelper.handleCommonError(getActivity(), e);
                }, throwable -> {
                    progressBar.setVisibility(View.GONE);
                    NetworkErrorHelper.handleCommonError(getActivity(), throwable);
                });

        viewModel.outputs.isCheck()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(isCheck -> checkRemember.setChecked(isCheck));

        viewModel.outputs.bindAccountEditText()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(bindAccount -> {
                    accountEditText.setText(bindAccount.first);
                    passwordEditText.setText(bindAccount.second);
                });

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        viewModel.inputs.getAccount();
    }

    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode != LOGIN_FLOW) {
            return;
        }
    }

    @OnTextChanged(R.id.account)
    void onAccountTextChanged(final @NonNull CharSequence account) {
        viewModel.inputs.account(account.toString());
//        textInputLayoutAccount.setError(null);
//        textInputLayoutAccount.setErrorEnabled(false);
    }

    @OnTextChanged(R.id.password)
    void onPasswordTextChanged(final @NonNull CharSequence password) {
        viewModel.inputs.password(password.toString());
    }


    @OnClick(R.id.login_button)
    public void loginButtonOnClick() {
        viewModel.inputs.loginClick();
        progressBar.setVisibility(View.VISIBLE);
        viewModel.inputs.rememberAccount(accountEditText.getText().toString(), passwordEditText.getText().toString(), checkRemember.isChecked());
    }

    public void onSuccess() {
        progressBar.setVisibility(View.GONE);
    }

    public void onFail(LogInResponse logInResponse) {
        Toast.makeText(getActivity(), logInResponse.getMessage(), Toast.LENGTH_SHORT).show();
        progressBar.setVisibility(View.GONE);
    }

    public void setLoginButtonEnabled(final boolean enabled) {
        loginButton.setEnabled(enabled);
    }

    private void onLoginError(ErrorEnvelope error) {
        try {
            progressBar.setVisibility(View.GONE);
            Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
            Logger.t(TAG).d("%s", ex.getMessage());
        }
    }

    public void clearEmailAndPassword() {
        accountEditText.setText("");
        passwordEditText.setText("");
        accountEditText.requestFocus();
//        textInputLayoutAccount.setError(null);
//        textInputLayoutAccount.setErrorEnabled(false);
//        textInputLayoutPassword.setError(null);
//        textInputLayoutPassword.setErrorEnabled(false);
    }

}
