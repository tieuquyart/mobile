package com.mk.autosecure.ui.activity;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.text.format.DateUtils;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.customview.widget.ViewDragHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.mk.autosecure.ui.adapter.ScaleAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.DragViewGroup;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.model.PlaybackUrl;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.DateTime;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.MediaPlayerWrapper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipPosChangeEvent;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.viewmodels.ScaleActivityViewModel;
import com.waylens.vrlib.MDVRLibrary;
import com.waylens.vrlib.model.BarrelDistortionConfig;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.internal.functions.Functions;
import io.reactivex.schedulers.Schedulers;
import tv.danmaku.ijk.media.player.IMediaPlayer;
@SuppressLint("CheckResult")
@RequiresActivityViewModel(ScaleActivityViewModel.ViewModel.class)
public class ScaleActivity extends BaseActivity<ScaleActivityViewModel.ViewModel> implements DragViewGroup.DragCallback {

    private static final String TAG = ScaleActivity.class.getSimpleName();

    private static final String CLIP = "clip";
    private static final String CLIPPOS = "clippos";
    private static final String CHOICE = "choice";
    private static final String STREAM = "stream";
    private static final int thumbnailHeight = ViewUtils.dp2px(56);
    private ClipPos mClipPos = null;

    private Clip clip;
    private ClipPos markClipPos;

    private int exportChoice = -1;

    private int mStreamIndex = 0;

    private CameraWrapper mCamera;

    private MediaPlayerWrapper mMediaPlayerWrapper = new MediaPlayerWrapper(false);

    private boolean isForeground = true;

    private MDVRLibrary mVRVideoLibrary;

    private LinearLayoutManager timelineLayoutManager;

    private ScaleAdapter scaleAdapter;

    private List<Clip> clipList = new ArrayList<>();
    //实际取thumbnail的间隔秒数
    private double pow;
    //时间轴的高度（包括margin）
    private int HEIGHT_TOTAL;
    //初始dragView的最小高度
    private int initMargin = ViewUtils.dp2px(70);

    //相对于clip的startTime的offset 毫秒
    private long offset = 0;
    //当前scale的播放时长 毫秒
    private int duration = 0;

    private boolean scrollToBorder = false;

    private long totalOffset = 0;

    private ObjectAnimator animator;

    private boolean firstInit = true;

    private boolean notSetTime = false;

