package com.mk.autosecure.ui.fragment;

import static android.view.View.VISIBLE;
import static com.mk.autosecure.libs.utils.ClipBeanUtils.startOfNextSegment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
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
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.Postcard;
import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.ExportActivity;
import com.mk.autosecure.ui.activity.LiveViewActivity;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.VideosActivity;
import com.mk.autosecure.ui.adapter.CloudThumbnailAdapter;
import com.mk.autosecure.ui.adapter.CloudVideoAdapter;
import com.mk.autosecure.ui.adapter.LocalVideoAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import android.widget.Toast;

import com.mk.autosecure.ui.view.CustomRecyclerView;
import com.mk.autosecure.ui.view.listener.DefOnGestureListener;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.utils.DateTime;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.EventBeanUtils;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipBeanCluster;
import com.mk.autosecure.model.ClipBeanPos;
import com.mk.autosecure.model.ClipBeanPosChangeEvent;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.model.EventBeanCluster;
import com.mk.autosecure.model.EventBeanPos;
import com.mk.autosecure.model.EventBeanPosChangeEvent;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.BindDeviceResponse;
import com.mk.autosecure.rest.request.BindDeviceBody;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.LiveViewViewModel;
import com.mk.autosecure.viewmodels.VideosActivityViewModel;
import com.mk.autosecure.viewmodels.fragment.CameraViewFragmentViewModel;
import com.mk.autosecure.viewmodels.fragment.CloudViewFragmentViewModel;
import com.mk.autosecure.viewmodels.fragment.RemoteVideoViewModel;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/9/22.
 */


@RequiresFragmentViewModel(RemoteVideoViewModel.ViewModel.class)
public class RemoteVideoFragment extends BaseFragment<RemoteVideoViewModel.ViewModel> {

    private static final String TAG = RemoteVideoFragment.class.getSimpleName();

    @BindView(R.id.rv_thumbnail)
    CustomRecyclerView rv_thumbnail;

    @BindView(R.id.recycler_view)
    RecyclerView recyclerView;

    @BindView(R.id.tv_videoStat)
    TextView tv_videoStat;

    @BindView(R.id.tv_playTime)
    TextView tv_playTime;

    @BindView(R.id.tv_liveView)
    TextView tv_liveView;

    @BindView(R.id.btn_toLive)
    ImageButton btnToLive;

    @BindView(R.id.ib_filter)
    ImageButton ibFilter;

    @BindView(R.id.va_base)
    ViewAnimator va_base;

    @BindView(R.id.rl_bottomToolbar)
    RelativeLayout rlBottomToolbar;

    @BindView(R.id.tv_no_videos_tips)
    TextView tv_no_videos_tips;

    @BindView(R.id.tv_user_tips)
    TextView tv_user_tips;

    @BindView(R.id.btn_user_action)
    Button btn_user_action;

    @BindView(R.id.dialog_view_export)
    View dialog_view_export;

    @BindView(R.id.tv_export_info)
    TextView tv_export_info;

    private VideosActivityViewModel.ViewModel videosViewModel;

    private LiveViewViewModel.ViewModel liveViewViewModel;

    private CameraViewFragmentViewModel.ViewModel cameraFragmentViewModel;

    private CloudViewFragmentViewModel.ViewModel cloudFragmentViewModel;

    private CameraBean mCameraBean;

    private FleetCameraBean mFleetCamera;

    private CloudVideoAdapter mVideoAdapter;

    private CloudThumbnailAdapter mThumbnailAdapter;

    private LinearLayoutManager mVideoManager;

    private LinearLayoutManager mThumbnailManager;

    public Map<String, Integer> clipListStat = new HashMap<>();

    private long clipID = -1;

    @OnClick(R.id.btn_toLive)
    public void onToLiveClick() {
        recyclerView.scrollToPosition(0);
        rv_thumbnail.scrollToPosition(0);
        tv_liveView.setVisibility(View.VISIBLE);
        showNavigation();

        if (mCameraBean != null) {
            setPlayTime(
                    Math.max(mCameraBean.onlineStatusChangeTime == null ? 0 : mCameraBean.onlineStatusChangeTime,
                            mCameraBean.thumbnailTime == null ? 0 : mCameraBean.thumbnailTime));
        } else if (mFleetCamera != null) {
//            setPlayTime(
//                    Math.max(mFleetCamera.getOnlineStatus() == null ? 0 : mFleetCamera.getOnlineStatus().getLastConnectTime(),
//                            mFleetCamera.getOnlineStatus() == null ? 0 : mFleetCamera.getOnlineStatus().getLastDisconnectTime()));
        }
        if (Constants.isFleet()) {
            RxBus.getDefault().post(new EventBeanPosChangeEvent(null, TAG, EventBeanPosChangeEvent.INTENT_LIVE));
        } else {
            RxBus.getDefault().post(new ClipBeanPosChangeEvent(null, TAG, ClipBeanPosChangeEvent.INTENT_LIVE));
        }
    }

    @OnClick(R.id.ib_filter)
    public void showFilter() {
        ibFilter.setVisibility(View.GONE);

        if (videosViewModel != null) {
            videosViewModel.filterVisibility(View.VISIBLE);
        } else if (liveViewViewModel != null) {
            liveViewViewModel.filterVisibility(View.VISIBLE);
        } else if (cameraFragmentViewModel != null) {
            cameraFragmentViewModel.filterVisibility(View.VISIBLE);
        } else if (cloudFragmentViewModel != null) {
            cloudFragmentViewModel.filterVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.btn_user_action)
    public void userAction() {
        String s = btn_user_action.getText().toString();
        if (s.equals(getString(R.string.camera_unbind_action))) {
            CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
            if (camera != null) {
                BindDeviceBody deviceBody = new BindDeviceBody();
                deviceBody.name = camera.getName();
                deviceBody.password = camera.getPassword();
                deviceBody.sn = camera.getSerialNumber();

                ApiService.createApiService().bindDeviceRes(deviceBody)
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doOnError(throwable -> NetworkErrorHelper.handleCommonError(getActivity(), throwable))
                        .subscribe(new BaseObserver<Response<BindDeviceResponse>>() {
                            @Override
                            protected void onHandleSuccess(Response<BindDeviceResponse> data) {
                                boolean result = data.body().result;
                                Logger.t(TAG).d("bindDeviceRes onHandleSuccess: " + result);
                                if (result) {
                                    LocalLiveActivity.launch(getActivity(), true);
                                }
                            }
                        });
            }
        } else if (s.equals(getString(R.string.log_in))) {
            LoginActivity.launch(getActivity());
        }
    }

    public static RemoteVideoFragment newInstance(CameraBean cameraBean) {
        RemoteVideoFragment fragment = new RemoteVideoFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(IntentKey.CAMERA_BEAN, cameraBean);
        fragment.setArguments(bundle);
        return fragment;
    }

    public static RemoteVideoFragment newInstance(FleetCameraBean camerasBean) {
        RemoteVideoFragment fragment = new RemoteVideoFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(IntentKey.FLEET_CAMERA, camerasBean);
        fragment.setArguments(bundle);
        return fragment;
    }

    private Context mContext;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;

        if (context instanceof VideosActivity) {
            videosViewModel = ((VideosActivity) context).viewModel();
        } else if (context instanceof LiveViewActivity) {
            liveViewViewModel = ((LiveViewActivity) context).viewModel();
        } else {
            Fragment parentFragment = getParentFragment();
            if (parentFragment instanceof CameraViewFragment) {
                cameraFragmentViewModel = ((CameraViewFragment) parentFragment).viewModel();
            } else if (parentFragment instanceof CloudViewFragment) {
                cloudFragmentViewModel = ((CloudViewFragment) parentFragment).viewModel();
            }
        }
    }

