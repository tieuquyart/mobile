package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;

import java.lang.ref.WeakReference;
import java.text.DecimalFormat;

import butterknife.BindView;
import butterknife.ButterKnife;

public class DataCameraAdapter extends BaseQuickAdapter<BillingDataBean.CamerasBean, DataCameraAdapter.DataCameraViewHolder> {

    private final static String TAG = DataCameraAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    public DataCameraAdapter(Context context) {
        super(R.layout.item_data_usage_camera);
        mReference = new WeakReference<>(context);
    }

    @Override
    protected void convert(DataCameraViewHolder helper, BillingDataBean.CamerasBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(DataCameraViewHolder holder, BillingDataBean.CamerasBean bean) {
        holder.tvCameraSn.setText(bean.getCameraSN());

        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        holder.tvDataUsage.setText(String.format("%s GB", decimalFormat.format(bean.getDataVolumeInMB() / 1024)));
    }

    public class DataCameraViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_camera_sn)
        TextView tvCameraSn;

        @BindView(R.id.tv_data_usage)
        TextView tvDataUsage;

        public DataCameraViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