    private long startTime;
    private long endTime;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.gl_view)
    GLSurfaceView gl_view;

    @BindView(R.id.btnPlayPause)
    ImageButton btnPlayPause;

    @BindView(R.id.rl_scale)
    RelativeLayout rl_scale;

    @BindView(R.id.rv_timeline)
    RecyclerView rv_timeline;

    @BindView(R.id.dragView)
    DragViewGroup dragView;

    @BindView(R.id.tv_scale_style)
    TextView tv_scale_style;

    @BindView(R.id.tv_scale_duration)
    TextView tv_scale_duration;

    @BindView(R.id.btn_ensure_scale)
    ImageButton btn_ensure_scale;

    @BindView(R.id.tv_top_time)
    TextView tv_top_time;
    @BindView(R.id.tv_btm_time)
    TextView tv_btm_time;

    @BindView(R.id.viewLine)
    View viewLine;

    @BindView(R.id.cl_export_confirm)
    ConstraintLayout cl_export_confirm;

    public static void launch(Context context, Clip clip, ClipPos clipPos, String sn, int choice, VideoStreamType streamType) {
        Intent i = new Intent(context, ScaleActivity.class);
        i.putExtra(CLIP, clip);
        i.putExtra(CLIPPOS, clipPos);
        i.putExtra(IntentKey.SERIAL_NUMBER, sn);
        i.putExtra(CHOICE, choice);
        i.putExtra(STREAM, streamType);
        context.startActivity(i);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_scale);
        ButterKnife.bind(this);

        cancelBusy();
        setToolbar();

        Bundle extras = getIntent().getExtras();

        if (extras != null) {
            clip = (Clip) extras.getSerializable(CLIP);
            markClipPos = (ClipPos) extras.getSerializable(CLIPPOS);
            String sn = extras.getString(IntentKey.SERIAL_NUMBER);
            mCamera = TextUtils.isEmpty(sn) ? VdtCameraManager.getManager().getCurrentCamera() : VdtCameraManager.getManager().getCamera(sn);
            exportChoice = extras.getInt(CHOICE);
            VideoStreamType streamType = (VideoStreamType) extras.getSerializable(STREAM);
            if (clip != null && streamType != null) {
                mStreamIndex = clip.getDescriptionIndex(streamType);
            }
//            mStreamIndex = extras.getSerializable(STREAM);
        }

        Logger.t(TAG).d("mStreamIndex: " + mStreamIndex);

        if (clip == null) {
            Logger.t(TAG).e("clip == null !!!");
            finish();
            return;
        }

        mVRVideoLibrary = createVideoVRLibrary();

        RxBus.getDefault().toObservable(CameraConnectionEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCameraConnectionEvent);

        RxBus.getDefault().toObservable(ClipPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipPosChangeEvent, new ServerErrorHandler());

        Observable.interval(0, 500, TimeUnit.MILLISECONDS)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::checkProgress, new ServerErrorHandler());

        clipList.add(clip);

        rl_scale.post(new Runnable() {
            @Override
            public void run() {
                HEIGHT_TOTAL = rl_scale.getHeight();

                computeDragMargin();

                Logger.t(TAG).e("HEIGHT_TOTAL: " + HEIGHT_TOTAL + "--" + thumbnailHeight + "--" + initMargin + "--" + clip.getDurationMs());
                dragView.adjustHeight(initMargin);
                scaleAdapter.setMargin((HEIGHT_TOTAL - thumbnailHeight) / 2);
                scaleAdapter.setClipList(clipList, (int) (pow * (clip.getVideoType() == VideoEventType.TYPE_BUFFERED ? 1 : 8)));

                if (markClipPos != null) {

                    int clipPosIndex = scaleAdapter.getClipPosIndex(markClipPos, clip);
                    Logger.t(TAG).e("clipPosIndex: " + clipPosIndex);

                    ClipPos curClipPos = (ClipPos) scaleAdapter.getViewItemObjectAt(clipPosIndex);
                    long subTime = markClipPos.getClipTimeMs() - (curClipPos.getClipTimeMs() - clip.getStartTimeMs());
                    Logger.t(TAG).e("subTime: " + subTime);
                    ClipPos tempClipPos = (ClipPos) scaleAdapter.getViewItemObjectAt(clipPosIndex - 1);
                    Logger.t(TAG).e("tempClipPos: " + tempClipPos);
                    double percent;
                    if (tempClipPos != null) {
                        long totalTime = tempClipPos.getClipTimeMs() - curClipPos.getClipTimeMs();
                        Logger.t(TAG).e("totalTime: " + totalTime);
                        percent = 1 - (double) subTime / totalTime;
                        Logger.t(TAG).e("percent: " + percent);
                    } else {
                        long totalTime = clip.getEndTimeMs() - curClipPos.getClipTimeMs();
                        Logger.t(TAG).e("totalTime: " + totalTime);
                        percent = 1 - (double) subTime / totalTime;
                        Logger.t(TAG).e("percent: " + percent);
                    }

                    //最大移动距离
                    int max = (timelineLayoutManager.getItemCount() - 2) * thumbnailHeight + (HEIGHT_TOTAL - thumbnailHeight) / 2 - (HEIGHT_TOTAL - initMargin);
                    //最小移动距离
                    int min = (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin;
                    //预计移动距离
                    int move = (clipPosIndex - 1) * thumbnailHeight + (HEIGHT_TOTAL - thumbnailHeight) / 2 - (int) (HEIGHT_TOTAL / 2 - percent * thumbnailHeight);
                    Logger.t(TAG).e("max: " + max);
                    Logger.t(TAG).e("min: " + min);
                    Logger.t(TAG).e("move: " + move);
                    if (move > max) {
                        timelineLayoutManager.scrollToPositionWithOffset(timelineLayoutManager.getItemCount() - 2,
                                HEIGHT_TOTAL - initMargin - thumbnailHeight);
                    } else if (move < min) {
                        timelineLayoutManager.scrollToPositionWithOffset(1,
                                initMargin);
                    } else {
                        timelineLayoutManager.scrollToPositionWithOffset(clipPosIndex,
                                (int) (HEIGHT_TOTAL / 2 - percent * thumbnailHeight));
                    }
                } else {
                    timelineLayoutManager.scrollToPositionWithOffset(timelineLayoutManager.getItemCount() - 2,
                            HEIGHT_TOTAL - initMargin - thumbnailHeight);
                }
                postClipPosChangeEvent();
            }
        });

        timelineLayoutManager = new LinearLayoutManager(this);
        scaleAdapter = new ScaleAdapter(this);
        rv_timeline.setLayoutManager(timelineLayoutManager);
        rv_timeline.setAdapter(scaleAdapter);

        dragView.setDragCallback(this, rv_timeline);

        //滑动联动处理
        rv_timeline.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                Logger.t(TAG).e("onScrollStateChanged: " + newState);
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {

                    //回弹效果
                    //这里获取的是可见视图的第一个
                    View firstView = rv_timeline.getChildAt(0);
                    int firstOffset = firstView.getBottom() - dragView.getTopLine(false);
                    Logger.t(TAG).e("--" + firstView.getBottom() + "--" + dragView.getTopLine(false) + "--" + firstOffset);
                    if (firstOffset > 0) {
                        rv_timeline.scrollBy(0, firstOffset);
                    }

                    //这里获取的是可见视图的最后一个
                    View lastView = rv_timeline.getChildAt(rv_timeline.getChildCount() - 1);
                    int lastOffset = lastView.getTop() - dragView.getBottomLine(false);
                    Logger.t(TAG).e("--" + lastView.getTop() + "--" + dragView.getBottomLine(false) + "--" + lastOffset);
                    if (lastOffset < 0) {
                        rv_timeline.scrollBy(0, lastOffset);
                    }

                    //1.回滚到起点

                    //2.滑动到别的clipPos,刷新播放
                    postClipPosChangeEvent();

                } else {
                    if (mMediaPlayerWrapper != null) {
                        mMediaPlayerWrapper.pause();
                    }
                }
            }

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                //dy > 0 向上移动  dy < 0 向下移动
                Logger.t(TAG).e("onScrolled: " + "dx: " + dx + " dy: " + dy);

                //底部是起点
                totalOffset -= dy;
