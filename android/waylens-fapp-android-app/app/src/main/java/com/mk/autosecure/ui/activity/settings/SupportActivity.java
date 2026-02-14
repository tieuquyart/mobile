package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.alibaba.android.arouter.launcher.ARouter;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.ui.activity.LocalLiveActivity;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 * Created by DoanVT on 2017/11/30.
 * Email: doanvt-hn@mk.com.vn
 */

public class SupportActivity extends RxActivity {
    private static final String TAG = SupportActivity.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.ll_faq)
    LinearLayout llFaq;

    @BindView(R.id.iv_show_1)
    ImageView iv_show_1;

    @BindView(R.id.ll_response_1)
    LinearLayout ll_response_1;

    @BindView(R.id.iv_show_2)
    ImageView iv_show_2;

    @BindView(R.id.ll_response_2)
    LinearLayout ll_response_2;

    @BindView(R.id.iv_show_3)
    ImageView iv_show_3;

    @BindView(R.id.ll_response_3)
    LinearLayout ll_response_3;

    @BindView(R.id.rl_get_help)
    RelativeLayout rlGetHelp;

    @BindView(R.id.rl_contact_support)
    RelativeLayout rlContactSupport;

    @BindView(R.id.rl_watch_support)
    RelativeLayout rlWatchSupport;

    @BindView(R.id.view_line)
    View viewLine;

    @BindView(R.id.view_shadow)
    View viewShadow;

    @OnClick(R.id.rl_start_tour)
    public void onTour() {
        //这里进入要进行全部流程
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_UI, true);
        PreferenceUtils.putBoolean(PreferenceUtils.KEY_TOUR_GUIDE_DIRECT, true);
        LocalLiveActivity.launchForGuide(this);
    }

    @OnClick(R.id.rl_power_cord)
    public void onDirectTest() {
        DirectTestActivity.launch(this, false);
    }

    @OnClick(R.id.rl_network_test)
    public void onNetworkTest() {
//        NetworkTestActivity.launch(this, false);
        ARouter.getInstance()
                .build("/ui/activity/settings/NetworkTestActivity")
                .withString("skipSelect", "Secure360")
                .navigation(this);
    }

    @OnClick(R.id.ll_faq_1)
    public void faq1() {
        if (ll_response_1.getVisibility() == View.VISIBLE) {
            rotateHide(iv_show_1);
            ll_response_1.setVisibility(View.GONE);
        } else {
            rotateShow(iv_show_1);
            ll_response_1.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.tv_watch_video)
    public void watchVideo() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_WATCH_VIDEO);
    }

    @OnClick(R.id.ll_faq_2)
    public void faq2() {
        if (ll_response_2.getVisibility() == View.VISIBLE) {
            rotateHide(iv_show_2);
            ll_response_2.setVisibility(View.GONE);
        } else {
            rotateShow(iv_show_2);
            ll_response_2.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.ll_faq_3)
    public void faq3() {
        if (ll_response_3.getVisibility() == View.VISIBLE) {
            rotateHide(iv_show_3);
            ll_response_3.setVisibility(View.GONE);
        } else {
            rotateShow(iv_show_3);
            ll_response_3.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.ll_get_more)
    public void getMore() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_FAQ);
    }

    @OnClick(R.id.rl_get_help)
    public void getHelp() {
        Uri uri = Uri.parse("https://forum.waylens.com");
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        startActivity(intent);
    }

    @OnClick(R.id.rl_contact_support)
    public void contactSupport() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_CHAT);
    }

    @OnClick(R.id.rl_report_issue)
    public void reportIssue() {
        FeedbackActivity.launch(this);
    }

    @OnClick(R.id.rl_watch_support)
    public void watchSupport() {
//        WebViewActivity.launch(this, WebViewActivity.PAGE_VIDEO_TUTORIALS);
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, SupportActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();
    }

    private void initViews() {
        setContentView(R.layout.activity_support);
        ButterKnife.bind(this);

        setupToolbar();

        if (Constants.isFleet()) {
            llFaq.setVisibility(View.GONE);
            rlGetHelp.setVisibility(View.GONE);
            rlContactSupport.setVisibility(View.GONE);
            rlWatchSupport.setVisibility(View.GONE);
            viewLine.setVisibility(View.GONE);
            viewShadow.setVisibility(View.GONE);
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.support));
        }
    }

    private void rotateHide(ImageView imageView) {
        RotateAnimation animation = new RotateAnimation(180f, 360f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        animation.setDuration(300);
        animation.setFillAfter(true);
        animation.setInterpolator(new LinearInterpolator());
        imageView.startAnimation(animation);
    }

    private void rotateShow(ImageView imageView) {
        RotateAnimation animation = new RotateAnimation(0f, 180f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        animation.setDuration(300);
        animation.setFillAfter(true);
        animation.setInterpolator(new LinearInterpolator());
        imageView.startAnimation(animation);
    }
}
