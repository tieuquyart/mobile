package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.content.res.AssetManager;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.net.Uri;
import android.view.Surface;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Map;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;
import tv.danmaku.ijk.media.player.misc.IMediaDataSource;

/**
 * Created by DoanVT on 2017/8/2.
 */
public class MediaPlayerWrapper implements IMediaPlayer.OnPreparedListener {

    public static final String TAG = MediaPlayerWrapper.class.getSimpleName();

    public static final int STATUS_IDLE = 0;
    public static final int STATUS_PREPARING = 1;
    public static final int STATUS_PREPARED = 2;
    public static final int STATUS_STARTED = 3;
    public static final int STATUS_PAUSED = 4;
    public static final int STATUS_STOPPED = 5;

    private IjkMediaPlayer mMediaPlayer;

    private IjkMediaPlayer.OnPreparedListener mPreparedListener;

    private int mStatus = STATUS_IDLE;

    private boolean isLive = false;

    public MediaPlayerWrapper() {
        this(false);
    }

    public MediaPlayerWrapper(boolean isLive) {
        this.isLive = isLive;
        mStatus = STATUS_IDLE;
        mMediaPlayer = new IjkMediaPlayer();
    }

    public void init() {
        mMediaPlayer.setOnPreparedListener(this);
        mMediaPlayer.setOnInfoListener(new IMediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(IMediaPlayer mp, int what, int extra) {
                return false;
            }
        });
        if (isHardwareDecodingSupported()) {
            Logger.t(TAG).d("isHardwareDecodingSupported");
            enableHardwareDecoding();
        }
        IjkMediaPlayer player = (IjkMediaPlayer) mMediaPlayer;
        if (isLive) {
            // Param for living
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", 2000);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 0);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fflags", "nobuffer");

            //network
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_queue_size", 10 * 1024 * 1024);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", 3);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "probsize", "4096");
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", "2000000");

            //waylens
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "probesize", 500 * 1024);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "probesize", 500 * 1024);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "formatprobesize", 200 * 1024);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fpsprobesize", 5);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-buffer-size", 500 * 1024);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "max_ts_probe", 200 * 1024);
        } else {
            // Param for playback
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", 4000);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", 0);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 1);

            //设置支持跳转非关键帧
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", 1);
        }
    }

    /**
     * 判断是否支持解码video/avc格式下的2K视频数据
     *
     * @return
     */
    private boolean isHardwareDecodingSupported() {
        boolean isSupported = false;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            MediaCodecList mediaCodecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
            MediaCodecInfo[] codecInfoList = mediaCodecList.getCodecInfos();
            for (MediaCodecInfo codecInfo : codecInfoList) {
                boolean isEncoder = codecInfo.isEncoder();
                String type = "video/avc";
                for (String ty : codecInfo.getSupportedTypes()) {
                    //Logger.t(TAG).d(ty);
                }
                if (!isEncoder && Arrays.asList(codecInfo.getSupportedTypes()).contains(type)) {
                    try {
                        MediaCodecInfo.CodecCapabilities capabilitiesForType = codecInfo.getCapabilitiesForType(type);
                        //Logger.t(TAG).d("default format = " + capabilitiesForType.getDefaultFormat().toString());

                        // get video capabilities
//                        Logger.t(TAG).d("video capabilities");
                        MediaCodecInfo.VideoCapabilities videoCapabilities = capabilitiesForType.getVideoCapabilities();
                        if (videoCapabilities != null) {
//                            Logger.t(TAG).v("SupportedHeights = " + videoCapabilities.getSupportedHeights());
//                            Logger.t(TAG).v("SupportedWidths = " + videoCapabilities.getSupportedWidths());

                            isSupported = isSupported || videoCapabilities.getSupportedHeights().contains(2048);
                            //Logger.t(TAG).d("check if the given media type support certain heights, such 2048px, " + "isSupported = " + isSupported);
                            if (isSupported) {
                                break;
                            }
                        }
                    } catch (IllegalArgumentException e) {
                        Logger.t(TAG).e(e.getMessage());
                    }
                }
            }
        }
        return isSupported;
    }

    private void enableHardwareDecoding() {
        if (mMediaPlayer != null) {
            IjkMediaPlayer player = mMediaPlayer;
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec-all-videos", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec-auto-rotate", 1);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "overlay-format", IjkMediaPlayer.SDL_FCC_RV32);

            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", 60);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-fps", 0);
            player.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", 48);
        }
    }

    public void setSurface(Surface surface) {
        if (getPlayer() != null) {
            getPlayer().setSurface(surface);
        }
    }

    public void setVolume(float volume) {
        if (getPlayer() != null) {
            getPlayer().setVolume(volume, volume);
        }
    }

    public void openRemoteFile(String url) {
        try {
            mMediaPlayer.setDataSource(url);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void openRemoteFileWithCookie(String url) {
        try {
            Map<String, String> cookie = CookieUtil.getCookie();
            mMediaPlayer.setDataSource(HornApplication.getContext(), Uri.parse(url), cookie);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void openAssetFile(Context context, String assetPath) {
        try {
            AssetManager am = context.getResources().getAssets();
            final InputStream is = am.open(assetPath);
            mMediaPlayer.setDataSource(new IMediaDataSource() {
                @Override
                public int readAt(long position, byte[] buffer, int offset, int size) throws IOException {
                    return is.read(buffer, offset, size);
                }

                @Override
                public long getSize() throws IOException {
                    return is.available();
                }

                @Override
                public void close() throws IOException {
                    is.close();
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public IMediaPlayer getPlayer() {
        return mMediaPlayer;
    }

    public int getStatus() {
        return mStatus;
    }

    public void prepare() {
        if (mMediaPlayer == null) return;
        if (mStatus == STATUS_IDLE || mStatus == STATUS_STOPPED) {
            mMediaPlayer.prepareAsync();
            mStatus = STATUS_PREPARING;
        }
    }

    public void stop() {
        if (mMediaPlayer == null) return;
        if (mStatus == STATUS_STARTED || mStatus == STATUS_PAUSED) {
            mMediaPlayer.stop();
            mStatus = STATUS_STOPPED;
        }
    }

    public void pause() {
        if (mMediaPlayer == null) return;
        if (mMediaPlayer.isPlaying() && mStatus == STATUS_STARTED) {
            mMediaPlayer.pause();
            mStatus = STATUS_PAUSED;
        }
    }

    private void start() {
        if (mMediaPlayer == null) return;
        if (mStatus == STATUS_PREPARED || mStatus == STATUS_PAUSED) {
            mMediaPlayer.start();
            mStatus = STATUS_STARTED;
        }
    }

    public void setPreparedListener(IMediaPlayer.OnPreparedListener mPreparedListener) {
        this.mPreparedListener = mPreparedListener;
    }

    @Override
    public void onPrepared(IMediaPlayer mp) {
        mStatus = STATUS_PREPARED;
        start();
        if (mPreparedListener != null) mPreparedListener.onPrepared(mp);
    }

    public void resume() {
        start();
    }

    public void destroy() {
        stop();
        if (mMediaPlayer != null) {
//            mMediaPlayer.setSurface(null);
            mMediaPlayer.release();
        }
        mMediaPlayer = null;
    }
}
