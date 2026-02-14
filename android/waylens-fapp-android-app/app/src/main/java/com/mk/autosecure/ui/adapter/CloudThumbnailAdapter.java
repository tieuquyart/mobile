package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.ui.view.RoundCornerImageView;
import com.mkgroup.camera.bean.ClipBean;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.utils.ClipBeanClusterGroupHelper;
import com.mk.autosecure.libs.utils.ClipBeanClusterHelper;
import com.mk.autosecure.libs.utils.EventBeanClusterGroupHelper;
import com.mk.autosecure.libs.utils.EventBeanClusterHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipBeanCluster;
import com.mk.autosecure.model.ClipBeanPos;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.model.EventBeanCluster;
import com.mk.autosecure.model.EventBeanPos;
import com.mk.autosecure.rest_fleet.bean.EventBean;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;

/**
 * Created by DoanVT on 2017/12/5.
 * Email: doanvt-hn@mk.com.vn
 */

public class CloudThumbnailAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

//    private final static String TAG = CloudThumbnailAdapter.class.getSimpleName();

    private List<ViewItem> viewItemList = new ArrayList<>();

    private static int dividerMarginTop = ViewUtils.dp2px(48);

//    public static int playerTimeTolerance = 3000;

//    public int thumbnailWidth = ViewUtils.dp2px(100);

