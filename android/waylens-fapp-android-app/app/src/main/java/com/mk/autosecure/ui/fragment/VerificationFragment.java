package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.viewmodels.fragment.VerificationViewModel;

import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/9.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint("CheckResult")
@RequiresFragmentViewModel(VerificationViewModel.ViewModel.class)
public final class VerificationFragment extends BaseFragment<VerificationViewModel.ViewModel> {
    private static final String TAG = VerificationFragment.class.getSimpleName();
    public static final int RESEND_EMAIL_INTERVAL_SECONDS = 60;

    @BindString(R.string.forget_password)
    String forgotPasswordString;
    @BindString(R.string.forgot_password_error)
    String errorMessageString;
    @BindString(R.string.general_error_oops)
    String errorTitleString;

    @BindView(R.id.btn_resend)
    Button btnResend;
    @BindView(R.id.et_code)
    EditText etCode;

    //ugly
    private boolean newShot = true;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_verification, container, false);

        ButterKnife.bind(this, view);
        //loginToolbar.setTitle(forgotPasswordString);

        btnResend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                viewModel.inputs.resendCodeClick();
            }
        });

        Observable.interval(0, 200, TimeUnit.MILLISECONDS)
                .compose(Transformers.combineLatestPair(viewModel.emailInfo.asObservable()))
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(pair -> VerificationFragment.this.updateResendStatus(pair.second.getIncludeNull()),
                        new ServerErrorHandler(TAG));

        viewModel.outputs.resendSuccess()
                .compose(bindToLifecycle())
                .subscribe(voidOptional -> {
                    String email = viewModel.emailAddress().getValue();
                    if (StringUtils.isEmail(email)) {
                        viewModel.emailInfo.refresh(new EmailInfo.Data(email, System.currentTimeMillis()));
                    }
                });

        viewModel.errors.resetError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onError, new ServerErrorHandler(TAG));

        viewModel.errors
                .lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> NetworkErrorHelper.handleCommonError(getActivity(), e), new ServerErrorHandler(TAG));

        return view;
    }

    private void updateResendStatus(EmailInfo.Data data) {
        if (data != null) {
            long diff = System.currentTimeMillis() - data.resetTimeStamp;
            if (diff < RESEND_EMAIL_INTERVAL_SECONDS * 1000 && diff > 0) {
                newShot = true;
                btnResend.setEnabled(false);
                btnResend.setText(String.format(Locale.getDefault(), getString(R.string.reset_password_send_email_format), RESEND_EMAIL_INTERVAL_SECONDS - diff / 1000));
            } else if (newShot && diff > RESEND_EMAIL_INTERVAL_SECONDS * 1000) {
                newShot = false;
                btnResend.setEnabled(true);
                btnResend.setText(getString(R.string.reset_password_send_email));
            }
        }
    }

    @OnTextChanged(R.id.et_code)
    void onEmailTextChanged(final @NonNull CharSequence code) {
        viewModel.inputs.code(code.toString());
    }

    @OnClick(R.id.btn_resend)
    public void onBtnResendClick() {
        viewModel.inputs.resendCodeClick();
    }

    @OnClick(R.id.tv_back)
    public void onBackClick() {
        viewModel.inputs.backClick();
    }

    private void onError(ErrorEnvelope error) {
        try {
            Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
            Logger.t(TAG).d("%s", ex.getMessage());
        }
    }

}
