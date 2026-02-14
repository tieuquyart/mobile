package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.textfield.TextInputLayout;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;

import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.settings.WebViewActivity;

import android.widget.Toast;

import com.mk.autosecure.ui.view.ClearableEditText;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.viewmodels.fragment.RegisterViewModel;
import com.orhanobut.logger.Logger;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/15.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint({"CheckResult", "NonConstantResourceId"})
@RequiresFragmentViewModel(RegisterViewModel.ViewModel.class)
public class RegisterFragment extends BaseFragment<RegisterViewModel.ViewModel> {
    private static final String TAG = RegisterFragment.class.getSimpleName();

    public RegisterFragment(ViewType viewType) {
        this.viewType = viewType;
    }

    public enum ViewType {SIGNUP, CHECK_SN, NEW_FLEET}

    public ViewType viewType;

    @BindView(R.id.llScrollMain)
    ScrollView llScrollMain;

    protected @BindView(R.id.signup_btn)
    Button signupButton;

    protected @BindView(R.id.fleet)
    EditText fleetEditText;

    protected @BindView(R.id.account)
    EditText accountEditText;

    protected @BindView(R.id.password)
    EditText passwordEditText;

    protected @BindView(R.id.fullName)
    EditText fullNameEditText;

    protected @BindView(R.id.email)
    EditText emailEditText;

    protected @BindView(R.id.phone)
    EditText phoneEditText;

    @BindView(R.id.progressBar)
    ProgressBar progressBar;

    //view check cameraSn

    @BindView(R.id.llCheckCameraSn)
    LinearLayout llCheckCameraSn;

    @BindView(R.id.cameraSn)
    EditText cameraSn;

    //view signup fleet

    @BindView(R.id.llScrollCreateFleet)
    ScrollView llScrollCreateFleet;

    @BindView(R.id.fleetName)
    EditText fleetName;

    @BindView(R.id.account_fleet)
    EditText accountFleet;

    @BindView(R.id.email_fleet)
    EditText emailFleet;

    @BindView(R.id.phone_fleet)
    EditText phoneFleet;

    protected @BindView(R.id.signup_fleet)
    Button signupFleet;

    protected @BindView(R.id.checkSerialBtn)
    Button checkSerialBtn;

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

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_register, container, false);
        ButterKnife.bind(this, view);

        //checkShowView
        showViewWithType(viewType);

        viewModel.outputs.signupSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onSuccess(), new ServerErrorHandler());

        viewModel.outputs.checkSnSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onCheckSuccess(), new ServerErrorHandler());

        viewModel.outputs.formSubmitting()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormDisabled, new ServerErrorHandler());

        viewModel.outputs.newfleetIsValid()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setSubmitEnable, new ServerErrorHandler(TAG));

        viewModel.outputs.formIsValid()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::setFormEnabled, new ServerErrorHandler());

        viewModel.errors.signupError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::showError, new ServerErrorHandler());

        viewModel.errors.lowLevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(e -> NetworkErrorHelper.handleCommonError(getActivity(), e));

        viewModel.signupFailure()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(res -> {
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(getActivity(), res.getMessage(), Toast.LENGTH_SHORT).show();
                });

