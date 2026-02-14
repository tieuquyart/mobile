package com.mk.autosecure.ui.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;
import androidx.appcompat.widget.Toolbar;
import android.view.View;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.adapter.MyFragmentStatePagerAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.CustomViewPager;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.EmailInfo;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.fragment.ResetPasswordFragment;
import com.mk.autosecure.ui.fragment.TwoFactorFragment;
import com.mk.autosecure.ui.fragment.VerificationFragment;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/8.
 * Email: doanvt-hn@mk.com.vn
 */

public class ForgetPwdActivity extends RxFragmentActivity {
    public static final String TAG = ForgetPwdActivity.class.getSimpleName();

    public static void launch(Context context, String email) {
        Intent intent = new Intent(context, ForgetPwdActivity.class);
        if (StringUtils.isEmail(email)) {
            intent.putExtra(IntentKey.EMAIL, email);
        }
        context.startActivity(intent);
    }

    String mEmail = "";

    String mCode = "";

    AppComponent component;

    EmailInfo emailInfo;

    ViewPager.OnPageChangeListener mListener;

    ResetPasswordFragment resetPasswordFragment;
    VerificationFragment verificationFragment;
    TwoFactorFragment twoFactorFragment;

    List<Fragment> fragments = new ArrayList<>();

    @BindView(R.id.viewpager)
    CustomViewPager mViewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String email = getIntent().getStringExtra(IntentKey.EMAIL);
        setContentView(R.layout.activity_forget_password);
        ButterKnife.bind(this);
        setupToolbar();
        component = HornApplication.getComponent();

        emailInfo = component.emailInfo();

        MyFragmentStatePagerAdapter adapter = new MyFragmentStatePagerAdapter(getSupportFragmentManager());

        resetPasswordFragment = ResetPasswordFragment.createInstance(email);

        verificationFragment = new VerificationFragment();
        twoFactorFragment = new TwoFactorFragment();

        fragments.clear();
        fragments.add(resetPasswordFragment);
        fragments.add(verificationFragment);
        fragments.add(twoFactorFragment);

        resetPasswordFragment.setViewModel(this);
        verificationFragment.setViewModel(this);
        twoFactorFragment.setViewModel(this);

        setupWithComponents();

        adapter.addFragment(resetPasswordFragment);
        adapter.addFragment(verificationFragment);
        adapter.addFragment(twoFactorFragment);

        mListener = new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                Fragment fragment = fragments.get(position);
                if (fragment instanceof VerificationFragment) {
                    mEmail = resetPasswordFragment.viewModel().validEmail();
                    verificationFragment.viewModel().inputs.setEmail(mEmail);
                } else if (fragment instanceof TwoFactorFragment) {
                    mCode = verificationFragment.viewModel().validCode();
                    mEmail = resetPasswordFragment.viewModel().validEmail();
                    twoFactorFragment.viewModel().inputs.code(mCode);
                    twoFactorFragment.viewModel().inputs.email(mEmail);
                    Logger.t(TAG).d("email = " + mEmail);
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        };

        mViewPager.addOnPageChangeListener(mListener);

        mViewPager.setAdapter(adapter);
        //fetchUserProfile();
    }

    private void setupWithComponents() {
        resetPasswordFragment.viewModel()
                .outputs.resetSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(voidOptional -> {
                    String email = resetPasswordFragment.viewModel().validEmail();
                    emailInfo.refresh(new EmailInfo.Data(email, System.currentTimeMillis()));
                    verificationFragment.viewModel().inputs.setEmail(email);
                    mViewPager.setCurrentItem(1, true);
                }, new ServerErrorHandler());

        verificationFragment.viewModel()
                .outputs.isCodeValid()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(s -> {
                    String code = verificationFragment.viewModel().validCode();
                    String email = resetPasswordFragment.viewModel().validEmail();
                    twoFactorFragment.viewModel().inputs.code(code);
                    twoFactorFragment.viewModel().inputs.email(email);
                    mViewPager.setCurrentItem(2, true);
                }, new ServerErrorHandler());

        twoFactorFragment.viewModel()
                .outputs.resetSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(voidOptional -> {
                    /* mViewPager.setCurrentItem(2); */
                    component.currentUser().logout();
                    LoginActivity.launch(ForgetPwdActivity.this);
                    ForgetPwdActivity.this.finish();
                }, new ServerErrorHandler());

        Observable.merge(resetPasswordFragment.viewModel().outputs.stepBack(),
                verificationFragment.viewModel().outputs.stepBack(),
                twoFactorFragment.viewModel().outputs.stepBack())
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(Transformers.neverError())
                .subscribe(__ -> stepBack(), new ServerErrorHandler());
    }

    private void stepBack() {
        int current = mViewPager.getCurrentItem();
        if (current > 0) {
            mViewPager.setCurrentItem(current - 1, true);
        } else {
            finish();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        mViewPager.removeOnPageChangeListener(mListener);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    public void setupToolbar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    finish();
                }
            });
        }
    }
}