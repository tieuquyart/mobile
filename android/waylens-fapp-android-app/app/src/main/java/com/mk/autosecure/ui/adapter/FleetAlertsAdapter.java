package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.ui.activity.TimelineActivity;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/31.
 */

public class FleetAlertsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = FleetAlertsAdapter.class.getSimpleName();

    private static final int TYPE_SECTION_DATE = 0x00;
    private static final int TYPE_FOOTER = 0x01;

    private WeakReference<Context> mWeakRef;

    private List<FleetAlertsAdapter.ViewItem> viewItemList = new ArrayList<>();

    private List<NotificationBean> notificationList = new ArrayList<>();

    private TimelineActivity.TimelineOperationListener mListener;

    public FleetAlertsAdapter(Context context) {
        this.mWeakRef = new WeakReference<>(context);
    }

    public void setTimelineOperationListener(TimelineActivity.TimelineOperationListener listener) {
        this.mListener = listener;
    }

    public List<NotificationBean> getNotificationList() {
        return notificationList;
    }

    public void setNotificationList(List<NotificationBean> notificationList) {
        this.notificationList = notificationList;
        recalculateNotificationList(notificationList);
        notifyDataSetChanged();
    }

    private void recalculateNotificationList(List<NotificationBean> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

//        Collections.sort(beanList, (o1, o2) -> ((o2.getReceiveTime() - o1.getReceiveTime()) > 0) ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            NotificationBean timelineBeans = beanList.get(i);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_SECTION_DATE;
            headItem.itemObject = timelineBeans;
            headItem.extra = 0; // 区分是timeline还是notification
            viewItemList.add(headItem);
        }

        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
    }

    public List<FleetAlertsAdapter.ViewItem> getViewItemList() {
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
        if (viewType == TYPE_FOOTER) {
            return new FooterViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_no_more_events, parent, false));
        }
        return new SectionViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_fleet_alerts, parent, false));
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
            case TYPE_SECTION_DATE:
                onBindDateViewHolder((SectionViewHolder) holder, position);
                break;
            case TYPE_FOOTER:
                onBindFooterViewHolder((FooterViewHolder) holder, position);
                break;
            default:
                break;
        }
    }

    @Override
    public int getItemCount() {
//        Logger.t(TAG).e("getItemCount: " + viewItemList.size());
        return viewItemList.size();
    }

    private void onBindFooterViewHolder(FooterViewHolder holder, int position) {
        Logger.t(TAG).d("onBindFooterViewHolder: " + position);
    }

    @SuppressLint("CheckResult")
    private void onBindDateViewHolder(SectionViewHolder holder, int position) {
//        Logger.t(TAG).d("onBindDateViewHolder: " + position);
        ViewItem viewItem = viewItemList.get(position);
        NotificationBean bean = (NotificationBean) viewItem.itemObject;
//
//        transformAlertTime(holder, bean.getReceiveTime());
//        holder.tvVideoTime.setText(getFormattedDate(bean.getNotificationTime()));
//
//        NotificationBean.EventBean beanEvent = bean.getEvent();
//        IgnitionBean ignition = bean.getIgnition();
//        GeoFenceEventBean geoFenceEvent = bean.getGeoFenceEvent();
//
//        if (beanEvent != null) {
//            holder.tvVideoLocation.setText(beanEvent.getAddress());
//
//            String eventType = beanEvent.getEventType();
//            holder.tvVideoType.setText(String.format("%s · %s",
//                    bean.getDriverName(),
//                    VideoEventType.dealEventType(mWeakRef.get(), eventType)));
//
//            holder.viewBuffered.setVisibility(View.INVISIBLE);
//            holder.viewEvent.setVisibility(View.VISIBLE);
//            holder.viewEvent.setBackgroundResource(VideoEventType.getEventDrawable(eventType));
//
//            holder.ivNextPlay.setVisibility(View.VISIBLE);
//        } else if (ignition != null) {
//            holder.tvVideoLocation.setText(String.format("Went into %s mode",
//                    ignition.getIgnitionStatus()));
//
//            holder.tvVideoType.setText(bean.getDriverName());
//
//            holder.viewBuffered.setVisibility(View.VISIBLE);
//            holder.viewEvent.setVisibility(View.INVISIBLE);
//
//            holder.ivNextPlay.setVisibility(View.INVISIBLE);
//        } else if (geoFenceEvent != null) {
//            holder.tvVideoLocation.setText(String.format("%s geo-fence %s Driving %s",
//                    "enter".equals(geoFenceEvent.getGeoFenceType()) ? "Entered" : "Exited",
//                    geoFenceEvent.getGeoFenceRuleName(),
//                    bean.getPlateNumber()));
//
//            holder.tvVideoType.setText(bean.getDriverName());
//
//            holder.viewBuffered.setVisibility(View.VISIBLE);
//            holder.viewEvent.setVisibility(View.INVISIBLE);
//
//            holder.ivNextPlay.setVisibility(View.INVISIBLE);
//        }
//
//        holder.itemView.setOnClickListener(v -> {
//            if (beanEvent != null && mListener != null) {
//                Logger.t(TAG).e("onClickItem: " + viewItem.itemObject);
////                mListener.onClickItem(bean.getDriverID(),
////                        bean.getEvent() != null ? bean.getEvent().getClipID() : "",
////                        bean.getDriverName(),
////                        bean.getPlateNumber());
//            }
//        });
    }

    private void transformAlertTime(SectionViewHolder holder, long createTime) {
        long currentTimeMillis = System.currentTimeMillis();
        long l = currentTimeMillis - createTime;
//        Logger.t(TAG).e("currentTimeMillis - createTime: " + l / 1000);

        if (l <= 60 * 1000) {
            holder.tvAlertTime.setText(R.string.one_minute_ago);
        } else if (l <= 3600 * 1000) {
            holder.tvAlertTime.setText(mWeakRef.get().getString(R.string.minutes_ago, l / 60 / 1000));
        } else if (l <= 3600 * 1000 * 2) {
            holder.tvAlertTime.setText(R.string.one_hour_ago);
        } else if (l <= 3600 * 1000 * 24) {
            holder.tvAlertTime.setText(mWeakRef.get().getString(R.string.hours_ago, l / 3600 / 1000));
        } else {
            boolean isZh = Locale.getDefault().getLanguage().equals("zh");
//            Logger.t(TAG).d("isZh: " + isZh + "--" + Locale.getDefault().getLanguage());
            SimpleDateFormat format = new SimpleDateFormat(isZh ? "yyyy, MMM d" : "MMM d, yyyy", Locale.getDefault());
            holder.tvAlertTime.setText(format.format(new Date(createTime)));
        }
    }

    private String getFormattedDate(long utcTimeMillis) {
//        UserLogin fleetUser = HornApplication.getComponent().currentUser().getUserLogin();
        TimeZone timeZone = TimeZone.getDefault();

        SimpleDateFormat format = new SimpleDateFormat("HH:mm MMM d", Locale.getDefault());
        format.setTimeZone(timeZone);

        long currentTime = System.currentTimeMillis();
        Calendar calendar = Calendar.getInstance();

        calendar.setTimeZone(timeZone);
        calendar.setTimeInMillis(utcTimeMillis);
        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int clipDateYear = calendar.get(Calendar.YEAR);

        calendar.setTimeZone(TimeZone.getTimeZone("UTC"));
        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        String dateString = format.format(utcTimeMillis);

        if (clipDateYear == currentDateYear) {
            if ((currentDateDay - clipDateDay) < 1) {
                format = new SimpleDateFormat("HH:mm", Locale.getDefault());
                format.setTimeZone(timeZone);
                dateString = format.format(utcTimeMillis);
            }
        } else {
            format = new SimpleDateFormat("HH:mm MMM d yyyy", Locale.getDefault());
            format.setTimeZone(timeZone);
            dateString = format.format(utcTimeMillis);
        }
        return dateString;
    }

    class FooterViewHolder extends RecyclerView.ViewHolder {

        FooterViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    class SectionViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_alert_time)
        TextView tvAlertTime;

        @BindView(R.id.view_event)
        View viewEvent;

        @BindView(R.id.view_buffered)
        View viewBuffered;

        @BindView(R.id.tv_videoType)
        TextView tvVideoType;

        @BindView(R.id.tv_videoTime)
        TextView tvVideoTime;

        @BindView(R.id.tv_videoLocation)
        TextView tvVideoLocation;

        @BindView(R.id.iv_next_play)
        ImageView ivNextPlay;

        SectionViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public static class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;
    }
}


