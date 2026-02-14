package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.TripBeanClusterHelper;
import com.mk.autosecure.rest_fleet.bean.TripBean;
import com.mk.autosecure.ui.fragment.OverviewFragment;
import com.orhanobut.logger.Logger;

import java.lang.ref.WeakReference;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint({"SetTextI18n","NonConstantResourceId","CheckResult","NotifyDataSetChanged"})
public class TripAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = TripAdapter.class.getSimpleName();

    private static final int TYPE_SECTION_DATE = 0x00;
    private static final int TYPE_FOOTER = 0x01;

    private WeakReference<Context> mWeakRef;

    List<LinearLayout> cardViewList = new ArrayList<>();

    private List<TripAdapter.ViewItem> viewItemList = new ArrayList<>();

    private List<List<TripBean>> mTripClusterList;

    private OverviewFragment.TripBeanOperationListener mListener;

    public TripAdapter(Context context) {
        this.mWeakRef = new WeakReference<>(context);
    }

    public void setTripBeanOperationListener(OverviewFragment.TripBeanOperationListener listener) {
        this.mListener = listener;
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setTripList(List<TripBean> tripBeanList) {
        mTripClusterList = new TripBeanClusterHelper(tripBeanList).getClusterList();
        recalculateTripList(mTripClusterList);
        notifyDataSetChanged();
    }


    private void recalculateTripList(List<List<TripBean>> beanList) {
        if (beanList == null) {
            return;
        }

        viewItemList.clear();

        Collections.sort(beanList, (o1, o2) -> {
            for (int i = 0; i < beanList.size(); i++) {
                if (o1.get(i).getDrivingTime() == null || o2.get(i).getDrivingTime() == null)
                    return 0;
                return getTimeFromString(o1.get(i).getDrivingTime()).compareTo(getTimeFromString(o2.get(i).getDrivingTime()));
            }
            return 0;
        });

        for (int i = 0; i < beanList.size(); i++) {
            List<TripBean> tripBeans = beanList.get(i);
//            Collections.sort(tripBeans, (o1, o2) -> compare(o2.getCreateTime(), o1.getCreateTime()));
            for (TripBean bean : tripBeans) {
                ViewItem viewItem = new ViewItem();
                viewItem.itemObject = bean;
                viewItemList.add(viewItem);
            }
        }
    }

    public List<TripAdapter.ViewItem> getViewItemList() {
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
        return new TripViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_tripbean, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        TripAdapter.ViewItem viewItem = viewItemList.get(position);
        TripBean bean = (TripBean) viewItem.itemObject;

        if (bean == null) {
            ((TripViewHolder) holder).tvNoTrips.setVisibility(View.VISIBLE);
            ((TripViewHolder) holder).tvTotalTime.setVisibility(View.GONE);
            ((TripViewHolder) holder).tvTripName.setVisibility(View.GONE);
            ((TripViewHolder) holder).tvTimeStart.setVisibility(View.GONE);
            ((TripViewHolder) holder).tvTimeEnd.setVisibility(View.GONE);

            return;
        }
        double mins = (Math.floor((bean.getHours() * 60) * 100) / 100);
        String totalTime = mins + " phút";
        String drivingTime = "";
        String parkingTime = "";
        drivingTime = bean.getDrivingTime();
        parkingTime = bean.getParkingTime();

        if (holder instanceof TripViewHolder) {
            ((TripViewHolder) holder).tvTotalTime.setText(totalTime);
            ((TripViewHolder) holder).tvTripName.setText("Trip #" + bean.getId());
            ((TripViewHolder) holder).tvTimeStart.setText(mWeakRef.get().getString(R.string.timeFrom) + getTimeFromString(drivingTime));
            ((TripViewHolder) holder).tvTimeEnd.setText(mWeakRef.get().getString(R.string.timeTo) + getTimeFromString(parkingTime));
            ((TripViewHolder) holder).tvNoTrips.setVisibility(View.GONE);
            ((TripViewHolder) holder).tvTripName.setVisibility(View.VISIBLE);
            ((TripViewHolder) holder).tvTotalTime.setVisibility(View.GONE);
            ((TripViewHolder) holder).tvTimeStart.setVisibility(View.VISIBLE);
            ((TripViewHolder) holder).tvTimeEnd.setVisibility(View.VISIBLE);

            cardViewList.add(((TripViewHolder) holder).cardView);

            holder.itemView.setOnClickListener(view -> {
                if (mListener != null) {
                    Logger.t(TAG).e("onClickItem: " + viewItem.itemObject);
                    mListener.onClickItem(bean);
                    for (LinearLayout cardView : cardViewList) {
                        cardView.setBackgroundResource(R.drawable.bg_item_trip);
                    }
                    ((TripViewHolder) holder).cardView.setBackgroundResource(R.drawable.item_trip_selected);
                }
            });
            cardViewList.get(0).setBackgroundResource(R.drawable.item_trip_selected);
        }
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

    private String getTimeFromString(String time) {
        if (time == null || time.equals("")) return "Now";
        String temp = "";
        String[] tempArr = time.split("T");
        if (tempArr.length > 1) {
            temp = tempArr[1];
        }
        return temp.substring(0, 5);
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < getItemCount()) {
            return viewItemList.get(position).itemType;
        }
        return -1;
    }

    @Override
    public int getItemCount() {
        return viewItemList.size();
    }


    static class TripViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tvTotalTime)
        TextView tvTotalTime;

        @BindView(R.id.tvTripName)
        TextView tvTripName;

        @BindView(R.id.tv_timeStart)
        TextView tvTimeStart;

        @BindView(R.id.tvTimeEnd)
        TextView tvTimeEnd;

        @BindView(R.id.tv_noTrips)
        TextView tvNoTrips;

        LinearLayout cardView;

        TripViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            cardView = itemView.findViewById(R.id.item_trip);
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
