package com.mk.autosecure.ui.fragment;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.WebPlanActivity;
import com.mk.autosecure.ui.activity.settings.FirmwareUpdateActivity;
import com.mk.autosecure.ui.adapter.AlertAdapter;
import com.mk.autosecure.ui.adapter.FleetAlertAdapter;
import com.mk.autosecure.ui.adapter.MessageAdapter;
import com.orhanobut.logger.Logger;
import com.tubb.smrv.SwipeMenuRecyclerView;
import com.mkgroup.camera.bean.Alert;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.Notifications;
import com.mk.autosecure.rest.reponse.AlertListResponse;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest.reponse.EventResponse;
import com.mk.autosecure.rest.reponse.NotificationListResponse;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.rest_fleet.response.AllEventsResponse;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mk.autosecure.viewmodels.LocalLiveViewModel;
import com.mk.autosecure.viewmodels.fragment.AlertsFragmentViewModel;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindArray;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@RequiresFragmentViewModel(AlertsFragmentViewModel.ViewModel.class)
public class AlertsFragment extends BaseLazyLoadFragment<AlertsFragmentViewModel.ViewModel> {

    private final static String TAG = AlertsFragment.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.iv_read_all)
    ImageView ivReadAll;

    @BindView(R.id.iv_message)
    ImageView ivMessage;

    @BindView(R.id.va_root_alerts)
    ViewAnimator vaRootAlerts;

    @BindView(R.id.refresh_alert_layout)
    SwipeRefreshLayout refreshAlertLayout;

    @BindView(R.id.va_alert_content)
    ViewAnimator vaAlertContent;

    @BindView(R.id.recycler_alert_view)
    SwipeMenuRecyclerView recyclerAlertView;

    @BindView(R.id.refresh_message_layout)
    SwipeRefreshLayout refreshMsgLayout;

    @BindView(R.id.va_message_content)
    ViewAnimator vaMsgContent;

    @BindView(R.id.recycler_message_view)
    SwipeMenuRecyclerView recyclerMsgView;

    @BindArray(R.array.web_url_list)
    String[] webServer;

    @OnClick(R.id.iv_read_all)
    public void readAll() {
        int displayedChild = vaRootAlerts.getDisplayedChild();
        if (displayedChild == 0) {
            DialogHelper.markNotificationDialog(getActivity(), AlertsFragment.this::markAllEventRead);
        } else {
            List<Notifications> data = mMsgAdapter.getData();
            boolean existUnread = false;
            for (int i = 0; i < data.size(); i++) {
                Notifications notifications = data.get(i);
                Boolean read = notifications.isRead();
                if (read != null && !read) {
                    existUnread = true;
                    break;
                }
            }
            Logger.t(TAG).d("existUnread: " + existUnread);
            if (existUnread) {
                ApiService.createApiService().markAllMsgRead()
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .doFinally(() -> {
                            for (Notifications notifications : mMsgAdapter.getData()) {
                                notifications.setRead(true);
                            }
                            mMsgAdapter.notifyDataSetChanged();

                            restoreView();
                            ivMessage.setImageResource(R.drawable.icon_message);
                        })
                        .subscribe(response -> Logger.t(TAG).d("markAllMsgRead response: " + response.result),
                                new ServerErrorHandler(TAG));
            } else {
                restoreView();
                ivMessage.setImageResource(R.drawable.icon_message);
            }
        }
    }

    private void restoreView() {
        Logger.t(TAG).d("restoreView");
        vaRootAlerts.setDisplayedChild(0);
        tvToolbarTitle.setText(R.string.toolbar_alerts);
        if (Constants.isFleet()) {
            if (mFleetAlertAdapter.getItemCount() == 0)
                ivReadAll.setVisibility(View.INVISIBLE);
        } else {
            if (mAlertAdapter.getItemCount() == 0)
                ivReadAll.setVisibility(View.INVISIBLE);
        }
        ivReadAll.setImageResource(R.drawable.icon_read_all);
        if (Constants.isFleet()) {
            ivMessage.setVisibility(View.INVISIBLE);
        } else {
            ivMessage.setVisibility(View.VISIBLE);
        }
    }

    @OnClick(R.id.iv_message)
    public void viewMessage() {
        vaRootAlerts.setDisplayedChild(1);
        tvToolbarTitle.setText(R.string.toolbar_messages);
        ivReadAll.setVisibility(View.VISIBLE);
        ivReadAll.setImageResource(R.drawable.ic_back);
        ivMessage.setVisibility(View.INVISIBLE);
    }

    @OnClick(R.id.ll_learn_more)
    public void learnMore() {
        String BASE_URL = PreferenceUtils.getString(PreferenceUtils.WEB_URL, webServer[webServer.length - 1]);
        Uri uri = Uri.parse(BASE_URL + "/shop/360?from=android");
        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
        startActivity(intent);
    }

    private LocalLiveViewModel.ViewModel parentViewModel;

    private long mAlertCursor = 0;

    private long mMsgCursor = 0;

    private static final int count = 10;

    private boolean have4gCamera = false;

    public boolean mShowMessage = false;

    private AlertAdapter mAlertAdapter;

    private FleetAlertAdapter mFleetAlertAdapter;

    private MessageAdapter mMsgAdapter;

    private PublishSubject<Throwable> networkError = PublishSubject.create();

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof LocalLiveActivity) {
            parentViewModel = ((LocalLiveActivity) context).viewModel();
        }
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_alert;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        initAlertView();
        initMessageView();
        initEvent();
    }

    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
        Logger.t(TAG).d("onFragmentResume mShowMessage: " + mShowMessage);
        if (!mShowMessage) {
            restoreView();
        }

        loadAlert(true);
        loadMessage(true);
    }

    @Override
    protected void onFragmentFirstVisible() {
        if (viewModel != null) {
            ArrayList<CameraBean> devices = viewModel.getCurrentUser().getDevices();
            Logger.t(TAG).d("devices number: " + devices.size());
            for (CameraBean bean : devices) {
                if (bean != null && bean.is4G != null && bean.is4G) {
                    have4gCamera = true;
                    break;
                }
            }

            Logger.t(TAG).d("have4gCamera: " + have4gCamera);
            if (!have4gCamera) {
                vaAlertContent.setDisplayedChild(2);
            }
        }
    }

    private void initMessageView() {
        mMsgAdapter = new MessageAdapter(getContext());
        recyclerMsgView.setAdapter(mMsgAdapter);
        recyclerMsgView.setLayoutManager(new LinearLayoutManager(getContext()));

        mMsgAdapter.setOnLoadMoreListener(() -> loadMessage(false), recyclerMsgView);
        mMsgAdapter.disableLoadMoreIfNotFullPage();

        mMsgAdapter.setMessageOperationListener(notifications -> {
            Logger.t(TAG).d("markReaded: " + notifications);
            if (notifications != null) {
                markEventRead(notifications);
            }
        });

        refreshMsgLayout.setOnRefreshListener(() -> {
            mMsgAdapter.setNewData(null);
            loadMessage(true);
        });
        refreshMsgLayout.setEnabled(true);
    }

    private void markEventRead(Notifications notifications) {
        ApiService.createApiService().markMsgRead(notifications.getNotificationID())
                .compose(Transformers.switchSchedulers())
                .compose(Transformers.pipeErrorsTo(networkError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<BooleanResponse>() {
                    @Override
                    protected void onHandleSuccess(BooleanResponse data) {
                        Logger.t(TAG).d("markMsgRead: " + data.result);
                        int index = mMsgAdapter.getData().indexOf(notifications);
                        mMsgAdapter.getData().get(index).setRead(true);
                        mMsgAdapter.notifyItemChanged(index);

                        Notifications.NotificationContent notificationsContent = notifications.getContent();
                        if (notificationsContent != null) {
                            String type = notificationsContent.getNotificationType();
                            // DataUsage, DataPlan, OnlineStatus, AppVersion, Firmware, General
                            Logger.t(TAG).e("notificationType: " + type);
                            switch (type) {
                                case "DataUsage":
                                case "DataPlan":
                                    WebPlanActivity.launch(getActivity(), notifications.getCameraSN(), false);
                                    break;
                                case "OnlineStatus":
                                    if (parentViewModel != null && parentViewModel.inputs != null) {
                                        parentViewModel.inputs.showCamera(notifications.getCameraSN());
                                    }
                                    break;
                                case "AppVersion":
                                    if (getContext() != null) {
                                        final String appPackageName = getContext().getPackageName();
                                        try {
                                            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
                                        } catch (android.content.ActivityNotFoundException anfe) {
                                            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)));
                                        }
                                    }
                                    break;
                                case "Firmware":
                                    ArrayList<CameraBean> devices = HornApplication.getComponent().currentUser().getDevices();
                                    Logger.t(TAG).d("owner devices: " + devices.size());
                                    if (devices.size() != 0) {
                                        FirmwareUpdateActivity.launch(getActivity(), devices.get(0));
                                    }
                                    break;
                                default:
                                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(notificationsContent.getLink())));
                                    break;
                            }
                        }
                    }
                });
    }

    private void initAlertView() {
        if (Constants.isFleet()) {
            mFleetAlertAdapter = new FleetAlertAdapter(getContext());
            recyclerAlertView.setAdapter(mFleetAlertAdapter);

            mFleetAlertAdapter.setOnLoadMoreListener(() -> loadAlert(false), recyclerAlertView);
            mFleetAlertAdapter.disableLoadMoreIfNotFullPage();

        } else {
            mAlertAdapter = new AlertAdapter(getContext());
            recyclerAlertView.setAdapter(mAlertAdapter);

            mAlertAdapter.setOnLoadMoreListener(() -> loadAlert(false), recyclerAlertView);
            mAlertAdapter.disableLoadMoreIfNotFullPage();

            mAlertAdapter.setAlertOperationListener(new AlertOperationListener() {
                @Override
                public void markAlertReaded(Alert alert) {
                    Logger.t(TAG).d("%s", "mark read" + ToStringUtils.getString(alert));
                    if (alert != null) {
                        markEventRead(alert);
                    }
                }

                @Override
                public void deleteAlert(Alert alert) {
                    if (alert != null) {
                        deleteEvent(alert);
                    }
                }

                @Override
                public void playAlertReaded() {
                    if (parentViewModel != null && parentViewModel.inputs != null) {
                        parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.Single);
                    }
                }
            });
        }
        recyclerAlertView.setLayoutManager(new LinearLayoutManager(getContext()));

        //OverScrollDecoratorHelper.setUpOverScroll(recyclerView, OverScrollDecoratorHelper.ORIENTATION_VERTICAL);

        refreshAlertLayout.setOnRefreshListener(() -> {
            if (Constants.isFleet()) {
                mFleetAlertAdapter.setNewData(null);
            } else {
                mAlertAdapter.setNewData(null);
            }
            loadAlert(true);
        });
        refreshAlertLayout.setEnabled(true);
    }

    private void markEventRead(Alert alert) {
        Logger.t(TAG).d("%s", "mark read" + ToStringUtils.getString(alert));
        ApiService.createApiService().markEventRead(alert.eventID)
                .compose(Transformers.switchSchedulers())
                .compose(Transformers.pipeErrorsTo(networkError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<EventResponse>() {
                    @Override
                    protected void onHandleSuccess(EventResponse data) {
                        Logger.t(TAG).d("markEventRead: " + data.affectedNum);
                        int i = mAlertAdapter.getData().indexOf(alert);
                        mAlertAdapter.getData().get(i).isRead = true;
                        mAlertAdapter.notifyItemChanged(i);

                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.Single);
                        }
                    }
                });
    }

    private void deleteEvent(Alert alert) {
        Logger.t(TAG).d("%s", "delete" + ToStringUtils.getString(alert));
        ApiService.createApiService().deleteEvent(alert.eventID)
                .compose(Transformers.switchSchedulers())
                .compose(Transformers.pipeErrorsTo(networkError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<EventResponse>() {
                    @Override
                    protected void onHandleSuccess(EventResponse data) {
                        Logger.t(TAG).d("deleteEvent: " + data.affectedNum);
                        mAlertAdapter.remove(mAlertAdapter.getData().indexOf(alert));

                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.Single);
                        }
                    }
                });
    }

    private void markAllEventRead() {
        Logger.t(TAG).d("%s", "mark all read");
        ApiService.createApiService().markAllEventRead()
                .compose(Transformers.switchSchedulers())
                .compose(Transformers.pipeErrorsTo(networkError))
                .compose(Transformers.neverError())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<EventResponse>() {
                    @Override
                    protected void onHandleSuccess(EventResponse data) {
                        Logger.t(TAG).d("markAllEventRead: " + data.affectedNum);
                        for (Alert alert : mAlertAdapter.getData()) {
                            alert.isRead = true;
                        }
                        mAlertAdapter.notifyDataSetChanged();

                        if (parentViewModel != null && parentViewModel.inputs != null) {
                            parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.All);
                        }
                    }
                });
    }

    public void loadAlert(boolean isRefresh) {
//        if (!have4gCamera) {
//            refreshLayout.setRefreshing(false);
//            return;
//        }

        if (isRefresh) {
            mAlertCursor = 0;
            refreshAlertLayout.setRefreshing(true);
        }

        if (Constants.isFleet()) {
//            ApiClient.createApiService().getAlertList(mAlertCursor, count)
//                    .compose(Transformers.switchSchedulers())
//                    .compose(bindToLifecycle())
//                    .doOnError(throwable -> {
//                        vaAlertContent.setDisplayedChild(1);
//                        refreshAlertLayout.setRefreshing(false);
//                        NetworkErrorHelper.handleCommonError(getContext(), throwable);
//                    })
//                    .subscribe(new BaseObserver<AllEventsResponse>() {
//                        @Override
//                        protected void onHandleSuccess(AllEventsResponse data) {
//                            onLoadFleetResponse(data);
//                        }
//                    });
        } else {
            ApiService.createApiService().getAlertList(mAlertCursor, count)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .doOnError(throwable -> {
                        vaAlertContent.setDisplayedChild(1);
                        refreshAlertLayout.setRefreshing(false);
                        NetworkErrorHelper.handleCommonError(getContext(), throwable);
                    })
                    .subscribe(new BaseObserver<AlertListResponse>() {
                        @Override
                        protected void onHandleSuccess(AlertListResponse data) {
                            onLoadResponse(data);
                        }
                    });
        }
    }

    public void loadMessage(boolean isRefresh) {
        if (isRefresh) {
            mMsgCursor = 0;
            refreshMsgLayout.setRefreshing(true);
        }

        ApiService.createApiService().getMessageList(mMsgCursor, count)
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doOnError(throwable -> {
                    vaMsgContent.setDisplayedChild(1);
                    refreshMsgLayout.setRefreshing(false);
                    NetworkErrorHelper.handleCommonError(getContext(), throwable);
                })
                .subscribe(new BaseObserver<NotificationListResponse>() {
                    @Override
                    protected void onHandleSuccess(NotificationListResponse data) {
                        onLoadResponse(data);
                    }
                });

    }

    private void onLoadResponse(NotificationListResponse notificationListResponse) {
        refreshMsgLayout.setRefreshing(false);

        Logger.t(TAG).d("onLoadResponse: " + notificationListResponse.toString());

        if (notificationListResponse.getNotifications().size() <= 0) {
            vaMsgContent.setDisplayedChild(1);
        } else {
            vaMsgContent.setDisplayedChild(0);

            for (Notifications notifications : notificationListResponse.getNotifications()) {
                if (notifications.isRead() != null && !notifications.isRead()) {
                    ivMessage.setImageResource(R.drawable.icon_message_news);
                    break;
                }
            }
        }

        if (mMsgCursor == 0) {
            mMsgAdapter.setNewData(notificationListResponse.getNotifications());
        } else {
            mMsgAdapter.addData(notificationListResponse.getNotifications());
        }

        mMsgCursor += notificationListResponse.getNotifications().size();
        mMsgAdapter.loadMoreComplete();
        if (notificationListResponse.getHasMore() != null && !notificationListResponse.getHasMore()) {
            mMsgAdapter.loadMoreEnd();
        }
    }

    private void onLoadResponse(AlertListResponse alertListResponse) {
        refreshAlertLayout.setRefreshing(false);

        Logger.t(TAG).d("onLoadResponse: " + alertListResponse.toString());

        if (alertListResponse.alerts.size() <= 0) {
            vaAlertContent.setDisplayedChild(1);
        } else {
            vaAlertContent.setDisplayedChild(0);
            ivReadAll.setVisibility(View.VISIBLE);

            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.None);
            }

            for (Alert alert : alertListResponse.alerts) {
                if (!"finish".equals(alert.status)) {
                    pollAlerts(alert);
                    break;
                }
            }
        }
