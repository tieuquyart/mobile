package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.text.format.DateUtils;
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
import com.mkgroup.camera.bean.Alert;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.EventResponse;
import com.mk.autosecure.ui.activity.VideoPlayerActivity;
import com.mk.autosecure.ui.fragment.AlertsFragment;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class AlertAdapter extends BaseQuickAdapter<Alert, AlertAdapter.AlertViewHolder> {

    private final static String TAG = AlertAdapter.class.getSimpleName();

    private final static int spaceTime = 1500;

    private WeakReference<Context> mReference;

    private AlertsFragment.AlertOperationListener mListener;

    private long lastClickTime = 0;

    public AlertAdapter(Context context) {
        super(R.layout.item_alert_wrap);
        mReference = new WeakReference<>(context);
    }

    public void setAlertOperationListener(AlertsFragment.AlertOperationListener listener) {
        mListener = listener;
    }

    private void onBindViewHolder(AlertViewHolder holder, Alert alert) {

        if (alert.isRead) {
            holder.ll_read.setVisibility(View.GONE);
            holder.tvCameraName.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            holder.tvAlertTime.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
        } else {
            holder.ll_read.setVisibility(View.VISIBLE);
            holder.tvCameraName.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            holder.tvAlertTime.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
        }

        dealAlertType(holder, alert);

//        holder.itemView.setBackgroundColor(alert.isRead ? ContextCompat.getColor(mReference.get(), R.color.gray) : ContextCompat.getColor(mReference.get(), R.color.white));
        if (holder.sml.isSwipeEnable()) {
            holder.sml.smoothCloseEndMenu();
        }


        if (alert.location != null && alert.location.address != null) {
            holder.tvAlertLocation.setText(alert.location.route);
        }

        Long alertTime = alert.alertTime;
        if (alertTime != null) {
            holder.tvAlertTime.setText(getFormattedTime(alertTime));
        }

        if (!TextUtils.isEmpty(alert.mediaType) && alert.mediaType.equals(Alert.TYPE_VIDEO) && !TextUtils.isEmpty(alert.thumbnail)) {

            if ("finish".equals(alert.status)) {
                holder.llUploading.setVisibility(View.GONE);
                holder.tvAlertDuration.setText(DateUtils.formatElapsedTime(alert.durationMs / 1000L));
            } else {
                long sub = System.currentTimeMillis() - (alertTime != null ? alertTime : 0);
                //超过两分钟就不再显示uploading的状态
                if (sub <= 60 * 2 * 1000) {
                    holder.llUploading.setVisibility(View.VISIBLE);
                    holder.llUploading.setBackgroundResource(R.color.colorAccentWithAlpha);
                } else {
                    holder.llUploading.setVisibility(View.GONE);
                }
                holder.tvAlertDuration.setText("");
            }

            holder.itemView.setOnClickListener(v -> {
                long currentTimeMillis = System.currentTimeMillis();
                if (currentTimeMillis - lastClickTime < spaceTime) {
                    return;
                } else {
                    lastClickTime = currentTimeMillis;
                }

                if (alert.isRead) {
                    Logger.t(TAG).d("alert: " + alert);
                    VideoPlayerActivity.launch(mReference.get(), alert);
                } else {
                    ApiService.createApiService().markEventRead(alert.eventID)
                            .compose(Transformers.switchSchedulers())
                            .doFinally(() -> {
                                Logger.t(TAG).d("alert: " + alert);
                                VideoPlayerActivity.launch(mReference.get(), alert);
                            })
                            .subscribe(new BaseObserver<EventResponse>() {
                                @Override
                                protected void onHandleSuccess(EventResponse data) {
                                    int position = holder.getAdapterPosition();
                                    if (mListener != null) {
                                        mListener.playAlertReaded();
                                    }
                                    getData().get(position).isRead = true;
                                    notifyItemChanged(position);
                                }
                            });
                }
            });
        } else {
            holder.tvAlertDuration.setText("");
            holder.itemView.setOnClickListener(null);
        }

        if (TextUtils.isEmpty(alert.thumbnail)) {
            holder.llUploading.setVisibility(View.VISIBLE);
            holder.llUploading.setBackgroundResource(R.color.colorAccent);
            Glide.clear(holder.ivAlertThumbnail);
            holder.ivAlertThumbnail.setImageDrawable(null);
        } else {
            boolean lensMode = TextUtils.isEmpty(alert.rotate) || LENS_NORMAL.equals(alert.rotate);
            Glide.with(mReference.get())
                    .load(alert.thumbnail)
                    .transform(new TwoDirectionTransform(mContext, lensMode))
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.bg_single_thumbnail)
                    .error(R.drawable.bg_single_thumbnail)
                    .into(holder.ivAlertThumbnail);
        }

        holder.ll_delete.setOnClickListener(v -> {
            int position = holder.getAdapterPosition();
            if (mListener != null && position < getData().size()) {
                mListener.deleteAlert(getData().get(position));
            }
            holder.sml.smoothCloseEndMenu();
//                remove(position);
        });

        holder.ll_read.setOnClickListener(v -> {
            int position = holder.getAdapterPosition();
            if (mListener != null && position < getData().size()) {
                mListener.markAlertReaded(getData().get(position));
            }
            holder.sml.smoothCloseEndMenu();
//                getData().get(position).isRead = true;
//                notifyItemChanged(position);
        });
    }

    private void dealAlertType(AlertViewHolder holder, Alert alert) {
        String alertType = alert.alertType;

        holder.tvCameraName.setText(String.format("%s · %s", alert.cameraName,
                VideoEventType.dealEventType(mReference.get(), alertType)));

        holder.alertType.setBackgroundColor(mReference.get().getResources()
                .getColor(VideoEventType.getEventColor(alertType)));
    }

    private String getFormattedTime(long date) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd KK:mm a", Locale.getDefault());
        SimpleDateFormat withoutYearFormat;
        SimpleDateFormat withoutDayFormat;
        if (DateFormat.is24HourFormat(mContext)) {
            withoutYearFormat = new SimpleDateFormat("HH:mm MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        } else {
            withoutYearFormat = new SimpleDateFormat("KK:mm a MMM dd", Locale.getDefault());
            withoutDayFormat = new SimpleDateFormat("KK:mm a", Locale.getDefault());
        }

        long currentTime = System.currentTimeMillis();

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(date);
        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int clipDateYear = calendar.get(Calendar.YEAR);

        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        String dateString = format.format(date);

        if (clipDateYear == currentDateYear) {
            if ((currentDateDay - clipDateDay) < 1) {
                dateString = withoutDayFormat.format(date);
            } else if ((currentDateDay - clipDateDay) < 2) {
                dateString = withoutDayFormat.format(date) + " " + mContext.getString(R.string.yesterday);
            } else {
                dateString = withoutYearFormat.format(date);
            }
        }
        return dateString;
    }

    @Override
    protected void convert(AlertViewHolder helper, Alert item) {
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
