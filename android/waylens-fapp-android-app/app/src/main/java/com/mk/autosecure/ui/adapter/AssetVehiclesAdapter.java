package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.ui.fragment.interfaces.VehiclesOperationListener;
import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint({"CheckResult", "NewApi"})
public class AssetVehiclesAdapter extends BaseQuickAdapter<VehicleInfoBean, AssetVehiclesAdapter.VehicleViewHolder> implements Filterable {

    private final static String TAG = AssetVehiclesAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;
    List<VehicleInfoBean> vehicleInfoBeanListFull = new ArrayList<>();

    private VehiclesOperationListener mListener;

    public AssetVehiclesAdapter(Context context) {
        super(R.layout.item_asset_vehicles);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(VehiclesOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(VehicleViewHolder helper, VehicleInfoBean item) {
        onBindViewHolder(helper, item);
    }

    @NonNull
    @Override
    public List<VehicleInfoBean> getData() {
        return super.getData();
    }

    @Override
    public int getItemCount() {
        return super.getItemCount();
    }

    @Override
    public void setNewData(@Nullable List<VehicleInfoBean> data) {
        super.setNewData(data);
    }

    public void setDataMK(@Nullable List<VehicleInfoBean> dataMK) {
        assert dataMK != null;
//        VehicleInfoBean bean = vehicleInfoBeanListFull.get(0);
//        if (bean != null) vehicleInfoBeanListFull.add(0,null);
        vehicleInfoBeanListFull = dataMK;
        vehicleInfoBeanListFull.add(0,null);
        Log.d(TAG, "dataInit: " + vehicleInfoBeanListFull.toString());
        setNewData(vehicleInfoBeanListFull);
    }

    public void setNewDataMK(@Nullable List<VehicleInfoBean> dataMK) {

        if (dataMK != null && dataMK.size() != 0) {

            Log.d(TAG, "dataNew: " + dataMK.toString());
            setNewData(dataMK);
        } else {
            Log.d(TAG, "dataOld: " + vehicleInfoBeanListFull.toString());
            setNewData(null/*vehicleInfoBeanListFull*/);
        }
    }

    private void onBindViewHolder(VehicleViewHolder holder, VehicleInfoBean bean) {
        if (bean == null) {
            holder.rlItemVehicle.setVisibility(View.GONE);
            holder.rlAddVehicle.setVisibility(View.VISIBLE);

            holder.rlAddVehicle.setOnClickListener(v -> {
                Logger.t(TAG).d("onClick add Item");
                if (mListener != null){
                    mListener.onAddVehicle();
                }
            });
            return;
        } else {
            holder.rlItemVehicle.setVisibility(View.VISIBLE);
            holder.rlAddVehicle.setVisibility(View.GONE);
        }
        holder.tvPlateNumber.setText(bean.getPlateNo());
        if (!StringUtils.isEmpty(bean.getDriverName())) {
            holder.tvDriverName.setText(bean.getDriverName());
            holder.tvDriverName.setTextColor(mContext.getColor(R.color.colorNaviText));
        } else {
            holder.tvDriverName.setText(mContext.getString(R.string.miss_driver));
            holder.tvDriverName.setTextColor(mContext.getColor(R.color.holo_red_light));
        }

        if (!StringUtils.isEmpty(bean.getCameraSn())) {
            holder.tvCameraSn.setText(bean.getCameraSn());
            holder.tvCameraSn.setTextColor(mContext.getColor(R.color.colorNaviText));
        } else {
            holder.tvCameraSn.setText(mContext.getString(R.string.miss_device));
            holder.tvCameraSn.setTextColor(mContext.getColor(R.color.holo_red_light));
        }

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickVehicleItem(bean, v);
            }
        });
    }

    @Override
    public Filter getFilter() {
        return filterEx;
    }

    private Filter filterEx = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence charSequence) {
            List<VehicleInfoBean> filterList = new ArrayList<>();
            if (charSequence == null || charSequence.length() == 0) {
                filterList = vehicleInfoBeanListFull;
            } else {
                String filterPattern = charSequence.toString().toLowerCase().trim();
                for (VehicleInfoBean bean : vehicleInfoBeanListFull) {
                    Log.d(TAG, "filterString:= " + filterPattern);
                    if (bean != null && (bean.getPlateNo().toLowerCase().trim().contains(filterPattern) /*|| bean.getVehicleNo().toLowerCase().contains(filterPattern)*/)) {
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
            setNewDataMK((List<VehicleInfoBean>) filterResults.values);
        }
    };

    public class VehicleViewHolder extends BaseViewHolder {


        @BindView(R.id.tv_plate_number)
        TextView tvPlateNumber;

        @BindView(R.id.tv_camera_sn)
        TextView tvCameraSn;

        @BindView(R.id.tv_driver_name)
        TextView tvDriverName;

        @BindView(R.id.ll_menu)
        LinearLayout llMenu;

        @BindView(R.id.rlAdd)
        RelativeLayout rlAddVehicle;

        @BindView(R.id.rlItemVehicle)
        RelativeLayout rlItemVehicle;

        public VehicleViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
