package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import android.os.Handler;
import android.text.Html;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.ui.activity.ForgetPwdActivity;

import android.widget.Toast;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.UserProfile;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.viewmodels.setting.ChangePwdViewModel;

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
@RequiresActivityViewModel(ChangePwdViewModel.ViewModel.class)
public final class ChangePwdActivity extends BaseActivity<ChangePwdViewModel.ViewModel> {
    private static final String TAG = ChangePwdActivity.class.getSimpleName();

    protected @BindView(R.id.forgot_your_password_text_view)
    TextView forgotPasswordTextView;

    protected @BindView(R.id.et_password)
    EditText passwordEditText;
    protected @BindView(R.id.et_newPwdFirst)
    EditText newPwdFirstEditText;
    protected @BindView(R.id.et_newPwdSecond)
    EditText newPwdSecondEditText;

    @BindView(R.id.btn_confirm)
    Button btnConfirm;

    @BindView(R.id.btn_cancel)
    Button btnCancel;

    protected @BindString(R.string.login_buttons_forgot_password_html)
    String forgotPasswordString;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, ChangePwdActivity.class);
        activity.startActivity(intent);
    }

    @OnClick(R.id.btn_confirm)
    public void confirmOnClick() {
        viewModel.inputs.confirmClick();
    }

    @OnClick(R.id.btn_cancel)
    public void cancelOnClick() {
        finish();
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @Override
    protected void onCreate(final @Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_change_password);
        ButterKnife.bind(this);
        setupToolbar();

        forgotPasswordTextView.setText(Html.fromHtml(forgotPasswordString));
        forgotPasswordTextView.setVisibility(View.GONE);

        viewModel.outputs.changeSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSuccess, new ServerErrorHandler());

        viewModel.outputs.showResetPasswordSuccessDialog()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(showAndEmail -> {
                    final boolean show = showAndEmail.first;
                    final String email = showAndEmail.second;
                }, new ServerErrorHandler());

        viewModel.outputs.setConfirmButtonIsEnabled()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setConfirmMenuEnabled, new ServerErrorHandler());

        viewModel.errors.apiError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleApiError, new ServerErrorHandler(TAG));

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));

        viewModel.errors.error()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleError, new ServerErrorHandler(TAG));
    }

    private void handleApiError(ErrorEnvelope error) {
        Toast.makeText(this, error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void handleNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(this, throwable);
    }

    private void handleError(Response response) {
        NetworkErrorHelper.handleExpireToken(this, response);
    }

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        setResult(resultCode, intent);
        finish();
    }

    @OnTextChanged(R.id.et_password)
    void onPasswordTextChanged(final @NonNull CharSequence email) {
        viewModel.inputs.password(email.toString());
    }

    @OnTextChanged(R.id.et_newPwdFirst)
    void onNewPwdFirstTextChanged(final @NonNull CharSequence password) {
        viewModel.inputs.newPasswordFirst(password.toString());
    }

    @OnTextChanged(R.id.et_newPwdSecond)
    void onNewPwdSecondTextChanged(final @NonNull CharSequence password) {
        viewModel.inputs.newPasswordSecond(password.toString());
    }

    @OnClick(R.id.forgot_your_password_text_view)
    public void onForgetPwdTextViewClicked() {
        if (Constants.isFleet()) {
            UserLogin userLoginProfile = this.viewModel.getCurrentUser().getUserLoginProfile();
            ForgetPwdActivity.launch(this, userLoginProfile != null ? userLoginProfile.getRealName() : null);
        } else {
            UserProfile profile = this.viewModel().getCurrentUser().getProfile();
            ForgetPwdActivity.launch(this, profile != null ? profile.email : null);
        }
    }

    public void onSuccess(Boolean isSuccess) {
        if (isSuccess) {
            Toast.makeText(this, R.string.change_pwd_success, Toast.LENGTH_SHORT).show();
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    setResult(Activity.RESULT_OK);
                    finish();
                }
            }, 500);
        }
    }

    public void setConfirmMenuEnabled(final boolean enabled) {
        btnConfirm.setEnabled(enabled);
    }

    public void setupToolbar() {
        tvToolbarTitle.setText(getString(R.string.profile_account_change_password));

        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(v -> finish());
        }
    }
}
