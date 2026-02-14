package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.net.wifi.p2p.WifiP2pDevice;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/11.
 */

public class WifiDirectAdapter extends RecyclerView.Adapter<WifiDirectAdapter.DirectViewHolder> {

    private final static String TAG = WifiDirectAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private onDirectClickListener mListener;

    private List<WifiP2pDevice> wifiDeviceList = new ArrayList<>();

    public WifiDirectAdapter(Context context) {
        mReference = new WeakReference<>(context);
    }

    public void setListener(onDirectClickListener listener) {
        mListener = listener;
    }

    synchronized public void setWifiDeviceListList(List<WifiP2pDevice> deviceList) {
        if (deviceList == null) {
            return;
        }
        Logger.t(TAG).e("setWifiDeviceListList: " + deviceList.size());
        this.wifiDeviceList.clear();
        this.wifiDeviceList.addAll(deviceList);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DirectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_wifi_direct, parent, false);
        return new DirectViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DirectViewHolder directViewHolder, int pos) {
        onBindWifiDevice(directViewHolder, pos);
    }

    private void onBindWifiDevice(DirectViewHolder holder, int pos) {
        WifiP2pDevice wifiP2pDevice = wifiDeviceList.get(pos);
        holder.tv_direct_name.setText(wifiP2pDevice.deviceName);

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onDirectClicked(wifiP2pDevice);
            }
        });
    }

    @Override
    public int getItemCount() {
        return wifiDeviceList.size();
    }

    static public class DirectViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_direct_name)
        TextView tv_direct_name;

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
        void onDirectClicked(WifiP2pDevice wifiP2pDevice);
    }
}
