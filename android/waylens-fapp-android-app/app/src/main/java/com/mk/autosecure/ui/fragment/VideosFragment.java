package com.mk.autosecure.ui.fragment;

import static android.view.View.VISIBLE;
import static androidx.recyclerview.widget.RecyclerView.SCROLL_STATE_IDLE;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Pair;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.ICameraWrapper;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipCluster;
import com.mk.autosecure.model.ClipPosChangeEvent;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.ui.activity.ScaleActivity;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.mk.autosecure.ui.adapter.LocalDateAdapter;
import com.mk.autosecure.ui.adapter.LocalThumbnailAdapter;
import com.mk.autosecure.ui.adapter.LocalVideoAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.CustomRecyclerView;
import com.mk.autosecure.ui.view.listener.DefOnGestureListener;
import com.mk.autosecure.viewmodels.VideosActivityViewModel;
import com.mk.autosecure.viewmodels.VideosFragmentViewModel;
import com.mk.autosecure.viewmodels.fragment.CameraViewFragmentViewModel;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.event.MarkLiveMsgEvent;
import com.mkgroup.camera.event.SDCardStateEvent;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipActionInfo;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.DateTime;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;

import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper;

/**
 * Created by DoanVT on 2017/7/24.
 * Email: doanvt-hn@mk.com.vn
 */

@SuppressLint({"CheckResult","ClickableViewAccessibility","NonConstantResourceId"})
@RequiresFragmentViewModel(VideosFragmentViewModel.ViewModel.class)
public class VideosFragment extends BaseFragment<VideosFragmentViewModel.ViewModel> {
    public static final String TAG = VideosFragment.class.getSimpleName();

    @BindView(R.id.recycler_view)
    RecyclerView recyclerView;

    @BindView(R.id.rv_thumbnail)
    CustomRecyclerView rvThumbnail;

    RecyclerView rvDate;

    @BindView(R.id.tv_videoStat)
    TextView tvVideoStat;

    @BindView(R.id.tv_playTime)
    TextView tvPlayTime;

    @BindView(R.id.tv_liveView)
    TextView tv_liveView;

    @BindView(R.id.btn_toLive)
    ImageButton btnToLive;

    @BindView(R.id.ib_filter)
    ImageButton ibFilter;

    @BindView(R.id.va_base)
    ViewAnimator vaBase;

    @BindView(R.id.rl_bottomToolbar)
    RelativeLayout rlBottomToolbar;

    @BindView(R.id.tv_no_videos_tips)
    TextView tv_no_videos_tips;

    @BindView(R.id.dialog_view_export)
    View dialogViewExport;

    @BindView(R.id.dialog_view_export_fleet)
    View dialogViewExportFleet;

    @BindView(R.id.tv_export_info)
    TextView tvExportInfo;

    @BindView(R.id.tv_export_info_fleet)
    TextView tvExportInfoFleet;

    private String serialNumber;

    private VideosActivityViewModel.ViewModel parentViewModel;

    private CameraViewFragmentViewModel.ViewModel parentFragmentViewModel;

    public LocalVideoAdapter mAdapter;

    private LinearLayoutManager layoutManager;

    public LocalThumbnailAdapter localThumbnailAdapter;

    private LinearLayoutManager thumbnailLayoutManager;

    public LocalDateAdapter localDateAdapter;

    private LinearLayoutManager dateLayoutManager;

    private Clip mIntentClip;

    private long mStartTimeMs = -1;

    @OnClick(R.id.btn_toLive)
    public void onToLiveClick() {
        recyclerView.scrollToPosition(0);
        rvThumbnail.scrollToPosition(0);
        tv_liveView.setVisibility(View.VISIBLE);
        showNavigation();

        RxBus.getDefault().post(new ClipPosChangeEvent(null, TAG, ClipPosChangeEvent.INTENT_LIVE));
    }

    @OnClick(R.id.ib_filter)
    public void showFilter() {
        ibFilter.setVisibility(View.GONE);

        if (parentViewModel != null) {
            parentViewModel.filterVisibility(View.VISIBLE);
        } else if (parentFragmentViewModel != null) {
            parentFragmentViewModel.filterVisibility(VISIBLE);
        }
    }

    public static VideosFragment newInstance(String sn) {
        VideosFragment fragment = new VideosFragment();
        Bundle args = new Bundle();
        args.putString(IntentKey.SERIAL_NUMBER, sn);
        fragment.setArguments(args);
        return fragment;
    }

    private Context mContext;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;

