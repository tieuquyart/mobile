package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.bean.UserProfile;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/11/16.
 * Email: doanvt-hn@mk.com.vn
 */

//chromium调试
public class WebViewActivity extends RxActivity {

    private final static String TAG = WebViewActivity.class.getSimpleName();

    private static String REQUEST_STRING = "request_code";

    public static final int PAGE_LICENSE = 0;
    public static final int PAGE_PRIVACY = 1;
    public static final int PAGE_TERMS_OF_USE = 2;
    public static final int PAGE_SUPPORT = 3;
    public static final int PAGE_FAQ = 4;
    public static final int PAGE_INSTALL = 5;
    public static final int PAGE_WATCH_VIDEO = 6;
    public static final int PAGE_CHAT = 7;
    public static final int PAGE_VIDEO_TUTORIALS = 8;
    public static final int PAGE_AGREEMENT = 9;
    public static final int PAGE_INSTALLER = 10;

    private int requestCode;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, WebViewActivity.class);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, int requestCode) {
        Intent intent = new Intent(activity, WebViewActivity.class);
        intent.putExtra(REQUEST_STRING, requestCode);
        activity.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tv_toolbarTitle;

    @BindView(R.id.agreement_web)
    WebView mWebView;

    @BindView(R.id.va_content)
    ViewAnimator va_root;

    @BindArray(R.array.web_url_list)
    String[] webServer;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        requestCode = intent.getIntExtra(REQUEST_STRING, 0);
        init();
    }

    protected void init() {
        initViews();
    }

    private void initViews() {
        setContentView(R.layout.activity_webview);
        ButterKnife.bind(this);
        mWebView.addJavascriptInterface(this, "android");

        WebSettings settings = mWebView.getSettings();
        settings.setUseWideViewPort(true);
        settings.setAllowFileAccess(true);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        settings.setPluginState(WebSettings.PluginState.ON);
        settings.setJavaScriptEnabled(true);

        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                if (request.isForMainFrame()) {
                    va_root.setDisplayedChild(1);
                }
            }

            @Override
            public void onPageCommitVisible(WebView view, String url) {
                super.onPageCommitVisible(view, url);
                if (requestCode == PAGE_CHAT) {
                    UserProfile userProfile = HornApplication.getComponent().currentUser().getProfile();
                    if (userProfile != null) {
                        String product = "Secure360";
                        String username = !TextUtils.isEmpty(userProfile.displayName) ? userProfile.displayName : userProfile.userName;
                        String account = userProfile.email;
                        String js = "javascript:setMetadata('" + product + "','" + username + "','" + account + "')";
                        //setMetadata('Secure360','\(username)','\(email)')
                        Logger.t(TAG).d("js: " + js);
                        view.loadUrl(js);
                    }
                }
            }
        });

        String BASE_URL = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServer[webServer.length - 1]);

        switch (requestCode) {
//            case PAGE_LICENSE:
//                mWebView.loadUrl("file:///android_asset/about/license.htm");
//                break;
//            case PAGE_PRIVACY:
//                mWebView.loadUrl("file:///android_asset/about/privacy.htm");
//                break;
//            case PAGE_TERMS_OF_USE:
//                mWebView.loadUrl("file:///android_asset/about/terms.htm");
//                break;
//            case PAGE_SUPPORT:
//                mWebView.loadUrl("file:///android_asset/guide/index.html");
//                break;
//            case PAGE_FAQ:
//                mWebView.loadUrl(BASE_URL + "/support/faq/28?webview=1");
//                break;
//            case PAGE_INSTALL:
//                mWebView.loadUrl(BASE_URL + "/support/faq/28/33/2938");
//                break;
//            case PAGE_WATCH_VIDEO:
//                mWebView.loadUrl(BASE_URL + "/support/faq/33/0/2938?webview=1");
//                break;
//            case PAGE_CHAT:
//                mWebView.loadUrl("file:///android_asset/chat.html");
//                break;
//            case PAGE_VIDEO_TUTORIALS:
//                mWebView.loadUrl(BASE_URL + "/support/guide/1?webview=1");
//                break;
//            case PAGE_AGREEMENT:
//                mWebView.loadUrl(BASE_URL + "/terms-share/raw.html");
//                break;
//            case PAGE_INSTALLER:
//                mWebView.loadUrl(BASE_URL + "/support/faq/28/100/4561");
//                break;
            default:
                break;
        }
        setupToolbar();

    }

    public void setupToolbar() {
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        switch (requestCode) {
            case PAGE_LICENSE:
                tv_toolbarTitle.setText(R.string.license_agreement);
                break;
            case PAGE_PRIVACY:
                tv_toolbarTitle.setText(R.string.privacy_policy);
                break;
            case PAGE_TERMS_OF_USE:
                tv_toolbarTitle.setText(R.string.terms_of_use);
                break;
            case PAGE_SUPPORT:
                break;
            case PAGE_FAQ:
            case PAGE_INSTALL:
            case PAGE_WATCH_VIDEO:
            case PAGE_INSTALLER:
                tv_toolbarTitle.setText(R.string.setting_item_faq);
                break;
            case PAGE_AGREEMENT:
                tv_toolbarTitle.setText(R.string.waylens_agreement);
                break;
            default:
                break;
        }
    }

    @JavascriptInterface
    public void close() {
        finish();
    }
}
