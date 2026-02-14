package com.mk.autosecure.ui.activity;

/**
 * Created by DoanVT on 2017/8/7.
 * Email: doanvt-hn@mk.com.vn
 */

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.eid.InitSdkActivity;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.DebugHelper;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.fragment.LoginFragment;
import com.mk.autosecure.ui.fragment.VerifyEmailFragment;
import com.mk.autosecure.ui.view.WrapContentViewPager;
import com.mk.autosecure.viewmodels.LoginViewModel;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;

import butterknife.BindString;
import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;

@SuppressLint({"CheckResult","MissingSuperCall","NonConstantResourceId"})
@RequiresActivityViewModel(LoginViewModel.ViewModel.class)
public final class LoginActivity extends BaseActivity<LoginViewModel.ViewModel> {
    private final static String TAG = LoginActivity.class.getSimpleName();
    public final static String KEY_EMAIL = "email";
    public final static int LOGIN_FLOW = 0x0001f;

    @BindView(R.id.viewpager)
    WrapContentViewPager viewPager;

    @BindString(R.string.login_buttons_forgot_password_html)
    String forgotPasswordString;
    @BindString(R.string.login_errors_does_not_match)
    String loginDoesNotMatchString;
    @BindString(R.string.login_errors_unable_to_log_in)
    String unableToLoginString;
    @BindString(R.string.log_in)
    String loginString;

    LoginFragment loginFragment;
    VerifyEmailFragment verifyEmailFragment;
    MyFragmentStatePagerAdapter adapter;

    private int mClickCount = 10;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, LoginActivity.class);
        activity.startActivity(intent);
    }

    public static void launchClearTask(Context activity) {
        Intent intent = new Intent(activity, LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
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

    AppComponent component;

    @Override
    protected void onCreate(final @Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        ButterKnife.bind(this);

        component = HornApplication.getComponent();
        adapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());
        loginFragment = new LoginFragment();
        loginFragment.setViewModel(this);

        verifyEmailFragment = new VerifyEmailFragment();
        verifyEmailFragment.setViewModel(this);

        adapter.addFragment(loginFragment);
        adapter.addFragment(verifyEmailFragment);
        viewPager.setAdapter(adapter);

        //check for login but not verified
//        onLoginSuccess();

        setupWithComponents();
    }

    private void setupWithComponents() {
        loginFragment.viewModel().outputs.loginSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> onLoginSuccess(), new ServerErrorHandler());

        verifyEmailFragment.viewModel()
                .outputs
                .stepBack()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> stepBackToRegister(), new ServerErrorHandler(TAG));

        verifyEmailFragment.viewModel().outputs.verifySuccess()
                .first(Optional.of(true))
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(booleanOptional -> launchLive(), new ServerErrorHandler());
    }

    /**
     * Lưu access-token khi login thành công
     * */
    private void onLoginSuccess() {
        if (Constants.isFleet()) {
            String accessToken = component.currentUser().getAccessToken();
            if (!TextUtils.isEmpty(accessToken)) {
                Logger.t(TAG).d("accessToken not null");
                launchLive();
            }
        }
    }

    private void stepBackToRegister() {
        component.currentUser().logout();
        loginFragment.clearEmailAndPassword();
        viewPager.setCurrentItem(0, true);
    }

    private void launchLive() {
        Logger.t(TAG).d("isCheckedMOC: " + loginFragment.isUseMoc);
        if (loginFragment.isUseMoc) {
            Intent intent = new Intent(this,InitSdkActivity.class);
            startActivity(intent);
        } else {
            finish();
            PreferenceUtils.putBoolean(Constants.KEY_IS_LOGIN, true);
            LocalLiveActivity.launch(this, true);
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

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode != LOGIN_FLOW) {
            return;
        }
        setResult(resultCode, intent);
        finish();
    }

    public void onSuccess() {
        setResult(Activity.RESULT_OK);
        finish();
    }

    private long mExitTime = 0;

    @Override
    public void onBackPressed() {
//        super.onBackPressed();
        if (System.currentTimeMillis() - mExitTime > 2000) {
            Toast.makeText(this, getString(R.string.double_click_exit), Toast.LENGTH_SHORT).show();
            mExitTime = System.currentTimeMillis();
        } else {
            Intent a = new Intent(Intent.ACTION_MAIN);
            a.addCategory(Intent.CATEGORY_HOME);
            a.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(a);
        }
    }
}