        if (context instanceof VideosActivity) {
            parentViewModel = ((VideosActivity) context).viewModel();
        } else {
            Fragment parentFragment = getParentFragment();
            if (parentFragment instanceof CameraViewFragment) {
                parentFragmentViewModel = ((CameraViewFragment) parentFragment).viewModel();
            }
        }
    }

    @Override
    public @Nullable
    View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view;
        if (Constants.isFleet()) {
            view = inflater.inflate(R.layout.fragment_videos_fleet, container, false);
            rvDate = view.findViewById(R.id.rv_date);
        } else {
            view = inflater.inflate(R.layout.fragment_videos, container, false);
        }
        ButterKnife.bind(this, view);

        serialNumber = getArguments() != null ? getArguments().getString(IntentKey.SERIAL_NUMBER) : "";

        thumbnailLayoutManager = new LinearLayoutManager(mContext);
        localThumbnailAdapter = new LocalThumbnailAdapter(mContext);

        rvThumbnail.setLayoutManager(thumbnailLayoutManager);
        rvThumbnail.setAdapter(localThumbnailAdapter);

        layoutManager = new LinearLayoutManager(mContext);
        mAdapter = new LocalVideoAdapter((RxFragmentActivity) mContext);

        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setAdapter(mAdapter);

        if (Constants.isFleet()) {
            rvDate.post(() -> {
                dateLayoutManager = new LinearLayoutManager(mContext);
                localDateAdapter = new LocalDateAdapter(mContext, rvDate.getHeight());
                localDateAdapter.setMaxShowItem(!TextUtils.isEmpty(serialNumber) && serialNumber.startsWith("6B") ? 8 : 15);

                rvDate.setLayoutManager(dateLayoutManager);
                rvDate.setAdapter(localDateAdapter);
            });
        }

        OverScrollDecoratorHelper.setUpOverScroll(recyclerView, OverScrollDecoratorHelper.ORIENTATION_VERTICAL);

        if (parentViewModel != null) {
            parentViewModel.liveTime()
                    .compose(bindToLifecycle())
                    .throttleFirst(500, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::setPlayTime, new ServerErrorHandler());
        } else if (parentFragmentViewModel != null) {
            parentFragmentViewModel.liveTime()
                    .compose(bindToLifecycle())
                    .throttleFirst(500, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::setPlayTime, new ServerErrorHandler());
        }

        recyclerView.setOnTouchListener((v, event) -> gestureDetector.onTouchEvent(event));

        recyclerView.addOnScrollListener(scrollListener);

        if (Constants.isFleet()) {
            rvDate.setOnTouchListener((v, event) -> dateGesture.onTouchEvent(event));
            rvDate.addOnScrollListener(dateScroll);
        }

        initEvent();
        return view;
    }

    /**
     * khởi tạo - xử lý handler nhận event
     * */
    @SuppressLint("CheckResult")
    private void initEvent(){

        registerDialogCallback();

        viewModel.outputs.filterVisibility()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::filterVisibility, new ServerErrorHandler());

        viewModel.outputs.filterShow()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::filterShow, new ServerErrorHandler());

        viewModel.outputs.clipList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipList, new ServerErrorHandler());

        RxBus.getDefault().toObservable(SDCardStateEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onSDCardStateEvent, new ServerErrorHandler());

        RxBus.getDefault().toObservable(MarkLiveMsgEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventMarkLiveMsg, new ServerErrorHandler());

        RxBus.getDefault().toObservable(ClipPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipPosChangeEvent, new ServerErrorHandler());
    }

    private void filterVisibility(Integer visibility) {
        Logger.t(TAG).d("filterVisibility: " + visibility);
        ibFilter.setVisibility(visibility);
    }

    private void filterShow(Integer resource) {
        Logger.t(TAG).d("filterShow: " + resource);
        ibFilter.setImageResource(resource);
    }

    /**
     * handler show list clip
     * */
    private void onClipList(List<Clip> clipList) {
        Logger.t(TAG).d("onClipList size = " + clipList.size());

        if (clipList.size() == 0) {
            vaBase.setDisplayedChild(4);
            tv_no_videos_tips.setText(R.string.sdcard_no_videos);
            clearData();
        } else {
            vaBase.setDisplayedChild(0);

            Clip selectedClip = mAdapter.getSelectedClip();
            mAdapter.setClipList(clipList);
            mAdapter.setSelectedClip(selectedClip);
            localThumbnailAdapter.setClipList(clipList);
            if (Constants.isFleet()) {
                localDateAdapter.setClipList(clipList);
            }

            if (mStartTimeMs != -1) {
                Clip selectClip = null;
                Collections.sort(clipList, (o1, o2) -> ((o2.getStartTimeMsAbs() - o1.getStartTimeMsAbs()) > 0) ? 1 : -1);

                for (Clip clip : clipList) {
                    if (clip.getStartTimeMsAbs() <= mStartTimeMs) {
                        selectClip = clip;
                        break;
                    }
                }

                if (selectClip != null) {
                    tv_liveView.setVisibility(View.INVISIBLE);
                    hideNavigation();

                    Logger.t(TAG).e("selectClip: " + DateTime.get24HTimeWithoutSec(selectClip.getStartTimeMsAbs() + selectClip.getOffset(), true));

                    ClipPosChangeEvent changeEvent = new ClipPosChangeEvent(new ClipPos(selectClip, 0), TAG);
                    adjustProgress(changeEvent);
                    RxBus.getDefault().post(changeEvent);
                }

                mStartTimeMs = -1;
            }

            ClipPos currentClipPos = getCurrentClipPos();
            if (currentClipPos != null) {
                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.clipPosChanged(currentClipPos);
                } else if (parentFragmentViewModel != null && parentFragmentViewModel.inputs != null) {
                    parentFragmentViewModel.inputs.clipPosChanged(currentClipPos);
                }
            }

            recyclerView.post(() -> {
                int height = recyclerView.getHeight();
                mAdapter.setBottomMargin(height);
                localThumbnailAdapter.setBottomMargin(height);
            });
        }
    }
    /**
     * Thay đổi event ClipPos
     * */
    private void onClipPosChangeEvent(ClipPosChangeEvent event) {
//        Logger.t(TAG).d("onClipPosChangeEvent: " + event.getIntent() + "--" + event.getPublisher());
        if (event.getPublisher().equals(VideosActivity.class.getSimpleName())
                || event.getPublisher().equals(CameraViewFragment.class.getSimpleName())) {

            if (event.getIntent() == ClipPosChangeEvent.INTENT_PLAY_END) {
                Logger.t(TAG).d("INTENT_PLAY_END");
                VideosFragment.this.tryPlayNext(event.getClipPos());
                clearDialog();
                return;
            } else if (event.getIntent() == ClipPosChangeEvent.INTENT_LIVE) {
                Logger.t(TAG).d("INTENT_LIVE");
                onToLiveClick();
                return;
            }

//            Logger.t(TAG).d("%s", "process event");
            if (parentViewModel != null && !parentViewModel.isLiveOrNot) {
                VideosFragment.this.adjustProgress(event);
            } else if (parentFragmentViewModel != null && !parentFragmentViewModel.isLiveOrNot) {
                VideosFragment.this.adjustProgress(event);
            }
        }
    }

    /**
     * state SDCard
     * */
    private void onSDCardStateEvent(SDCardStateEvent stateEvent) {
        int state = stateEvent.getState();
        Logger.t(TAG).d("onSDCardStateEvent: " + state);
        switch (state) {
            case VdtCamera.STATE_STORAGE_ERROR:
                vaBase.setDisplayedChild(2);
                clearData();
                break;
            case VdtCamera.STATE_STORAGE_NO_STORAGE:
                vaBase.setDisplayedChild(3);
                clearData();
                break;
            case VdtCamera.STATE_STORAGE_READY:
                vaBase.setDisplayedChild(0);
                if (parentViewModel != null) {
                    viewModel.loadClips(parentViewModel.filterList, false);
                } else if (parentFragmentViewModel != null) {
                    viewModel.loadClips(parentFragmentViewModel.filterList, false);
                }
                break;
            default:
                break;
        }
    }

    private void clearData() {
        mAdapter.clearData();
        localThumbnailAdapter.clearData();

        if (Constants.isFleet()) {
            localDateAdapter.clearData();
        }

        tvVideoStat.setText("");
        tvPlayTime.setText("");
    }

    @SuppressLint("CheckResult")
    @Override
    public void onResume() {
        super.onResume();
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onCurrentCamera, new ServerErrorHandler());
    }

    private void onCurrentCamera(Optional<CameraWrapper> camera) {
        CameraWrapper cameraWrapper = camera.getIncludeNull();
        if (cameraWrapper != null) {
            onNewCamera(cameraWrapper);
            cameraWrapper.queryStorageState();
        } else {
            onDisconnectCamera();
        }
    }

    private void onNewCamera(CameraWrapper camera) {
        Logger.t(TAG).d("got one camera: " + camera.getSerialNumber());
        if (!TextUtils.isEmpty(serialNumber) && serialNumber.equals(camera.getSerialNumber())) {
            viewModel.currentCamera(camera);
        } else {
            onDisconnectCamera();
        }
    }

    private void onDisconnectCamera() {
        vaBase.setDisplayedChild(1);
        mAdapter.clearData();
        localThumbnailAdapter.clearData();

        if (Constants.isFleet()) {
            localDateAdapter.clearData();
        }

        tvVideoStat.setText("");
        tvPlayTime.setText("");
    }

    /**
     * play clipPos
     * */
    private void tryPlayNext(ClipPos endPos) {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
        Logger.t(TAG).d("currentView: " + currentView);
        ClipPos clipPos = null;
        if (currentView != null) {
            int currentPos = layoutManager.getPosition(currentView);
            Logger.t(TAG).d("currentPos: " + currentPos);
            if (mAdapter.getItemViewType(currentPos) == LocalVideoAdapter.TYPE_CLIP) {
                ClipPos endClipPos = getCurrentClipPos();
                ClipCluster clipCluster = null;
                if (endClipPos != null) {
                    Object obj = mAdapter.getViewItemObjectAt(currentPos);
                    if (obj instanceof ClipCluster) {
                        clipCluster = (ClipCluster) obj;
                    }
                }
                clipPos = startOfNextSegment(endPos, clipCluster);
            }

            if (clipPos == null) {
                clipPos = startOfNextCluster(currentPos);
            }
        }
        Logger.t(TAG).d("closest clip pos = " + clipPos);
        if (clipPos != null && endPos.getClip() != clipPos.getClip()) {
            ClipPosChangeEvent posChangeEvent = new ClipPosChangeEvent(clipPos, TAG);
            adjustProgress(posChangeEvent);
            Logger.t(TAG).v("%s", "clipPos = " + clipPos.getClipTimeMs());
            RxBus.getDefault().post(posChangeEvent);
        } else {
            clipPos = getCurrentClipPos();
            if (clipPos == null) {
                clipPos = getClosestClipPos();
                Logger.t(TAG).d("closest clip pos = " + clipPos);
                if (clipPos != null) {
                    ClipPosChangeEvent changeEvent = new ClipPosChangeEvent(clipPos, TAG);
                    adjustProgress(changeEvent);
                    RxBus.getDefault().post(changeEvent);
                }
            }
            ClipPosChangeEvent event;
            if (clipPos != null && endPos.getClip() != clipPos.getClip()) {
                event = new ClipPosChangeEvent(clipPos, TAG);
                adjustProgress(event);
                RxBus.getDefault().post(event);
            }
            if (clipPos != null && endPos.getClip() == clipPos.getClip()) {
                onToLiveClick();
            }
        }
    }


    /**
     * cập nhật thay đổi progress
     * */
    private void adjustProgress(ClipPosChangeEvent event) {
        Clip clip = event.getClipPos().getClip();
        long timeOffSet = clip.getStartTimeMs() + event.getClipPos().getClipTimeMs();
        long clipDateMs = clip.getClipDateWithDST();
        List<LocalVideoAdapter.ViewItem> viewItemList = mAdapter.getViewItemList();
        int index = -1;

        for (int i = 0; i < viewItemList.size(); i++) {
            LocalVideoAdapter.ViewItem viewItem = viewItemList.get(i);
            if (viewItem.itemType != LocalVideoAdapter.TYPE_CLIP) {
                continue;
            }
            ClipCluster clipCluster = (ClipCluster) viewItem.itemObject;
            if (clipCluster != null && clipCluster.getStartTime() <= clip.getStartTimeMs() + clipDateMs
                    && clip.getDurationMs() <= clipCluster.getDuration()) {
                index = i;
                break;
            }
        }
        setPlayTime(timeOffSet + clipDateMs + clip.getOffset());
        if (index != -1) {
            ClipCluster clipCluster = null;
            Object obj = mAdapter.getViewItemObjectAt(index);
            if (obj instanceof ClipCluster) {
                clipCluster = (ClipCluster) obj;
            }
            long curTime = timeOffSet + clip.getClipDateWithDST();
            //Logger.t(TAG).d("%s", "index = " + index);
            View view = layoutManager.findViewByPosition(index);
            if (view == null || clipCluster == null) {
//                Logger.t(TAG).d("view == null || clipBeanCluster== null");
                //如果位置刚好隔了一天，此时view是null，因为视图没有加载，只能手动去scroll
                int thumbnailIndex = localThumbnailAdapter.getFirstThumbnailIndex(clipCluster);

                layoutManager.scrollToPositionWithOffset(index, -ViewUtils.dp2px(8));
                thumbnailLayoutManager.scrollToPositionWithOffset(thumbnailIndex, -ViewUtils.dp2px(8));
                return;
            }
            int height = view.getHeight();

            List<ClipSegment> clipSegList = clipCluster.getClipSegment();
            long totalClipTimeMs = 0;
            for (ClipSegment segment : clipSegList) {
                totalClipTimeMs += segment.getLength();
            }

            float scale = ((float) height) / totalClipTimeMs;
            long offset = 0;
            long viewOffset = 0;
            for (ClipSegment seg : clipSegList) {
                long startY = offset;
                long endY = (long) (startY + scale * seg.getLength());
                offset = endY;
                if (seg.startTime <= curTime && curTime <= seg.startTime + seg.duration) {
                    float inSegOffset = (endY - startY) * ((float) (seg.startTime + seg.duration - curTime)) / seg.duration;
                    viewOffset = startY + (long) inSegOffset;
                    if (seg.data instanceof Clip) {
                        Clip topClip = (Clip) seg.data;
                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.clipPosChanged(new ClipPos(topClip));
                        } else if (parentFragmentViewModel != null && parentFragmentViewModel.inputs != null) {
                            parentFragmentViewModel.inputs.clipPosChanged(new ClipPos(topClip));
                        }
                    }
                    break;
                }
            }
            //Logger.t(TAG).d("viewOffset = %d", viewOffset);
            int thumbnailIndex = localThumbnailAdapter.getFirstThumbnailIndex(clipCluster);
            thumbnailIndex += viewOffset / LocalVideoAdapter.thumbnailHeight;
            long thumbnailOffset = viewOffset % LocalVideoAdapter.thumbnailHeight;

            layoutManager.scrollToPositionWithOffset(index, LocalVideoAdapter.dividerMarginTop - (int) viewOffset);
            thumbnailLayoutManager.scrollToPositionWithOffset(thumbnailIndex, LocalVideoAdapter.dividerMarginTop - (int) thumbnailOffset);
        }
    }

    private int getCurrentPosition(int pos) {
        View view = recyclerView.findChildViewUnder(0, pos);
        if (view == null) {
            return 0;
        }
        int position = layoutManager.getPosition(view);

        Logger.t(TAG).e("pos: " + position);
        return position;
    }

    public Pair<ClipPos, ClipSegment> getCurrentClipPosAndClipSeg() {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        return getClipPosAt(0, startPos);
    }

    public ClipPos getCurrentClipPos() {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        Pair<ClipPos, ClipSegment> pair = getClipPosAt(0, startPos);
        return pair == null ? null : pair.first;
    }

    private Pair<ClipPos, ClipSegment> getClipPosAt(float x, float y) {
        int startPos = (int) y;
        View view = recyclerView.findChildViewUnder(x, y);
        if (view == null) {
            return null;
        }
        int position = layoutManager.getPosition(view);

        // top position, live view item and date header view
        if (mAdapter.getItemViewType(position) != LocalVideoAdapter.TYPE_CLIP) {
            return null;
        }
        ClipCluster clipCluster = null;
        Object obj = mAdapter.getViewItemObjectAt(position);
        if (obj instanceof ClipCluster) {
            clipCluster = (ClipCluster) obj;
        }
        if (clipCluster != null) {
            List<ClipSegment> clipSegmentList = clipCluster.getClipSegment();
            int offset = startPos - view.getTop();
            long totalClipTimeMs = 0;
            for (ClipSegment segment : clipSegmentList) {
                totalClipTimeMs += segment.getLength();
            }
            float scale = (float) view.getHeight() / totalClipTimeMs;
            int curOffset = 0;
            long absTimeOffset = 0;
            ClipSegment targetSeg = null;
            for (ClipSegment seg : clipSegmentList) {
                int endY = curOffset;
                int startY = (int) (endY + scale * seg.getLength());
                curOffset = startY;
                if (offset >= endY && offset <= startY && startY > endY) {
                    targetSeg = seg;
                    absTimeOffset = seg.startTime + (long) (seg.duration * ((float) startY - offset) / (startY - endY));
//                    Logger.t(TAG).d("%s", "offset = " + absTimeOffset);
                    break;
                }
            }
            //ClipPos clipPos = new ClipPos(clipFragment.getClip(), clipFragment.getStartTimeMs() + timeOffset);
            if (targetSeg != null && targetSeg.data instanceof Clip) {
                return new Pair<>(new ClipPos((Clip) targetSeg.data, absTimeOffset - ((Clip) targetSeg.data).getStartTimeMs() - ((Clip) targetSeg.data).getClipDateWithDST()), targetSeg);
            } else {
                return null;
            }
        }
        return null;
    }

    // fallback for duration <= 0 (bug videos)
    private Clip getClipAt(float x, float y) {
        View view = recyclerView.findChildViewUnder(x, y);
        if (view == null) {
            return null;
        }
        int position = layoutManager.getPosition(view);

        // top position, live view item and date header view
        if (mAdapter.getItemViewType(position) != LocalVideoAdapter.TYPE_CLIP) {
            return null;
        }
        ClipCluster clipCluster = null;
        Object obj = mAdapter.getViewItemObjectAt(position);
        if (obj instanceof ClipCluster) {
            clipCluster = (ClipCluster) obj;
        }
        if (clipCluster != null) {
            return clipCluster.getClipList().get(0);
        } else {
            return null;
        }
    }

    private ClipPos getClosestClipPos() {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
        if (currentView != null) {
            int currentPos = layoutManager.getPosition(currentView);
            if (mAdapter.getItemViewType(currentPos) == LocalVideoAdapter.TYPE_LIST_HEADER) {
                ClipPos clipPos = startOfNextCluster(currentPos);
                if (clipPos != null) {
                    return clipPos;
                }
            }
        }

        int maxMargin = ViewUtils.dp2px(36);
        View view = recyclerView.findChildViewUnder(0, startPos - maxMargin);
        if (view == null) {
            return null;
        }

        int position = layoutManager.getPosition(view);
        if (mAdapter.getItemViewType(position) != LocalVideoAdapter.TYPE_CLIP) {
            return null;
        }
        ClipCluster clipCluster;
        Object obj = mAdapter.getViewItemObjectAt(position);
        if (obj instanceof ClipCluster) {
            clipCluster = (ClipCluster) obj;
        } else {
            return null;
        }
        int size = clipCluster.getClipSegment().size();
        if (size > 0) {
            //last in list order, first in timeline
            ClipSegment firstClipSegment = clipCluster.getClipSegment().get(size - 1);
            return new ClipPos((Clip) firstClipSegment.data, 0);
        }
        return null;
    }

    private ClipPos startOfNextCluster(int curPos) {
        ClipCluster cluster;
        for (int pos = curPos - 1; pos >= 0; pos--) {
            Object obj = mAdapter.getViewItemObjectAt(pos);
            if (obj instanceof ClipCluster) {
                cluster = (ClipCluster) obj;
                int size = cluster.getClipSegment().size();
                if (size > 0) {
                    //last in list order, first in timeline
                    ClipSegment firstClipSegment = cluster.getClipSegment().get(size - 1);
                    return new ClipPos((Clip) firstClipSegment.data, 0);
                }
            }
        }
        return null;
    }

    private ClipPos startOfNextSegment(ClipPos endPos, ClipCluster clipCluster) {
        if (endPos == null || clipCluster == null) {
            return null;
        }
        Clip clip = endPos.getClip();
        long timeOffSet = clip.getStartTimeMs() + endPos.getClipTimeMs();
        long curTime = timeOffSet + clip.getClipDateWithDST();
        int index = -1;
        for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
            ClipSegment seg = clipCluster.getClipSegment().get(i);
            if (seg.startTime <= curTime + LocalVideoAdapter.playerTimeTolerance
                    && curTime - LocalVideoAdapter.playerTimeTolerance <= seg.startTime + seg.duration
                    && clip.equals(seg.data)) {
                index = i;
                break;
            }
        }
        if (index > 0 && index < clipCluster.getClipSegment().size()) {
            ClipSegment nextClipSegment = clipCluster.getClipSegment().get(index - 1);
            Clip nextClip = (Clip) nextClipSegment.data;
            return new ClipPos(nextClip, nextClipSegment.startTime - nextClip.getStartTimeMsAbs());
        }
        return null;
    }

    public void clearDialog() {
//        ibFilter.setVisibility(View.VISIBLE);

        Logger.t(TAG).e("clearDialog: " + DownloadManager.getManager().getJobCount());

        rlBottomToolbar.setVisibility(View.INVISIBLE);
        mAdapter.setSelectedClip(null);
    }

    private void showDialog() {
//        ibFilter.setVisibility(View.GONE);

        ViewAnimator vaContent = rlBottomToolbar.findViewById(R.id.va_content);

        if (Constants.isFleet()) {
            vaContent.setDisplayedChild(3);
            if (Constants.isLogin() /*|| Constants.isDriver()*/) {
                rlBottomToolbar.findViewById(R.id.ll_save_album_fleet).setVisibility(View.GONE);
            }
        } else {
            vaContent.setDisplayedChild(0);
        }

        Clip clip = mAdapter.getSelectedClip();
        if (clip != null) {
            String videoType = VideoEventType.getEventTypeForString(clip.getVideoType());
            Logger.t(TAG).d("videoType: " + videoType);

            int eventDrawable = VideoEventType.getEventDrawable(videoType);
            dialogViewExport.setBackgroundResource(eventDrawable);
            dialogViewExportFleet.setBackgroundResource(eventDrawable);

            int eventColor = VideoEventType.getEventColor(videoType);
            tvExportInfo.setTextColor(getResources().getColor(eventColor));
            tvExportInfoFleet.setTextColor(getResources().getColor(eventColor));

            String eventType = VideoEventType.dealEventType(getContext(), videoType);
            int durationMs = clip.getDurationMs();
            tvExportInfo.setText(String.format(Locale.US, "%s · %s", eventType,
                    StringUtils.formatDuration(durationMs / 1000)));
            tvExportInfoFleet.setText(String.format(Locale.US, "%s · %s", eventType,
                    StringUtils.formatDuration(durationMs / 1000)));

            if (clip.isLiveRecording()) {
                LinearLayout llDelete = rlBottomToolbar.findViewById(R.id.ll_delete);
                llDelete.setVisibility(View.GONE);
            } else {
                LinearLayout llDelete = rlBottomToolbar.findViewById(R.id.ll_delete);
                llDelete.setVisibility(View.VISIBLE);
            }
            rlBottomToolbar.setVisibility(View.VISIBLE);
            ((TextView) rlBottomToolbar.findViewById(R.id.tv_delete_tips)).setText(R.string.video_delete_tips);
        }
    }

    /**
     * khởi tạo handler dialogCallback
     * */
    private void registerDialogCallback() {
        LinearLayout llExportInfo = rlBottomToolbar.findViewById(R.id.ll_export_info);
        LinearLayout llExportInfoFleet = rlBottomToolbar.findViewById(R.id.ll_export_info_fleet);
        LinearLayout llDownload = rlBottomToolbar.findViewById(R.id.ll_download);
        LinearLayout llDelete = rlBottomToolbar.findViewById(R.id.ll_delete);
//        ImageButton btnCancel = rlBottomToolbar.findViewById(R.id.ib_cancel);

        Button btnDelete = rlBottomToolbar.findViewById(R.id.btn_delete);
        Button btnCancel = rlBottomToolbar.findViewById(R.id.btn_delete_cancel);

        llExportInfo.setOnClickListener(v -> showClipDetail());

        llExportInfoFleet.setOnClickListener(v -> showClipDetail());

        llDownload.setOnClickListener(v -> {

            String sn = serialNumber;
            if (viewModel.mCamera != null && TextUtils.isEmpty(sn)) {
                sn = viewModel.mCamera.getSerialNumber();
            }
            Clip selectedClip = mAdapter.getSelectedClip();
            ClipPos currentClipPos = getCurrentClipPos();
            VideoStreamType streamType = parentFragmentViewModel != null ?
                    parentFragmentViewModel.mStreamType : VideoStreamType.Panorama;
            if (selectedClip != null
                    && currentClipPos != null && currentClipPos.clip != null
                    && currentClipPos.clip.cid.equals(selectedClip.cid)) {
                ScaleActivity.launch(getActivity(), selectedClip, currentClipPos, sn, -1, streamType);
            } else {
                ScaleActivity.launch(getActivity(), selectedClip, null, sn, -1, streamType);
            }
            onToLiveClick();
            //vaContent.setDisplayedChild(1);
//            clearDialog();
        });

        llDelete.setOnClickListener(v -> {
            ViewAnimator vaContent = rlBottomToolbar.findViewById(R.id.va_content);
            vaContent.setDisplayedChild(1);
        });

        btnDelete.setOnClickListener(v -> {
            Toast.makeText(mContext, R.string.deleted, Toast.LENGTH_SHORT).show();
            deleteClip(mAdapter.getSelectedClip());
            clearDialog();
        });

        btnCancel.setOnClickListener(v -> clearDialog());

        rlBottomToolbar.findViewById(R.id.ll_save_album_fleet).setOnClickListener(v -> {
            launchScale(0);
            onToLiveClick();

//            clearDialog();
        });

        rlBottomToolbar.findViewById(R.id.ll_save_library_fleet).setOnClickListener(v -> {
            launchScale(1);
            onToLiveClick();

//            clearDialog();
        });

        rlBottomToolbar.findViewById(R.id.ll_share_waylens_fleet).setOnClickListener(v -> {
            launchScale(2);
            onToLiveClick();

//            clearDialog();
        });

        rlBottomToolbar.findViewById(R.id.btn_export_cancel_fleet).setOnClickListener(v -> clearDialog());

    }

    private void launchScale(int choice) {
        String sn = serialNumber;
        if (viewModel.mCamera != null && TextUtils.isEmpty(sn)) {
            sn = viewModel.mCamera.getSerialNumber();
        }
        Clip selectedClip = mAdapter.getSelectedClip();
        ClipPos currentClipPos = getCurrentClipPos();
        VideoStreamType streamType = parentFragmentViewModel != null
                ? parentFragmentViewModel.mStreamType : VideoStreamType.Panorama;
        if (selectedClip != null
                && currentClipPos != null && currentClipPos.clip != null
                && currentClipPos.clip.cid.equals(selectedClip.cid)) {
            ScaleActivity.launch(getActivity(), selectedClip, currentClipPos, sn, choice, streamType);
        } else {
            ScaleActivity.launch(getActivity(), selectedClip, null, sn, choice, streamType);
        }
    }

    /**
     * hiển thị chi tiết clip
     * */
    private void showClipDetail() {
        FrameLayout frameLayout = getActivity().getWindow().getDecorView().findViewById(android.R.id.content);
        View view = LayoutInflater.from(mContext).inflate(R.layout.layout_guide_detail, null);
        view.setOnTouchListener((v12, event) -> true);

        if (Constants.isFleet()) {
            view.findViewById(R.id.ll_behavior).setVisibility(View.VISIBLE);
        }

        view.findViewById(R.id.layout_guide_detail)
                .findViewById(R.id.tv_skip_guide).setVisibility(View.GONE);

        TextView tvGoGuide = view.findViewById(R.id.layout_guide_detail)
                .findViewById(R.id.btn_go_guide);
        tvGoGuide.setText(R.string.export_done);
        tvGoGuide.setOnClickListener(v1 -> frameLayout.removeView(view));

        frameLayout.addView(view);
    }
    /**
     * xóa clip
     * */
    private void deleteClip(Clip clip) {
        if (clip == null) {
            return;
        }
        viewModel.deleteClip(clip)
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> deleteSuccess(clip), new ServerErrorHandler());
    }

    private void deleteSuccess(Clip clip) {
        CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
        boolean deleteClip = camera.getClipsManager().deleteClip(clip);

        Logger.t(TAG).e("deleteClip: " + deleteClip);
        if (deleteClip) {
            Toast.makeText(mContext, R.string.deleted, Toast.LENGTH_SHORT).show();
            if (parentViewModel != null) {
                viewModel.loadClips(parentViewModel.filterList, true);
            } else if (parentFragmentViewModel != null) {
                viewModel.loadClips(parentFragmentViewModel.filterList, true);
            }

            //跳转到live下
//            onToLiveClick();
        }
    }


    /**
     * add bookmark
     * */
    public void doAddBookmark() {
        Pair<ClipPos, ClipSegment> pair = getCurrentClipPosAndClipSeg();
        ClipPos clipPos = pair != null ? pair.first : null;
        ClipSegment clipSegment = pair != null ? pair.second : null;
        Logger.t(TAG).d("clipPos = %s", clipPos);
        if (clipPos != null) {
            Logger.t(TAG).d("video type = %s", clipPos.clip.getVideoType());
        }
        if (clipPos == null || clipPos.clip.getVideoType() != VideoEventType.TYPE_BUFFERED) {
            return;
        }
        Logger.t(TAG).d("%s", "add bookmark");

        long startTimeMs = clipPos.getClipTimeMs() + clipPos.clip.getStartTimeMs() - VdtCamera.getHalfMarkTime();
        long endTimeMs = clipPos.getClipTimeMs() + clipPos.clip.getStartTimeMs() + VdtCamera.getHalfMarkTime();

//        Logger.t(TAG).d("start = %d  end - %d", clipSegment.getStartTime(), clipSegment.getEndTime());

        startTimeMs = Math.max(startTimeMs, clipSegment.getStartTime() - clipPos.getClip().getClipDateWithDST());
        endTimeMs = Math.min(endTimeMs, clipSegment.getEndTime() - clipPos.getClip().getClipDateWithDST());

        SnipeApi.addHighlightRx(clipPos.cid, startTimeMs, endTimeMs)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(integer -> Logger.t(TAG).d("add bookmark res = %d", integer), new ServerErrorHandler());
    }

    /**
     * Sự kiện MarkLiveMsg
     * */
    public void onEventMarkLiveMsg(MarkLiveMsgEvent event) {
        //Logger.t(TAG).d("%s", "clipInfoMsgEvent");
        CameraWrapper camera = event.getCamera();
        if (camera != null && viewModel.mCamera != null && camera.getSerialNumber().equals(viewModel.mCamera.getSerialNumber())) {
            ClipActionInfo actionInfo = event.getClipActionInfo();

            if (actionInfo == null) {
                boolean markLiveState = event.getMarkLiveState();
//                Logger.t(TAG).e("markLiveState: " + markLiveState);
                if (markLiveState) {
                    Toast.makeText(mContext, R.string.highlight_successfully, Toast.LENGTH_SHORT).show();
                }
                return;
            }
            Clip tempClip = actionInfo.clip;

            if (actionInfo.action == ClipActionInfo.CLIP_ACTION_CREATED) {
                Logger.t(TAG).d("%s", "new clip created");
                if (parentViewModel != null) {
                    viewModel.loadClips(parentViewModel.filterList, false);
                } else if (parentFragmentViewModel != null) {
                    viewModel.loadClips(parentFragmentViewModel.filterList, false);
                }
            } else if (actionInfo.action == ClipActionInfo.CLIP_ACTION_FINISHED) {
                Logger.t(TAG).d("%s", "new clip finished");
                if (parentViewModel != null) {
                    viewModel.loadClips(parentViewModel.filterList, false);
                } else if (parentFragmentViewModel != null) {
                    viewModel.loadClips(parentFragmentViewModel.filterList, false);
                }
            }
        }
    }

    private void setPlayTime(long time) {
        tvPlayTime.setText(DateFormat.is24HourFormat(mContext) ?
                DateTime.get24HTimeString(time, true) : DateTime.get12HTimeString(time, true));
        Map<String, Integer> clipCountMap = mAdapter.getClipCountMap();
        Integer count = clipCountMap.get(mAdapter.getFormattedDate(time));

        if (count != null) {
            tvVideoStat.setText(String.format(getString(R.string.video_count_string), mAdapter.getFormattedDate(time), count,
                    count > 1 ? getString(R.string.videos) : getString(R.string.video)));

            if (Constants.isFleet()) {
                localDateAdapter.setPlayTime(time);
            }
        }
    }

    public Clip getCurrentPosClip(float x, float y) {
        Pair<ClipPos, ClipSegment> pair = getClipPosAt(x, y);
        ClipPos clipPos = pair != null ? pair.first : null;
        Clip clip;
        if (clipPos != null) {
            clip = clipPos.clip;
        } else {
            clip = getClipAt(x, y);
        }
        return clip;
    }

    public void scrollToStartTime(long startTime) {
        Logger.t(TAG).e("scrollToStartTime: " + startTime);
        this.mStartTimeMs = startTime;
    }

    private boolean onSingleTap(float x, float y) {
        Clip clip = getCurrentPosClip(x, y);
        if (clip == null) {
            return false;
        }

        if (mAdapter.getSelectedClip() != null) {
            mAdapter.setSelectedClip(null);
            clearDialog();
        } else {
            mAdapter.setSelectedClip(clip);
            tv_liveView.setVisibility(View.INVISIBLE);
            hideNavigation();

            showDialog();

            ClipPosChangeEvent changeEvent = new ClipPosChangeEvent(new ClipPos(clip, 0), TAG);
            adjustProgress(changeEvent);
            RxBus.getDefault().post(changeEvent);
        }
        return true;
    }

    public GestureDetector gestureDetector = new GestureDetector(mContext, new DefOnGestureListener() {
        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            float y = e.getY();
            float x = e.getX();

            return onSingleTap(x, y);
        }
    });

    public GestureDetector dateGesture = new GestureDetector(mContext, new DefOnGestureListener() {

        private int mPos = 1;

        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            return onTouchDateList(e.getX(), e.getY(), false);
        }

        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            return onTouchDateList(e2.getX(), e2.getY(), true);
        }

        private boolean onTouchDateList(float x, float y, boolean isScroll) {
            View childViewUnder = rvDate.findChildViewUnder(x, y);
            if (childViewUnder == null) {
                return false;
            }

            int position = dateLayoutManager.getPosition(childViewUnder);
            if (mPos == position) {
                return false;
            } else {
                mPos = position;
            }

            int itemViewType = localDateAdapter.getItemViewType(position);

            if (itemViewType != LocalDateAdapter.TYPE_DATE) {
                Object objectAt = localDateAdapter.getViewItemObjectAt(position);

                if (objectAt instanceof ClipCluster) {
                    List<Clip> clipList = ((ClipCluster) objectAt).getClipList();
                    Clip clip = clipList.get(0);

                    if (clip != null) {
                        tv_liveView.setVisibility(View.INVISIBLE);
                        hideNavigation();

                        localDateAdapter.setPlayDate(position);
                        ClipPosChangeEvent event = new ClipPosChangeEvent(new ClipPos(clip, 0), TAG);
                        adjustProgress(event);
                        if (isScroll) {
                            mIntentClip = clip;
                            RxBus.getDefault().post(new ClipPosChangeEvent(new ClipPos(clip, 0), TAG, ClipPosChangeEvent.INTENT_SHOW_THUMBNAIL));
                        } else {
                            RxBus.getDefault().post(event);
                        }
                    }
                }
            }
            return true;
        }
    });

    public RecyclerView.OnScrollListener dateScroll = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
            super.onScrollStateChanged(recyclerView, newState);
            if (newState == SCROLL_STATE_IDLE) {
                if (mIntentClip != null) {
                    RxBus.getDefault().post(new ClipPosChangeEvent(new ClipPos(mIntentClip, 0), TAG));
                    mIntentClip = null;
                }
            }
        }
    };

    RecyclerView.OnScrollListener scrollListener = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
            super.onScrollStateChanged(recyclerView, newState);
            if (newState == SCROLL_STATE_IDLE) {

                View view = recyclerView.findChildViewUnder(0, LocalVideoAdapter.dividerMarginTop);
                if (view != null) {
                    int position = layoutManager.getPosition(view);
                    // top position, live view
                    if (position == 0 || position == 1) {
                        Logger.t(TAG).d("%s", " live view position ");
                        onToLiveClick();
                        return;
                    }
                }

                ClipPos clipPos = getCurrentClipPos();
                if (clipPos == null) {
                    clipPos = getClosestClipPos();
                    Logger.t(TAG).d("closest clip pos = " + clipPos);
                    if (clipPos != null) {
                        adjustProgress(new ClipPosChangeEvent(clipPos, TAG));
                    }
                }
                ClipPosChangeEvent event;
                if (clipPos != null) {
                    Logger.t(TAG).d("onScrollStateChanged SCROLL_STATE_IDLE: " + clipPos.getClipTimeMs());
                    event = new ClipPosChangeEvent(clipPos, TAG);
                    Logger.t(TAG).d("%s", "post event");
                    RxBus.getDefault().post(event);
                    tv_liveView.setVisibility(View.INVISIBLE);
//                    hideNavigation();
                }
            }
        }

        private int totalDy = 0;

        @Override
        public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
            if (dx == 0 && dy == 0) {
                return;
            }
            rvThumbnail.scrollBy(dx, dy);

            if (totalDy > 0 && dy < 0) {
                totalDy = 0;
            } else if (totalDy < 0 && dy > 0) {
                totalDy = 0;
            }
            totalDy += dy;

            if (totalDy > 188) {
                hideNavigation();
            } else if (totalDy < -188) {
                showNavigation();
            }

            ClipPos clipPos = getCurrentClipPos();

            if (clipPos != null) {
                tv_liveView.setVisibility(View.INVISIBLE);

                if (parentViewModel != null && parentViewModel.inputs != null) {
                    parentViewModel.inputs.clipPosChanged(clipPos);
                } else if (parentFragmentViewModel != null && parentFragmentViewModel.inputs != null) {
                    parentFragmentViewModel.inputs.clipPosChanged(clipPos);
                }
                setPlayTime(clipPos.getClipTimeMs() + clipPos.getClip().getStartTimeMsAbs() + clipPos.clip.getOffset());

                ClipPosChangeEvent event = null;
                if (recyclerView.getScrollState() != SCROLL_STATE_IDLE) {
                    event = new ClipPosChangeEvent(clipPos, TAG, ClipPosChangeEvent.INTENT_SHOW_THUMBNAIL);
                }
                if (event != null) {
                    RxBus.getDefault().post(event);
                }
            }
        }
    };

    public void hideNavigation() {
        ibFilter.setVisibility(VISIBLE);
        btnToLive.setVisibility(VISIBLE);

        Logger.t(TAG).d("hideNavigation");
        Fragment parentFragment = getParentFragment();
        if (parentFragment instanceof CameraViewFragment) {
            CameraViewFragment cameraViewFragment = (CameraViewFragment) parentFragment;
            cameraViewFragment.toolbar4K.setVisibility(View.GONE);
        }

        FragmentActivity parentActivity = getActivity();
        if (parentActivity instanceof VideosActivity) {
            VideosActivity videosActivity = (VideosActivity) parentActivity;
//            videosActivity.toolbar4K.setVisibility(View.GONE);
        }

        FragmentActivity activity = (FragmentActivity) mContext;
        if (activity instanceof LocalLiveActivity) {
            LocalLiveActivity liveActivity = (LocalLiveActivity) activity;
            liveActivity.showOrHideNavigation(View.GONE);
        }
    }

    public void showNavigation() {
        ibFilter.setVisibility(View.GONE);
        btnToLive.setVisibility(View.GONE);

        if (rlBottomToolbar.getVisibility() == VISIBLE) {
            clearDialog();
        }

        Logger.t(TAG).d("showNavigation");
        Fragment parentFragment = getParentFragment();
        if (parentFragment instanceof CameraViewFragment) {
            CameraViewFragment cameraViewFragment = (CameraViewFragment) parentFragment;
            CameraWrapper mCamera = cameraViewFragment.mCamera;
            if (mCamera != null && mCamera.getHardwareModel() == ICameraWrapper.Model.TW06) {
                cameraViewFragment.toolbar4K.setVisibility(VISIBLE);
            }
        }

        FragmentActivity parentActivity = getActivity();
        if (parentActivity instanceof VideosActivity) {
            VideosActivity videosActivity = (VideosActivity) parentActivity;
            CameraWrapper mCamera = videosActivity.mCamera;
            if (mCamera != null && mCamera.getHardwareModel() == ICameraWrapper.Model.TW06) {
//                videosActivity.toolbar4K.setVisibility(VISIBLE);
            }
        }

        FragmentActivity activity = (FragmentActivity) mContext;
        if (activity instanceof LocalLiveActivity) {
            LocalLiveActivity liveActivity = (LocalLiveActivity) activity;
            liveActivity.showOrHideNavigation(VISIBLE);
        }
    }
}

