package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.utils.StringUtils;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.CameraEventBean;
import com.mk.autosecure.ui.activity.TimelineActivity;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/31.
 */

public class EventsTripAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = EventsTripAdapter.class.getSimpleName();

    private static final int TYPE_STATUS = 0x00;
    private static final int TYPE_EVENT = 0x01;

    private static final int TOP_HEADER = 1;
    private static final int BOTTOM_HEADER = 2;

    private WeakReference<Context> mReference;

    private List<EventsTripAdapter.ViewItem> viewItemList = new ArrayList<>();

    private TimelineActivity.TimelineOperationListener mListener;

    EventsTripAdapter(Context context) {
        this.mReference = new WeakReference<>(context);
    }

    void setTimelineOperationListener(TimelineActivity.TimelineOperationListener listener) {
        this.mListener = listener;
    }

    void setEventsTripBeanList(List<CameraEventBean> beanList) {
        recalculateEventList(beanList);
        notifyDataSetChanged();
    }


    private void recalculateEventList(List<CameraEventBean> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

        for (int i = 0; i < beanList.size(); i++) {
            CameraEventBean bean = beanList.get(i);
            ViewItem viewItem = new ViewItem();
            viewItem.itemType = TYPE_EVENT;
            viewItem.itemObject = bean;
            if (i == 0) {
                viewItem.extra = TOP_HEADER;
            } else if (i == beanList.size() - 1) {
                viewItem.extra = BOTTOM_HEADER;
            }
            viewItemList.add(viewItem);
        }
    }

    public List<EventsTripAdapter.ViewItem> getViewItemList() {
        return viewItemList;
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new EventsTripViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_events_trip, parent, false));
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < getItemCount()) {
            return viewItemList.get(position).itemType;
        }
        return -1;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        onBindEventViewHolder((EventsTripViewHolder) holder, position);
    }

    private void onBindEventViewHolder(EventsTripViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);

        String createTime = "";
        String category = "";
        String eventType = "";
        int id = 0;
        CameraEventBean bean = null;

        if (viewItem.itemObject instanceof CameraEventBean) {
            bean = (CameraEventBean) viewItem.itemObject;
            Log.d(TAG,""+ bean.getDriverName());

            createTime = bean.getCreateTime();
            eventType = bean.getEventType();
            category = bean.getEventCategory();
            id = bean.getId();
        }

        //parking-driving time

        holder.tvTime.setText(StringUtils.getTimeFromString(createTime,"Không có dữ liệu thời gian"));

        holder.tvCategory.setText(VideoEventType.dealCategory(mReference.get(), category));

        holder.tvEventType.setText(VideoEventType.dealEventType(mReference.get(), eventType));

        int finalId = id;
        CameraEventBean finalBean = bean;

        holder.imgPlay.setOnClickListener(v -> {
            if (mListener != null) {
                Logger.t(TAG).e("onClickItem: " + viewItem.itemObject);
                mListener.onClickItem(finalId, finalBean);
            }
        });

        holder.itemView.requestLayout();
    }

    @Override
    public int getItemCount() {
        return viewItemList.size();
    }

    static class EventsTripViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tvCategory)
        TextView tvCategory;

        @BindView(R.id.tvEventType)
        TextView tvEventType;

        @BindView(R.id.tvTime)
        TextView tvTime;

        @BindView(R.id.imgPlay)
        ImageView imgPlay;

        EventsTripViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public static class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;

        @NonNull
        @Override
        public String toString() {
            return "ViewItem{" +
                    "itemType=" + itemType +
                    ", itemObject=" + itemObject +
                    ", extra=" + extra +
                    '}';
        }
    }

}


