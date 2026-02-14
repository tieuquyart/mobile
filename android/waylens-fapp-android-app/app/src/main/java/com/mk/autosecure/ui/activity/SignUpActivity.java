package com.mk.autosecure.ui.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import android.widget.Toast;

import com.mk.autosecure.ui.view.WrapContentViewPager;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DebugHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.fragment.RegisterFragment;
import com.mk.autosecure.ui.fragment.VerifyEmailFragment;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint("CheckResult")
public class SignUpActivity extends RxFragmentActivity {
    private static final String TAG = "SignUpActivity";

    protected @BindString(R.string.login_buttons_forgot_password_html)
    String forgotPasswordString;
    protected @BindString(R.string.login_errors_does_not_match)
    String loginDoesNotMatchString;
    protected @BindString(R.string.login_errors_unable_to_log_in)
    String unableToLoginString;
    protected @BindString(R.string.log_in)
    String loginString;

    protected @BindView(R.id.viewpager)
    WrapContentViewPager viewPager;

    protected RegisterFragment registerFragment;
    protected VerifyEmailFragment verifyEmailFragment;
    protected MyFragmentStatePagerAdapter adapter;

    protected AppComponent component;

    private int mClickCount = 10;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SignUpActivity.class);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, boolean checkSn) {
        Intent intent = new Intent(activity, SignUpActivity.class);
        intent.putExtra("checkSn",checkSn);
        activity.startActivity(intent);
    }


//    @OnClick(R.id.view_debug)
    public void onViewDebug() {
        mClickCount--;
        if (mClickCount == 0) {
            DebugHelper.setDebugMode(true);
            DebugMenuActivity.launch(this);
            finish();
        }
    }

    @Override
    protected void onCreate(final @Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        component = HornApplication.getComponent();
        setContentView(R.layout.activity_signup);
        ButterKnife.bind(this);

        adapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());
        boolean checkSn = false;
        if (getIntent() != null){
            checkSn = getIntent().getBooleanExtra("checkSn",false);
        }
        registerFragment = new RegisterFragment(checkSn ? RegisterFragment.ViewType.CHECK_SN : RegisterFragment.ViewType.SIGNUP);
        registerFragment.setViewModel(this);

        verifyEmailFragment = new VerifyEmailFragment();
        verifyEmailFragment.setViewModel(this);

        adapter.addFragment(registerFragment);
        adapter.addFragment(verifyEmailFragment);
        viewPager.setAdapter(adapter);

        setupWithComponents();
    }

    private void setupWithComponents() {
        registerFragment.viewModel()
                .outputs
                .signupSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onSignUpSuccess(), new ServerErrorHandler(TAG));

        verifyEmailFragment.viewModel()
                .outputs
                .stepBack()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> stepBackToRegister(), new ServerErrorHandler(TAG));

        verifyEmailFragment.viewModel()
                .outputs
                .verifySuccess()
                .first(Optional.of(true))
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> stepToBindDevice(), new ServerErrorHandler(TAG));
    }

    private void stepToBindDevice() {
        finish();
        boolean tourGuide = PreferenceUtils.getBoolean(PreferenceUtils.KEY_TOUR_GUIDE_SETUP, !Constants.isFleet());
        Logger.t(TAG).d("tourGuide: " + tourGuide);
        if (tourGuide) {
//            PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE, false);
            LocalLiveActivity.launchForGuide(this);
        } else {
            LocalLiveActivity.launch(this, true);
        }
    }

    private void stepBackToRegister() {
        component.currentUser().logout();
        registerFragment.clearEmailAndPassword();
        viewPager.setCurrentItem(0, true);
    }

    private void onSignUpSuccess() {
        User user = component.currentUser().getUser();
        if (user != null && !user.verified()) {
            viewPager.setCurrentItem(1, true);
            String email = registerFragment.viewModel().outputs.signupEmail().getValue();
            if (StringUtils.isEmail(email)) {
                verifyEmailFragment.setEmail(email);
            }
            verifyEmailFragment.viewModel().inputs.startPolling();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        User user = component.currentUser().getUser();
        if (user != null && !user.verified()) {
            component.currentUser().logout();
        }
    }

    public void onSuccess() {
        setResult(Activity.RESULT_OK);
        finish();
    }

    public void showError(String err) {
        Toast.makeText(this, err, Toast.LENGTH_LONG).show();
    }

}
