package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.ui.view.RoundCornerImageView;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.glide_adapter.SnipeGlideLoader;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipPos;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.utils.ClipClusterHelper;
import com.mk.autosecure.model.ClipCluster;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.ui.view.MultiSegBar;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by doanvt on 2018/6/6.
 * Email：doanvt-hn@mk.com.vn
 */

public class ScaleAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = ScaleAdapter.class.getSimpleName();

    private List<ViewItem> viewItemList = new ArrayList<>();
    private List<ClipCluster> mClipClusterList = new ArrayList<>();
    private List<ClipSegment> mClipSegmentList = new ArrayList<>();

    //buffered标记的每个thumbnail对应240s，marked标记的每个thumbnail对应30s，由ratio调整
    private int interval = 30 * 8;

    private int margin;

    private SoftReference<Context> mContextRef;

    private final static int TYPE_TOP_MARGIN = 0x00;
    public final static int TYPE_THUMBNAIL = 0x01;
    private final static int TYPE_BOTTOM_MARGIN = 0x02;

    private static final int SINGLE_THUMBNAIL = 0;
    private static final int TOP_THUMBNAIL = 1;
    private static final int MIDDLE_THUMBNAIL = 2;
    private static final int BOTTOM_THUMBNAIL = 3;

    public static class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;
    }

    public ScaleAdapter(Context context) {
        this.mContextRef = new SoftReference<>(context);
    }

    public void setMargin(int margin) {
        if (margin >= 0) {
            this.margin = margin;
            notifyItemChanged(0);
            notifyItemChanged(getItemCount() - 1);
        }
    }

//    public void clearData() {
//        viewItemList.clear();
//        notifyDataSetChanged();
//    }

    public void setClipList(List<Clip> clipList, int interval) {
        Logger.t(TAG).e("interval: " + interval);
        this.interval = interval;
        mClipClusterList = new ClipClusterHelper(clipList).getClipClusterList();
        recalculateViewItemList();
        notifyDataSetChanged();
    }

    private void recalculateViewItemList() {
        if (mClipClusterList == null) {
            return;
        }
        viewItemList.clear();
        mClipSegmentList.clear();

        ViewItem topMarginItem = new ViewItem();
        topMarginItem.itemType = TYPE_TOP_MARGIN;
        viewItemList.add(topMarginItem);

        for (int index = 0; index < mClipClusterList.size(); index++) {
            ClipCluster clipCluster = mClipClusterList.get(index);
            Logger.t(TAG).e("mClipClusterList: " + mClipClusterList.size());
            mClipSegmentList.addAll(clipCluster.getClipSegment());
            Logger.t(TAG).e("mClipSegmentList: " + mClipSegmentList.size());

            for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
                ClipSegment clipSegment = clipCluster.getClipSegment().get(i);
                if (clipSegment.data instanceof Clip) {
                    Clip clip = (Clip) clipSegment.data;
                    long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (interval * 1000));
                    Logger.t(TAG).e("thumbnailSize: " + thumbnailSize);
                    for (long j = thumbnailSize - 1; j >= 0; j--) {
                        ClipPos clipPos = new ClipPos(clip,
                                j * interval * 1000 / clipSegment.ratio + clipSegment.startTime - clip.getClipDateWithDST());

//                        Logger.t(TAG).e("clipTimeMs: " + clipPos.getClipTimeMs()
//                                + "--" + j * interval * 1000
//                                + "--" + clipSegment.ratio
//                                + "--" + clipSegment.startTime
//                                + "--" + clip.getClipDateWithDST());

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
        }
        ViewItem btmMarginItem = new ViewItem();
        btmMarginItem.itemType = TYPE_BOTTOM_MARGIN;
        viewItemList.add(btmMarginItem);
    }

    public List<ViewItem> getViewItemList() {
        return viewItemList;
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

//    public Object getClipCluster(int position) {
//        if (position >= 0 && position < viewItemList.size()) {
//            return mClipClusterList.get(0);
//        }
//        return null;
//    }

    //区分此时进入的是哪个index
    public int getClipPosIndex(ClipPos mClipPos, Clip mClip) {
        if (mClipPos == null || mClip == null) {
            return getItemCount() - 2;
        }

        long clipTimeMs = mClipPos.getClipTimeMs();
        long startTimeMs = mClip.getStartTimeMs();

        for (ViewItem item : viewItemList) {
            if (item.itemType == TYPE_THUMBNAIL) {
                ClipPos clipPos = (ClipPos) item.itemObject;
                long sub = clipPos.getClipTimeMs() - startTimeMs;
//                Logger.t(TAG).e("sub: " + sub + "--" + clipTimeMs);
                //考虑到排序是倒序
                if (clipTimeMs > sub) {
                    return viewItemList.indexOf(item);
                }
            }
        }
        return getItemCount() - 2;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case TYPE_TOP_MARGIN:
            case TYPE_BOTTOM_MARGIN:
                return new MarginViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.margin_item, parent, false));
            default:
                return new ThumbnailViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.thumbnail_item, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        switch (getItemViewType(position)) {
            case TYPE_TOP_MARGIN:
            case TYPE_BOTTOM_MARGIN:
                onBindMarginViewHolder((MarginViewHolder) holder);
                break;
            case TYPE_THUMBNAIL:
                onBindThumbnailViewHolder((ThumbnailViewHolder) holder, position);
                break;
            default:
                break;
        }
    }

    private void onBindThumbnailViewHolder(ThumbnailViewHolder holder, int position) {
        holder.iv_thumbnail.clear();
        ViewItem viewItem = viewItemList.get(position);
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
        ClipPos clipPos = (ClipPos) viewItem.itemObject;

        Context context = mContextRef.get();
        if (context != null) {
            Glide.with(context)
                    .using(new SnipeGlideLoader(VdtCameraManager.getManager().getCurrentVdbRequestQueue(), false))
                    .load(clipPos)
                    .transform(new TwoDirectionTransform(context, clipPos.clip.isLensNormal()))
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.bg_single_thumbnail)
                    .into(holder.iv_thumbnail);
        }

        holder.itemView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                v.performClick();
            }
            return false;
        });

        holder.v_videoIndicator.setSegList(mClipSegmentList);
    }

    private void onBindMarginViewHolder(MarginViewHolder holder) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
        params.height = margin;
        holder.itemView.setLayoutParams(params);
        holder.itemView.requestLayout();
    }

    @Override
    public int getItemCount() {
        return viewItemList.size();
    }

    @Override
    public int getItemViewType(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemType;
        }
        return -1;
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof ThumbnailViewHolder) {
            ThumbnailViewHolder viewHolder = (ThumbnailViewHolder) holder;
            Glide.clear(viewHolder.iv_thumbnail);
            viewHolder.iv_thumbnail.setImageDrawable(null);
        }
    }

    class ThumbnailViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.v_videoIndicator)
        MultiSegBar v_videoIndicator;
        @BindView(R.id.iv_thumbnail)
        RoundCornerImageView iv_thumbnail;

        ThumbnailViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    class MarginViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.ll_base)
        LinearLayout ll_base;

        MarginViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}
