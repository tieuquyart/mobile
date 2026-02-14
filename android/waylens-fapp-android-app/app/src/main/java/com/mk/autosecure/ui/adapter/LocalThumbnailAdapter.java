package com.mk.autosecure.ui.adapter;

import android.content.Context;
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
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.glide_adapter.SnipeGlideLoader;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipPos;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.utils.ClipClusterGroupHelper;
import com.mk.autosecure.libs.utils.ClipClusterHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipCluster;
import com.mk.autosecure.model.ClipSegment;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/12/5.
 * Email: doanvt-hn@mk.com.vn
 */

public class LocalThumbnailAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

//    private final static String TAG = LocalThumbnailAdapter.class.getSimpleName();

    private List<ViewItem> viewItemList = new ArrayList<>();

    private final static int dividerMarginTop = ViewUtils.dp2px(48);

//    public final static int playerTimeTolerance = 3000;

    private int bottomMargin;

    private List<List<ClipCluster>> mClipClusterGroupList = new ArrayList<>();
    //    private Clip selectedClip;
    private List<Pair<ClipCluster, Integer>> mClipClusterFirstThumbnailIndex = new ArrayList<>();

    private static final int TYPE_LIVE = 0x00;
    private static final int TYPE_THUMBNAIL = 0x01;
    private static final int TYPE_LIST_HEADER = 0x02;
    private static final int TYPE_MARGIN = 0x03;

    private static final int MIDDLE_THUMBNAIL = 0;
    private static final int TOP_THUMBNAIL = 1;
    private static final int BOTTOM_THUMBNAIL = 2;
    private static final int SINGLE_THUMBNAIL = 3;

    private static final int NORMAL_HEADER = 0;
    private static final int TOP_HEADER = 1;

    private SoftReference<Context> mContextRef;

    public LocalThumbnailAdapter(Context context) {
        this.mContextRef = new SoftReference<>(context);
        this.bottomMargin = ViewUtils.dp2px(160);
    }

    class ViewItem {
        int itemType;
        Object itemObject;
        int extra;
    }

//    public void setSelectedClip(Clip clip) {
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

    public void clearData() {
        viewItemList.clear();
        ViewItem liveItem = new ViewItem();
        liveItem.itemType = TYPE_LIVE;
        viewItemList.add(liveItem);
//        selectedClip = null;
        mClipClusterFirstThumbnailIndex.clear();
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
        recalculateViewItemList();
        notifyDataSetChanged();
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
            List<ClipCluster> clipClusterList = mClipClusterGroupList.get(in);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = clipClusterList.get(0).getStartTime();
            headItem.extra = in == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            for (int index = 0; index < clipClusterList.size(); index++) {
                ClipCluster clipCluster = clipClusterList.get(index);
                mClipClusterFirstThumbnailIndex.add(new Pair<>(clipCluster, viewItemList.size()));
                for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
                    ClipSegment clipSegment = clipCluster.getClipSegment().get(i);
                    if (clipSegment.data instanceof Clip) {
                        Clip clip = (Clip) clipSegment.data;
                        boolean overFiveMs = clipSegment.duration >= 5000;
                        long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
                        //录制的起始时间
                        long offset = clipSegment.startTime - clip.getClipDateWithDST();
                        for (long j = thumbnailSize - 1; j >= 0; j--) {
                            long clipTimeMs = j * 30 * 8 * 1000 / clipSegment.ratio + offset;
                            if (clipTimeMs == 0 && overFiveMs) {
                                clipTimeMs = 5000;
                            }
                            ClipPos clipPos = new ClipPos(clip, clipTimeMs);
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
    }

//    public Clip getSelectedClip() {
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

    public int getFirstThumbnailIndex(ClipCluster clipCluster) {
        for (Pair<ClipCluster, Integer> item : mClipClusterFirstThumbnailIndex) {
            if (item.first.equals(clipCluster)) {
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
                return new LiveViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_local_live_view, parent, false));
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
            case TYPE_MARGIN:
                onBindMarginViewHolder((MarginViewHolder) holder, position);
                break;
            default:
                break;
        }
    }

    @Override
    public int getItemCount() {
//        Logger.t(TAG).e("getItemCount: "+viewItemList.size());
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
            holder.tv_clipListDate.setVisibility(View.GONE);
            holder.ll_header.setPadding(0, 0, 0, ViewUtils.dp2px(16));
        } else {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, ViewUtils.dp2px(16), 0, ViewUtils.dp2px(16));
        }
        holder.itemView.requestLayout();
    }

    private void onBindThumbnailViewHolder(ThumbnailViewHolder holder, int position) {
        holder.iv_thumbnail.clear();
        ViewItem viewItem = viewItemList.get(position);
        ClipPos clipPos = (ClipPos) viewItem.itemObject;
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

        //clipPos.setIgnorable(true);

        Context context = mContextRef.get();
        if (context != null) {
            Glide.with(context)
                    .using(new SnipeGlideLoader(VdtCameraManager.getManager().getCurrentVdbRequestQueue(), false))
                    .load(clipPos)
                    //.override(256, 256)
                    .transform(new TwoDirectionTransform(context, clipPos.clip.isLensNormal()))
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
//              .crossFade()
                    .placeholder(R.drawable.bg_single_thumbnail)
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

    class LiveViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_liveView)
        ImageView iv_liveView;

        private LiveViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    class HeaderViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_clipListDate)
        TextView tv_clipListDate;

        @BindView(R.id.ll_header)
        LinearLayout ll_header;

        private HeaderViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    class ThumbnailViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_thumbnail)
        RoundCornerImageView iv_thumbnail;

        private ThumbnailViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }

    class MarginViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.ll_base)
        LinearLayout ll_base;

        private MarginViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}