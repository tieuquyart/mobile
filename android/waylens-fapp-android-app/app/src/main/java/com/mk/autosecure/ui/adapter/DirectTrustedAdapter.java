package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.direct.PairedDevices;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.MacAddressUtil;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/11.
 */

public class DirectTrustedAdapter extends RecyclerView.Adapter<DirectTrustedAdapter.DirectViewHolder> {

    private final static String TAG = DirectTrustedAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private onDirectClickListener mListener;

    private List<PairedDevices.DevicesBean> wifiDeviceList = new ArrayList<>();

    private final static List<String> myMacAddress = MacAddressUtil.getMacAddress();

    public DirectTrustedAdapter(Context context) {
        mReference = new WeakReference<>(context);
    }

    public void setListener(onDirectClickListener listener) {
        mListener = listener;
    }

    synchronized public void setWifiDeviceListList(List<PairedDevices.DevicesBean> deviceList) {
        if (deviceList == null) {
            return;
        }
        Logger.t(TAG).e("setWifiDeviceListList: " + deviceList.toString());
        sortPropList(deviceList);
        notifyDataSetChanged();
    }

    private void sortPropList(List<PairedDevices.DevicesBean> deviceList) {
        wifiDeviceList.clear();

        for (PairedDevices.DevicesBean bean : deviceList) {
            String mac = bean.getMac();

            for (String address : myMacAddress) {
                String replace = mac.replace(":", "");
                if (address.equals(replace)) {
                    bean.setCurrent(true);
                    break;
                } else {
                    bean.setCurrent(false);
                }
            }
        }
        wifiDeviceList.addAll(deviceList);

        Collections.sort(wifiDeviceList, (o1, o2) -> (o2.isCurrent() ? 1 : 0) - (o1.isCurrent() ? 1 : 0));
    }

    @NonNull
    @Override
    public DirectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_trusted_phone, parent, false);
        return new DirectViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DirectViewHolder directViewHolder, int pos) {
        onBindWifiDevice(directViewHolder, pos);
    }

    private void onBindWifiDevice(DirectViewHolder holder, int pos) {
        PairedDevices.DevicesBean devicesBean = wifiDeviceList.get(pos);
        holder.tv_phone_name.setText(devicesBean.getName());

        String mac = devicesBean.getMac();
        holder.tv_phone_mac.setText(mac);

        boolean current = devicesBean.isCurrent();
        if (current) {
            holder.tv_connected.setVisibility(View.VISIBLE);
            holder.ib_remove.setVisibility(View.GONE);
        } else {
            holder.ib_remove.setVisibility(View.VISIBLE);
            holder.tv_connected.setVisibility(View.GONE);
        }

        holder.ib_remove.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onRemoveTrusted(devicesBean);
            }
        });
    }

    @Override
    public int getItemCount() {
        return wifiDeviceList.size();
    }

    static public class DirectViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_phone_name)
        TextView tv_phone_name;

        @BindView(R.id.tv_phone_mac)
        TextView tv_phone_mac;

        @BindView(R.id.tv_connected)
        TextView tv_connected;

        @BindView(R.id.ib_remove)
        ImageButton ib_remove;

        DirectViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }

    public interface onDirectClickListener {
        void onRemoveTrusted(PairedDevices.DevicesBean bean);
    }
}
