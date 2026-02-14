package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.ui.fragment.interfaces.DevicesOperationListener;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint("NewApi")
public class AssetDevicesAdapter extends BaseQuickAdapter<FleetCameraBean, AssetDevicesAdapter.DeviceViewHolder> implements Filterable {

    private final static String TAG = AssetDevicesAdapter.class.getSimpleName();
    private final int VIEW_TYPE_ITEM = 0;
    private final int VIEW_TYPE_LOADING = 1;


    private WeakReference<Context> mReference;
    List<FleetCameraBean> cameraBeans = new ArrayList<>();

    private DevicesOperationListener mListener;

    public AssetDevicesAdapter(Context context) {
        super(R.layout.item_asset_devices);
        mReference = new WeakReference<>(context);
    }


    public void setOperationListener(DevicesOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(DeviceViewHolder helper, FleetCameraBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(DeviceViewHolder holder, FleetCameraBean bean) {
        if (bean == null) {
            holder.rlItemDevice.setVisibility(View.GONE);
            holder.rlAddDevice.setVisibility(View.VISIBLE);

            holder.rlAddDevice.setOnClickListener(v -> {
                Logger.t(TAG).d("onClick add Item");
                if (mListener != null) {
                    mListener.onAddDevice();
                }
            });
            return;
        } else {
            holder.rlItemDevice.setVisibility(View.VISIBLE);
            holder.rlAddDevice.setVisibility(View.GONE);
        }
        holder.tvCameraSn.setText(!StringUtils.isEmpty(bean.getSn()) ? bean.getSn() : "");

        int status = bean.getStatus();
        holder.tvCameraStatus.setText(getStatusStringWithCode(status));
        if (status == 0) {
            holder.tvCameraStatus.setTextColor(mReference.get().getColor(R.color.holo_red_light));
        }else if(status == 1){
            holder.tvCameraStatus.setTextColor(mReference.get().getColor(R.color.orange));
        } else  {
            holder.tvCameraStatus.setTextColor(mReference.get().getColor(R.color.green));
        }

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickDeviceItem(bean,v);
            }
        });
    }


    public void setDataMK(@Nullable List<FleetCameraBean> dataMK) {
        cameraBeans = dataMK;
        assert cameraBeans != null;
        cameraBeans.add(0, null);
        Log.d(TAG, "dataInit: " + cameraBeans.toString());
        setNewData(dataMK);
    }

    public void setNewDataMK(@Nullable List<FleetCameraBean> dataMK) {

        if (dataMK != null && dataMK.size() != 0) {

            Log.d(TAG, "dataNew: " + dataMK.toString());
            setNewData(dataMK);
        } else {
            Log.d(TAG, "dataOld: " + cameraBeans.toString());
            setNewData(null/*cameraBeans*/);
        }
    }


    @Override
    public Filter getFilter() {
        return filterEx;
    }

    private Filter filterEx = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence charSequence) {
            List<FleetCameraBean> filterList = new ArrayList<>();
            if (charSequence == null || charSequence.length() == 0) {
                filterList = cameraBeans;
            } else {
                String filterPattern = charSequence.toString().toLowerCase().trim();
                for (FleetCameraBean bean : cameraBeans) {
                    Log.d(TAG, "filterString:= " + filterPattern);
                    if (bean != null && (bean.getSn().toLowerCase().trim().contains(filterPattern) /*|| bean.getPhone().toLowerCase().contains(filterPattern)*/)) {
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
            setNewDataMK((List<FleetCameraBean>) filterResults.values);
        }
    };

    private String getStatusStringWithCode(int statusCode) {
        if (statusCode == 0)
            return "Đã thêm";
        else if (statusCode == 1)
            return "Đã đăng ký";
        else if (statusCode == 2)
            return "Đã kích hoạt";
        else return "Đã Đăng ký";
    }

    public class DeviceViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_camera_sn)
        TextView tvCameraSn;

        @BindView(R.id.tv_camera_status)
        TextView tvCameraStatus;

        @BindView(R.id.rlItemDevice)
        RelativeLayout rlItemDevice;

        @BindView(R.id.rlAdd)
        RelativeLayout rlAddDevice;

        public DeviceViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }

    private class LoadingViewHolder extends BaseViewHolder {

        ProgressBar progressBar;

        public LoadingViewHolder(@NonNull View itemView) {
            super(itemView);
            progressBar = itemView.findViewById(R.id.progressBar);
        }
    }
}
