package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.bean.FleetViewBean;
import com.mk.autosecure.rest_fleet.bean.FleetViewRecord;
import com.mk.autosecure.ui.fragment.OverviewFragment;
import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;
import java.text.DecimalFormat;

import butterknife.BindView;
import butterknife.ButterKnife;

public class SummaryAdapter extends BaseQuickAdapter<FleetViewRecord, SummaryAdapter.SummaryViewHolder> {

    private final static String TAG = SummaryAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private OverviewFragment.SummaryOperationListener mListener;

    public SummaryAdapter(Context context) {
        super(R.layout.item_summary);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(OverviewFragment.SummaryOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(SummaryViewHolder helper, FleetViewRecord item) {
        onBindViewHolder(helper, item);
    }

    @SuppressLint({"SetTextI18n", "NewApi"})
    private void onBindViewHolder(SummaryViewHolder holder, FleetViewRecord record) {
        holder.tvDriverName.setText(StringUtils.isEmpty(record.driverName) ? "Không có tài xế" : record.driverName);
        holder.tvPlateNumber.setText(record.plateNo);
        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        DecimalFormat decimalFormat2 = new DecimalFormat("0.0");
        holder.tvMiles.setText(record.miles > 0 ? decimalFormat.format((float) record.miles / 1000) + " km" : decimalFormat2.format((float) record.miles) + " km");//1609.3f)); //英里
        holder.tvHours.setText(record.hours > 0 ? decimalFormat.format((float) record.hours) + " h" : decimalFormat2.format((float) record.hours) + " h");
        holder.tvEvents.setText(String.valueOf(record.events));
        holder.tvSimState.setText(StringUtils.isEmpty(record.simState) ? "UNKNOWN" : record.simState);
        String check = "";
        if (StringUtils.isEmpty(record.simState)) check = "UNKNOWN";
        else check = record.simState;
        switch (check) {
            case "DEACTIVATED":
                holder.tvSimState.setTextColor(mContext.getColor(R.color.gray));
                break;
            case "UNKNOWN":
                holder.tvSimState.setTextColor(mContext.getColor(R.color.holo_red_dark));
                break;
            case "ACTIVATED":
            default:
                holder.tvSimState.setTextColor(mContext.getColor(R.color.green));
                break;
        }
        if (record.gpsData != null) {
            String speed = record.gpsData.speed > 0 ? decimalFormat.format((float) record.gpsData.speed) + " km/h" : decimalFormat2.format((float) record.gpsData.speed) + " km/h";
            holder.tvSpeed.setText(speed);
        } else {
            holder.tvSpeed.setText("0,0 km/h");
            holder.tvSpeed.setVisibility(View.GONE);
            holder.llSpeedReal.setVisibility(View.GONE);
        }

        String status = !TextUtils.isEmpty(record.mode) ? record.mode : "null";

        Logger.t(TAG).d("mode: " + status);

        if ("parking".equals(status)) {
            holder.ivCameraStatus.setImageResource(R.drawable.ic_parking_map);
        } else if ("driving".equals(status)) {
            holder.ivCameraStatus.setImageResource(R.drawable.ic_driving_map);
        } else {
            holder.ivCameraStatus.setImageResource(R.drawable.icon_offline_mode);
        }

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickSummary(record);
            }
        });
    }

    public class SummaryViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_driver_name)
        TextView tvDriverName;

        @BindView(R.id.iv_camera_status)
        ImageView ivCameraStatus;

        @BindView(R.id.tv_plate_number)
        TextView tvPlateNumber;

        @BindView(R.id.tv_miles)
        TextView tvMiles;

        @BindView(R.id.tv_hours)
        TextView tvHours;

        @BindView(R.id.tv_events)
        TextView tvEvents;

        @BindView(R.id.tvSimState)
        TextView tvSimState;

        @BindView(R.id.tvSpeed)
        TextView tvSpeed;

        @BindView(R.id.llSpeedReal)
        RelativeLayout llSpeedReal;

        public SummaryViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
