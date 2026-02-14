package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.ui.fragment.DashDriverFragment;

import java.lang.ref.WeakReference;

import butterknife.BindView;
import butterknife.ButterKnife;

public class DashDriverAdapter extends BaseQuickAdapter<DetailBean.Record, DashDriverAdapter.DashboardViewHolder> {

    private final static String TAG = DashDriverAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private DashDriverFragment.OperationListener mListener;

    public DashDriverAdapter(Context context) {
        super(R.layout.item_dashboard_driver);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(DashDriverFragment.OperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(DashboardViewHolder helper, DetailBean.Record item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(DashboardViewHolder holder, DetailBean.Record record) {
        holder.tvSectionDate.setText(record.getSummaryTime());

        int tempMiles = (int) (record.getDistanceTotal() / 1000);
        String milesString = String.valueOf(tempMiles);
            holder.tvMiles.setText(milesString);

        double tempHours = record.getHoursTotal();
        String hoursString = String.valueOf(tempHours);
        holder.tvHours.setText(hoursString);

        double tempEvents = record.getEventTotal();
        String eventsString = String.valueOf(tempEvents);
        holder.tvEvents.setText(eventsString);


        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClick(record);
            }
        });
    }

    public class DashboardViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_section_date)
        TextView tvSectionDate;

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
