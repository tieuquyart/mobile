package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.ui.fragment.DataFleetFragment;

import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

public class DataFleetAdapter extends BaseQuickAdapter<BillingDataBean, DataFleetAdapter.DataFleetViewHolder> {

    private final static String TAG = DataFleetAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private DataFleetFragment.OperationListener mListener;

    public DataFleetAdapter(Context context) {
        super(R.layout.item_data_usage_fleet);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(DataFleetFragment.OperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(DataFleetViewHolder helper, BillingDataBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(DataFleetViewHolder holder, BillingDataBean bean) {
        long cycleEndDate = bean.getCycleEndDate();
        SimpleDateFormat format = new SimpleDateFormat("MMMM", Locale.getDefault());
        holder.tvBillingMonth.setText(format.format(cycleEndDate));

        long totalMB = 0;
        List<BillingDataBean.CamerasBean> cameras = bean.getCameras();
        for (BillingDataBean.CamerasBean camerasBean : cameras) {
            totalMB += camerasBean.getDataVolumeInMB();
        }
        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        holder.tvDataUsage.setText(String.format("%s GB", decimalFormat.format((float) totalMB / 1024)));

        // TODO: 2019-11-29 yangkun 定义
        holder.tvBillingStatus.setText(bean.getStatus());

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(bean);
            }
        });
    }

    public class DataFleetViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_billing_month)
        TextView tvBillingMonth;

        @BindView(R.id.tv_data_usage)
        TextView tvDataUsage;

        @BindView(R.id.tv_billing_status)
        TextView tvBillingStatus;

        public DataFleetViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
