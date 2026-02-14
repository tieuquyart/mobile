package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.ui.fragment.interfaces.DriverOperationListener;
import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

public class AssetDriverAdapter extends BaseQuickAdapter<DriverInfoBean, AssetDriverAdapter.DriverViewHolder> implements Filterable {

    private final static String TAG = AssetDriverAdapter.class.getSimpleName();

    private DriverOperationListener mListener;

    private WeakReference<Context> mReference;
    List<DriverInfoBean> driverInfoBeans = new ArrayList<>();

    public AssetDriverAdapter(Context context) {
        super(R.layout.item_asset_drivers);
        mReference = new WeakReference<>(context);
    }


    public void setOperationListener(DriverOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    public void setNewData(@Nullable List<DriverInfoBean> data) {
        super.setNewData(data);
    }

    @Override
    protected void convert(DriverViewHolder helper, DriverInfoBean item) {
        onBindViewHolder(helper, item);
    }

    public void setDataMK(@Nullable List<DriverInfoBean> dataMK) {
        driverInfoBeans = dataMK;
        assert driverInfoBeans != null;
        driverInfoBeans.add(0, null);
        Log.d(TAG, "dataInit: " + driverInfoBeans.toString());
        setNewData(dataMK);
    }

    public void setNewDataMK(@Nullable List<DriverInfoBean> dataMK) {

        if (dataMK != null && dataMK.size() != 0) {

            Log.d(TAG, "dataNew: " + dataMK.toString());
            setNewData(dataMK);
        } else {
            Log.d(TAG, "dataOld: " + driverInfoBeans.toString());
            setNewData(null/*driverInfoBeans*/);
        }
    }

//    private

    @Override
    public Filter getFilter() {
        return filterDriver;
    }

    private Filter filterDriver = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence charSequence) {
            List<DriverInfoBean> filterList = new ArrayList<>();
            if (charSequence == null || charSequence.length() == 0) {
                filterList = driverInfoBeans;
            } else {
                String filterPattern = charSequence.toString().toLowerCase().trim();
                for (DriverInfoBean bean : driverInfoBeans) {
                    Log.d(TAG, "filterString:= " + filterPattern);
                    if (bean != null && (bean.getName().toLowerCase().trim().contains(filterPattern) /*|| bean.getPhoneNo().toLowerCase().contains(filterPattern) || bean.getIdNumber().toLowerCase().contains(filterPattern)*/)) {
                        filterList.add(bean);
                    }
                }
            }

            FilterResults results = new FilterResults();
            results.values = filterList;
            Log.d(TAG, filterList.toString());
            return results;
        }

        @Override
        protected void publishResults(CharSequence charSequence, FilterResults filterResults) {
            setNewDataMK((List<DriverInfoBean>) filterResults.values);
        }
    };

    private void onBindViewHolder(AssetDriverAdapter.DriverViewHolder holder, DriverInfoBean bean) {
        if (bean == null) {
            holder.rlAddDriver.setVisibility(View.VISIBLE);
            holder.rlItemDriver.setVisibility(View.GONE);
            holder.rlAddDriver.setOnClickListener(v -> {
                Logger.t(TAG).d("onClick add Item");
                if (mListener != null) {
                    mListener.onAddDriver();
                }
            });
            return;
        } else {
            holder.rlItemDriver.setVisibility(View.VISIBLE);
            holder.rlAddDriver.setVisibility(View.GONE);
        }
        holder.tvDriverName.setText(bean.getName());
        holder.tvPhoneNo.setText(bean.getPhoneNo());
        holder.tvLicenseType.setText(bean.getLicenseType());

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickDriverItem(bean, v);
            }
        });
    }

    public class DriverViewHolder extends BaseViewHolder {
        @BindView(R.id.tv_driver_name)
        TextView tvDriverName;

        @BindView(R.id.tv_phone_number)
        TextView tvPhoneNo;

        @BindView(R.id.tv_license_type)
        TextView tvLicenseType;

        @BindView(R.id.rlItemDriver)
        RelativeLayout rlItemDriver;

        @BindView(R.id.rlAdd)
        RelativeLayout rlAddDriver;

        public DriverViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
