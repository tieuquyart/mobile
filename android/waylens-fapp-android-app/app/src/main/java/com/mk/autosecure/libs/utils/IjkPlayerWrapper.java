package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaPlayer;
import android.net.Uri;
import android.view.Surface;

import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.util.Arrays;
import java.util.Map;

import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

public class IjkPlayerWrapper implements IMediaPlayer.OnPreparedListener, IMediaPlayer.OnCompletionListener,
        IMediaPlayer.OnErrorListener, IMediaPlayer.OnSeekCompleteListener,
        IMediaPlayer.OnInfoListener, IMediaPlayer.OnVideoSizeChangedListener {

    public static final String TAG = IjkPlayerWrapper.class.getSimpleName();

    private static final int STATE_ERROR = -1;
    private static final int STATE_IDLE = 0;
    private static final int STATE_PREPARING = 1;
    private static final int STATE_PREPARED = 2;
    private static final int STATE_PLAYING = 3;
    private static final int STATE_PAUSED = 4;
    private static final int STATE_PLAYBACK_COMPLETED = 5;

    private int mCurrentState;

    private Context mContext;
    private IMediaPlayer mMediaPlayer = null;

    private IMediaPlayer.OnVideoSizeChangedListener mOnVideoSizeChangedListener;
    private IMediaPlayer.OnCompletionListener mOnCompletionListener;
    private IMediaPlayer.OnPreparedListener mOnPreparedListener;
    private IMediaPlayer.OnErrorListener mOnErrorListener;
    private IMediaPlayer.OnInfoListener mOnInfoListener;

    public IjkPlayerWrapper(Context context) {
        this.mContext = context;
        mCurrentState = STATE_IDLE;
    }

    private IMediaPlayer createPlayer(boolean isLiveState) {
        IjkMediaPlayer mediaPlayer = new IjkMediaPlayer();
        if (isHardwareDecodingSupported()) {
            enableHardwareDecoding();
        }

        if (isLiveState) {
            // Param for living
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", 2000);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", 1);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 0);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fflags", "nobuffer");

            //network
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_queue_size", 10 * 1024 * 1024);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", 1);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", 3);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "probsize", "4096");
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", "2000000");

            //waylens
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "probesize", 500 * 1024);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "probesize", 500 * 1024);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "formatprobesize", 200 * 1024);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fpsprobesize", 5);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-buffer-size", 500 * 1024);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", 1);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "max_ts_probe", 200 * 1024);
        } else {
            // Param for playback
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", 4000);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", 0);
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 1);

            //设置支持跳转非关键帧
            mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", 1);
        }
        return mediaPlayer;
    }

    /**
     * 判断是否支持解码video/avc格式下的2K视频数据
     */
    private boolean isHardwareDecodingSupported() {
        boolean isSupported = false;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            MediaCodecList mediaCodecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
            MediaCodecInfo[] codecInfoList = mediaCodecList.getCodecInfos();
            for (MediaCodecInfo codecInfo : codecInfoList) {
                boolean isEncoder = codecInfo.isEncoder();
                String type = "video/avc";
                if (!isEncoder && Arrays.asList(codecInfo.getSupportedTypes()).contains(type)) {
                    try {
                        MediaCodecInfo.CodecCapabilities capabilitiesForType = codecInfo.getCapabilitiesForType(type);
                        MediaCodecInfo.VideoCapabilities videoCapabilities = capabilitiesForType.getVideoCapabilities();
                        if (videoCapabilities != null) {
                            isSupported = videoCapabilities.getSupportedHeights().contains(2048);
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
            IjkMediaPlayer player = (IjkMediaPlayer) mMediaPlayer;
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
        if (mMediaPlayer != null) {
            mMediaPlayer.setSurface(surface);
        }
    }

    public void setVolume(float volume) {
        if (mMediaPlayer != null) {
            mMediaPlayer.setVolume(volume, volume);
        }
    }

    public int getCurrentState() {
        return mCurrentState;
    }

    public synchronized void openVideoUrl(boolean isLiveState, String url) {
        try {
            Logger.t(TAG).e("DEBUG openVideoUrl: " + mMediaPlayer);
            release();
            mMediaPlayer = createPlayer(isLiveState);

            mMediaPlayer.setOnSeekCompleteListener(this);
            mMediaPlayer.setOnCompletionListener(this);
            mMediaPlayer.setOnPreparedListener(this);
            mMediaPlayer.setOnErrorListener(this);
            mMediaPlayer.setOnInfoListener(this);

            if (isLiveState) {
                mMediaPlayer.setDataSource(url);
            } else {
                Map<String, String> cookie = CookieUtil.getCookie();
                mMediaPlayer.setDataSource(mContext, Uri.parse(url), cookie);
            }

            mMediaPlayer.setScreenOnWhilePlaying(true);
            mMediaPlayer.prepareAsync();
            mCurrentState = STATE_PREPARING;
        } catch (IOException ex) {
            Logger.t(TAG).e("openVideoUrl exception: " + ex.getMessage());
            mCurrentState = STATE_ERROR;
            mOnErrorListener.onError(mMediaPlayer, MediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
        }
    }

    public synchronized void stop() {
        Logger.t(TAG).d("DEBUG STOP into: " + mMediaPlayer);
        if (mMediaPlayer != null) {
            Logger.t(TAG).e("DEBUG STOP release start");
            mMediaPlayer.stop();
            mMediaPlayer.release();
            Logger.t(TAG).e("DEBUG STOP release done");
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
        }
    }

    public void pause() {
        if (isInPlaybackState() && mMediaPlayer.isPlaying()) {
            mMediaPlayer.pause();
            mCurrentState = STATE_PAUSED;
        }
    }

    public void resume() {
        start();
    }

    public int getDuration() {
        if (isInPlaybackState()) {
            return (int) mMediaPlayer.getDuration();
        }

        return -1;
    }

    public int getCurrentPosition() {
        if (isInPlaybackState()) {
            return (int) mMediaPlayer.getCurrentPosition();
        }
        return 0;
    }

    public void seekTo(int msec) {
        if (isInPlaybackState()) {
            mMediaPlayer.seekTo(msec);
        }
    }

    public boolean isPlaying() {
        return isInPlaybackState() && mMediaPlayer.isPlaying();
    }

    private void start() {
        if (isInPlaybackState()) {
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
        }
    }

    private boolean isInPlaybackState() {
        return (mMediaPlayer != null &&
                mCurrentState != STATE_ERROR &&
                mCurrentState != STATE_IDLE &&
                mCurrentState != STATE_PREPARING);
    }

    //release the media player in any state
    public synchronized void release() {
        Logger.t(TAG).d("DEBUG RELEASE into: " + mMediaPlayer);
        if (mMediaPlayer != null) {
            Logger.t(TAG).e("DEBUG RELEASE release start");
            mMediaPlayer.reset();
            mMediaPlayer.release();
            Logger.t(TAG).e("DEBUG RELEASE release done");
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
        }
    }

    public void setPreparedListener(IMediaPlayer.OnPreparedListener mPreparedListener) {
        this.mOnPreparedListener = mPreparedListener;
    }

    public void setCompletionListener(IMediaPlayer.OnCompletionListener mCompletionListener) {
        this.mOnCompletionListener = mCompletionListener;
    }

    public void setErrorListener(IMediaPlayer.OnErrorListener mErrorListener) {
        this.mOnErrorListener = mErrorListener;
    }

    public void setVideoSizeChangedListener(IMediaPlayer.OnVideoSizeChangedListener mVideoSizeChangedListener) {
        this.mOnVideoSizeChangedListener = mVideoSizeChangedListener;
    }

    public void setInfoListener(IMediaPlayer.OnInfoListener mInfoListener) {
        this.mOnInfoListener = mInfoListener;
    }

    @Override
    public void onPrepared(IMediaPlayer mp) {
        mCurrentState = STATE_PREPARED;
        if (mMediaPlayer != null && mOnPreparedListener != null) {
            mOnPreparedListener.onPrepared(mp);
        }
        start();
    }

    @Override
    public void onCompletion(IMediaPlayer iMediaPlayer) {
        mCurrentState = STATE_PLAYBACK_COMPLETED;

        if (mMediaPlayer != null && mOnCompletionListener != null) {
            mOnCompletionListener.onCompletion(iMediaPlayer);
        }
    }

    @Override
    public boolean onError(IMediaPlayer iMediaPlayer, int i, int i1) {
        mCurrentState = STATE_ERROR;

        if (mMediaPlayer != null && mOnErrorListener != null) {
            mOnErrorListener.onError(iMediaPlayer, i, i1);
        }
        return true;
    }

    @Override
    public void onSeekComplete(IMediaPlayer iMediaPlayer) {
        // do something
    }

    @Override
    public boolean onInfo(IMediaPlayer iMediaPlayer, int i, int i1) {
        if (mMediaPlayer != null && mOnInfoListener != null) {
            mOnInfoListener.onInfo(iMediaPlayer, i, i1);
        }
        return true;
    }

    @Override
    public void onVideoSizeChanged(IMediaPlayer iMediaPlayer, int i, int i1, int i2, int i3) {
        if (mMediaPlayer != null && mOnVideoSizeChangedListener != null) {
            mOnVideoSizeChangedListener.onVideoSizeChanged(iMediaPlayer, i, i1, i2, i3);
        }
    }
}
