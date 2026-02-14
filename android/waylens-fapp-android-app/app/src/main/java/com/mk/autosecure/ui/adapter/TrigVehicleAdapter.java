package com.mk.autosecure.ui.adapter;

import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.FenceVehicleBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.ui.fragment.FenceVehicleFragment;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by cloud on 2020/5/13.
 */
public class TrigVehicleAdapter extends BaseQuickAdapter<FenceVehicleBean, TrigVehicleAdapter.FenceViewHolder> {

    private FenceVehicleFragment.VehicleOperationListener mListener;
    private List<FenceVehicleBean> mList = new ArrayList<>();

    public TrigVehicleAdapter(int layoutResId) {
        super(layoutResId);
    }

    public void setOperationListener(FenceVehicleFragment.VehicleOperationListener listener) {
        this.mListener = listener;
    }

    public void setDataList(List<FenceVehicleBean> list) {
        this.mList = list;
        setNewData(list);
    }

    public List<FenceVehicleBean> getDataList() {
        return mList;
    }

    @Override
    protected void convert(FenceViewHolder helper, FenceVehicleBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(FenceViewHolder helper, FenceVehicleBean item) {
//        helper.cbSelected.setChecked(item.selected);
//        helper.cbSelected.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
//            @Override
//            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
//                int index = mList.indexOf(item);
//                FenceVehicleBean vehicleBean = mList.get(index);
//                vehicleBean.selected = isChecked;
////                notifyDataSetChanged();
//            }
//        });

        VehicleInfoBean vehicleInfoBean = item.vehicleInfoBean;
        if (vehicleInfoBean != null) {
            helper.tvPlateNumber.setText(vehicleInfoBean.getPlateNo());
            helper.tvDriver.setText(vehicleInfoBean.getDriverName());
        }

        helper.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(item);
            }
        });
    }

    public static class FenceViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_plate_number)
        TextView tvPlateNumber;

        @BindView(R.id.tv_driver)
        TextView tvDriver;

        public FenceViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