//    public int thumbnailHeight = ViewUtils.dp2px(56);

    private int bottomMargin;

    private List<List<ClipBeanCluster>> mClipClusterGroupList = new ArrayList<>();
    //    private ClipBean selectedClip;
    private List<Pair<ClipBeanCluster, Integer>> mClipClusterFirstThumbnailIndex = new ArrayList<>();

    private List<List<EventBeanCluster>> mEventClusterGroupList = new ArrayList<>();
    //    private EventBean selectedEvent;
    private List<Pair<EventBeanCluster, Integer>> mEventClusterFirstThumbnailIndex = new ArrayList<>();

    private static final int TYPE_LIVE = 0x00;
    private static final int TYPE_THUMBNAIL = 0x01;
    private static final int TYPE_LIST_HEADER = 0x02;
    private static final int TYPE_MARGIN = 0x03;
    private static final int TYPE_THUMBNAIL_FLEET = 0x04;

    private static final int MIDDLE_THUMBNAIL = 0;
    private static final int TOP_THUMBNAIL = 1;
    private static final int BOTTOM_THUMBNAIL = 2;
    private static final int SINGLE_THUMBNAIL = 3;

    private static final int NORMAL_HEADER = 0;
    private static final int TOP_HEADER = 1;

    private SoftReference<Context> mContextRef;

    public CloudThumbnailAdapter(Context context) {
        this.mContextRef = new SoftReference<>(context);
        this.bottomMargin = ViewUtils.dp2px(160);
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

//    public void setSelectedClip(ClipBean clip) {
//        this.selectedClip = clip;
//        notifyDataSetChanged();
//    }

    /**
     * top timeline height 48dp,
     * normal bottom margin 24dp
     */
    public void setBottomMargin(int rvHeight) {
        if (rvHeight >= 0) {
            bottomMargin = rvHeight - dividerMarginTop + ViewUtils.dp2px(24);
            notifyItemChanged(getItemCount() - 1);
        }
    }

//    public void clearData() {
//        viewItemList.clear();
//        ViewItem liveItem = new ViewItem();
//        liveItem.itemType = TYPE_LIVE;
//        viewItemList.add(liveItem);
//        selectedClip = null;
//        mClipClusterFirstThumbnailIndex.clear();
//        notifyDataSetChanged();
//    }

    public void setClipList(List<ClipBean> clipList) {
        List<ClipBeanCluster> clipClusterList = new ClipBeanClusterHelper(clipList).getClipBeanClusterList();
        this.mClipClusterGroupList = new ClipBeanClusterGroupHelper(clipClusterList).getClipClusterGroup();
//        com.orhanobut.logger.Logger.t(TAG).e("size : " + mClipClusterList.size() + "--" + mClipClusterGroupList.size());
        recalculateViewItemList();
        notifyDataSetChanged();
    }

    public void setEventsList(List<EventBean> eventsList) {
        List<EventBeanCluster> mEventClusterList = new EventBeanClusterHelper(eventsList).getEventBeanClusterList();
        this.mEventClusterGroupList = new EventBeanClusterGroupHelper(mEventClusterList).getEventClusterGroup();
        recalculateFleetViewItemList();
        notifyDataSetChanged();
    }

    private void recalculateFleetViewItemList() {
        if (mEventClusterGroupList == null) {
            return;
        }

        mEventClusterFirstThumbnailIndex.clear();
        viewItemList.clear();

        ViewItem liveItem = new ViewItem();
        liveItem.itemType = TYPE_LIVE;
        viewItemList.add(liveItem);

        for (int in = 0; in < mEventClusterGroupList.size(); in++) {
            List<EventBeanCluster> clipClusterList = mEventClusterGroupList.get(in);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = clipClusterList.get(0).getStartTime();
            headItem.extra = in == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            for (int index = 0; index < clipClusterList.size(); index++) {
                EventBeanCluster clipCluster = clipClusterList.get(index);
                mEventClusterFirstThumbnailIndex.add(new Pair<>(clipCluster, viewItemList.size()));
                for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
                    ClipSegment clipSegment = clipCluster.getClipSegment().get(i);
                    if (clipSegment.data instanceof EventBean) {
                        EventBean clip = (EventBean) clipSegment.data;
                        long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
//                        com.orhanobut.logger.Logger.t(TAG).e("thumbnailSize: " + thumbnailSize);
                        for (long j = thumbnailSize - 1; j >= 0; j--) {
                            EventBeanPos clipPos = new EventBeanPos(clip, j * 30 * 8 * 1000 / clipSegment.ratio + clipSegment.startTime);
                            ViewItem thumbnailItem = new ViewItem();
                            thumbnailItem.itemType = TYPE_THUMBNAIL_FLEET;
                            thumbnailItem.itemObject = clipPos;
                            if (thumbnailSize == 1) {
                                thumbnailItem.extra = SINGLE_THUMBNAIL;
                            } else if (j == thumbnailSize - 1) {
                                thumbnailItem.extra = TOP_THUMBNAIL;
                            } else if (j == 0) {
                                thumbnailItem.extra = BOTTOM_THUMBNAIL;
                            } else {
                                thumbnailItem.extra = MIDDLE_THUMBNAIL;
                            }
                            viewItemList.add(thumbnailItem);
                        }
                    }
                }
                ViewItem marginItem = new ViewItem();
                marginItem.itemType = TYPE_MARGIN;
                marginItem.itemObject = (index == clipClusterList.size() - 1) ? 0 : ViewUtils.dp2px(24);
                viewItemList.add(marginItem);
            }
        }
    }

    private void recalculateViewItemList() {
        if (mClipClusterGroupList == null) {
            return;
        }
        mClipClusterFirstThumbnailIndex.clear();
        viewItemList.clear();

        ViewItem liveItem = new ViewItem();
        liveItem.itemType = TYPE_LIVE;
        viewItemList.add(liveItem);

        for (int in = 0; in < mClipClusterGroupList.size(); in++) {
            List<ClipBeanCluster> clipClusterList = mClipClusterGroupList.get(in);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = clipClusterList.get(0).getStartTime();
            headItem.extra = in == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            for (int index = 0; index < clipClusterList.size(); index++) {
                ClipBeanCluster clipCluster = clipClusterList.get(index);
                mClipClusterFirstThumbnailIndex.add(new Pair<>(clipCluster, viewItemList.size()));
                for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
                    ClipSegment clipSegment = clipCluster.getClipSegment().get(i);
                    if (clipSegment.data instanceof ClipBean) {
                        ClipBean clip = (ClipBean) clipSegment.data;
                        long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
//                        com.orhanobut.logger.Logger.t(TAG).e("thumbnailSize: " + thumbnailSize);
                        for (long j = thumbnailSize - 1; j >= 0; j--) {
                            ClipBeanPos clipPos = new ClipBeanPos(clip, j * 30 * 8 * 1000 / clipSegment.ratio + clipSegment.startTime);
                            ViewItem thumbnailItem = new ViewItem();
                            thumbnailItem.itemType = TYPE_THUMBNAIL;
                            thumbnailItem.itemObject = clipPos;
                            if (thumbnailSize == 1) {
                                thumbnailItem.extra = SINGLE_THUMBNAIL;
                            } else if (j == thumbnailSize - 1) {
                                thumbnailItem.extra = TOP_THUMBNAIL;
                            } else if (j == 0) {
                                thumbnailItem.extra = BOTTOM_THUMBNAIL;
                            } else {
                                thumbnailItem.extra = MIDDLE_THUMBNAIL;
                            }
                            viewItemList.add(thumbnailItem);
                        }
                    }
                }
                ViewItem marginItem = new ViewItem();
                marginItem.itemType = TYPE_MARGIN;
                marginItem.itemObject = (index == clipClusterList.size() - 1) ? 0 : ViewUtils.dp2px(24);
                viewItemList.add(marginItem);
            }
        }
