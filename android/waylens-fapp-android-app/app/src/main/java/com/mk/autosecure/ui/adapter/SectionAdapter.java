package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.NotificationBeanClusterHelper;
import com.mk.autosecure.libs.utils.TimelineBeanClusterHelper;
import com.mk.autosecure.libs.utils.TripBeanClusterHelper;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.rest_fleet.bean.TimelineBean;
import com.mk.autosecure.rest_fleet.bean.TripBean;

import java.lang.ref.WeakReference;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/31.
 */
@SuppressLint("NotifyDataSetChanged")
public class SectionAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = SectionAdapter.class.getSimpleName();

    private static final int TYPE_SECTION_DATE = 0x00;
    private static final int TYPE_FOOTER = 0x01;

    private WeakReference<Context> mWeakRef;

    private String driverName;

    private String plateNumber;

    private String vehicleBrand;

    private String vehicleType;

    private List<SectionAdapter.ViewItem> viewItemList = new ArrayList<>();

    private List<List<TimelineBean>> mTimelineClusterList;

    private List<List<TripBean>> mTripClusterList;

    private List<List<NotificationBean>> mNotificationClusterList;

    public SectionAdapter(Context context) {
        this.mWeakRef = new WeakReference<>(context);
    }

    public void setVehicleInfo(String driverName, String plateNumber, String vehicleBrand, String vehicleType) {
        Logger.t(TAG).d("setVehicleInfo: " + driverName + " " + plateNumber);
        this.driverName = driverName;
        this.plateNumber = plateNumber;
        this.vehicleBrand = vehicleBrand;
        this.vehicleType = vehicleType;
    }

    public void setTimelineList(List<TimelineBean> timelineList) {
        mTimelineClusterList = new TimelineBeanClusterHelper(timelineList).getClusterList();
        recalculateTimelineList(mTimelineClusterList);
        notifyDataSetChanged();
    }

    public void setTripList(List<TripBean> tripBeanList) {
        mTripClusterList = new TripBeanClusterHelper(tripBeanList).getClusterList();
        recalculateTripList(mTripClusterList);
        notifyDataSetChanged();
    }

    public void setNotificationList(List<NotificationBean> notificationList) {
        mNotificationClusterList = new NotificationBeanClusterHelper(notificationList).getClusterList();
        recalculateNotificationList(mNotificationClusterList);
        notifyDataSetChanged();
    }

    private void recalculateTimelineList(List<List<TimelineBean>> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

        Collections.sort(beanList, (o1, o2) -> ((o1.get(0).getTimelineTime() - o2.get(0).getTimelineTime()) > 0) ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            List<TimelineBean> timelineBeans = beanList.get(i);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_SECTION_DATE;
            headItem.itemObject = timelineBeans.get(0).getTimelineTime();
            headItem.extra = 1;
            viewItemList.add(headItem);
        }

        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
    }

    private void recalculateTripList(List<List<TripBean>> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();
        Collections.sort(beanList, (o1, o2) -> {
            for (int i = 0; i < o1.size(); i++) {
                if (o1.get(i).getDrivingTime() == null || o2.get(i).getDrivingTime() == null)
                    return 0;
                return o1.get(i).getDrivingTime().compareTo(o2.get(i).getDrivingTime());
            }
            return 0;
        });

        for (int i = 0; i < beanList.size(); i++) {
            List<TripBean> tripBeans = beanList.get(i);
//            Collections.sort(tripBeans, (o1, o2) -> compare(o2.getCreateTime(), o1.getCreateTime()));
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_SECTION_DATE;
            headItem.itemObject = tripBeans.get(0);
            headItem.extra = 1;
            viewItemList.add(headItem);
        }
        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
    }

    private void recalculateNotificationList(List<List<NotificationBean>> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

//        Collections.sort(beanList, (o1, o2) -> ((o2.get(0).getNotificationTime() - o1.get(0).getNotificationTime()) > 0) ? 1 : -1);

        for (int i = 0; i < beanList.size(); i++) {
            List<NotificationBean> timelineBeans = beanList.get(i);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_SECTION_DATE;
//            headItem.itemObject = timelineBeans.get(0).getNotificationTime();
            headItem.extra = 0;
            viewItemList.add(headItem);
        }

        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
    }

    public int compare(String lhs, String rhs) {
        String first = lhs.replace("T", " ");
        String se = rhs.replace("T", " ");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        try {
            return dateFormat.parse(first).compareTo(dateFormat.parse(se));
        } catch (ParseException e) {
            e.printStackTrace();
            return 0;
        }
    }

    public List<SectionAdapter.ViewItem> getViewItemList() {
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
        if (viewType == TYPE_FOOTER) {
            return new FooterViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_no_more_events, parent, false));
        }
        return new SectionViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_section, parent, false));
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
        switch (getItemViewType(position)) {
            case TYPE_SECTION_DATE:
                onBindDateViewHolder((SectionViewHolder) holder, position);
                break;
            case TYPE_FOOTER:
                onBindFooterViewHolder((FooterViewHolder) holder, position);
                break;
            default:
                break;
        }
    }

    @Override
    public int getItemCount() {
//        Logger.t(TAG).e("getItemCount: " + viewItemList.size());
        return viewItemList.size();
    }

    private void onBindFooterViewHolder(FooterViewHolder holder, int position) {
        Logger.t(TAG).d("onBindFooterViewHolder: " + position);
    }

    @SuppressLint({"CheckResult", "SetTextI18n"})
    private void onBindDateViewHolder(SectionViewHolder holder, int position) {
        Logger.t(TAG).d("onBindDateViewHolder: " + position);
        ViewItem viewItem = viewItemList.get(position);
        TripBean tripBean = (TripBean) viewItem.itemObject;

        double mins = tripBean.getHours() * 60;
        double distance = tripBean.getDistance();
        double km = distance / 1000;
        String time = (Math.floor(mins * 100) / 100) + " Mins, " + km + " Km";
        holder.tvSectionDate.setText(time);
        holder.tvTripName.setText("Trip #" + tripBean.getId());

        holder.rvTimeline.setLayoutManager(new LinearLayoutManager(mWeakRef.get()));
        TimelineAdapter adapter = new TimelineAdapter(mWeakRef.get());
        holder.rvTimeline.setAdapter(adapter);
        holder.rvTimeline.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, 0);
            }
        });

        adapter.setTimelineOperationListener((id, bean) -> {

        });

        if (viewItem.extra == 0) {
            List<NotificationBean> beanList = mNotificationClusterList.get(position);
            adapter.setNotificationBeanList(beanList);
        } else {
            List<TripBean> beanList = mTripClusterList.get(position);
            adapter.setTripBeanList(beanList);
            adapter.setDataVehicle(this.vehicleBrand, this.vehicleType);
        }
    }


    static class FooterViewHolder extends RecyclerView.ViewHolder {

        FooterViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    @SuppressLint("NonConstantResourceId")
    static class SectionViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_section_date)
        TextView tvSectionDate;

        @BindView(R.id.tvTripName)
        TextView tvTripName;

        @BindView(R.id.rv_timeline)
        RecyclerView rvTimeline;

        @BindView(R.id.exp_Event)
        ExpandableListView expEvent;

        SectionViewHolder(View itemView) {
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


