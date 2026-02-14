package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.launcher.ARouter;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.ui.activity.FleetVideoActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.DateTime;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.CameraEventBean;
import com.mk.autosecure.rest_fleet.bean.GeoFenceEventBean;
import com.mk.autosecure.rest_fleet.bean.IgnitionBean;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.bean.TimelineBean;
import com.mk.autosecure.rest_fleet.bean.TripBean;
import com.mk.autosecure.ui.activity.TimelineActivity;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/31.
 */

@SuppressLint("CheckResult")
public class TimelineAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = TimelineAdapter.class.getSimpleName();

    private static final int TYPE_STATUS = 0x00;
    private static final int TYPE_EVENT = 0x01;

    private static final int TOP_HEADER = 1;
    private static final int BOTTOM_HEADER = 2;

    private WeakReference<Context> mReference;

    private List<TimelineAdapter.ViewItem> viewItemList = new ArrayList<>();

    private List<CameraEventBean> events = new ArrayList<>();

    private TimelineActivity.TimelineOperationListener mListener;

    private List<List<CameraEventBean>> mEventTripClusterList;

    private String vehicleBrand;
    private String vehicleType;

    TimelineAdapter(Context context) {
        this.mReference = new WeakReference<>(context);
    }

    void setTimelineOperationListener(TimelineActivity.TimelineOperationListener listener) {
        this.mListener = listener;
    }

    void setTimelineBeanList(List<TimelineBean> beanList) {
        recalculateTimelineList(beanList);
        notifyDataSetChanged();
    }

    void setTripBeanList(List<TripBean> beanList) {
        recalculateTripList(beanList);
        notifyDataSetChanged();
    }

    void setDataVehicle(String brand, String type){
        this.vehicleBrand = brand;
        this.vehicleType = type;
    }

    void setNotificationBeanList(List<NotificationBean> beanList) {
        recalculateNotificationList(beanList);
        notifyDataSetChanged();
    }

    private void recalculateNotificationList(List<NotificationBean> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

//        Collections.sort(beanList, (o1, o2) -> o2.getNotificationTime() - o1.getNotificationTime() > 0 ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            NotificationBean bean = beanList.get(i);
            ViewItem viewItem = new ViewItem();
//            viewItem.itemType = bean.getEvent() != null ? TYPE_EVENT : TYPE_STATUS;
            viewItem.itemObject = bean;
            if (i == 0) {
                viewItem.extra = TOP_HEADER;
            } else if (i == beanList.size() - 1) {
                viewItem.extra = BOTTOM_HEADER;
            }
            viewItemList.add(viewItem);
        }
    }

    private void recalculateTimelineList(List<TimelineBean> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

        Collections.sort(beanList, (o1, o2) -> ((o2.getTimelineTime() - o1.getTimelineTime()) > 0) ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            TimelineBean bean = beanList.get(i);

            // filter PowerEvent
            if (bean.getIgnition() == null
                    && bean.getEvent() == null
                    && bean.getGeoFenceEvent() == null) {
                continue;
            }

            ViewItem viewItem = new ViewItem();
            viewItem.itemType = bean.getEvent() != null ? TYPE_EVENT : TYPE_STATUS;
            viewItem.itemObject = bean;
            if (i == 0) {
                viewItem.extra = TOP_HEADER;
            } else if (i == beanList.size() - 1) {
                viewItem.extra = BOTTOM_HEADER;
            }
            viewItemList.add(viewItem);
        }
    }

    private void recalculateTripList(List<TripBean> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

        Collections.sort(beanList, (o1, o2) -> ((o2.getEventCount() - o1.getEventCount()) > 0) ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            TripBean bean = beanList.get(i);
            ViewItem viewItem = new ViewItem();
            viewItem.itemType = TYPE_EVENT;
            viewItem.itemObject = bean;
            if (i == 0) {
                viewItem.extra = TOP_HEADER;
            } else if (i == beanList.size() - 1) {
                viewItem.extra = BOTTOM_HEADER;
            }
            viewItemList.add(viewItem);
        }
    }

    public List<TimelineAdapter.ViewItem> getViewItemList() {
        return viewItemList;
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == TYPE_STATUS) {
            return new StatusViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_timeline_status, parent, false));
        } else {
            return new EventViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_trip, parent, false));
        }
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < getItemCount()) {
            return viewItemList.get(position).itemType;
        }
        return -1;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        switch (getItemViewType(position)) {
            case TYPE_STATUS:
                onBindStatusViewHolder((StatusViewHolder) holder, position);
                break;
            case TYPE_EVENT:
                onBindEventViewHolder((EventViewHolder) holder, position);
                break;
        }
    }

    @SuppressLint("SetTextI18n")
    private void onBindEventViewHolder(EventViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);

        String drivingTime = "";
        String parkingTime = "";
        int eventCount = 0;
        boolean isExpanded = false;
        String driverName = "";


        if (viewItem.itemObject instanceof TripBean) {
            TripBean bean = (TripBean) viewItem.itemObject;
            drivingTime = bean.getDrivingTime();
            parkingTime = bean.getParkingTime();
            eventCount = bean.getEventCount();
            isExpanded = bean.isExpanded();
            driverName = bean.getDriverName();
        }

        //parking-driving time

        String timeDriving = StringUtils.getTimeFromString(drivingTime, "Không có dữ liệu thời gian");
        holder.timeStart.setText(timeDriving);

        String timeParking = StringUtils.getTimeFromString(parkingTime, "Hiện tại");
        holder.timeEnd.setText(timeParking);

        holder.tvBrand.setText(!StringUtils.isEmpty(this.vehicleBrand) ? this.vehicleBrand : "Hãng xe");
        holder.tvType.setText(!StringUtils.isEmpty(this.vehicleType) ? this.vehicleType : "Kiểu xe");

        if (eventCount > 0) {
            holder.llEventCount.setVisibility(View.VISIBLE);
            holder.eventCount.setText("" + eventCount);
        } else {
            holder.llEventCount.setVisibility(View.INVISIBLE);
        }

        holder.imgExpand.setImageResource(isExpanded ? R.drawable.icon_arrow_dn_gray : R.drawable.icon_arrow_right);

        holder.expEvent.setVisibility(isExpanded ? View.VISIBLE : View.GONE);

        holder.rvEvent.setLayoutManager(new LinearLayoutManager(mReference.get()));
        holder.rvEvent.setVisibility(events.size() > 0 ? View.VISIBLE : View.GONE);
        EventsTripAdapter adapter = new EventsTripAdapter(mReference.get());

        holder.timeIntoDriving.setText(StringUtils.getTimeFromString(drivingTime, "No Time"));

        holder.msgIntoDriving.setText(driverName + " Đã lái xe");

        holder.timeIntoParking.setText(StringUtils.getTimeFromString(parkingTime, "Hiện tại"));

        holder.msgIntoParking.setText(driverName + " Đã đỗ xe");

        holder.itemView.setOnClickListener(v -> {
            if (viewItem.itemObject instanceof TripBean) {
                TripBean bean = (TripBean) viewItem.itemObject;
                bean.setExpanded(!bean.isExpanded());
                if (!TextUtils.isEmpty(bean.getTripId())) {
                    CurrentUser currentUser = HornApplication.getComponent().currentUser();
                    ApiClient.createApiService().getAllEventsForOneTrip(bean.getTripId(), currentUser.getAccessToken())
                            .compose(Transformers.switchSchedulers())
                            .subscribe(response -> {
                                events = response.getEvents();
                                adapter.setEventsTripBeanList(events);
                                holder.rvEvent.setAdapter(adapter);
                                notifyItemChanged(position);
                            }, throwable -> {
                                Logger.t(TAG).e("getEventsList throwable: " + throwable.getMessage());
                                notifyItemChanged(position);
                                NetworkErrorHelper.handleCommonError(mReference.get(), throwable);
                            });
                }
            }
        });

        adapter.setEventsTripBeanList(events);
        holder.rvEvent.setAdapter(adapter);

        adapter.setTimelineOperationListener((id, bean) -> {
            if (id != 0 && bean != null) {
                ApiClient.createApiService().getVideoUrl(id, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .subscribe(response -> ARouter.getInstance().build("/ui/activity/FleetVideoActivity")
                                .withString(FleetVideoActivity.VIDEO_URL, response.getData())
                                .withString(FleetVideoActivity.EVENT_TYPE, bean.getEventType())
                                .withString(FleetVideoActivity.START_TIME, bean.getStartTime())
                                .withDouble(FleetVideoActivity.DURATION, bean.getDuration())
                                .withString(IntentKey.FLEET_DRIVER_NAME, bean.getDriverName())
                                .withString(IntentKey.FLEET_PLATE_NUMBER, bean.getPlateNo())
                                .withString(IntentKey.FLEET_CAMERA_ROTATE, "upsidedown")
                                .withString(IntentKey.SERIAL_NUMBER, bean.getCameraSn())
                                .withDouble(IntentKey.GPS_LAT, bean.getGpsLatitude())
                                .withDouble(IntentKey.GPS_LONG, bean.getGpsLongitude())
                                .withBoolean(FleetVideoActivity.LOCAL_VIDEO, false)
                                .navigation(), throwable -> {
                            Logger.t(TAG).e("getVideoUrl throwable: " + throwable.getMessage());
                            Toast.makeText(mReference.get(), throwable.getMessage(), Toast.LENGTH_SHORT).show();
                        });
            } else {
                Toast.makeText(mReference.get(), "Lấy thông tin video lỗi", Toast.LENGTH_SHORT).show();
            }
        });

        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        if (getItemCount() == 1) {
            layoutParams.setMargins(0, ViewUtils.dp2px(5), 0, ViewUtils.dp2px(16));
            holder.itemView.setLayoutParams(layoutParams);
        } else if (viewItem.extra == TOP_HEADER) {
            layoutParams.setMargins(0, ViewUtils.dp2px(5), 0, 0);
            holder.itemView.setLayoutParams(layoutParams);
        } else if (viewItem.extra == BOTTOM_HEADER) {
            layoutParams.setMargins(0, 0, 0, ViewUtils.dp2px(16));
            holder.itemView.setLayoutParams(layoutParams);
        } else {
            layoutParams.setMargins(0, 0, 0, 0);
            holder.itemView.setLayoutParams(layoutParams);
        }
        holder.itemView.requestLayout();
    }

    private void onBindStatusViewHolder(StatusViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);

        long utcTimeMills = 0;
        String driverName = "";
        IgnitionBean ignition = null;
        GeoFenceEventBean geoFenceEvent = null;

        if (viewItem.itemObject instanceof TimelineBean) {
            TimelineBean bean = (TimelineBean) viewItem.itemObject;
            utcTimeMills = bean.getTimelineTime();
            driverName = bean.getDriverName();
            ignition = bean.getIgnition();
            geoFenceEvent = bean.getGeoFenceEvent();
        }
        TimeZone timeZone = TimeZone.getDefault();

        String time;
        if (DateFormat.is24HourFormat(mReference.get())) {
            time = DateTime.get24HTimeWithTZ(timeZone, utcTimeMills);
        } else {
            time = DateTime.get12HTimeWithTZ(timeZone, utcTimeMills);
        }
        holder.tv_videoTime.setText(time);

        if (!TextUtils.isEmpty(driverName) && driverName.length() > 18) {
            driverName = driverName.substring(0, 18) + "...";
        }

        if (ignition != null) {
            String ignitionStatus = ignition.getIgnitionStatus();
            if ("parking".equals(ignitionStatus)) {
                holder.viewStatus.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor("#5BC162")));
            } else if ("driving".equals(ignitionStatus)) {
                holder.viewStatus.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor("#4A90E2")));
            }
            holder.tv_videoStatus.setText(String.format("%s went into %s mode", driverName, ignitionStatus));
        } else if (geoFenceEvent != null) {
            String geoFenceType = geoFenceEvent.getGeoFenceType();
            String geoFenceRuleName = geoFenceEvent.getGeoFenceRuleName();
            holder.tv_videoStatus.setText(String.format("%s %s geo-fence %s", driverName, geoFenceType, geoFenceRuleName));
        }

        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        if (getItemCount() == 1) {
            holder.viewTop.setBackgroundResource(R.drawable.background_timeline_top_header);
            holder.viewBtm.setBackgroundResource(R.drawable.background_timeline_btm_header);

            layoutParams.setMargins(0, ViewUtils.dp2px(16), 0, ViewUtils.dp2px(16));
            holder.itemView.setLayoutParams(layoutParams);
        } else if (viewItem.extra == TOP_HEADER) {
            holder.viewTop.setBackgroundResource(R.drawable.background_timeline_top_header);

            layoutParams.setMargins(0, ViewUtils.dp2px(16), 0, 0);
            holder.itemView.setLayoutParams(layoutParams);
        } else if (viewItem.extra == BOTTOM_HEADER) {
            holder.viewBtm.setBackgroundResource(R.drawable.background_timeline_btm_header);

            layoutParams.setMargins(0, 0, 0, ViewUtils.dp2px(16));
            holder.itemView.setLayoutParams(layoutParams);
        } else {
            holder.viewTop.setBackgroundResource(R.color.gray);
            holder.viewBtm.setBackgroundResource(R.color.gray);

            layoutParams.setMargins(0, 0, 0, 0);
            holder.itemView.setLayoutParams(layoutParams);
        }
        holder.itemView.requestLayout();
    }

    @Override
    public int getItemCount() {
        return viewItemList.size();
    }

    static class EventViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.totalTime)
        TextView totalTime;

        @BindView(R.id.llEventCound)
        View llEventCount;

        @BindView(R.id.eventCount)
        TextView eventCount;

        @BindView(R.id.timeStart)
        TextView timeStart;

        @BindView(R.id.timeEnd)
        TextView timeEnd;

        @BindView(R.id.expEvent)
        LinearLayout expEvent;

        @BindView(R.id.rv_Event)
        RecyclerView rvEvent;

        @BindView(R.id.imgExpand)
        ImageView imgExpand;

        @BindView(R.id.msgIntoDriving)
        TextView msgIntoDriving;

        @BindView(R.id.msgIntoParking)
        TextView msgIntoParking;

        @BindView(R.id.timeIntoDriving)
        TextView timeIntoDriving;

        @BindView(R.id.timeIntoParking)
        TextView timeIntoParking;

        @BindView(R.id.tvBrand)
        TextView tvBrand;
        @BindView(R.id.tvType)
        TextView tvType;

        EventViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static class StatusViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_videoStatus)
        TextView tv_videoStatus;

        @BindView(R.id.view_status)
        View viewStatus;

        @BindView(R.id.tv_videoTime)
        TextView tv_videoTime;

        @BindView(R.id.view_top)
        View viewTop;

        @BindView(R.id.view_bottom)
        View viewBtm;

        StatusViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public static class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;

        @NonNull
        @Override
        public String toString() {
            return "ViewItem{" +
                    "itemType=" + itemType +
                    ", itemObject=" + itemObject +
                    ", extra=" + extra +
                    '}';
        }
    }

}