    @Override
    public @Nullable
    View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_videos, container, false);
        ButterKnife.bind(this, view);

        Bundle arguments = getArguments();
        if (arguments != null) {
            mCameraBean = (CameraBean) arguments.getSerializable(IntentKey.CAMERA_BEAN);
            mFleetCamera = (FleetCameraBean) arguments.getSerializable(IntentKey.FLEET_CAMERA);
        }

        mVideoAdapter = new CloudVideoAdapter(mContext);
        mThumbnailAdapter = new CloudThumbnailAdapter(mContext);

        mVideoManager = new LinearLayoutManager(getActivity());
        mThumbnailManager = new LinearLayoutManager(getActivity());

        recyclerView.setLayoutManager(mVideoManager);
        rv_thumbnail.setLayoutManager(mThumbnailManager);

        OverScrollDecoratorHelper.setUpOverScroll(recyclerView, OverScrollDecoratorHelper.ORIENTATION_VERTICAL);

        recyclerView.setAdapter(mVideoAdapter);
        rv_thumbnail.setAdapter(mThumbnailAdapter);

        if (liveViewViewModel != null) {
            //更新直播的时间戳
            liveViewViewModel.liveTime()
                    .compose(bindToLifecycle())
                    .throttleFirst(500, TimeUnit.MILLISECONDS)
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::setPlayTime, new ServerErrorHandler(TAG));
        } else if (cloudFragmentViewModel != null) {
            //更新直播的时间戳
            cloudFragmentViewModel.liveTime()
                    .compose(bindToLifecycle())
                    .throttleFirst(500, TimeUnit.MILLISECONDS)
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this::setPlayTime, new ServerErrorHandler(TAG));
        }

        recyclerView.setOnTouchListener((v, event) -> gestureDetector.onTouchEvent(event));

        recyclerView.addOnScrollListener(scrollListener);

        registerDialogCallback();

        return view;
    }

    private void filterVisibility(Integer visibility) {
        Logger.t(TAG).d("filterVisibility: " + visibility);
        ibFilter.setVisibility(visibility);
    }

    private void filterShow(Integer resource) {
        Logger.t(TAG).d("filterShow: " + resource);
        ibFilter.setImageResource(resource);
    }

    private void onClipListStat(Map<String, Integer> stringIntegerMap) {
        this.clipListStat = stringIntegerMap;
        if (videosViewModel != null) {
            videosViewModel.filterClipBean(stringIntegerMap, videosViewModel.filterList);
        } else if (liveViewViewModel != null) {
            liveViewViewModel.filterClipBean(stringIntegerMap, liveViewViewModel.filterList);
        } else if (cameraFragmentViewModel != null) {
            cameraFragmentViewModel.filterClipBean(stringIntegerMap, cameraFragmentViewModel.filterList);
        } else if (cloudFragmentViewModel != null) {
            cloudFragmentViewModel.filterClipBean(stringIntegerMap, cloudFragmentViewModel.filterList);
        }
    }

    private void onClipBeanPosChangeEvent(ClipBeanPosChangeEvent event) {
//        Logger.t(TAG).d("onClipBeanPosChangeEvent: " + event.getIntent() + "--" + event.getPublisher());
        if (event.getPublisher().equals(VideosActivity.class.getSimpleName())
                || event.getPublisher().equals(LiveViewActivity.class.getSimpleName())
                || event.getPublisher().equals(CameraViewFragment.class.getSimpleName())
                || event.getPublisher().equals(CloudViewFragment.class.getSimpleName())) {

            if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY_END) {
                Logger.t(TAG).d("INTENT_PLAY_END");
                tryPlayNext(event.getClipBeanPos());
                clearDialog();
                return;
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
                Logger.t(TAG).d("INTENT_LIVE");
                onToLiveClick();
                return;
            }

//            Logger.t(TAG).d("%s", "process event");
            if (videosViewModel != null && !videosViewModel.isLiveOrNot) {
                adjustProgress(event);
            } else if (liveViewViewModel != null && !liveViewViewModel.isLiveOrNot) {
                adjustProgress(event);
            } else if (cameraFragmentViewModel != null && !cameraFragmentViewModel.isLiveOrNot) {
                adjustProgress(event);
            } else if (cloudFragmentViewModel != null && !cloudFragmentViewModel.isLiveOrNot) {
                adjustProgress(event);
            }
        }
    }

    private void onEventBeanPosChangeEvent(EventBeanPosChangeEvent event) {
        if (event.getPublisher().equals(VideosActivity.class.getSimpleName())
                || event.getPublisher().equals(LiveViewActivity.class.getSimpleName())
                || event.getPublisher().equals(CameraViewFragment.class.getSimpleName())
                || event.getPublisher().equals(CloudViewFragment.class.getSimpleName())) {

            if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_PLAY_END) {
                Logger.t(TAG).d("INTENT_PLAY_END");
                tryPlayNextFleet(event.getClipBeanPos());
                clearDialog();
                return;
            } else if (event.getIntent() == ClipBeanPosChangeEvent.INTENT_LIVE) {
                Logger.t(TAG).d("INTENT_LIVE");
                onToLiveClick();
                return;
            }

//            Logger.t(TAG).d("%s", "process event");
            if (videosViewModel != null && !videosViewModel.isLiveOrNot) {
                adjustProgressFleet(event);
            } else if (liveViewViewModel != null && !liveViewViewModel.isLiveOrNot) {
                adjustProgressFleet(event);
            } else if (cameraFragmentViewModel != null && !cameraFragmentViewModel.isLiveOrNot) {
                adjustProgressFleet(event);
            } else if (cloudFragmentViewModel != null && !cloudFragmentViewModel.isLiveOrNot) {
                adjustProgressFleet(event);
            }
        }
    }

    private void onClipBeanList(List<ClipBean> clipBeanList) {
        Logger.t(TAG).d("onClipBeanList size = " + clipBeanList.size());

        if (clipBeanList.size() == 0) {
            va_base.setDisplayedChild(4);
            tv_no_videos_tips.setText(R.string.cloud_no_videos);
        } else {
            va_base.setDisplayedChild(0);

            mVideoAdapter.setClipList(clipBeanList);
            mThumbnailAdapter.setClipList(clipBeanList);

            if (mCameraBean != null) {
                setPlayTime(
                        Math.max(mCameraBean.onlineStatusChangeTime == null ? 0 : mCameraBean.onlineStatusChangeTime,
                                mCameraBean.thumbnailTime == null ? 0 : mCameraBean.thumbnailTime));
            }

            if (clipID != -1) {
                ClipBean selectClip = null;
                for (ClipBean clipBean : clipBeanList) {
                    if (clipBean.clipID == clipID) {
                        selectClip = clipBean;
                        break;
                    }
                }

                clipID = -1;

                if (selectClip != null) {
                    tv_liveView.setVisibility(View.GONE);
                    hideNavigation();

                    Logger.t(TAG).e("selectClip: " + DateTime.get24HTimeWithoutSec(selectClip.captureTime, false));

                    ClipBeanPosChangeEvent changeEvent = new ClipBeanPosChangeEvent(new ClipBeanPos(selectClip, 0), TAG);
                    adjustProgress(changeEvent);
                    RxBus.getDefault().post(changeEvent);
                }
            }

            recyclerView.post(() -> {
                int height = recyclerView.getMeasuredHeight() + ViewUtils.dp2px(49);
//                Logger.t(TAG).d("recycleView Height = " + height);
                mVideoAdapter.setBottomMargin(height);
                mThumbnailAdapter.setBottomMargin(height);
            });
        }
    }

    private void onEventsBeanList(List<EventBean> eventBeanList) {
        Logger.t(TAG).d("onEventsBeanList size = " + eventBeanList.size());

        if (eventBeanList.size() == 0) {
            va_base.setDisplayedChild(4);
            tv_no_videos_tips.setText(R.string.cloud_no_videos);
        } else {
            va_base.setDisplayedChild(0);

            mVideoAdapter.setEventsList(eventBeanList);
            mThumbnailAdapter.setEventsList(eventBeanList);

            if (mFleetCamera != null) {
//                setPlayTime(
//                        Math.max(mFleetCamera.getOnlineStatus() == null ? 0 : mFleetCamera.getOnlineStatus().getLastConnectTime(),
//                                mFleetCamera.getOnlineStatus() == null ? 0 : mFleetCamera.getOnlineStatus().getLastDisconnectTime()));
            }

//            if (clipID != -1) {
//                ClipBean selectClip = null;
//                for (ClipBean clipBean : clipBeanList) {
//                    if (clipBean.clipID == clipID) {
//                        selectClip = clipBean;
//                        break;
//                    }
//                }
//
//                clipID = -1;
//
//                if (selectClip != null) {
//                    tv_liveView.setVisibility(View.GONE);
//                    btnToLive.setVisibility(View.VISIBLE);
//
//                    Logger.t(TAG).e("selectClip: " + DateTime.get24HTimeWithoutSec(selectClip.captureTime, false));
//
//                    ClipBeanPosChangeEvent changeEvent = new ClipBeanPosChangeEvent(new ClipBeanPos(selectClip, 0), TAG);
//                    adjustProgress(changeEvent);
//                    RxBus.getDefault().post(changeEvent);
//                }
//            }

            recyclerView.post(() -> {
                int height = recyclerView.getMeasuredHeight();
//                                Logger.t(TAG).d("recycleView Height = " + height);
                mVideoAdapter.setBottomMargin(height);
                mThumbnailAdapter.setBottomMargin(height);
            });
        }
    }

    private void deleteSuccess() {
        Toast.makeText(getActivity(), R.string.deleted, Toast.LENGTH_SHORT).show();
        if (videosViewModel != null) {
            viewModel.inputs.loadClipBean(videosViewModel.filterList, false);
        } else if (liveViewViewModel != null) {
            viewModel.inputs.loadClipBean(liveViewViewModel.filterList, false);
        } else if (cameraFragmentViewModel != null) {
            viewModel.inputs.loadClipBean(cameraFragmentViewModel.filterList, false);
        } else if (cloudFragmentViewModel != null) {
            viewModel.inputs.loadClipBean(cloudFragmentViewModel.filterList, false);
        }

        //跳转到live下
        onToLiveClick();
    }

    private void apiError(ErrorEnvelope error) {
        Toast.makeText(getActivity(), error.getErrorMessage(), Toast.LENGTH_SHORT).show();
    }

    private void networkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(getActivity(), throwable);
    }

    @Override
    public void onResume() {
        super.onResume();
        initEvents();
        checkCameraStatus();
    }

    @SuppressLint("CheckResult")
    private void initEvents() {
        RxBus.getDefault().toObservable(ClipBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipBeanPosChangeEvent, new ServerErrorHandler());

        RxBus.getDefault().toObservable(EventBeanPosChangeEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventBeanPosChangeEvent, new ServerErrorHandler());

        viewModel.outputs.filterVisibility()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::filterVisibility, new ServerErrorHandler());

        viewModel.outputs.filterShow()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::filterShow, new ServerErrorHandler());

        viewModel.outputs.clipListStat()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipListStat, new ServerErrorHandler());

        viewModel.outputs.clipBeanList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onClipBeanList, new ServerErrorHandler());

        viewModel.outputs.eventsBeanList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onEventsBeanList, new ServerErrorHandler());

        viewModel.outputs.deleteSuccess()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(voidOptional -> deleteSuccess(), new ServerErrorHandler());

        viewModel.errors.apiError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::apiError, new ServerErrorHandler());

        viewModel.errors.networkError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::networkError, new ServerErrorHandler());
    }

    private void checkCameraStatus() {
        CurrentUser currentUser = HornApplication.getComponent().currentUser();
        if (currentUser.exists()) {
            if (mCameraBean != null) {
                viewModel.inputs.setSerialNumber(mCameraBean.sn);
                if (videosViewModel != null) {
                    viewModel.inputs.loadClipBean(videosViewModel.filterList, false);
                } else if (liveViewViewModel != null) {
                    viewModel.inputs.loadClipBean(liveViewViewModel.filterList, false);
                } else if (cameraFragmentViewModel != null) {
                    viewModel.inputs.loadClipBean(cameraFragmentViewModel.filterList, false);
                } else if (cloudFragmentViewModel != null) {
                    viewModel.inputs.loadClipBean(cloudFragmentViewModel.filterList, false);
                }
            } else if (mFleetCamera != null) {
                viewModel.inputs.setSerialNumber(mFleetCamera.getSn());
                if (videosViewModel != null) {
                    viewModel.inputs.loadClipBean(videosViewModel.filterList, false);
                } else if (liveViewViewModel != null) {
                    viewModel.inputs.loadClipBean(liveViewViewModel.filterList, false);
                } else if (cameraFragmentViewModel != null) {
                    viewModel.inputs.loadClipBean(cameraFragmentViewModel.filterList, false);
                } else if (cloudFragmentViewModel != null) {
                    viewModel.inputs.loadClipBean(cloudFragmentViewModel.filterList, false);
                }
            } else {
                va_base.setDisplayedChild(5);
                tv_user_tips.setText(R.string.camera_unbind);
                btn_user_action.setText(R.string.camera_unbind_action);
            }
        } else {
            va_base.setDisplayedChild(5);
            tv_user_tips.setText(R.string.camera_not_logged);
            btn_user_action.setText(R.string.log_in);
        }
    }

    private void showDialog() {
//        ibFilter.setVisibility(View.GONE);

        ViewAnimator vaContent = rlBottomToolbar.findViewById(R.id.va_content);
        vaContent.setDisplayedChild(0);
        if (Constants.isFleet()) {
            EventBean selectedEventBean = mVideoAdapter.getSelectedEventBean();
            Logger.t(TAG).d("selectedEventBean: " + selectedEventBean);
            if (selectedEventBean != null) {
                String videoType = selectedEventBean.getEventType();
                Logger.t(TAG).d("videoType: " + videoType);

                dialog_view_export.setBackgroundResource(VideoEventType.getEventDrawable(videoType));
                tv_export_info.setTextColor(getResources().getColor(VideoEventType.getEventColor(videoType)));

                long durationMs = selectedEventBean.getDuration();
                tv_export_info.setText(String.format(Locale.US, "%s · %s",
                        VideoEventType.dealEventType(getContext(), videoType),
                        StringUtils.formatDuration((int) (durationMs / 1000))));

                LinearLayout llDownload = rlBottomToolbar.findViewById(R.id.ll_download);
                llDownload.setOnClickListener(v -> vaContent.setDisplayedChild(2));
                LinearLayout llDelete = rlBottomToolbar.findViewById(R.id.ll_delete);
                llDelete.setOnClickListener(v -> vaContent.setDisplayedChild(1));

                llDelete.setVisibility(View.GONE);

//                rlBottomToolbar.findViewById(R.id.btn_delete).setOnClickListener(v -> {
//                    viewModel.inputs.deleteClip(selectedClipBean);
//                    clearDialog();
//                });

//                rlBottomToolbar.findViewById(R.id.btn_delete_cancel).setOnClickListener(v -> clearDialog());

                Postcard postcard = ARouter.getInstance().build("/ui/activity/ExportActivity")
                        .withString(ExportActivity.URL, selectedEventBean.getMp4Url())
                        .withLong(ExportActivity.CREATE_TIME, selectedEventBean.getStartTime())
                        .withInt(ExportActivity.DURATION, selectedEventBean.getDuration())
                        .withString(ExportActivity.ROTATE, selectedEventBean.getRotate())
                        .withInt(ExportActivity.TYPE, VideoEventType.getEventTypeForInteger(selectedEventBean.getEventType()))
                        .withString(ExportActivity.LOCATION, "");

                rlBottomToolbar.findViewById(R.id.ll_save_album).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 0).navigation();
                });

                rlBottomToolbar.findViewById(R.id.ll_save_library).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 1).navigation();
                });

                rlBottomToolbar.findViewById(R.id.ll_share_waylens).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 2).navigation();
                });

                rlBottomToolbar.findViewById(R.id.btn_export_cancel).setOnClickListener(v -> clearDialog());
            }
        } else {
            ClipBean selectedClipBean = mVideoAdapter.getSelectedClipBean();
            Logger.t(TAG).d("selectedClipBean: " + selectedClipBean);
            if (selectedClipBean != null) {
                String videoType = selectedClipBean.clipType;
                Logger.t(TAG).d("videoType: " + videoType);

                dialog_view_export.setBackgroundResource(VideoEventType.getEventDrawable(videoType));
                tv_export_info.setTextColor(getResources().getColor(VideoEventType.getEventColor(videoType)));

                long durationMs = selectedClipBean.durationMs;
                tv_export_info.setText(String.format(Locale.US, "%s · %s",
                        VideoEventType.dealEventType(getContext(), videoType),
                        StringUtils.formatDuration((int) (durationMs / 1000))));

                LinearLayout llDownload = rlBottomToolbar.findViewById(R.id.ll_download);
                llDownload.setOnClickListener(v -> vaContent.setDisplayedChild(2));
                LinearLayout llDelete = rlBottomToolbar.findViewById(R.id.ll_delete);
                llDelete.setOnClickListener(v -> vaContent.setDisplayedChild(1));

                rlBottomToolbar.findViewById(R.id.btn_delete).setOnClickListener(v -> {
                    viewModel.inputs.deleteClip(selectedClipBean);
                    clearDialog();
                });

                rlBottomToolbar.findViewById(R.id.btn_delete_cancel).setOnClickListener(v -> clearDialog());

                Postcard postcard = ARouter.getInstance().build("/ui/activity/ExportActivity")
                        .withString(ExportActivity.URL, selectedClipBean.url)
                        .withLong(ExportActivity.CREATE_TIME, selectedClipBean.captureTime)
                        .withInt(ExportActivity.DURATION, (int) selectedClipBean.durationMs)
                        .withString(ExportActivity.ROTATE, selectedClipBean.rotate)
                        .withInt(ExportActivity.TYPE, VideoEventType.getEventTypeForInteger(videoType))
                        .withString(ExportActivity.LOCATION, selectedClipBean.location != null ? selectedClipBean.location.route : "");

                rlBottomToolbar.findViewById(R.id.ll_save_album).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 0).navigation();
                });

                rlBottomToolbar.findViewById(R.id.ll_save_library).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 1).navigation();
                });

                rlBottomToolbar.findViewById(R.id.ll_share_waylens).setOnClickListener(v -> {
                    clearDialog();
                    onToLiveClick();

                    postcard.withInt(ExportActivity.CHOICE, 2).navigation();
                });

                rlBottomToolbar.findViewById(R.id.btn_export_cancel).setOnClickListener(v -> clearDialog());

            }
        }
        rlBottomToolbar.setVisibility(View.VISIBLE);
        ((TextView) rlBottomToolbar.findViewById(R.id.tv_delete_tips)).setText(R.string.cloud_delete_tips);
    }

    private void registerDialogCallback() {
        LinearLayout llExportInfo = rlBottomToolbar.findViewById(R.id.ll_export_info);

        llExportInfo.setOnClickListener(v -> {
            FrameLayout frameLayout = getActivity().getWindow().getDecorView().findViewById(android.R.id.content);
            View view = LayoutInflater.from(getActivity()).inflate(R.layout.layout_guide_detail, null);
            view.setOnTouchListener((v12, event) -> true);

            view.findViewById(R.id.layout_guide_detail)
                    .findViewById(R.id.tv_skip_guide).setVisibility(View.GONE);

            TextView tvGoGuide = view.findViewById(R.id.layout_guide_detail)
                    .findViewById(R.id.btn_go_guide);
            tvGoGuide.setText(R.string.export_done);
            tvGoGuide.setOnClickListener(v1 -> frameLayout.removeView(view));

            frameLayout.addView(view);
        });
    }

    public void clearDialog() {
//        ibFilter.setVisibility(View.VISIBLE);

        Logger.t(TAG).e("clearDialog: " + DownloadManager.getManager().getJobCount());

        rlBottomToolbar.setVisibility(View.INVISIBLE);
        mVideoAdapter.setSelectedClip(null);
        mVideoAdapter.setSelectedEvent(null);

//        if (com.mk.autosecure.snipe.download.DownloadManager.getManager().getJobCount() > 0) {
//            if (rlBottomToolbar.getVisibility() != View.VISIBLE) {
//                rlBottomToolbar.setVisibility(View.VISIBLE);
//            }
//            ViewAnimator vaContent = (ViewAnimator) rlBottomToolbar.findViewById(R.id.va_content);
//            vaContent.setDisplayedChild(1);
//        } else {
//            ProgressBar pbDownload = (ProgressBar) rlBottomToolbar.findViewById(R.id.pb_download);
//            pbDownload.setProgress(0);
//            rlBottomToolbar.setVisibility(View.INVISIBLE);
//            mVideoAdapter.setSelectedClip(null);
//        }
    }

    private void tryPlayNext(ClipBeanPos endPos) {
        Logger.t(TAG).e("tryPlayNext");
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
//        Logger.t(TAG).d("currentView: " + currentView);
        ClipBeanPos clipPos = null;
        if (currentView != null) {
            int currentPos = mVideoManager.getPosition(currentView);
            Logger.t(TAG).d("currentPos: " + currentPos);
            if (mVideoAdapter.getItemViewType(currentPos) == CloudVideoAdapter.TYPE_PLAYBACK) {
                ClipBeanPos endClipPos = getCurrentClipBeanPos(startPos);
                ClipBeanCluster clipCluster = null;
                if (endClipPos != null) {
                    Object obj = mVideoAdapter.getViewItemObjectAt(currentPos);
                    if (obj instanceof ClipBeanCluster) {
                        clipCluster = (ClipBeanCluster) obj;
                    }
                }
                clipPos = startOfNextSegment(endPos, clipCluster);
            }

            if (clipPos == null) {
                clipPos = startOfNextClipCluster(currentPos);
            }
        }
        Logger.t(TAG).d("closest clip pos = " + clipPos);
        if (clipPos != null && endPos.getClipBean() != clipPos.getClipBean()) {
            adjustProgress(new ClipBeanPosChangeEvent(clipPos, TAG));
            RxBus.getDefault().post(new ClipBeanPosChangeEvent(clipPos, TAG));
        } else {
            clipPos = getCurrentClipBeanPos(startPos);
            if (clipPos == null) {
                clipPos = getClosestClipBeanPos();
                Logger.t(TAG).d("closest clip pos = " + clipPos);
                if (clipPos != null && endPos.getClipBean() != clipPos.getClipBean()) {
                    adjustProgress(new ClipBeanPosChangeEvent(clipPos, TAG));
                    RxBus.getDefault().post(new ClipBeanPosChangeEvent(clipPos, TAG));
                }
            }
            ClipBeanPosChangeEvent event;
            if (clipPos != null && endPos.getClipBean() != clipPos.getClipBean()) {
                adjustProgress(new ClipBeanPosChangeEvent(clipPos, TAG));
                event = new ClipBeanPosChangeEvent(clipPos, TAG);
                RxBus.getDefault().post(event);
            }
            if (clipPos != null && endPos.getClipBean() == clipPos.getClipBean()) {
                onToLiveClick();
            }
        }
    }

    private void tryPlayNextFleet(EventBeanPos endPos) {
        Logger.t(TAG).e("tryPlayNextFleet");
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
//        Logger.t(TAG).d("currentView: " + currentView);
        EventBeanPos eventPos = null;
        if (currentView != null) {
            int currentPos = mVideoManager.getPosition(currentView);
            Logger.t(TAG).d("currentPos: " + currentPos);
            if (mVideoAdapter.getItemViewType(currentPos) == CloudVideoAdapter.TYPE_PLAYBACK_FLEET) {
                EventBeanPos endClipPos = getCurrentEventBeanPos(startPos);
                EventBeanCluster clipCluster = null;
                if (endClipPos != null) {
                    Object obj = mVideoAdapter.getViewItemObjectAt(currentPos);
                    if (obj instanceof EventBeanCluster) {
                        clipCluster = (EventBeanCluster) obj;
                    }
                }
                eventPos = EventBeanUtils.startOfNextSegment(endPos, clipCluster);
            }

            if (eventPos == null) {
                eventPos = startOfNextEventCluster(currentPos);
            }
        }
        Logger.t(TAG).d("closest clip pos = " + eventPos);
        if (eventPos != null && endPos.getEventBean() != eventPos.getEventBean()) {
            adjustProgressFleet(new EventBeanPosChangeEvent(eventPos, TAG));
            RxBus.getDefault().post(new EventBeanPosChangeEvent(eventPos, TAG));
        } else {
            eventPos = getCurrentEventBeanPos(startPos);
            if (eventPos == null) {
                eventPos = getClosestEventBeanPos();
                Logger.t(TAG).d("closest clip pos = " + eventPos);
                if (eventPos != null && endPos.getEventBean() != eventPos.getEventBean()) {
                    adjustProgressFleet(new EventBeanPosChangeEvent(eventPos, TAG));
                    RxBus.getDefault().post(new EventBeanPosChangeEvent(eventPos, TAG));
                }
            }
            EventBeanPosChangeEvent event;
            if (eventPos != null && endPos.getEventBean() != eventPos.getEventBean()) {
                adjustProgressFleet(new EventBeanPosChangeEvent(eventPos, TAG));
                event = new EventBeanPosChangeEvent(eventPos, TAG);
                RxBus.getDefault().post(event);
            }
            if (eventPos != null && endPos.getEventBean() == eventPos.getEventBean()) {
                onToLiveClick();
            }
        }
    }

    private void adjustProgress(ClipBeanPosChangeEvent event) {
//        Logger.t(TAG).e("timeOffSet: " + event.getClipBeanPos().getOffset());

        ClipBean clipBean = event.getClipBeanPos().getClipBean();
        long timeOffSet = clipBean.getStartTimeMs() + event.getClipBeanPos().getOffset();

//        Logger.t(TAG).e("timeOffSet: " + DateTime.get12HTimeString(timeOffSet));

        List<CloudVideoAdapter.ViewItem> viewItemList = mVideoAdapter.getViewItemList();

        int index = -1;
        for (int i = 0; i < viewItemList.size(); i++) {
            CloudVideoAdapter.ViewItem viewItem = viewItemList.get(i);
            if (viewItem.itemType != CloudVideoAdapter.TYPE_PLAYBACK) {
                continue;
            }
            ClipBeanCluster clipBeanCluster = (ClipBeanCluster) viewItem.itemObject;
            if (clipBeanCluster != null && clipBeanCluster.getStartTime() <= clipBean.getStartTimeMs()
                    && clipBean.getDuration() <= clipBeanCluster.getDuration()) {
                index = i;
                break;
            }
        }

        setPlayTime(timeOffSet);

        if (index != -1) {
            ClipBeanCluster clipBeanCluster = null;
            Object objectAt = mVideoAdapter.getViewItemObjectAt(index);
            if (objectAt instanceof ClipBeanCluster) {
                clipBeanCluster = (ClipBeanCluster) objectAt;
            }

            long curTime = timeOffSet;

            View view = mVideoManager.findViewByPosition(index);
            if (view == null || clipBeanCluster == null) {
                Logger.t(TAG).d("view == null || clipBeanCluster== null");
                //如果位置刚好隔了一天，此时view是null，因为视图没有加载，只能手动去scroll
                int thumbnailIndex = mThumbnailAdapter.getFirstThumbnailIndex(clipBeanCluster);

                mVideoManager.scrollToPositionWithOffset(index, -ViewUtils.dp2px(8));
                mThumbnailManager.scrollToPositionWithOffset(thumbnailIndex, -ViewUtils.dp2px(8));
                return;
            }

            int height = view.getHeight();

            List<ClipSegment> clipSegment = clipBeanCluster.getClipSegment();
            long totalClipTimeMs = 0;
            for (ClipSegment segment : clipSegment) {
                totalClipTimeMs += segment.getLength();
            }

            float scale = ((float) height) / totalClipTimeMs;
            long offset = 0;
            long viewOffset = 0;
            for (ClipSegment seg : clipSegment) {
                long startY = offset;
                long endY = (long) (startY + scale * seg.getLength());
                offset = endY;
                if (seg.startTime <= curTime && curTime <= seg.startTime + seg.duration) {
                    float inSegOffset = (endY - startY) * ((float) (seg.startTime + seg.duration - curTime)) / seg.duration;
                    viewOffset = startY + (long) inSegOffset;
                    break;
                }
            }

            int thumbnailIndex = mThumbnailAdapter.getFirstThumbnailIndex(clipBeanCluster);
            thumbnailIndex += viewOffset / mVideoAdapter.thumbnailHeight;
            long thumbnailOffset = viewOffset % mVideoAdapter.thumbnailHeight;

            mVideoManager.scrollToPositionWithOffset(index, LocalVideoAdapter.dividerMarginTop - (int) viewOffset);
            mThumbnailManager.scrollToPositionWithOffset(thumbnailIndex, LocalVideoAdapter.dividerMarginTop - (int) thumbnailOffset);
        }
    }

    private void adjustProgressFleet(EventBeanPosChangeEvent event) {
//        Logger.t(TAG).e("timeOffSet: " + event.getClipBeanPos().getOffset());

        EventBean clipBean = event.getClipBeanPos().getEventBean();
        long timeOffSet = clipBean.getStartTime() + event.getClipBeanPos().getOffset();

//        Logger.t(TAG).e("timeOffSet: " + DateTime.get12HTimeString(timeOffSet));

        List<CloudVideoAdapter.ViewItem> viewItemList = mVideoAdapter.getViewItemList();

        int index = -1;
        for (int i = 0; i < viewItemList.size(); i++) {
            CloudVideoAdapter.ViewItem viewItem = viewItemList.get(i);
            if (viewItem.itemType != CloudVideoAdapter.TYPE_PLAYBACK_FLEET) {
                continue;
            }
            EventBeanCluster clipBeanCluster = (EventBeanCluster) viewItem.itemObject;
            if (clipBeanCluster != null && clipBeanCluster.getStartTime() <= clipBean.getStartTime()
                    && clipBean.getDuration() <= clipBeanCluster.getDuration()) {
                index = i;
                break;
            }
        }

        setPlayTime(timeOffSet);

        if (index != -1) {
            EventBeanCluster clipBeanCluster = null;
            Object objectAt = mVideoAdapter.getViewItemObjectAt(index);
            if (objectAt instanceof EventBeanCluster) {
                clipBeanCluster = (EventBeanCluster) objectAt;
            }

            long curTime = timeOffSet;

            View view = mVideoManager.findViewByPosition(index);
            if (view == null || clipBeanCluster == null) {
                Logger.t(TAG).d("view == null || clipBeanCluster== null");
                //如果位置刚好隔了一天，此时view是null，因为视图没有加载，只能手动去scroll
                int thumbnailIndex = mThumbnailAdapter.getFirstThumbnailIndex(clipBeanCluster);

                mVideoManager.scrollToPositionWithOffset(index, -ViewUtils.dp2px(8));
                mThumbnailManager.scrollToPositionWithOffset(thumbnailIndex, -ViewUtils.dp2px(8));
                return;
            }

            int height = view.getHeight();

            List<ClipSegment> clipSegment = clipBeanCluster.getClipSegment();
            long totalClipTimeMs = 0;
            for (ClipSegment segment : clipSegment) {
                totalClipTimeMs += segment.getLength();
            }

            float scale = ((float) height) / totalClipTimeMs;
            long offset = 0;
            long viewOffset = 0;
            for (ClipSegment seg : clipSegment) {
                long startY = offset;
                long endY = (long) (startY + scale * seg.getLength());
                offset = endY;
                if (seg.startTime <= curTime && curTime <= seg.startTime + seg.duration) {
                    float inSegOffset = (endY - startY) * ((float) (seg.startTime + seg.duration - curTime)) / seg.duration;
                    viewOffset = startY + (long) inSegOffset;
                    break;
                }
            }

            int thumbnailIndex = mThumbnailAdapter.getFirstThumbnailIndex(clipBeanCluster);
            thumbnailIndex += viewOffset / mVideoAdapter.thumbnailHeight;
            long thumbnailOffset = viewOffset % mVideoAdapter.thumbnailHeight;

            mVideoManager.scrollToPositionWithOffset(index, LocalVideoAdapter.dividerMarginTop - (int) viewOffset);
            mThumbnailManager.scrollToPositionWithOffset(thumbnailIndex, LocalVideoAdapter.dividerMarginTop - (int) thumbnailOffset);
        }
    }

    private void setPlayTime(long time) {
//        Logger.t(TAG).e("setPlayTime: " + time);
        tv_playTime.setText(DateFormat.is24HourFormat(getActivity()) ?
                DateTime.get24HTimeString(time, false) : DateTime.get12HTimeString(time, false));

        Map<String, Integer> clipCountMap = mVideoAdapter.getClipCountMap();
        Integer count = clipCountMap.get(mVideoAdapter.getFormattedDate(time));
        if (count != null) {
            tv_videoStat.setVisibility(View.VISIBLE);
            tv_videoStat.setText(String.format(getString(R.string.video_count_string), mVideoAdapter.getFormattedDate(time), count,
                    count > 1 ? getString(R.string.videos) : getString(R.string.video)));
        } else {
            tv_videoStat.setVisibility(View.INVISIBLE);
        }
    }

    private int getCurrentPosition(int pos) {
        View view = recyclerView.findChildViewUnder(0, pos);
        if (view == null) {
            return 0;
        }
        int position = mVideoManager.getPosition(view);

        Logger.t(TAG).e("pos: " + position);
        return position;
    }

    private ClipBeanPos getCurrentClipBeanPos(int pos) {
        View view = recyclerView.findChildViewUnder(0, pos);
        if (view == null) {
            return null;
        }
        int position = mVideoManager.getPosition(view);

//        Logger.t(TAG).e("pos: " + position);

        if (mVideoAdapter.getItemViewType(position) != CloudVideoAdapter.TYPE_PLAYBACK) {
            return null;
        }

        CloudVideoAdapter.ViewItem viewItem = mVideoAdapter.getViewItemList().get(position);

        ClipBeanCluster clipBeanCluster;
        if (viewItem.itemType == CloudVideoAdapter.TYPE_PLAYBACK && viewItem.itemObject != null) {
            clipBeanCluster = (ClipBeanCluster) viewItem.itemObject;
            List<ClipSegment> clipSegmentList = clipBeanCluster.getClipSegment();

            int offset = pos - view.getTop();

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
            if (targetSeg != null && targetSeg.data != null && targetSeg.data instanceof ClipBean) {
                return new ClipBeanPos((ClipBean) targetSeg.data, absTimeOffset - ((ClipBean) targetSeg.data).getStartTimeMs());
            } else {
                return null;
            }
        }
        return null;
    }

    private EventBeanPos getCurrentEventBeanPos(int pos) {
        View view = recyclerView.findChildViewUnder(0, pos);
        if (view == null) {
            return null;
        }
        int position = mVideoManager.getPosition(view);

//        Logger.t(TAG).e("pos: " + position);

        if (mVideoAdapter.getItemViewType(position) != CloudVideoAdapter.TYPE_PLAYBACK_FLEET) {
            return null;
        }

        CloudVideoAdapter.ViewItem viewItem = mVideoAdapter.getViewItemList().get(position);

        EventBeanCluster clipBeanCluster;
        if (viewItem.itemType == CloudVideoAdapter.TYPE_PLAYBACK_FLEET && viewItem.itemObject != null) {
            clipBeanCluster = (EventBeanCluster) viewItem.itemObject;
            List<ClipSegment> clipSegmentList = clipBeanCluster.getClipSegment();

            int offset = pos - view.getTop();

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
            if (targetSeg != null && targetSeg.data != null && targetSeg.data instanceof EventBean) {
                return new EventBeanPos((EventBean) targetSeg.data, absTimeOffset - ((EventBean) targetSeg.data).getStartTime());
            } else {
                return null;
            }
        }
        return null;
    }

    private ClipBeanPos getClosestClipBeanPos() {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
        if (currentView != null) {
            int currentPos = mVideoManager.getPosition(currentView);
            if (mVideoAdapter.getItemViewType(currentPos) == CloudVideoAdapter.TYPE_LIST_HEADER) {
                ClipBeanPos clipPos = startOfNextClipCluster(currentPos);
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

        int position = mVideoManager.getPosition(view);
        if (mVideoAdapter.getItemViewType(position) != CloudVideoAdapter.TYPE_PLAYBACK) {
            return null;
        }
        ClipBeanCluster clipCluster = null;
        Object obj = mVideoAdapter.getViewItemObjectAt(position);
        if (obj instanceof ClipBeanCluster) {
            clipCluster = (ClipBeanCluster) obj;
        } else {
            return null;
        }
        int size = clipCluster.getClipSegment().size();
        if (size > 0) {
            //last in list order, first in timeline
            ClipSegment firstClipSegment = clipCluster.getClipSegment().get(size - 1);
            return new ClipBeanPos((ClipBean) firstClipSegment.data, 0);
        }
        return null;
    }

    private EventBeanPos getClosestEventBeanPos() {
        int startPos = LocalVideoAdapter.dividerMarginTop;
        View currentView = recyclerView.findChildViewUnder(0, startPos);
        if (currentView != null) {
            int currentPos = mVideoManager.getPosition(currentView);
            if (mVideoAdapter.getItemViewType(currentPos) == CloudVideoAdapter.TYPE_LIST_HEADER) {
                EventBeanPos clipPos = startOfNextEventCluster(currentPos);
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

        int position = mVideoManager.getPosition(view);
        if (mVideoAdapter.getItemViewType(position) != CloudVideoAdapter.TYPE_PLAYBACK_FLEET) {
            return null;
        }
        EventBeanCluster clipCluster = null;
        Object obj = mVideoAdapter.getViewItemObjectAt(position);
        if (obj instanceof EventBeanCluster) {
            clipCluster = (EventBeanCluster) obj;
        } else {
            return null;
        }
        int size = clipCluster.getClipSegment().size();
        if (size > 0) {
            //last in list order, first in timeline
            ClipSegment firstClipSegment = clipCluster.getClipSegment().get(size - 1);
            return new EventBeanPos((EventBean) firstClipSegment.data, 0);
        }
        return null;
    }

    private ClipBeanPos startOfNextClipCluster(int curPos) {
        ClipBeanCluster cluster = null;
        for (int pos = curPos - 1; pos >= 0; pos--) {
            Object obj = mVideoAdapter.getViewItemObjectAt(pos);
            if (obj != null && obj instanceof ClipBeanCluster) {
                cluster = (ClipBeanCluster) obj;
                int size = cluster.getClipSegment().size();
                if (size > 0) {
                    //last in list order, first in timeline
                    ClipSegment firstClipSegment = cluster.getClipSegment().get(size - 1);
                    return new ClipBeanPos((ClipBean) firstClipSegment.data, 0);
                }
            }
        }
        return null;
    }

    private EventBeanPos startOfNextEventCluster(int curPos) {
        EventBeanCluster cluster = null;
        for (int pos = curPos - 1; pos >= 0; pos--) {
            Object obj = mVideoAdapter.getViewItemObjectAt(pos);
            if (obj != null && obj instanceof EventBeanCluster) {
                cluster = (EventBeanCluster) obj;
                int size = cluster.getClipSegment().size();
                if (size > 0) {
                    //last in list order, first in timeline
                    ClipSegment firstClipSegment = cluster.getClipSegment().get(size - 1);
                    return new EventBeanPos((EventBean) firstClipSegment.data, 0);
                }
            }
        }
        return null;
    }

    public void scrollToClipID(long clipID) {
        Logger.t(TAG).e("scrollToClipID: " + clipID);
        this.clipID = clipID;
    }

    GestureDetector gestureDetector = new GestureDetector(getActivity(), new DefOnGestureListener() {
        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            Logger.t(TAG).d("single tap = " + e.getY());
            float y = e.getY();
            if (Constants.isFleet()) {
                EventBeanPos currentEventBeanPos = getCurrentEventBeanPos((int) y);

                if (currentEventBeanPos == null) {
                    return false;
                }
                if (mVideoAdapter.getSelectedEventBean() != null) {
                    mVideoAdapter.setSelectedEvent(null);
                    clearDialog();
                } else {
                    mVideoAdapter.setSelectedEvent(currentEventBeanPos.getEventBean());
                    tv_liveView.setVisibility(View.GONE);
                    hideNavigation();

                    showDialog();

                    //调整recyclerview到合适的位置
                    int position = getCurrentPosition((int) y);
                    View selectedView = mVideoManager.findViewByPosition(position);
                    Logger.t(TAG).e("select height: " + selectedView.getHeight() + "--" + ViewUtils.dp2px(56));
                    mVideoManager.scrollToPositionWithOffset(position, ViewUtils.dp2px(48) - selectedView.getHeight());

                    CloudVideoAdapter.ViewItem viewItem = mVideoAdapter.getViewItemList().get(position);

                    EventBeanCluster eventBeanCluster = (EventBeanCluster) viewItem.itemObject;
                    int thumbnailIndex = mThumbnailAdapter.getFirstThumbnailIndex(eventBeanCluster);
                    mThumbnailManager.scrollToPositionWithOffset(thumbnailIndex, ViewUtils.dp2px(48) - selectedView.getHeight());
                    RxBus.getDefault().post(new EventBeanPosChangeEvent(currentEventBeanPos, TAG));
                }
            } else {
                ClipBeanPos currentClipBeanPos = getCurrentClipBeanPos((int) y);

                if (currentClipBeanPos == null) {
                    return false;
                }
                if (mVideoAdapter.getSelectedClipBean() != null) {
                    mVideoAdapter.setSelectedClip(null);
                    clearDialog();
                } else {
                    mVideoAdapter.setSelectedClip(currentClipBeanPos.getClipBean());
                    tv_liveView.setVisibility(View.GONE);
                    hideNavigation();

                    showDialog();

                    //调整recyclerview到合适的位置
                    int position = getCurrentPosition((int) y);
                    View selectedView = mVideoManager.findViewByPosition(position);
                    Logger.t(TAG).e("select height: " + selectedView.getHeight() + "--" + ViewUtils.dp2px(56));
                    mVideoManager.scrollToPositionWithOffset(position, ViewUtils.dp2px(48) - selectedView.getHeight());

                    CloudVideoAdapter.ViewItem viewItem = mVideoAdapter.getViewItemList().get(position);

                    ClipBeanCluster clipBeanCluster = (ClipBeanCluster) viewItem.itemObject;
                    Logger.t(TAG).e("clipBeanCluster: " + clipBeanCluster + "--" + position + "--" + viewItem.itemType);
                    int thumbPos = mThumbnailAdapter.getFirstThumbnailIndex(clipBeanCluster);
                    Logger.t(TAG).e("thumbPos: " + thumbPos);
                    mThumbnailManager.scrollToPositionWithOffset(thumbPos, ViewUtils.dp2px(48) - selectedView.getHeight());
                    RxBus.getDefault().post(new ClipBeanPosChangeEvent(currentClipBeanPos, TAG));
                }
            }
            return true;
        }
    });

    RecyclerView.OnScrollListener scrollListener = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
//            Logger.t(TAG).e("onScrollStateChanged: " + newState);
            super.onScrollStateChanged(recyclerView, newState);
            if (newState == RecyclerView.SCROLL_STATE_DRAGGING) {
//                    View view = recyclerView.findChildViewUnder(0, ViewUtils.dp2px(48));
//                    if (view != null) {
//                        int position = mVideoManager.getPosition(view);
//                        if (position == 0) {
//                            RxBus.getDefault().post(new ClipBeanPosChangeEvent(null, TAG, ClipBeanPosChangeEvent.INTENT_LIVE));
//                        } else {
//                            RxBus.getDefault().post(new ClipBeanPosChangeEvent(null, TAG, ClipBeanPosChangeEvent.INTENT_LIVE));
//                        }
//                    }
            } else if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                View view = recyclerView.findChildViewUnder(0, ViewUtils.dp2px(48));
                if (view != null) {
                    int position = mVideoManager.getPosition(view);
                    // top position, live view
                    if (position == 0 || position == 1) {
                        Logger.t(TAG).d("%s", " live view position ");
                        onToLiveClick();
                        return;
                    }
                }

                if (Constants.isFleet()) {
                    EventBeanPos eventBeanPos = getCurrentEventBeanPos(ViewUtils.dp2px(48));

                    if (eventBeanPos == null) {
                        eventBeanPos = getClosestEventBeanPos();
                        if (eventBeanPos != null) {
                            adjustProgressFleet(new EventBeanPosChangeEvent(eventBeanPos, TAG));
                        }
                    }

                    EventBeanPosChangeEvent event;
                    if (eventBeanPos != null) {
                        event = new EventBeanPosChangeEvent(eventBeanPos, TAG);
                        RxBus.getDefault().post(event);
                        tv_liveView.setVisibility(View.GONE);
//                        btnToLive.setVisibility(View.VISIBLE);
                    }
                } else {
                    ClipBeanPos clipBeanPos = getCurrentClipBeanPos(ViewUtils.dp2px(48));

                    //滑动到间隔处
                    if (clipBeanPos == null) {
                        clipBeanPos = getClosestClipBeanPos();
                        Logger.t(TAG).d("closest clip pos = " + clipBeanPos);
                        if (clipBeanPos != null) {
                            adjustProgress(new ClipBeanPosChangeEvent(clipBeanPos, TAG));
                        }
                    }

                    ClipBeanPosChangeEvent event;
                    if (clipBeanPos != null) {
                        event = new ClipBeanPosChangeEvent(clipBeanPos, TAG);
                        RxBus.getDefault().post(event);
                        tv_liveView.setVisibility(View.GONE);
//                        btnToLive.setVisibility(View.VISIBLE);
                    }
                }
            }
        }

        private int totalDy = 0;

        @Override
        public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
//            Logger.t(TAG).d("onScrolled: " + dx + " " + dy);
            if (dx == 0 && dy == 0) {
                return;
            }
//                super.onScrolled(recyclerView, dx, dy);
            rv_thumbnail.scrollBy(dx, dy);
//                Logger.t(TAG).d("%s", "on scroll");

            if (totalDy > 0 && dy < 0) {
                totalDy = 0;
            } else if (totalDy < 0 && dy > 0) {
                totalDy = 0;
            }
            totalDy += dy;

            if (totalDy > 20) {
                hideNavigation();
            } else if (totalDy < -20) {
                showNavigation();
            }

            if (Constants.isFleet()) {
                EventBeanPos eventBeanPos = getCurrentEventBeanPos(ViewUtils.dp2px(48));
                if (eventBeanPos != null) {
                    tv_liveView.setVisibility(View.GONE);
//                    Logger.t(TAG).d("%s", "clipPos = " + clipBeanPos.offset + "--" + clipBeanPos.getClipBean().getStartTimeMs());
                    setPlayTime(eventBeanPos.getEventBean().getStartTime() + eventBeanPos.getOffset());

                    EventBeanPosChangeEvent event;
                    if (recyclerView.getScrollState() == RecyclerView.SCROLL_STATE_IDLE) {
                        event = new EventBeanPosChangeEvent(eventBeanPos, TAG);
                    } else {
                        event = new EventBeanPosChangeEvent(eventBeanPos, TAG, ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL);
                    }
//                    Logger.t(TAG).d("%s", "post event");
                    RxBus.getDefault().post(event);
                }
            } else {
                ClipBeanPos clipBeanPos = getCurrentClipBeanPos(ViewUtils.dp2px(48));
                if (clipBeanPos != null) {
                    tv_liveView.setVisibility(View.GONE);
//                    Logger.t(TAG).d("%s", "clipPos = " + clipBeanPos.offset + "--" + clipBeanPos.getClipBean().getStartTimeMs());
                    setPlayTime(clipBeanPos.getClipBean().getStartTimeMs() + clipBeanPos.getOffset());

                    ClipBeanPosChangeEvent event;
                    if (recyclerView.getScrollState() == RecyclerView.SCROLL_STATE_IDLE) {
                        event = new ClipBeanPosChangeEvent(clipBeanPos, TAG);
                    } else {
                        event = new ClipBeanPosChangeEvent(clipBeanPos, TAG, ClipBeanPosChangeEvent.INTENT_SHOW_THUMBNAIL);
                    }
//                    Logger.t(TAG).d("%s", "post event");
                    RxBus.getDefault().post(event);
                }
            }
        }
    };

    public void hideNavigation() {
        ibFilter.setVisibility(VISIBLE);
        btnToLive.setVisibility(VISIBLE);
        FragmentActivity activity = getActivity();
        if (activity instanceof LocalLiveActivity) {
            LocalLiveActivity liveActivity = (LocalLiveActivity) activity;
            liveActivity.showOrHideNavigation(View.GONE);
        }
    }

    public void showNavigation() {
        ibFilter.setVisibility(View.GONE);
        btnToLive.setVisibility(View.GONE);

        if (rlBottomToolbar.getVisibility() == VISIBLE)
            clearDialog();

        FragmentActivity activity = getActivity();
        if (activity instanceof LocalLiveActivity) {
            LocalLiveActivity liveActivity = (LocalLiveActivity) activity;
            liveActivity.showOrHideNavigation(VISIBLE);
        }
    }

}

