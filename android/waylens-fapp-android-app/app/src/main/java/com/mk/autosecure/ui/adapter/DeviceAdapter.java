package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/11.
 */

public class DeviceAdapter extends RecyclerView.Adapter<DeviceAdapter.DeviceViewHolder> {

    private final static String TAG = DeviceAdapter.class.getSimpleName();

    WeakReference<Context> mReference;
    private List<CameraBean> cameraList = new ArrayList<>();
    private List<CameraWrapper> localCameraList = new ArrayList<>();
    private List<FleetCameraBean> fleetCameraList = new ArrayList<>();

    onDeviceClickListener mListener;

    private static final int TYPE_BOND_CAMERA = 0x00;
    private static final int TYPE_LOCAL_CAMERA = 0x01;
    private static final int TYPE_FLEET_CAMERA = 0x02;

    public DeviceAdapter(Context context) {
        mReference = new WeakReference<>(context);
    }

    public void setListener(onDeviceClickListener listener) {
        mListener = listener;
    }

    synchronized public void setCameraList(List<CameraBean> cameraList) {
        Logger.t(TAG).e("setCameraList: " + cameraList.toString());
        this.cameraList.clear();
        this.cameraList.addAll(cameraList);
        notifyDataSetChanged();
    }

    synchronized public void setLocalCameraList(List<CameraWrapper> localCameraList) {
        Logger.t(TAG).e("setLocalCameraList: " + localCameraList.toString());
        this.localCameraList.clear();
        this.localCameraList.addAll(localCameraList);
        notifyDataSetChanged();
    }

    synchronized public void setFleetCameraList(List<FleetCameraBean> fleetCameraList) {
        Logger.t(TAG).e("setFleetCameraList: " + fleetCameraList.toString());
        this.fleetCameraList.clear();
        this.fleetCameraList.addAll(fleetCameraList);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DeviceViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_device, parent, false);
        return new DeviceViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DeviceViewHolder holder, int position) {
        switch (getItemViewType(position)) {
            case TYPE_BOND_CAMERA:
                onBindCameraBean(holder, position - localCameraList.size());
                break;
            case TYPE_LOCAL_CAMERA:
                onBindLocalCamera(holder, position);
                break;
            case TYPE_FLEET_CAMERA:
                onBindFleetCamera(holder, position);
                break;
            default:
                break;
        }
        holder.v_divider.setVisibility(position == getItemCount() - 1 ? View.INVISIBLE : View.VISIBLE);
    }

    private void onBindFleetCamera(DeviceViewHolder holder, int position) {
        if (position >= fleetCameraList.size()) {
            return;
        }

        FleetCameraBean camerasBean = fleetCameraList.get(position);

        holder.iv_cameraAvatar.setImageResource(R.drawable.icon_camera_fourg);

        holder.tvCameraName.setText(camerasBean.getSn());

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                CameraWrapper wrapper = VdtCameraManager.getManager().getCamera(camerasBean.getSn());
                if (wrapper == null) {
                    mListener.onFleetDeviceClicked(camerasBean);
                } else {
                    mListener.onConnectedClick(wrapper.getSerialNumber());
                }
            }
        });
    }

    private void onBindLocalCamera(DeviceViewHolder holder, int position) {
        CameraWrapper wrapper = localCameraList.get(position);

        if (wrapper.getMountVersion() != null && wrapper.getMountVersion().support_4g) {
            holder.iv_cameraAvatar.setImageResource(R.drawable.icon_camera_fourg);
        } else {
            holder.iv_cameraAvatar.setImageResource(R.drawable.icon_camera_wifi);
        }

        holder.tvCameraName.setText(wrapper.getName());

        holder.tvCameraStatus.setText(R.string.wifi_connected);
        holder.tvCameraStatus.setTextColor(Color.parseColor("#4EAEE3"));
        holder.tvCameraStatus.setTextSize(10f);

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onConnectedClick(wrapper.getSerialNumber());
            }
        });
    }

    private void onBindCameraBean(DeviceViewHolder holder, int position) {
        CameraBean camera = cameraList.get(position);

        if (camera.is4G) {
            holder.iv_cameraAvatar.setImageResource(R.drawable.icon_camera_fourg);
        } else {
            holder.iv_cameraAvatar.setImageResource(R.drawable.icon_camera_wifi);
        }

        holder.tvCameraName.setText(camera.name);

        if (!camera.isOnline) {
            if (camera.is4G) {
                holder.tvCameraStatus.setText(R.string.fourg_offline);
            } else {
                holder.tvCameraStatus.setText(R.string.offline);
            }
            holder.tvCameraStatus.setTextColor(Color.parseColor("#99A0A9"));
            holder.tvCameraStatus.setTextSize(10f);
        }

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                CameraWrapper cameraWrapper = VdtCameraManager.getManager().getCamera(camera.sn);
                if (cameraWrapper == null) {
                    mListener.onDeviceClicked(camera);
                } else {
                    mListener.onConnectedClick(cameraWrapper.getSerialNumber());
                }
            }
        });
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < getItemCount()) {
            if (position < localCameraList.size()) {
                return TYPE_LOCAL_CAMERA;
            } else if (Constants.isFleet()) {
                return TYPE_FLEET_CAMERA;
            } else {
                return TYPE_BOND_CAMERA;
            }
        }
        return -1;
    }

    @Override
    public int getItemCount() {
        if (Constants.isFleet()) {
            return fleetCameraList.size() + localCameraList.size();
        } else {
            return cameraList.size() + localCameraList.size();
        }
    }

    static class DeviceViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_cameraName)
        TextView tvCameraName;

        @BindView(R.id.tv_cameraStatus)
        TextView tvCameraStatus;

        @BindView(R.id.iv_cameraAvatar)
        ImageView iv_cameraAvatar;

        @BindView(R.id.v_divider)
        View v_divider;

        DeviceViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

    }

    public interface onDeviceClickListener {
        void onConnectedClick(String serialNum);

        void onDeviceClicked(CameraBean cameraBean);

        void onFleetDeviceClicked(FleetCameraBean camerasBean);
    }
}
