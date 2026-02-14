package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.ui.fragment.OverviewFragment;

import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

public class DashFleetAdapter extends BaseQuickAdapter<DetailBean.Record, DashFleetAdapter.DashboardViewHolder> {

    private final static String TAG = DashFleetAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private OverviewFragment.DashFleetOperationListener mListener;

    public DashFleetAdapter(Context context) {
        super(R.layout.item_dashboard_fleet);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(OverviewFragment.DashFleetOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(DashboardViewHolder helper, DetailBean.Record item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(DashboardViewHolder holder, DetailBean.Record record) {
        holder.tvDriverName.setText(record.getDriverName());

        int tempMiles = (int) (record.getDistanceTotal() / 1000);
        String milesString = String.valueOf(tempMiles);
        int milesLength = milesString.length();
        if (milesLength <= 4) {
            DecimalFormat decimalFormat = new DecimalFormat("0.00");
            holder.tvMiles.setText(decimalFormat.format((float) record.getDistanceTotal() / 1000));
        } else if (milesLength == 5) {
            holder.tvMiles.setText(milesString);
        } else if (milesLength == 6) {
            DecimalFormat decimalFormat = new DecimalFormat("0.00");
            holder.tvMiles.setText(String.format(Locale.getDefault(),
                    "%sK", decimalFormat.format((float) record.getDistanceTotal() / 1000 / 1000)));
        } else {
            DecimalFormat decimalFormat = new DecimalFormat("0.000");
            holder.tvMiles.setText(String.format(Locale.getDefault(),
                    "%sM", decimalFormat.format((float) record.getDistanceTotal() / 1000 / 1000 / 1000)));
        }

        double tempHours = record.getHoursTotal();
        String hoursString = String.valueOf(tempHours);
            holder.tvHours.setText(hoursString);


        double tempEvents = record.getEventTotal();
        String eventsString = String.valueOf(tempEvents);
            holder.tvEvents.setText(eventsString);


        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickDashFleet(record);
            }
        });
    }

    public class DashboardViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_driver_name)
        TextView tvDriverName;

        @BindView(R.id.tv_miles)
        TextView tvMiles;

        @BindView(R.id.tv_hours)
        TextView tvHours;

        @BindView(R.id.tv_events)
        TextView tvEvents;

        public DashboardViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
