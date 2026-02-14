package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.orhanobut.logger.Logger;
import com.tubb.smrv.SwipeHorizontalMenuLayout;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.rest_fleet.bean.EventBean;
import com.mk.autosecure.ui.activity.VideoPlayerActivity;
import com.mk.autosecure.ui.fragment.AlertsFragment;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class FleetAlertAdapter extends BaseQuickAdapter<EventBean, FleetAlertAdapter.AlertViewHolder> {

    private final static String TAG = FleetAlertAdapter.class.getSimpleName();

    private final static int spaceTime = 1500;

    private WeakReference<Context> mReference;

    private AlertsFragment.AlertOperationListener mListener;

    private long lastClickTime = 0;

    public FleetAlertAdapter(Context context) {
        super(R.layout.item_alert_wrap);
        mReference = new WeakReference<>(context);
    }

    public void setAlertOperationListener(AlertsFragment.AlertOperationListener listener) {
        mListener = listener;
    }

    private void onBindViewHolder(AlertViewHolder holder, EventBean eventBean) {

//        if (alert.isRead) {
//            holder.ll_read.setVisibility(View.GONE);
//            holder.tvCameraName.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
//            holder.tvAlertTime.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
//        } else {
//            holder.ll_read.setVisibility(View.VISIBLE);
//            holder.tvCameraName.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
//            holder.tvAlertTime.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
//        }

        dealAlertType(holder, eventBean);

//        holder.itemView.setBackgroundColor(alert.isRead ? ContextCompat.getColor(mReference.get(), R.color.gray) : ContextCompat.getColor(mReference.get(), R.color.white));
//        if (holder.sml.isSwipeEnable()) {
//            holder.sml.smoothCloseEndMenu();
//        }

        holder.sml.setSwipeEnable(false);

//        if (alert.location != null && alert.location.address != null) {
//            holder.tvAlertLocation.setText(alert.location.route);
//        }

        holder.tvAlertTime.setText(getFormattedTime(eventBean.getStartTime()));

        if (!TextUtils.isEmpty(eventBean.getMp4Url())) {

            holder.llUploading.setVisibility(View.GONE);
//            holder.tvAlertDuration.setText(DateUtils.formatElapsedTime(eventBean.getDuration() / 1000L));

            holder.itemView.setOnClickListener(v -> {
                long currentTimeMillis = System.currentTimeMillis();
                if (currentTimeMillis - lastClickTime < spaceTime) {
                    return;
                } else {
                    lastClickTime = currentTimeMillis;
                }

                Logger.t(TAG).d("alert: " + eventBean);
                VideoPlayerActivity.launch(mReference.get(), eventBean.getMp4Url(), eventBean.getEventType(),
                        eventBean.getStartTime(), eventBean.getCameraSN(), eventBean.getRotate(),
                        true, false);
            });
        } else {
//            holder.tvAlertDuration.setText("");
            holder.itemView.setOnClickListener(null);
        }

        Glide.with(mReference.get())
                .load(R.drawable.icon_event_playback)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .placeholder(R.drawable.bg_single_thumbnail)
                .error(R.drawable.bg_single_thumbnail)
                .into(holder.ivAlertThumbnail);
    }

    private void dealAlertType(AlertViewHolder holder, EventBean alert) {
        String eventType = alert.getEventType();

        holder.tvCameraName.setText(String.format("%s · %s", alert.getCameraSN(),
                VideoEventType.dealEventType(mReference.get(), eventType)));

        holder.alertType.setBackgroundColor(mReference.get().getResources()
                .getColor(VideoEventType.getEventColor(eventType)));
    }

    private String getFormattedTime(long utcTimeMillis) {
//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd KK:mm a", Locale.getDefault());
        format.setTimeZone(timeZone);

        SimpleDateFormat withoutYearFormat;
        SimpleDateFormat withoutDayFormat;
        if (DateFormat.is24HourFormat(mContext)) {
            withoutYearFormat = new SimpleDateFormat("HH:mm MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        } else {
            withoutYearFormat = new SimpleDateFormat("KK:mm a MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("KK:mm a", Locale.getDefault());
        }
        withoutYearFormat.setTimeZone(timeZone);
        withoutDayFormat.setTimeZone(timeZone);

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
                dateString = withoutDayFormat.format(utcTimeMillis);
            } else if ((currentDateDay - clipDateDay) < 2) {
                dateString = withoutDayFormat.format(utcTimeMillis) + " " + mContext.getString(R.string.yesterday);
            } else {
                dateString = withoutYearFormat.format(utcTimeMillis);
            }
        }
        return dateString;
    }

    @Override
    protected void convert(AlertViewHolder helper, EventBean item) {
        onBindViewHolder(helper, item);
    }

    static public class AlertViewHolder extends BaseViewHolder {

        @BindView(R.id.alertType)
        View alertType;

        @BindView(R.id.tv_camera_name)
        TextView tvCameraName;

        @BindView(R.id.tv_alert_location)
        TextView tvAlertLocation;

        @BindView(R.id.tv_alert_time)
        TextView tvAlertTime;

        @BindView(R.id.tv_alert_duration)
        TextView tvAlertDuration;

        @BindView(R.id.iv_alert_thumbnail)
        ImageView ivAlertThumbnail;

        @BindView(R.id.ll_uploading)
        LinearLayout llUploading;

        @BindView(R.id.sml)
        SwipeHorizontalMenuLayout sml;

        @BindView(R.id.ll_delete)
        LinearLayout ll_delete;

        @BindView(R.id.ll_read)
        LinearLayout ll_read;

        public AlertViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }
}