//        agreeCheckBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
//            @Override
//            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
//                viewModel.inputs.agreeCheck(isChecked);
//            }
//        });

        viewModel.inputs.agreeCheck(true);
        setBaseData();
        checkSerialBtn.setEnabled(false);
        return view;
    }

    private void showViewWithType(ViewType type) {
        switch (type) {
            case SIGNUP:
                llScrollMain.setVisibility(View.VISIBLE);
                llScrollCreateFleet.setVisibility(View.GONE);
                llCheckCameraSn.setVisibility(View.GONE);
                break;
            case CHECK_SN:
                llScrollMain.setVisibility(View.GONE);
                llScrollCreateFleet.setVisibility(View.GONE);
                llCheckCameraSn.setVisibility(View.VISIBLE);
                break;
            case NEW_FLEET:
                llScrollMain.setVisibility(View.GONE);
                llScrollCreateFleet.setVisibility(View.VISIBLE);
                llCheckCameraSn.setVisibility(View.GONE);
                break;
        }
    }

    private void setBaseData() {
        viewModel.inputs.account("");
        viewModel.inputs.email("");
        viewModel.inputs.password("");
        viewModel.inputs.fullName("");
        viewModel.inputs.fleetName("");
        viewModel.inputs.mobile("");
        //
        viewModel.inputs.fleet_Name("");
        viewModel.inputs.emailFleet("");
        viewModel.inputs.accountFleet("");
        viewModel.inputs.phoneFleet("");
    }

    public void clearEmailAndPassword() {
        emailEditText.setText("");
        passwordEditText.setText("");
    }

    @OnClick(R.id.btnSignin)
    public void onToLoginClick() {
        LoginActivity.launch(getActivity());
        this.getActivity().finish();
    }


    @OnTextChanged(R.id.email)
    void onEmailTextChanged(final @NonNull CharSequence email) {
        viewModel.inputs.email(email.toString());
    }

    @OnTextChanged(R.id.password)
    void onPasswordTextChange(final @NonNull CharSequence password) {
        viewModel.inputs.password(password.toString());
    }

    @OnTextChanged(R.id.fleet)
    void onFleetTextChange(final @NonNull CharSequence fleet) {
        viewModel.inputs.fleetName(fleet.toString());
    }

    @OnTextChanged(R.id.account)
    void onAccountTextChange(final @NonNull CharSequence account) {
        viewModel.inputs.account(account.toString());
    }

    @OnTextChanged(R.id.fullName)
    void onFullNameTextChange(final @NonNull CharSequence fullName) {
        viewModel.inputs.fullName(fullName.toString());
    }

    @OnTextChanged(R.id.phone)
    void onPhoneTextChange(final @NonNull CharSequence phone) {
        viewModel.inputs.mobile(phone.toString());
    }

    @OnTextChanged(R.id.fleetName)
    void onFleetNameTextChange(final @NonNull CharSequence s) {
        viewModel.inputs.fleet_Name(s.toString());
    }

    @OnTextChanged(R.id.account_fleet)
    void onAccountFleetTextChange(final @NonNull CharSequence s) {
        viewModel.inputs.accountFleet(s.toString());
    }

    @OnTextChanged(R.id.email_fleet)
    void onEmailFleetTextChange(final @NonNull CharSequence email) {
        viewModel.inputs.emailFleet(email.toString());
    }

    @OnTextChanged(R.id.phone_fleet)
    void onPhoneFleetTextChange(final @NonNull CharSequence phone) {
        viewModel.inputs.phoneFleet(phone.toString());
    }

    String cameraSN;

    @OnTextChanged(R.id.cameraSn)
    void onCameraSnTextChange(final @NonNull CharSequence s){
        cameraSN = s.toString();
        checkSerialBtn.setEnabled(!StringUtils.isEmpty(cameraSN));
    }

    /**
     * onClickSignup
     */
    @OnClick(R.id.signup_btn)
    public void signupButtonOnClick() {
        progressBar.setVisibility(View.VISIBLE);
        viewModel.inputs.signupClick();
    }

    /**
     * onClickCheckCameraSn
     */
    @OnClick(R.id.checkSerialBtn)
    public void checkCameraSnOnClick() {
        progressBar.setVisibility(View.VISIBLE);
        viewModel.checkClick(cameraSN);
    }

    /**
     * onClickSignupFleet
     */
    @OnClick(R.id.signup_fleet)
    public void signupFleetOnClick() {
        progressBar.setVisibility(View.VISIBLE);
        viewModel.inputs.signupFleetClick();
    }


    public void onSuccess() {
        //setResult(Activity.RESULT_OK);
        onToLoginClick();
        progressBar.setVisibility(View.GONE);
        Toast.makeText(getActivity(), "Thêm tài khoản thành công", Toast.LENGTH_SHORT).show();
    }

    public void onCheckSuccess() {
        progressBar.setVisibility(View.GONE);
        showViewWithType(ViewType.NEW_FLEET);
//        Toast.makeText(getActivity(), "Thêm tài khoản thành công", Toast.LENGTH_SHORT).show();
    }

    public void setFormEnabled(final boolean enabled) {
        Logger.t(TAG).d("setEnable: %s", enabled ? "true" : "false");
        signupButton.setEnabled(enabled);
    }

    public void setSubmitEnable(final boolean enabled) {
        Logger.t(TAG).d("setEnableSubmit: %s", enabled ? "true" : "false");
        signupFleet.setEnabled(enabled);
    }

    public void setFormDisabled(final boolean disabled) {
        setFormEnabled(!disabled);
        setSubmitEnable(!disabled);
    }

    public void showError(ErrorEnvelope err) {
        progressBar.setVisibility(View.GONE);
        Toast.makeText(getActivity(), err.getErrorMessage(), Toast.LENGTH_LONG).show();
    }

}
