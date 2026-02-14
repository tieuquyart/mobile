package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.model.Clip;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ClipClusterGroupHelper;
import com.mk.autosecure.libs.utils.ClipClusterHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipCluster;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

public class LocalDateAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = LocalDateAdapter.class.getSimpleName();

    public static final int TYPE_DATE = 0x00;
    private static final int TYPE_DAY = 0x01;
    private static final int TYPE_AGO = 0x02;

    private Context mContext;

    private int mRecyclerViewHeight;

    private ClipCluster mPlayClipCluster;

    private List<List<ClipCluster>> mClipClusterGroupList;

    private List<ViewItem> viewItemList = new ArrayList<>();

    private int MAX_SHOW_ITEM = 15;

    public LocalDateAdapter(Context context, int recyclerViewHeight) {
        this.mContext = context;
        this.mRecyclerViewHeight = recyclerViewHeight;
    }

    public void setMaxShowItem(int max) {
        this.MAX_SHOW_ITEM = max;
    }

    public void setPlayDate(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            Logger.t(TAG).d("position: " + position);
            this.mPlayClipCluster = (ClipCluster) viewItemList.get(position).itemObject;
            for (int i = 0; i < viewItemList.size(); i++) {
                ViewItem viewItem = viewItemList.get(i);
                viewItem.itemPlay = i == position;
            }
            notifyDataSetChanged();
        }
    }

    public void setPlayTime(long time) {
        String mPlayDate = getFormattedDate(time, Calendar.DAY_OF_YEAR);
//        Logger.t(TAG).d("mPlayDate: " + mPlayDate);
        if (TextUtils.isEmpty(mPlayDate)) {
            return;
        }

        for (int i = 0; i < viewItemList.size(); i++) {
            ViewItem viewItem = viewItemList.get(i);
            ClipCluster clipCluster = (ClipCluster) viewItem.itemObject;

            if (clipCluster != null) {
                String formattedDate = getFormattedDate(
                        clipCluster.getStartTime() + clipCluster.getClipList().get(0).getOffset(),
                        Calendar.DAY_OF_YEAR);
//                Logger.t(TAG).d("formattedDate: " + formattedDate);
                if (mPlayDate.equals(formattedDate) && !clipCluster.equals(mPlayClipCluster)) {
//                    Logger.t(TAG).d("day: " + getFormattedDate(
//                            clipCluster.getStartTime() + clipCluster.getClipList().get(0).getOffset(),
//                            Calendar.DAY_OF_MONTH)
//                            + " " + getFormattedDate(time, Calendar.DAY_OF_MONTH));
                    setPlayDate(i);
                }
            }
        }
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

    public void clearData() {
        viewItemList.clear();
        addItem(TYPE_DATE, null);
        mPlayClipCluster = null;
        notifyDataSetChanged();
    }

    public void setClipList(List<Clip> clipList) {
        for (int i = 0; i < clipList.size(); i++) {
            Clip clip = clipList.get(i);
            if (clip.getDurationMs() <= 0) {
                clipList.remove(clip);
                i--;
            }
        }
        List<ClipCluster> clipClusterList = new ClipClusterHelper(clipList).getClipClusterList();
        this.mClipClusterGroupList = new ClipClusterGroupHelper(clipClusterList).getClipClusterGroup();
        Logger.t(TAG).d("mClipClusterGroupList size: " + this.mClipClusterGroupList.size());
        recalculateViewItemList();
        notifyDataSetChanged();
    }

    private void recalculateViewItemList() {
        if (mClipClusterGroupList == null) {
            return;
        }

        viewItemList.clear();
        addItem(TYPE_DATE, null);

        int dateSize = mClipClusterGroupList.size();
        //仅显示15天日期
        boolean showAgo = dateSize > MAX_SHOW_ITEM;

        for (int i = 0; i < dateSize; i++) {
            List<ClipCluster> clipClusters = mClipClusterGroupList.get(i);
            ClipCluster clipCluster = clipClusters.get(clipClusters.size() - 1);

            //初始化显示
            if (mPlayClipCluster == null && i == 0) {
                mPlayClipCluster = clipCluster;
            }

            if (showAgo) {
                int size = viewItemList.size();
                if (size != MAX_SHOW_ITEM) {
                    addItem(TYPE_DAY, clipCluster);
                } else {
                    addItem(TYPE_AGO, clipCluster);
                    break;
                }
            } else {
                addItem(TYPE_DAY, clipCluster);
            }
        }
    }

    private void addItem(int itemType, Object itemObject) {
        ViewItem viewItem = new ViewItem();
        viewItem.itemType = itemType;
        viewItem.itemObject = itemObject;
        if (mPlayClipCluster != null && itemObject != null) {
            viewItem.itemPlay = mPlayClipCluster.getStartTime() == ((ClipCluster) itemObject).getStartTime();
        }
        viewItemList.add(viewItem);
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int viewType) {
        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_local_date, viewGroup, false);
        float measuredHeight = ViewUtils.dp2px(mContext.getResources().getDimensionPixelSize(R.dimen.dp_20) / ViewUtils.getDensity());
//        Logger.t(TAG).d("measuredHeight: " + measuredHeight + " mRecyclerViewHeight: " + mRecyclerViewHeight + " getItemCount: " + getItemCount());
        if (measuredHeight * getItemCount() > mRecyclerViewHeight) {
            view.getLayoutParams().height = mRecyclerViewHeight / (getItemCount() + 1);
//            Logger.t(TAG).d("height: " + (mRecyclerViewHeight / (getItemCount() + 1)));
        }
        return new DateViewHolder(view);
    }

    @Override
    public int getItemCount() {
        return Math.min(viewItemList.size(), MAX_SHOW_ITEM + 1);
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < getItemCount()) {
            return viewItemList.get(position).itemType;
        }
        return -1;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder viewHolder, int i) {
        switch (getItemViewType(i)) {
            case TYPE_DATE:
                onBindDateViewHolder((DateViewHolder) viewHolder);
                break;
            case TYPE_DAY:
            case TYPE_AGO:
                onBindDateViewHolder((DateViewHolder) viewHolder, i);
                break;
        }
    }

    private void onBindDateViewHolder(DateViewHolder viewHolder) {
        viewHolder.tvClipDate.setTextColor(mContext.getResources().getColor(R.color.colorPrimary));
        viewHolder.tvClipDate.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
        viewHolder.tvClipDate.setTextSize(10f);
        viewHolder.tvClipDate.setText(R.string.date);
    }

    private void onBindDateViewHolder(DateViewHolder holder, int i) {
        ViewItem viewItem = viewItemList.get(i);

        if (viewItem.itemPlay) {
            holder.tvClipDate.setTextColor(mContext.getResources().getColor(R.color.colorAccent));
            holder.tvClipDate.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            holder.ivCurrent.setVisibility(View.VISIBLE);
            holder.tvClipDate.setTextSize(12f);
        } else {
            holder.tvClipDate.setTextColor(mContext.getResources().getColor(R.color.colorPrimary));
            holder.tvClipDate.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            holder.ivCurrent.setVisibility(View.INVISIBLE);
            holder.tvClipDate.setTextSize(10f);
        }

        if (i == MAX_SHOW_ITEM) {
            holder.tvClipDate.setText(R.string.ago);
        } else {
            ClipCluster clipCluster = (ClipCluster) viewItem.itemObject;
            String formattedDate = getFormattedDate(
                    clipCluster.getStartTime() + clipCluster.getClipList().get(0).getOffset(),
                    Calendar.DAY_OF_MONTH);
//            Logger.t(TAG).e("formattedDate: " + formattedDate);
            holder.tvClipDate.setText(formattedDate);
        }
    }

    private String getFormattedDate(long date, int type) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeZone(TimeZone.getTimeZone("UTC"));
        calendar.setTimeInMillis(date);
        int clipDateDay = calendar.get(type);
        return String.valueOf(clipDateDay);
    }

    static class DateViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_clip_date)
        TextView tvClipDate;

        @BindView(R.id.iv_current)
        ImageView ivCurrent;

        private DateViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static class ViewItem {
        int itemType;
        Object itemObject;
        boolean itemPlay;
    }
}
