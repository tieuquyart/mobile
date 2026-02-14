package com.mk.autosecure.ui.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.waylens.preview.BitmapBuffer;
import com.waylens.preview.MjpegDecoder;
import com.waylens.preview.MjpegStream;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.texture.MD360BitmapTexture;

import java.lang.ref.WeakReference;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTouch;

import static com.mk.autosecure.libs.utils.ViewUtils.FULL_SCREEN_FLAG;

/**
 * Created by DoanVT on 2017/7/25.
 */


public class MJPEGPlayerActivity extends Activity {

    private static final String TAG = "MJPEGPlayerActivity";

    private MjpegStream mMjpegStream;

    private Bitmap mCurrentBitmap = null;

    private boolean mIsImmersive = false;

    private ControlPanelHandler mHandler = null;

    MD360BitmapTexture.Callback mCallback = null;

    private static final SparseArray<String> sProjectionMode = new SparseArray<>();

    static {

        sProjectionMode.put(MDVRLibrary.PROJECTION_MODE_DOME220_UPPER,"DOME 220 UPPER");
        sProjectionMode.put(CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS,"CUSTOM DOUBLE DIRECTIONS");

    }

    private MDVRLibrary mVRLibrary;


    public static void launch(Context context) {
        Intent intent = new Intent(context, MJPEGPlayerActivity.class);
        context.startActivity(intent);

    }

    @BindView(R.id.btnFullscreen)
    ImageButton mBtnFullscreen;

    private boolean isFullScreen() {
        int orientation = this.getRequestedOrientation();
        return orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
    }

    @BindView(R.id.control_panel)
    RelativeLayout mControlPanel;

    @BindView(R.id.media_window)
    FrameLayout mMediaWindow;


    @OnClick(R.id.btnFullscreen)
    public void onBtnFullscreenClicked() {
        if (!isFullScreen()) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            showControlPanel();
        } else {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }

    }

    @OnTouch(R.id.gl_view)
    public boolean onSurfaceClicked() {
        Logger.t(TAG).d("media window clicked");
        showControlPanel();
        return false;
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // set content view
        setContentView(R.layout.fragment_preview);
        ButterKnife.bind(this);

        mHandler = new ControlPanelHandler(this);

        // init VR Library
        mVRLibrary = createVRLibrary();

        SpinnerHelper.with(this)
                .setData(sProjectionMode)
                .setDefault(mVRLibrary.getProjectionMode())
                .setClickHandler(new SpinnerHelper.ClickHandler() {
                    @Override
                    public void onSpinnerClicked(int index, int key, String value) {
                        mVRLibrary.switchProjectionMode(MJPEGPlayerActivity.this, key);
                    }
                })
                .init(R.id.spinner_projection);
    }

    synchronized private void loadMJPEG(MD360BitmapTexture.Callback callback) {
//        Logger.t(TAG).d("load image with max texture size:" + callback.getMaxTextureSize());
        mCallback = callback;
        try {
            if (mMjpegStream == null) {
                startStream(new InetSocketAddress(InetAddress.getByName("192.168.110.1"), 8081));
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
    }

    protected MDVRLibrary createVRLibrary() {
        return MDVRLibrary.with(this)
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asBitmap(new MDVRLibrary.IBitmapProvider() {
                    @Override
                    public void onProvideBitmap(final MD360BitmapTexture.Callback callback) {
                        loadMJPEG(callback);
                    }
                })
                .pinchEnabled(true)
                .projectionFactory(new CustomProjectionFactory())
                .build((GLSurfaceView) findViewById(R.id.gl_view));
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mVRLibrary.onOrientationChanged(this);
        if (isFullScreen()) {
            mBtnFullscreen.setBackgroundResource(R.drawable.playbar_screen_narrow_n);
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(64));
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            mControlPanel.setLayoutParams(params);

        } else {
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewUtils.dp2px(64));
            params.addRule(RelativeLayout.BELOW, mMediaWindow.getId());
            mControlPanel.setLayoutParams(params);
            mBtnFullscreen.setBackgroundResource(R.drawable.playbar_screen_full);
        }
        setImmersiveMode(isFullScreen());
    }

    public MDVRLibrary getVRLibrary() {
        return mVRLibrary;
    }

    public void startStream(final InetSocketAddress serverAddr) {
        mMjpegStream = new MyMjpegStream();
        mMjpegStream.start(serverAddr);

    }

    public void stopStream() {

        mMjpegStream.stop();

    }

    class MyMjpegStream extends MjpegStream {

        @Override
        protected void onBitmapReadyAsync(MjpegDecoder decoder, MjpegStream stream) {
            BitmapBuffer bb = stream.getOutputBitmapBuffer(decoder);
            if (bb != null) {
                mCurrentBitmap = bb.getBitmap();
                Logger.t(TAG).d("loaded image, size:" + mCurrentBitmap.getWidth() + "," + mCurrentBitmap.getHeight());

                // notify if size changed
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        getVRLibrary().onTextureResize(mCurrentBitmap.getWidth(), mCurrentBitmap.getHeight());
                        // texture
                        mCallback.texture(mCurrentBitmap);
                        cancelBusy();
                    }
                });
            }
        }

        @Override
        protected void onEventAsync(MjpegDecoder decoder, MjpegStream stream) {
        }

        @Override
        protected void onIoErrorAsync(MjpegStream stream, final int error) {

        }

    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mVRLibrary.onResume(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        stopStream();
        mVRLibrary.onPause(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mVRLibrary.onDestroy();
    }

    public void setImmersiveMode(boolean immersiveMode) {
        if (immersiveMode) {
            getWindow().getDecorView().setSystemUiVisibility(FULL_SCREEN_FLAG);
            mIsImmersive = true;
        } else {
            getWindow().getDecorView().setSystemUiVisibility(
                    0);
            mIsImmersive = false;
        }
    }

    protected Uri getUri() {
        Intent i = getIntent();
        if (i == null || i.getData() == null){
            return null;
        }
        return i.getData();
    }

    public void cancelBusy(){
        findViewById(R.id.progress).setVisibility(View.GONE);
    }

    public void busy(){
        findViewById(R.id.progress).setVisibility(View.VISIBLE);
    }

    private void hideControlPanel() {
        mControlPanel.setVisibility(View.GONE);
    }

    private void showControlPanel() {
        if (mControlPanel == null) {
            return;
        }
        Logger.t(TAG).d("show ControlPanel");
        mControlPanel.setVisibility(View.VISIBLE);
        mHandler.removeMessages(MJPEGPlayerActivity.ControlPanelHandler.FADE_OUT);
        mHandler.sendMessageDelayed(mHandler.obtainMessage(MJPEGPlayerActivity.ControlPanelHandler.FADE_OUT), 3000);
    }


    private static class ControlPanelHandler extends Handler {
        private WeakReference<MJPEGPlayerActivity> mRef;
        public static final int FADE_OUT = 0x01;

        ControlPanelHandler(MJPEGPlayerActivity activity) {
            super();
            mRef = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            MJPEGPlayerActivity activity = mRef.get();
            if (activity == null) {
                return;
            }
            Logger.t(TAG).d("handle message");
            switch (msg.what) {
                case FADE_OUT:
                    try {
                        if (activity.isFullScreen()) {
                            activity.hideControlPanel();
                            activity.setImmersiveMode(true);
                        }
                    } catch (Exception e) {
                        Logger.t(TAG).d("fragment is be GCed!");
                    }
                    break;
                default:
                    break;
            }
        }
    }

}