//        com.orhanobut.logger.Logger.t(TAG).e("recalculateViewItemList: " + viewItemList.toString() + "--" + viewItemList.size());
    }

//    public ClipBean getSelectedClip() {
//        return selectedClip;
//    }

    public List<ViewItem> getViewItemList() {
        return viewItemList;
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

    public int getFirstThumbnailIndex(ClipBeanCluster clipCluster) {
        for (Pair<ClipBeanCluster, Integer> item : mClipClusterFirstThumbnailIndex) {
            if (item.first.equals(clipCluster)) {
                return item.second;
            }
        }
        return -1;
    }

    public int getFirstThumbnailIndex(EventBeanCluster eventCluster) {
        for (Pair<EventBeanCluster, Integer> item : mEventClusterFirstThumbnailIndex) {
            if (item.first.equals(eventCluster)) {
                return item.second;
            }
        }
        return -1;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case TYPE_LIVE:
                return new LiveViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_view, parent, false));
            case TYPE_LIST_HEADER:
                return new HeaderViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_clip_cluster_list_header, parent, false));
            case TYPE_MARGIN:
                return new MarginViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.margin_item, parent, false));
            default:
                return new ThumbnailViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_thumbnail, parent, false));
        }
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
            case TYPE_LIVE:
                onBindLiveViewHolder((LiveViewHolder) holder);
                break;
            case TYPE_LIST_HEADER:
                onBindDateHeaderViewHolder((HeaderViewHolder) holder, position);
                break;
            case TYPE_THUMBNAIL:
                onBindThumbnailViewHolder((ThumbnailViewHolder) holder, position);
                break;
            case TYPE_THUMBNAIL_FLEET:
                onBindFleetViewHolder((ThumbnailViewHolder) holder, position);
                break;
            case TYPE_MARGIN:
                onBindMarginViewHolder((MarginViewHolder) holder, position);
                break;
            default:
                break;
        }
    }

    @Override
    public int getItemCount() {
//        com.orhanobut.logger.Logger.t(TAG).e("getItemCount: " + viewItemList.size());
        return viewItemList.size();
    }

    private void onBindLiveViewHolder(LiveViewHolder holder) {
        holder.iv_liveView.setVisibility(View.INVISIBLE);
    }

    private void onBindMarginViewHolder(MarginViewHolder holder, int position) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(new LinearLayout.LayoutParams(holder.itemView.getLayoutParams()));
        params.height = position == getItemCount() - 1 ? bottomMargin : (int) viewItemList.get(position).itemObject;
        holder.itemView.setLayoutParams(params);
        holder.itemView.requestLayout();
    }

    private void onBindDateHeaderViewHolder(HeaderViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);
        if (viewItem.extra == TOP_HEADER) {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, 0, 0, ViewUtils.dp2px(16));
        } else {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, ViewUtils.dp2px(16), 0, ViewUtils.dp2px(16));
        }
        holder.itemView.requestLayout();
    }

    private void onBindFleetViewHolder(ThumbnailViewHolder holder, int position) {
        holder.iv_thumbnail.clear();
        ViewItem viewItem = viewItemList.get(position);
//        EventBeanPos eventBeanPos = (EventBeanPos) viewItem.itemObject;
        switch (viewItem.extra) {
            case SINGLE_THUMBNAIL:
                holder.iv_thumbnail.setCorner(1, 1, 1, 1);
                break;
            case TOP_THUMBNAIL:
                holder.iv_thumbnail.setCorner(1, 1, 0, 0);
                break;
            case BOTTOM_THUMBNAIL:
                holder.iv_thumbnail.setCorner(0, 0, 1, 1);
                break;
            case MIDDLE_THUMBNAIL:
                holder.iv_thumbnail.setCorner(0, 0, 0, 0);
            default:
                break;
        }

//        EventBean eventBean = eventBeanPos.getEventBean();
//        boolean lensMode = TextUtils.isEmpty(eventBean.getRotate()) || LENS_NORMAL.equals(eventBean.getRotate());

        Context context = mContextRef.get();
        if (context != null) {
            Glide.with(context)
                    .load(R.drawable.icon_event_playback)
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.bg_single_thumbnail)
                    .error(R.drawable.bg_single_thumbnail)
                    .into(holder.iv_thumbnail);
        }

        holder.itemView.setOnTouchListener((View v, MotionEvent event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                v.performClick();
            }
            return false;
        });
    }

    private void onBindThumbnailViewHolder(ThumbnailViewHolder holder, int position) {
        holder.iv_thumbnail.clear();
        ViewItem viewItem = viewItemList.get(position);
        ClipBeanPos clipPos = (ClipBeanPos) viewItem.itemObject;
        switch (viewItem.extra) {
            case SINGLE_THUMBNAIL:
                holder.iv_thumbnail.setCorner(1, 1, 1, 1);
                break;
            case TOP_THUMBNAIL:
                holder.iv_thumbnail.setCorner(1, 1, 0, 0);
                break;
            case BOTTOM_THUMBNAIL:
                holder.iv_thumbnail.setCorner(0, 0, 1, 1);
                break;
            case MIDDLE_THUMBNAIL:
                holder.iv_thumbnail.setCorner(0, 0, 0, 0);
            default:
                break;
        }

        ClipBean clipBean = clipPos.getClipBean();
        boolean lensMode = TextUtils.isEmpty(clipBean.rotate) || LENS_NORMAL.equals(clipBean.rotate);

        Context context = mContextRef.get();
        if (context != null) {
            Glide.with(context)
                    .load(clipBean.thumbnail)
                    .transform(new TwoDirectionTransform(context, lensMode))
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.bg_single_thumbnail)
                    .error(R.drawable.bg_single_thumbnail)
                    .into(holder.iv_thumbnail);
        }

        holder.itemView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                v.performClick();
            }
            return false;
        });
    }


    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder viewHolder) {
        if (viewHolder instanceof ThumbnailViewHolder) {
            ThumbnailViewHolder thumbnailViewHolder = (ThumbnailViewHolder) viewHolder;
            Glide.clear(thumbnailViewHolder.iv_thumbnail);
            thumbnailViewHolder.iv_thumbnail.setImageDrawable(null);
        }
    }

    static class LiveViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_liveView)
        ImageView iv_liveView;

        LiveViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static class HeaderViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_clipListDate)
        TextView tv_clipListDate;

        @BindView(R.id.ll_header)
        LinearLayout ll_header;

        HeaderViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static class ThumbnailViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_thumbnail)
        RoundCornerImageView iv_thumbnail;

        ThumbnailViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }

    static class MarginViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.ll_base)
        LinearLayout ll_base;

        MarginViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}