//        Logger.t(TAG).d("size = " + alertListResponse.alerts.size());
        if (mAlertCursor == 0) {
            mAlertAdapter.setNewData(alertListResponse.alerts);
        } else {
            mAlertAdapter.addData(alertListResponse.alerts);
        }
        mAlertCursor += alertListResponse.alerts.size();
        mAlertAdapter.loadMoreComplete();
        if (!alertListResponse.hasMore) {
            mAlertAdapter.loadMoreEnd();
        }
    }

    private void onLoadFleetResponse(AllEventsResponse response) {
        refreshAlertLayout.setRefreshing(false);

        Logger.t(TAG).d("onLoadResponse: " + response.toString());

        List<EventBean> originList = response.getEvents();
        List<EventBean> filterList = filterManual(originList);

        if (filterList.size() <= 0) {
            vaAlertContent.setDisplayedChild(1);
        } else {
            vaAlertContent.setDisplayedChild(0);
//            ivReadAll.setVisibility(View.VISIBLE);

            if (parentViewModel != null && parentViewModel.inputs != null) {
                parentViewModel.inputs.getUnreadMsg(LocalLiveViewModel.READ_MSG_MODE.None);
            }
        }
//        Logger.t(TAG).d("size = " + alertListResponse.alerts.size());
        if (mAlertCursor == 0) {
            mFleetAlertAdapter.setNewData(filterList);
        } else {
            mFleetAlertAdapter.addData(filterList);
        }
        mAlertCursor += originList.size();
        mFleetAlertAdapter.loadMoreComplete();
        if (!response.isHasMore()) {
            mFleetAlertAdapter.loadMoreEnd();
        }
    }

    private List<EventBean> filterManual(List<EventBean> events) {
        List<EventBean> tempList = new ArrayList<>(events);

        for (EventBean bean : events) {
            String eventType = bean.getEventType();
            if ("MANUAL".equals(eventType)) {
                tempList.remove(bean);
            }
        }
        return tempList;
    }

    private void pollAlerts(Alert alert) {
        new Handler().postDelayed(() -> {
            Long alertTime = alert.alertTime;
            long currentTimeMillis = System.currentTimeMillis();
            //当前时间跟alert生成时间超过两分钟就不再刷新alerts列表
            //防止服务端拉取的alerts出现一直在uploading的情况
            Logger.t(TAG).d("subTimeMillis: " + (currentTimeMillis - alertTime));
            if (currentTimeMillis - alertTime <= 60 * 2 * 1000) {
                loadAlert(true);
            } else {
                Logger.t(TAG).d("uploading alert timeout");
            }
        }, 5000);
    }

    private void initEvent() {
        networkError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (mShowMessage) {
            mShowMessage = false;
            vaRootAlerts.post(this::viewMessage);
        }
    }

    private void handleNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(getActivity(), throwable);
    }

    public interface AlertOperationListener {
        void markAlertReaded(Alert alert);

        void deleteAlert(Alert alert);

        void playAlertReaded();
    }

    public interface MessageOperationListener {
        void markReaded(Notifications notifications);
    }

}
