package com.mk.autosecure.ui.fragment;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.viewmodels.fragment.TwoFactorViewModel;

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


@RequiresFragmentViewModel(TwoFactorViewModel.ViewModel.class)
public final class TwoFactorFragment extends BaseFragment<TwoFactorViewModel.ViewModel> {
    private static final String TAG = TwoFactorFragment.class.getSimpleName();
    public @BindView(R.id.btn_submit)
    Button btnSubmit;
    //public @BindView(R.id.toolbar) Toolbar loginToolbar;

    @BindString(R.string.two_factor_error_message)
    String codeMismatchString;
    @BindString(R.string.login_errors_unable_to_log_in)
    String unableToLoginString;
    @BindString(R.string.two_factor_title)
    String verifyString;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_two_factor, container, false);
        ButterKnife.bind(this, view);
        //loginToolbar.setTitle(verifyString);

        viewModel.outputs.resetSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onSuccess(), new ServerErrorHandler());

        viewModel.outputs.formSubmitting()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormDisabled, new ServerErrorHandler());

        viewModel.outputs.formIsValid()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormEnabled, new ServerErrorHandler());

        viewModel.errors.resetError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onError, new ServerErrorHandler());

        viewModel.errors
                .lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> NetworkErrorHelper.handleCommonError(getActivity(), e), new ServerErrorHandler(TAG));

        return view;
    }

    private void onError(ErrorEnvelope error) {
        try {
            Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
            if (error.isChangePWDTokenError()) {
                viewModel.inputs.backClick();
            }
        } catch (Exception ex) {
            Logger.t(TAG).d("%s", ex.getMessage());
        }
    }

    @OnTextChanged(R.id.et_pwd)
    public void pwdEditTextOnTextChanged(final @NonNull CharSequence password) {
        viewModel.inputs.password(password.toString());
    }

    @OnTextChanged(R.id.et_pwd_repeat)
    public void pwdRepeatEditTextOnTextChanged(final @NonNull CharSequence passwordRepeat) {
        viewModel.inputs.passwordRepeat(passwordRepeat.toString());
    }

    @OnClick(R.id.btn_submit)
    public void loginButtonOnClick() {
        viewModel.inputs.submitClick();
    }

    @OnClick(R.id.tv_back)
    public void onBackClick() {
        viewModel.inputs.backClick();
    }


    public void onSuccess() {
        //setResult(Activity.RESULT_OK);
        //finish();
    }

    public void setFormEnabled(final boolean enabled) {
        btnSubmit.setEnabled(enabled);
    }

    public void setFormDisabled(final boolean disabled) {
        setFormEnabled(!disabled);
    }

}
