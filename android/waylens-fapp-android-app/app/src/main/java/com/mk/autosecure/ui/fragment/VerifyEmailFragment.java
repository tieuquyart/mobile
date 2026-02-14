package com.mk.autosecure.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.widget.Toast;

import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.viewmodels.fragment.VerifyEmailViewModel;

import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/14.
 * Email: doanvt-hn@mk.com.vn
 */

@RequiresFragmentViewModel(VerifyEmailViewModel.ViewModel.class)
public class VerifyEmailFragment extends BaseFragment<VerifyEmailViewModel.ViewModel> {
    private static final String TAG = "VerifyEmailFragment";

    public static final int RESEND_EMAIL_INTERVAL_SECONDS = 60;

    protected boolean newShot = true;
    protected String mEmail;

    @BindView(R.id.btn_resend_verification)
    Button btnResendVerification;
    @BindView(R.id.tv_verify_guide)
    TextView tvVerifyGuide;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_verify_email, container, false);
        ButterKnife.bind(this, view);

        viewModel.errors
                .resendError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onResendError, new ServerErrorHandler());

        viewModel.errors
                .lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> NetworkErrorHelper.handleCommonError(getActivity(), e), new ServerErrorHandler(TAG));

        Observable.interval(0, 200, TimeUnit.MILLISECONDS)
                .compose(Transformers.combineLatestPair(viewModel.component.emailInfo().asObservable()))
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(pair -> this.updateResendStatus(pair.second.getIncludeNull()), new ServerErrorHandler(TAG));

        viewModel.outputs
                .resendSuccess()
                .compose(bindToLifecycle())
                .subscribe(__ -> refreshEmailInfo(), new ServerErrorHandler());

        return view;
    }

    public void setEmail(String email) {
        if (StringUtils.isEmail(email)) {
            mEmail = email;
            refreshContent(mEmail);
        }
    }

    private void refreshContent(String email) {
        tvVerifyGuide.setText(String.format(Locale.getDefault(), getString(R.string.verify_email_content), email));
    }

    private void refreshEmailInfo() {
        Optional<EmailInfo.Data> dataOptional = viewModel.component.emailInfo().getData();
        if (dataOptional != null) {
            EmailInfo.Data data = dataOptional.getIncludeNull();
            String email = data != null ? data.email : mEmail;
            if (email != null && StringUtils.isEmail(email)) {
                viewModel.component.emailInfo().refresh(new EmailInfo.Data(email, System.currentTimeMillis()));
            }
        }
    }

    @OnClick(R.id.btn_resend_verification)
    public void onBtnResendVerificationClick() {
        viewModel.inputs.resendEmailClick();
    }

    @OnClick(R.id.tv_switch_email)
    public void onSwitchEmailClick() {
        viewModel.inputs.backClick();
    }

    private void onResendError(ErrorEnvelope error) {
        Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_LONG).show();
    }

    private void updateResendStatus(EmailInfo.Data data) {
        if (data != null) {
            long diff = System.currentTimeMillis() - data.resetTimeStamp;
            if (diff < RESEND_EMAIL_INTERVAL_SECONDS * 1000 && diff > 0) {
                newShot = true;
                btnResendVerification.setEnabled(false);
                btnResendVerification.setText(String.format(Locale.getDefault(), getString(R.string.verify_email_btn_text_format), RESEND_EMAIL_INTERVAL_SECONDS - diff / 1000));
            } else if (newShot && diff > 60 * 1000) {
                newShot = false;
                btnResendVerification.setEnabled(true);
                btnResendVerification.setText(getString(R.string.verify_email_btn_text));
            }
        }
    }
}
