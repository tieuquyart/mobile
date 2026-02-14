package com.mk.autosecure.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.net.wifi.p2p.WifiP2pDevice;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.JsResult;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.app.AppCompatActivity;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.direct.WifiDirectConnection;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.NetworkUtils;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

import static com.mk.autosecure.ui.activity.LocalLiveActivity.GUIDE_SUBSCRIBE;

public class WebPlanActivity extends AppCompatActivity {

    private final static String TAG = WebPlanActivity.class.getSimpleName();
    private final static int WIFI_SETTING = 0;

    private final static String KEY_FINISH_TITLE = "Waylens - Data Plan";

    private String url;

    @BindView(R.id.toolbar)
    androidx.appcompat.widget.Toolbar toolbar;

    @BindView(R.id.va_web_plan)
    ViewAnimator va_web_plan;

    @BindView(R.id.tv_prompt)
    TextView tv_prompt;
    @BindView(R.id.btn_connect)
    Button btn_connect;

    @BindView(R.id.web_plan)
    WebView webView;

    @BindArray(R.array.web_url_list)
    String[] webServer;

    @OnClick(R.id.btn_connect)
    public void disConnect() {
        startActivityForResult(new Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), WIFI_SETTING);
    }

    public static void launch(Activity activity, String sn, boolean guide) {
        Intent intent = new Intent(activity, WebPlanActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        if (guide) {
            activity.startActivityForResult(intent, GUIDE_SUBSCRIBE);
        } else {
            activity.startActivity(intent);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_plan);
        ButterKnife.bind(this);

        String BASE_URL = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServer[webServer.length - 1]);

        String sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        url = BASE_URL + "/my/device/" + sn + "/4g_subscription";
        Logger.t(TAG).e("url: " + url);

        setupToolbar();

        WifiP2pDevice connectedDevice = WifiDirectConnection.getInstance().getConnectedDevice();
        Logger.t(TAG).d("connectedDevice: " + connectedDevice);
        if (NetworkUtils.inHotspotMode() && connectedDevice == null) {
            va_web_plan.setDisplayedChild(0);
            tv_prompt.setText(R.string.direct_disconnect_camera);
            btn_connect.setText(R.string.disconnect);
        } else {
            toolbar.setVisibility(View.GONE);
            va_web_plan.setDisplayedChild(2);
            setCookie(url);
            initWebView();
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
        TextView tv_toolbarTitle = findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText("");
        }
    }

    private void initWebView() {
        WebView.setWebContentsDebuggingEnabled(true);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                Logger.t(TAG).e("onPageStarted: " + url);
                super.onPageStarted(view, url, favicon);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Logger.t(TAG).e("shouldOverrideUrlLoading: " + url);
                view.loadUrl(url);
                return true;
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Logger.t(TAG).e("shouldOverrideUrlLoading: " + request.getUrl().toString());
                return super.shouldOverrideUrlLoading(view, request);
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Logger.t(TAG).e("onReceivedError: " + error.getDescription());
                }
                if (request.isForMainFrame()) {
                    toolbar.setVisibility(View.VISIBLE);
                    va_web_plan.setDisplayedChild(1);
                }
            }

            @Override
            public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
                super.onReceivedSslError(view, handler, error);
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {

            @Override
            public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
                Logger.t(TAG).e("onCreateWindow");
                return super.onCreateWindow(view, isDialog, isUserGesture, resultMsg);
            }

            @Override
            public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
                Logger.t(TAG).e("onJsAlert: " + message);
                return super.onJsAlert(view, url, message, result);
            }

            @Override
            public void onCloseWindow(WebView window) {
                Logger.t(TAG).e("onCloseWindow");
                super.onCloseWindow(window);
                finish();
            }
        });
        webView.loadUrl(url);
        webView.addJavascriptInterface(new JavaInterface(), "waylens");

        WebSettings settings = webView.getSettings();
        settings.setAllowContentAccess(true);
        settings.setAllowFileAccess(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);
        settings.setSupportMultipleWindows(true);
        settings.setJavaScriptEnabled(true);
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);
//        settings.setAppCacheEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setDatabaseEnabled(true);

        //自适应
        settings.setUseWideViewPort(true);
        settings.setLoadWithOverviewMode(true);

        String userAgentString = settings.getUserAgentString();
        userAgentString += "webview";
//        Logger.t(TAG).e("userAgent: " + userAgentString);
        settings.setUserAgentString(userAgentString);
    }


    public class JavaInterface {
        @JavascriptInterface
        public void back(boolean isClosed) {
            Logger.t(TAG).d("JavaInterface back: " + isClosed);
            runOnUiThread(() -> {
                if (webView.canGoBack() && !isClosed) {
                    webView.goBack();
                } else {
                    finish();
                }
            });
        }

        @JavascriptInterface
        public int getVersion() {
            return BuildConfig.VERSION_CODE;
        }
    }

    private void setCookie(String url) {
        try {
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.setAcceptCookie(true);
            cookieManager.removeSessionCookies(null);//移除
            //本地存储的token
            String token = HornApplication.getComponent().currentUser().getAccessToken();
//            Logger.t(TAG).e("token: " + token);

            String cookieValue = ("user-token=" + token);
//            Logger.t(TAG).e("cookie: " + cookieValue);

            cookieManager.setCookie(url, cookieValue);

            String cookie = cookieManager.getCookie(url);
//            Logger.t(TAG).e("getCookie: " + cookie);

            cookieManager.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        String title = webView.getTitle();
        Logger.t(TAG).d("title: " + title);
        if (KEY_FINISH_TITLE.equals(title)) {
            finish();
            return true;
        }

        if (keyCode == KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
            Logger.t(TAG).e("goBack");
            webView.goBack();
            return true;
        } else if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
            Logger.t(TAG).e("finish");
            finish();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        Logger.t(TAG).d("requestCode: " + requestCode + " resultCode: " + resultCode + " data: " + data);
        if (requestCode == WIFI_SETTING) {
            toolbar.setVisibility(View.GONE);
            va_web_plan.setDisplayedChild(2);
            setCookie(url);
            initWebView();
        }
    }
}