//                setScaleTime(totalOffset);

                //1.获得当前ClipPos，刷新时间

                //2.Post ClipPosChangeEvent：当滑动结束静止时，刷新播放视频；当滑动中，刷新播放缩略图

                if (dx == 0 && dy == 0) {
                    if (firstInit) {
                        firstInit = false;
                        setPlayTime(getCurrentOffset(dragView.getBottomLine(true), false),
                                getCurrentOffset(dragView.getTopLine(true), true));
                    }
                } else {
                    if (!notSetTime) {
                        switch (dragView.SCROLL_STYLE) {
                            case DragViewGroup.TOP_BUTTON_SCROLL:
                                setEndTime(getCurrentOffset(dragView.getTopLine(false), true));
                                setDuration();
                                break;
                            case DragViewGroup.NO_BUTTON_SCROLL:
                                setPlayTime(getCurrentOffset(dragView.getBottomLine(false), false)
                                        , getCurrentOffset(dragView.getTopLine(false), true));
                                break;
                            case DragViewGroup.BOTTOM_BUTTON_SCROLL:
                                setStartTime(getCurrentOffset(dragView.getBottomLine(false), false));
                                setDuration();
                                break;
                        }

                    } else {
                        Logger.t(TAG).e("notSetTime = false;");
                        notSetTime = false;

                    }

                }
            }
        });
    }

    @SuppressLint("ObjectAnimatorBinding")
    private void initAnimator(int startPos, int endPos) {
        animator = ObjectAnimator.ofFloat(viewLine, "translationY", startPos, endPos);
        Logger.t(TAG).e("onAnimation: " + startPos + "--" + endPos + "--" + duration);
        animator.setDuration(duration);
        animator.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
//                Logger.t(TAG).e("onAnimationStart");
                viewLine.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
//                Logger.t(TAG).e("onAnimationEnd");
            }

            @Override
            public void onAnimationCancel(Animator animation) {
//                Logger.t(TAG).e("onAnimationCancel");
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
//                Logger.t(TAG).e("onAnimationRepeat");
            }
        });
    }

    private void computeDragMargin() {
        if (clip == null) {
            Logger.t(TAG).e("clip == null !!!");
            finish();
            return;
        }

        //缩略图对应的最大高度
        double minHeight = HEIGHT_TOTAL - 2 * ViewUtils.dp2px(70);
        //所容纳thumbnail的最大数量
        double num = minHeight / thumbnailHeight;
        //预计每隔几秒取一个thumbnail
        double second = 30 / num;
        //以2为底取指数，按照1.2.4.8..取间隔秒数
        double index = Math.ceil(Math.log(second) / Math.log(2));
        pow = Math.pow(2, index);
        //预计thumbnail的总数
        double thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);

        if (thumbnailNum < num) {
            for (double i = pow / 2; ; i = i / 2) {
                double temp = Math.ceil(clip.getDurationMs() / 1000 / i);
                Logger.t(TAG).e("temp: " + temp);
                if (temp > num) {
                    pow = i * 2;
                    Logger.t(TAG).e("result: " + pow);
                    break;
                }
            }
            thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);
        }
        if (clip.getDurationMs() / 1000 >= 30) {
            initMargin = (int) ((HEIGHT_TOTAL - thumbnailNum * thumbnailHeight * 30000 / clip.getDurationMs()) / 2);
        } else {
            initMargin = (int) ((HEIGHT_TOTAL - thumbnailNum * thumbnailHeight) / 2);
        }
        Logger.t(TAG).e("min: " + minHeight + "--num: " + num + "--second: " + second
                + "--index: " + index + "--pow: " + pow + "--thumbnum: " + thumbnailNum + "--init: " + initMargin);
    }

    private void onCameraConnectionEvent(CameraConnectionEvent event) {
        switch (event.getWhat()) {
            case CameraConnectionEvent.VDT_CAMERA_CONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_CONNECTED");
                break;
            case CameraConnectionEvent.VDT_CAMERA_DISCONNECTED:
                Logger.t(TAG).e("VDT_CAMERA_DISCONNECTED");
                finish();
                break;
            default:
                break;
        }
    }

    private long getCurrentOffset(int startPos, boolean top) {
        View childViewUnder = rv_timeline.findChildViewUnder(0, startPos);
        if (childViewUnder == null) {
            Logger.t(TAG).e("childViewUnder == null");
            if (top) {
                return clip.getDurationMs();
            } else {
                return 0;
            }
        }

        int position = timelineLayoutManager.getPosition(childViewUnder);
        Logger.t(TAG).e("position: " + position + "--size: " + (timelineLayoutManager.getItemCount() - 1));

        if (scaleAdapter.getItemViewType(position) != ScaleAdapter.TYPE_THUMBNAIL) {
            Logger.t(TAG).e("!= ScaleAdapter.TYPE_THUMBNAIL");
            if (top) {
                return clip.getDurationMs();
            } else {
                return 0;
            }
        }

        int itemOffset = Math.abs(startPos - childViewUnder.getTop());
        Logger.t(TAG).e("itemOffset: " + itemOffset + "--pos: " + position
                + "--startPos: " + startPos + "--Top: " + childViewUnder.getTop());

        double scale = (double) (itemOffset + (position - 1) * thumbnailHeight)
                / ((scaleAdapter.getItemCount() - 2) * thumbnailHeight);
        Logger.t(TAG).e("time: " + (1 - scale) * clip.getDurationMs()
                + "--time: " + Math.round((1 - scale) * clip.getDurationMs() / 1000) * 1000);

        return (long) ((1 - scale) * clip.getDurationMs());

        //四舍五入取值，防止偏差1s
//        return (long) (Math.round((1 - scale) * clip.getDurationMs() / 1000) * 1000);
    }

    private long getOffset(long dy, boolean start) {
        double offset = 1000 * dy * pow / thumbnailHeight;
//        double thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);
        double thumbnailNum = clip.getDurationMs() / 1000 / pow;
        double itemStart = thumbnailNum * clip.getDurationMs() / (scaleAdapter.getItemCount() - 2);
        return (long) (offset + (start ? 0 : itemStart));

//        if (clip.getDurationMs() / 1000 >= 30) {
//            return (long) (offset + (start ? 0 : 30000));
//        } else {
//            return start ? 0 : clip.getDurationMs();
//        }
    }

    private int updateThumbnail(String zoom, int start, int end) {
        //缩略图对应的最大高度
        double minHeight = HEIGHT_TOTAL - 2 * ViewUtils.dp2px(70);
        //容纳thumbnail的最大数量
        double num = minHeight / thumbnailHeight;
        //预计thumbnail的总数
        double thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);

        if (thumbnailNum < num) {
            for (double i = pow / 2; ; i = i / 2) {
                double temp = Math.ceil(clip.getDurationMs() / 1000 / i);
                Logger.t(TAG).e("temp: " + temp);
                if (temp > num) {
                    pow = i * 2;
                    Logger.t(TAG).e("result: " + pow);
                    break;
                }
            }
            thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);
        }
        long startOffset = getCurrentOffset(start, false);
        long endOffset = getCurrentOffset(end, true);
        //毫秒
        double duration = (double) (endOffset - startOffset);
        initMargin = (int) ((HEIGHT_TOTAL - thumbnailNum * thumbnailHeight * duration / clip.getDurationMs()) / 2);
        Logger.t(TAG).e("duration: " + duration + "--" + pow + "--" + thumbnailNum + "--" + thumbnailHeight + "--" + clip.getDurationMs());
        Logger.t(TAG).e("margin: " + initMargin + "--" + ViewUtils.dp2px(70) + "--" + (HEIGHT_TOTAL - thumbnailHeight) / 2);

        initMargin = Math.min(Math.max(ViewUtils.dp2px(70), initMargin), (HEIGHT_TOTAL - thumbnailHeight) / 2);
        Logger.t(TAG).e("margin: " + initMargin + "--" + ViewUtils.dp2px(70) + "--" + (HEIGHT_TOTAL - thumbnailHeight) / 2);

        View endView = rv_timeline.findChildViewUnder(0, end);
        if (endView == null) {
            Logger.t(TAG).e("endView == null");
            return 0;
        }

        int endViewPosition = timelineLayoutManager.getPosition(endView);
        int oldItemCount = timelineLayoutManager.getItemCount();
        Logger.t(TAG).e("endViewPosition: " + endViewPosition + "--size: " + (oldItemCount - 1));

        int endItemOffset = Math.abs(end - endView.getTop());
        Logger.t(TAG).e("endItemOffset: " + endItemOffset);

        double beforeEndOffset = endItemOffset + (endViewPosition - 1) * thumbnailHeight;

        View startView = rv_timeline.findChildViewUnder(0, start);
        if (startView == null) {
            Logger.t(TAG).e("startView == null");
            return 0;
        }

        int startViewPosition = timelineLayoutManager.getPosition(startView);
        Logger.t(TAG).e("startViewPosition: " + startViewPosition + "--size: " + (oldItemCount - 1));

        int startItemOffset = Math.abs(start - startView.getTop());
        Logger.t(TAG).e("startItemOffset: " + startItemOffset);

        double startPosOffset = startItemOffset + (startViewPosition - 1) * thumbnailHeight;

        double startPosScale = startPosOffset / ((scaleAdapter.getItemCount() - 2) * thumbnailHeight);

        double scale = beforeEndOffset / ((scaleAdapter.getItemCount() - 2) * thumbnailHeight);

        scaleAdapter.setClipList(clipList, (int) (pow * (clip.getVideoType() == VideoEventType.TYPE_BUFFERED ? 1 : 8)));

        int newItemCount = timelineLayoutManager.getItemCount();

        double afterEndOffset = (scaleAdapter.getItemCount() - 2) * thumbnailHeight * scale;

        Logger.t(TAG).e("before: " + beforeEndOffset + "--scale: " + scale + "--after: " + afterEndOffset
                + "--" + HEIGHT_TOTAL + "--" + thumbnailHeight + "--" + initMargin);

        notSetTime = true;
        int scrollDis = 0;
        Logger.t(TAG).e("ZOOM: " + zoom + "--" + ViewUtils.dp2px(60));
        if (getString(R.string.zoom_out).equals(zoom.toLowerCase())) {
            if (startViewPosition == oldItemCount - 1 && endViewPosition == 0 && startItemOffset != 0) {
                Logger.t(TAG).e("startViewPosition == timelineLayoutManager.getItemCount() - 1 && endViewPosition == 0");
                if (startItemOffset > endItemOffset) {
                    Logger.t(TAG).e("startItemOffset > endItemOffset");
                    rv_timeline.scrollToPosition(timelineLayoutManager.getItemCount() - 1);
                    rv_timeline.smoothScrollBy(0, initMargin - (HEIGHT_TOTAL - thumbnailHeight) / 2);
                } else if (endItemOffset > startItemOffset) {
                    Logger.t(TAG).e("endItemOffset > startItemOffset");
                    rv_timeline.scrollToPosition(0);
                    rv_timeline.smoothScrollBy(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin);
                }
                return initMargin;
            } else if (startViewPosition == oldItemCount - 1 && startItemOffset != 0) {
                Logger.t(TAG).e("startViewPosition == timelineLayoutManager.getItemCount() - 1");
                rv_timeline.scrollToPosition(timelineLayoutManager.getItemCount() - 1);
                rv_timeline.smoothScrollBy(0, initMargin - (HEIGHT_TOTAL - thumbnailHeight) / 2);
                return initMargin;
            } else if (endViewPosition == 0) {
                Logger.t(TAG).e("endViewPosition == 0");
                rv_timeline.scrollToPosition(0);
                rv_timeline.smoothScrollBy(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin);
                return initMargin;
            } else {
//                Logger.t(TAG).e("else");
                rv_timeline.scrollToPosition(0);
                rv_timeline.scrollBy(0, (int) (afterEndOffset + (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin));
                return initMargin;
            }
        } else if (getString(R.string.zoom_in).equals(zoom.toLowerCase())) {
            scrollDis = (int) (afterEndOffset - beforeEndOffset) + (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin;
            rv_timeline.scrollBy(0, scrollDis);
        }
        Logger.t(TAG).e("scrollDis: " + scrollDis);
        Logger.t(TAG).e("min: " + minHeight + "--num: " + num
                + "--pow: " + pow + "--thumbnum: " + thumbnailNum + "--init: " + initMargin);

//        pow =

        return initMargin;
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onResume(this);
        }
        if (mMediaPlayerWrapper != null && mClipPos != null) {
            initVideoPlayer(mClipPos);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onPause(this);
        }
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mVRVideoLibrary != null) {
            mVRVideoLibrary.onDestroy();
        }
        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        Glide.get(this).trimMemory(level);
    }

    @OnClick(R.id.btnPlayPause)
    public void onBtnPlayPauseClicked() {
        if (mMediaPlayerWrapper != null) {
            if (mMediaPlayerWrapper.getPlayer().isPlaying()) {
                mMediaPlayerWrapper.pause();
                togglePlayState(true);
            } else {
                mMediaPlayerWrapper.resume();
                togglePlayState(false);
            }
        }
    }

    @OnClick(R.id.btn_ensure_scale)
    public void goExport() {
        if (Constants.isFleet()) {
            Logger.t(TAG).e("duration: " + duration + "--offset: " + offset);
            if (mCamera != null) {
                ExportActivity.launch(this, exportChoice, mStreamIndex, clip, mCamera.getSerialNumber(), duration, offset);
            }
        } else {
            cl_export_confirm.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.ll_save_album)
    public void saveAlbum() {
        cl_export_confirm.setVisibility(View.INVISIBLE);
        Logger.t(TAG).e("duration: " + duration + "--offset: " + offset);
        if (mCamera != null) {
            ExportActivity.launch(this, 0, mStreamIndex, clip, mCamera.getSerialNumber(), duration, offset);
        }
    }

    @OnClick(R.id.ll_save_library)
    public void saveLibrary() {
        cl_export_confirm.setVisibility(View.INVISIBLE);
        Logger.t(TAG).e("duration: " + duration + "--offset: " + offset);
        if (mCamera != null) {
            ExportActivity.launch(this, 1, mStreamIndex, clip, mCamera.getSerialNumber(), duration, offset);
        }
    }

    @OnClick(R.id.ll_share_waylens)
    public void shareWaylesn() {
        cl_export_confirm.setVisibility(View.INVISIBLE);
        Logger.t(TAG).e("duration: " + duration + "--offset: " + offset);
        if (mCamera != null) {
            ExportActivity.launch(this, 2, mStreamIndex, clip, mCamera.getSerialNumber(), duration, offset);
        }
    }

    @OnClick(R.id.btn_export_cancel)
    public void cancel() {
        cl_export_confirm.setVisibility(View.INVISIBLE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == 1001 && resultCode == RESULT_OK) {
            finish();
        }
    }

    private void togglePlayState(boolean toPlay) {
        btnPlayPause.setBackground(getResources().getDrawable(toPlay ? R.drawable.playbar_play_n : R.drawable.playbar_pause_n));
    }

    private void setToolbar() {
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    protected MDVRLibrary createVideoVRLibrary() {
        int switchMode = CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS;
        if (clip != null) {
            boolean needDewarp = clip.getNeedDewarp();
            if (needDewarp) {
                boolean lensNormal = clip.isLensNormal();
                Logger.t(TAG).d("isLensNormal: " + lensNormal);
                switchMode = lensNormal ?
                        CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS : CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS_DOWN;
            } else {
                switchMode = MDVRLibrary.PROJECTION_MODE_PLANE_FIT;
            }
        }

        Logger.t(TAG).d("switchMode: " + (switchMode == CustomProjectionFactory.CUSTOM_PROJECTION_DOUBLE_DIRECTIONS));

        return MDVRLibrary.with(this)
                .displayMode(MDVRLibrary.DISPLAY_MODE_NORMAL)
                .interactiveMode(MDVRLibrary.INTERACTIVE_MODE_TOUCH)
                .asVideo(surface -> mMediaPlayerWrapper.setSurface(surface))
                .ifNotSupport(mode -> {
                    String tip = mode == MDVRLibrary.INTERACTIVE_MODE_MOTION
                            ? "onNotSupport:MOTION" : "onNotSupport:" + mode;
                    Toast.makeText(ScaleActivity.this, tip, Toast.LENGTH_SHORT).show();
                })
                .projectionMode(switchMode)
                .projectionFactory(new CustomProjectionFactory())
                .barrelDistortionConfig(new BarrelDistortionConfig().setDefaultEnabled(false).setScale(0.95f))
                .build(gl_view);
    }

    private void postClipPosChangeEvent() {
        Clip newClip = new Clip(clip);
        Logger.t(TAG).e("start: " + newClip.getStartTimeMs() + "--end: " + newClip.getEndTimeMs());
        //播放起点
        offset = getCurrentOffset(dragView.getBottomLine(false), false);
        Logger.t(TAG).e("offset: " + offset);
        duration = (int) (getCurrentOffset(dragView.getTopLine(false), true)
                - offset);
        Logger.t(TAG).e("duration: " + duration);
        newClip.setEndTime(newClip.getStartTimeMs() + duration);
        Logger.t(TAG).e("start: " + newClip.getStartTimeMs() + "--end: " + newClip.getEndTimeMs());

        ClipPos newClipPos = new ClipPos(newClip);
        ClipPosChangeEvent event = new ClipPosChangeEvent(newClipPos, TAG);
        //Logger.t(TAG).d("%s", "post event curClipPos = " + currentPos);
        RxBus.getDefault().post(event);
    }

    private void onClipPosChangeEvent(ClipPosChangeEvent clipPosChangeEvent) {
//        Logger.t(TAG).e("onClipPosChangeEvent");
        if (clipPosChangeEvent != null && clipPosChangeEvent.getClipPos() != null) {
            if (clipPosChangeEvent.getIntent() == ClipPosChangeEvent.INTENT_PLAY) {
                initVideoPlayer(clipPosChangeEvent.getClipPos());
            } else if (clipPosChangeEvent.getIntent() == ClipPosChangeEvent.INTENT_PLAY_END) {

            }
        }
    }

    private void checkProgress(long mLong) {
        if (mMediaPlayerWrapper != null && mMediaPlayerWrapper.getPlayer() != null && mMediaPlayerWrapper.getPlayer().isPlaying()) {
            long currentPos = mMediaPlayerWrapper.getPlayer().getCurrentPosition();
            long duration = mMediaPlayerWrapper.getPlayer().getDuration();
            refreshLine(currentPos, duration);
//            togglePlayState(false);
        }
    }

    /**
     * 移动标示线
     *
     * @param currentPos
     */
    private void refreshLine(long currentPos, long duration) {

    }

    private void initVideoPlayer(ClipPos clipPos) {
        busy();
        btnPlayPause.setVisibility(View.VISIBLE);

        mClipPos = clipPos;

        if (mMediaPlayerWrapper != null) {
            mMediaPlayerWrapper.destroy();
        }

        mMediaPlayerWrapper = new MediaPlayerWrapper(false);

        mMediaPlayerWrapper.init();

        mMediaPlayerWrapper.setPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer mp) {
                cancelBusy();

                if (!isForeground) {
                    mp.stop();
                }
                if (getVRVideoLibrary() != null) {
                    getVRVideoLibrary().notifyPlayerChanged();
                }
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnInfoListener(new IMediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(IMediaPlayer iMediaPlayer, int what, int extra) {
                switch (what) {
                    case IMediaPlayer.MEDIA_INFO_BUFFERING_START:
                        busy();
                        break;
                    case IMediaPlayer.MEDIA_INFO_BUFFERING_END:
                        cancelBusy();
                        break;
                    case IMediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH:

                        break;
                    case IMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
                        cancelBusy();
                        break;
                    default:
                        break;
                }
                return false;
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnErrorListener(new IMediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(IMediaPlayer mp, int what, int extra) {
                String error = String.format(Locale.getDefault(), "Play error: " + extra);
                Logger.t(TAG).e("onError: " + error);
                Toast.makeText(ScaleActivity.this, error, Toast.LENGTH_SHORT).show();
                return true;
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnVideoSizeChangedListener(new IMediaPlayer.OnVideoSizeChangedListener() {
            @Override
            public void onVideoSizeChanged(IMediaPlayer mp, int width, int height, int sar_num, int sar_den) {
                getVRVideoLibrary().onTextureResize(width, height);
            }
        });

        mMediaPlayerWrapper.getPlayer().setOnCompletionListener(new IMediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(IMediaPlayer iMediaPlayer) {
                togglePlayState(true);
            }
        });

        if (clipPos != null) {
            Observable.create((ObservableOnSubscribe<Void>) emitter -> {
                try {
                    PlaybackUrl playbackUrl = SnipeApi.getClipPlaybackUrlWithStream(clipPos.cid,
                            clipPos.getClip().getStartTimeMs(), offset, clipPos.getClip().getDurationMs(), mStreamIndex);
                    Logger.t(TAG).e("playback url = " + playbackUrl.url);
                    if (playbackUrl.url != null) {
                        mMediaPlayerWrapper.openRemoteFile(playbackUrl.url);
                        mMediaPlayerWrapper.prepare();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
//                    Logger.t(TAG).e(e.getMessage());
                }
            }).subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(Functions.emptyConsumer(), new ServerErrorHandler(TAG));
        }
    }

    public void cancelBusy() {
        findViewById(R.id.progress).setVisibility(View.GONE);
        togglePlayState(false);
        if (animator != null) {
            if (animator.isPaused()) {
                animator.resume();
            } else {
                animator.start();
            }
        }
    }

    public void busy() {
        findViewById(R.id.progress).setVisibility(View.VISIBLE);
        togglePlayState(true);
        if (animator != null && animator.isRunning()) {
            animator.pause();
        }
    }

    /**
     * 设置时间
     */
    private void setPlayTime(long startOffset, long endOffset) {
//        Logger.t(TAG).e("top: " + dragView.getTopLine(adjust) + "--btm: " + dragView.getBottomLine(adjust));
        offset = startOffset;
        endTime = clip.getGMTAbsTime(endOffset);
        startTime = clip.getGMTAbsTime(startOffset);

        if (DateFormat.is24HourFormat(this)) {
            tv_top_time.setText(DateTime.get24HTimeString(endTime, false));
            tv_btm_time.setText(DateTime.get24HTimeString(startTime, false));
        } else {
            tv_top_time.setText(DateTime.get12HTimeString(endTime, false));
            tv_btm_time.setText(DateTime.get12HTimeString(startTime, false));
        }

        duration = (int) (endTime - startTime);

        Logger.t(TAG).e("duration: " + (double) (endTime - startTime) / 1000);
        String time = DateUtils.formatElapsedTime(Math.round((double) (endTime - startTime) / 1000)) + "s";
        Logger.t(TAG).e("beforeReplace: " + time);
        int firstIndexOf = time.indexOf(":");
        int lastIndexOf = time.lastIndexOf(":");
        if (firstIndexOf == lastIndexOf) {
            time = time.replace(":", "m");
            time = time.replace("00m", "");
        } else {
            time = time.replace(":", "m");
            time = time.replaceFirst("m", "h");
        }
        Logger.t(TAG).e("afterReplace: " + time);
        if (!time.contains("-") && !"00s".equals(time)) {
            tv_scale_duration.setText(time);
        }
    }

    private void setStartTime(long startOffset) {
        offset = startOffset;
        startTime = clip.getGMTAbsTime(startOffset);

        if (DateFormat.is24HourFormat(this)) {
            tv_btm_time.setText(DateTime.get24HTimeString(startTime, false));
        } else {
            tv_btm_time.setText(DateTime.get12HTimeString(startTime, false));
        }
    }

    private void setEndTime(long endOffset) {
        endTime = clip.getGMTAbsTime(endOffset);
        if (DateFormat.is24HourFormat(this)) {
            tv_top_time.setText(DateTime.get24HTimeString(endTime, false));
        } else {
            tv_top_time.setText(DateTime.get12HTimeString(endTime, false));
        }
    }

    private void setDuration() {

        duration = (int) (endTime - startTime);

        Logger.t(TAG).e("duration: " + (double) (endTime - startTime) / 1000);
        String time = DateUtils.formatElapsedTime(Math.round((double) (endTime - startTime) / 1000)) + "s";
        Logger.t(TAG).e("beforeReplace: " + time);
        int firstIndexOf = time.indexOf(":");
        int lastIndexOf = time.lastIndexOf(":");
        if (firstIndexOf == lastIndexOf) {
            time = time.replace(":", "m");
            time = time.replace("00m", "");
        } else {
            time = time.replace(":", "m");
            time = time.replaceFirst("m", "h");
        }
        Logger.t(TAG).e("afterReplace: " + time);
        if (!time.contains("-") && !"00s".equals(time)) {
            tv_scale_duration.setText(time);
        }
    }

    private void setScaleTime(long dy) {
        long endTime = clip.getGMTAbsTime(getOffset(dy, false));
        long startTime = clip.getGMTAbsTime(getOffset(dy, true));

        if (DateFormat.is24HourFormat(this)) {
            tv_top_time.setText(DateTime.get24HTimeString(endTime, false));
            tv_btm_time.setText(DateTime.get24HTimeString(startTime, false));
        } else {
            tv_top_time.setText(DateTime.get12HTimeString(endTime, false));
            tv_btm_time.setText(DateTime.get12HTimeString(startTime, false));
        }

        Logger.t(TAG).e("duration: " + (endTime - startTime) / 1000);
        String time = DateUtils.formatElapsedTime((endTime - startTime) / 1000) + "s";
        Logger.t(TAG).e("beforeReplace: " + time);
        int firstIndexOf = time.indexOf(":");
        int lastIndexOf = time.lastIndexOf(":");
        if (firstIndexOf == lastIndexOf) {
            time = time.replace(":", "m");
            time = time.replace("00m", "");
        } else {
            time = time.replace(":", "m");
            time = time.replaceFirst("m", "h");
        }
        Logger.t(TAG).e("afterReplace: " + time);
        tv_scale_duration.setText(time);
    }

    private ClipPos getClipPos() {
        return mClipPos;
    }

    public MDVRLibrary getVRVideoLibrary() {
        return mVRVideoLibrary;
    }

    private void setHideAnimation(View view, int duration) {
        Animation mHideAnimation = null;
        if (null == view || duration < 0) {
            return;
        }

        if (null != mHideAnimation) {
            mHideAnimation.cancel();
        }
        mHideAnimation = new AlphaAnimation(1.0f, 0.0f);
        mHideAnimation.setDuration(duration);
        mHideAnimation.setFillAfter(true);
        view.startAnimation(mHideAnimation);
    }

    @Override
    public int[] dragResult(String zoom, int start, int end) {
        Logger.t(TAG).e("dragResult: " + zoom + "--" + start + "--" + end);

//        initAnimator(start, end);

        if (TextUtils.isEmpty(zoom)) {
            return new int[]{flingDrag(start, end), (int) pow};
        } else {
            zoom = zoom.replace("z", "Z");
            tv_scale_style.setText(zoom);
            setHideAnimation(tv_scale_style, 1500);

            long startOffset = getCurrentOffset(start, false);
            long endOffset = getCurrentOffset(end, true);
            setPlayTime(startOffset, endOffset);

            if (getString(R.string.zoom_out).equals(zoom.toLowerCase())) {
//                dragView.zoom = "";
                pow = pow * 2;
                //                rv_timeline.scrollBy(0, 1);
//                setPlayTime(false);
            } else if (getString(R.string.zoom_in).equals(zoom.toLowerCase()) && pow % 2 == 0) {
//                dragView.zoom = "";
                //排除1s的情况
                pow = pow / 2;
//                rv_timeline.scrollBy(0, 1);
//                setPlayTime(false);
            }
            return new int[]{updateThumbnail(zoom, start, end), (int) pow};
        }
    }

    private int flingDrag(int start, int end) {
//        Logger.t(TAG).e("flingDrag");
        //起始view
        View startView = rv_timeline.findChildViewUnder(0, start);
        if (startView == null) {
            Logger.t(TAG).e("startView == null");
            return 0;
        }

        int startViewPosition = timelineLayoutManager.getPosition(startView);
        Logger.t(TAG).e("startViewPosition: " + startViewPosition + "--size: " + (timelineLayoutManager.getItemCount() - 1));

        //取与最后一个thumbnail的距离(位于底部)
        int startItemOffset = Math.abs(start - startView.getTop());
        Logger.t(TAG).e("startItemOffset: " + startItemOffset);

        //终止view
        View endView = rv_timeline.findChildViewUnder(0, end);
        if (endView == null) {
            Logger.t(TAG).e("endView == null");
            return 0;
        }

        int endViewPosition = timelineLayoutManager.getPosition(endView);
        Logger.t(TAG).e("endViewPosition: " + endViewPosition + "--size: " + (timelineLayoutManager.getItemCount() - 1));

        //取与第一个thumbnail的距离(位于顶部)
        int endItemOffset = Math.abs(end - endView.getBottom());
        Logger.t(TAG).e("endItemOffset: " + endItemOffset);

        //预计thumbnail的总数
        double thumbnailNum = Math.ceil(clip.getDurationMs() / 1000 / pow);

        Logger.t(TAG).e("duration: " + duration + "--" + clip.getDurationMs());
        initMargin = (int) ((HEIGHT_TOTAL - thumbnailNum * thumbnailHeight * duration / clip.getDurationMs()) / 2);
        initMargin = Math.min(Math.max(ViewUtils.dp2px(70), initMargin), (HEIGHT_TOTAL - thumbnailHeight) / 2);

        if (startViewPosition == timelineLayoutManager.getItemCount() - 1 && endViewPosition == 0 && startItemOffset != 0) {
            Logger.t(TAG).e("startViewPosition == timelineLayoutManager.getItemCount() - 1 && endViewPosition == 0");
            if (startItemOffset > endItemOffset) {
                Logger.t(TAG).e("startItemOffset > endItemOffset");
                rv_timeline.scrollToPosition(timelineLayoutManager.getItemCount() - 1);
                rv_timeline.smoothScrollBy(0, initMargin - (HEIGHT_TOTAL - thumbnailHeight) / 2);
            } else if (endItemOffset > startItemOffset) {
                Logger.t(TAG).e("endItemOffset > startItemOffset");
                rv_timeline.scrollToPosition(0);
                rv_timeline.smoothScrollBy(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin);
            }
            return initMargin;
        } else if (startViewPosition == timelineLayoutManager.getItemCount() - 1 && startItemOffset != 0) {
            Logger.t(TAG).e("startViewPosition == timelineLayoutManager.getItemCount() - 1");
            rv_timeline.scrollToPosition(timelineLayoutManager.getItemCount() - 1);
            rv_timeline.smoothScrollBy(0, initMargin - (HEIGHT_TOTAL - thumbnailHeight) / 2);
            return initMargin;
        } else if (endViewPosition == 0) {
            Logger.t(TAG).e("endViewPosition == 0");
            rv_timeline.scrollToPosition(0);
            rv_timeline.smoothScrollBy(0, (HEIGHT_TOTAL - thumbnailHeight) / 2 - initMargin);
            return initMargin;
        }
        return 0;
    }

    @Override
    public void onViewDragStateChanged(int state) {
        if (state == ViewDragHelper.STATE_IDLE) {
            btn_ensure_scale.setVisibility(View.VISIBLE);
        } else {
            btn_ensure_scale.setVisibility(View.GONE);
        }
    }

    private void updateThumbnail(ClipPos clipPos) {
//        Glide.with(this)
//                .using(new SnipeGlideLoader(VdtCameraManager.getManager().getCurrentVdbRequestQueue()))
//                .load(clipPos)
//                .transform(new TwoDirectionTransform(this))
//                .diskCacheStrategy(DiskCacheStrategy.ALL)
//                .placeholder(R.drawable.bg_single_thumbnail)
//                .into(gl_view);
    }

}
