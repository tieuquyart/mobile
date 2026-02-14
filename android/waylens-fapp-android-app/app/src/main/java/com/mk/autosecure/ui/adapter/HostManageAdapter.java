package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.HornApplication;
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

public class HostManageAdapter extends RecyclerView.Adapter<HostManageAdapter.DirectViewHolder> {

    private final static String TAG = HostManageAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private onHostClickListener mListener;

    private List<String> ssidList = new ArrayList<>();

    private String mCurrentSsid;

    public HostManageAdapter(Context context) {
        mReference = new WeakReference<>(context);

        WifiManager wifiManager = (WifiManager) HornApplication.getContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifiManager != null) {
            //android q getConnectionInfo() need permission ACCESS_FINE_LOCATION
            WifiInfo wifiInfo = wifiManager.getConnectionInfo();
            if (wifiInfo != null && wifiInfo.getSSID() != null) {
                mCurrentSsid = wifiInfo.getSSID().replace("\"", "");
            }
            Logger.t(TAG).d("mCurrentSsid: " + mCurrentSsid);
        }
    }

    public void setListener(onHostClickListener listener) {
        mListener = listener;
    }

    synchronized public void setHostList(List<String> deviceList) {
        if (deviceList == null) {
            return;
        }
        Logger.t(TAG).e("setHostList: " + deviceList.toString());
        sortPropList(deviceList);
        notifyDataSetChanged();
    }

    private void sortPropList(List<String> deviceList) {
        ssidList.clear();
        ssidList.addAll(deviceList);
    }

    @NonNull
    @Override
    public DirectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_host, parent, false);
        return new DirectViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DirectViewHolder directViewHolder, int pos) {
        onBindWifiDevice(directViewHolder, pos);
    }

    private void onBindWifiDevice(DirectViewHolder holder, int pos) {
        String string = ssidList.get(pos);
        holder.tvSsid.setText(string);

        holder.tvConnected.setVisibility(string.equals(mCurrentSsid) ? View.VISIBLE : View.GONE);
        holder.ibConnect.setVisibility(string.equals(mCurrentSsid) ? View.GONE : View.VISIBLE);
        holder.ibRemove.setVisibility(string.equals(mCurrentSsid) ? View.GONE : View.VISIBLE);

        holder.ibConnect.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onConnectHost(string);
            }
        });

        holder.ibRemove.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onRemoveHost(string);
            }
        });
    }

    @Override
    public int getItemCount() {
        return ssidList.size();
    }

    static public class DirectViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_ssid)
        TextView tvSsid;

        @BindView(R.id.tv_connected)
        TextView tvConnected;

        @BindView(R.id.ib_connect)
        ImageButton ibConnect;

        @BindView(R.id.ib_remove)
        ImageButton ibRemove;

        DirectViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }

    public interface onHostClickListener {
        void onRemoveHost(String ssid);

        void onConnectHost(String ssid);
    }
}
