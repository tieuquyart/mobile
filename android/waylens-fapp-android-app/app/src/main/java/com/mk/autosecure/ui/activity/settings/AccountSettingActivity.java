package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentTransaction;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.ui.fragment.AccountSettingFragment;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;

import butterknife.BindView;
import butterknife.ButterKnife;

public class AccountSettingActivity extends RxFragmentActivity {

    protected AppComponent component;

    private AccountSettingFragment accountSettingFragment;

    @BindView(R.id.frameLayout)
    FrameLayout frameLayout;

    public static void launch(Activity activity){
        Intent intent = new Intent(activity, AccountSettingActivity.class);
        activity.startActivity(intent);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setting_account);
        component = HornApplication.getComponent();
        ButterKnife.bind(this);
        accountSettingFragment = new AccountSettingFragment();
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(frameLayout.getId(), accountSettingFragment).commit();
    }
}
