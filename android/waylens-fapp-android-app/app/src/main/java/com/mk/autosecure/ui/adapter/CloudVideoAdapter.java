package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.mk.autosecure.ui.view.SelectClipView;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.utils.DateTime;
import com.mk.autosecure.R;
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
import com.mk.autosecure.ui.view.MultiSegBar;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/8/31.
 */

public class CloudVideoAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = CloudVideoAdapter.class.getSimpleName();

    private Context mContext;

    public final static int dividerMarginTop = ViewUtils.dp2px(48);

    public static int playerTimeTolerance = 3000;

    public int thumbnailWidth = ViewUtils.dp2px(100);

    public int thumbnailHeight = ViewUtils.dp2px(56);

    private Map<String, Integer> mClipCount = new HashMap<>();

    private List<ClipBeanCluster> mClipClusterList = new ArrayList<>();
    private List<List<ClipBeanCluster>> mClipClusterGroupList = new ArrayList<>();

    private List<EventBeanCluster> mEventClusterList = new ArrayList<>();
    private List<List<EventBeanCluster>> mEventClusterGroupList = new ArrayList<>();

    private ClipBean selectedClipBean;

    private EventBean selectedEventBean;

    public static final int TYPE_LIVE = 0x00;
    public static final int TYPE_PLAYBACK = 0x01;
    public static final int TYPE_LIST_HEADER = 0x02;
    public static final int TYPE_FOOTER = 0x03;
    public static final int TYPE_PLAYBACK_FLEET = 0x04;

    public static final int NORMAL_HEADER = 0;
    public static final int TOP_HEADER = 1;

    public static class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;

        @Override
        public String toString() {
            return "ViewItem{" +
                    "itemType=" + itemType +
                    ", itemObject=" + itemObject +
                    ", extra=" + extra +
                    '}';
        }
    }

    private List<CloudVideoAdapter.ViewItem> viewItemList = new ArrayList<>();

    private int bottomMargin;

    public CloudVideoAdapter(Context context) {
        this.mContext = context;
    }

    /**
     * top timeline height 48dp,
     * normal bottom margin 24dp
     */
    public void setBottomMargin(int rvHeight) {
        if (rvHeight >= 0) {
            bottomMargin = rvHeight - dividerMarginTop;
            notifyItemChanged(getItemCount() - 1);
        }
    }

    public void setSelectedClip(ClipBean clipBean) {
        this.selectedClipBean = clipBean;
        notifyDataSetChanged();
    }

    public void setSelectedEvent(EventBean eventBean) {
        this.selectedEventBean = eventBean;
        notifyDataSetChanged();
    }

    public void setClipList(List<ClipBean> clipList) {
//        Logger.t(TAG).e("setClipList: " + clipList.toString());
//        Logger.t(TAG).e("size : " + clipList.size());
        this.mClipClusterList = new ClipBeanClusterHelper(clipList).getClipBeanClusterList();
        this.mClipClusterGroupList = new ClipBeanClusterGroupHelper(mClipClusterList).getClipClusterGroup();
//        Logger.t(TAG).e("size : " + mClipClusterList.size() + "--" + mClipClusterGroupList.size());
        recalculateViewItemList();
        notifyDataSetChanged();
    }

    public void setEventsList(List<EventBean> eventsList) {
        this.mEventClusterList = new EventBeanClusterHelper(eventsList).getEventBeanClusterList();
        this.mEventClusterGroupList = new EventBeanClusterGroupHelper(mEventClusterList).getEventClusterGroup();
        recalculateFleetList();
        notifyDataSetChanged();
    }

    private void recalculateFleetList() {
        if (mEventClusterGroupList == null) {
            return;
        }

        viewItemList.clear();
        mClipCount.clear();

        ViewItem viewItem = new ViewItem();
        viewItem.itemType = TYPE_LIVE;
        viewItemList.add(viewItem);

        for (int i = 0; i < mEventClusterGroupList.size(); i++) {
            List<EventBeanCluster> eventBeanClusters = mEventClusterGroupList.get(i);
            CloudVideoAdapter.ViewItem headItem = new CloudVideoAdapter.ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = eventBeanClusters.get(0).getStartTime();
            headItem.extra = i == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            int count = 0;
            for (EventBeanCluster clipBeanCluster : eventBeanClusters) {
                count += clipBeanCluster.getEventBeanList().size();
            }

            mClipCount.put(getFormattedDate(eventBeanClusters.get(0).getStartTime()), count);

            for (EventBeanCluster clipBeanCluster : eventBeanClusters) {
                ViewItem clipItem = new ViewItem();
                clipItem.itemType = TYPE_PLAYBACK_FLEET;
                clipItem.itemObject = clipBeanCluster;
                viewItemList.add(clipItem);
            }
        }
        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
//        Logger.t(TAG).e("recalculateViewItemList: " + viewItemList.toString());
    }

    private void recalculateViewItemList() {
        if (mClipClusterGroupList == null) {
            return;
        }

        viewItemList.clear();
        mClipCount.clear();

        ViewItem viewItem = new ViewItem();
        viewItem.itemType = TYPE_LIVE;
        viewItemList.add(viewItem);

        for (int i = 0; i < mClipClusterGroupList.size(); i++) {
            List<ClipBeanCluster> clipBeanClusters = mClipClusterGroupList.get(i);
            CloudVideoAdapter.ViewItem headItem = new CloudVideoAdapter.ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = clipBeanClusters.get(0).getStartTime();
            headItem.extra = i == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            int count = 0;
            for (ClipBeanCluster clipBeanCluster : clipBeanClusters) {
                count += clipBeanCluster.getClipBeanList().size();
            }

            mClipCount.put(getFormattedDate(clipBeanClusters.get(0).getStartTime()), count);

            for (ClipBeanCluster clipBeanCluster : clipBeanClusters) {
                ViewItem clipItem = new ViewItem();
                clipItem.itemType = TYPE_PLAYBACK;
                clipItem.itemObject = clipBeanCluster;
                viewItemList.add(clipItem);
            }
        }
        ViewItem footerItem = new ViewItem();
        footerItem.itemType = TYPE_FOOTER;
        viewItemList.add(footerItem);
//        Logger.t(TAG).e("recalculateViewItemList: " + viewItemList.toString());
    }

    public List<ClipBeanCluster> getClipBeanClusterList() {
        return mClipClusterList;
    }

    public ClipBean getSelectedClipBean() {
        return selectedClipBean;
    }

    public EventBean getSelectedEventBean() {
        return selectedEventBean;
    }

    public Map<String, Integer> getClipCountMap() {
        return mClipCount;
    }

    public List<CloudVideoAdapter.ViewItem> getViewItemList() {
        return viewItemList;
    }

    public Object getViewItemObjectAt(int position) {
        if (position >= 0 && position < viewItemList.size()) {
            return viewItemList.get(position).itemObject;
        }
        return null;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        switch (viewType) {
            case TYPE_LIVE:
                return new LiveViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_view, parent, false));
            case TYPE_PLAYBACK:
            case TYPE_PLAYBACK_FLEET:
                return new VideoViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cloud_video, parent, false));
            case TYPE_LIST_HEADER:
                return new HeaderViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_clip_cluster_list_header, parent, false));
            case TYPE_FOOTER:
                return new FooterViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_no_more_videos, parent, false));
            default:
                return new VideoViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cloud_video, parent, false));
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
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        switch (getItemViewType(position)) {
            case TYPE_LIVE:
                onBindLiveViewHolder((LiveViewHolder) holder, position);
                break;
            case TYPE_PLAYBACK:
                onBindVideoViewHolder((VideoViewHolder) holder, position);
                break;
            case TYPE_PLAYBACK_FLEET:
                onBindFleetViewHolder((VideoViewHolder) holder, position);
                break;
            case TYPE_LIST_HEADER:
                onBindDateHeaderViewHolder((HeaderViewHolder) holder, position);
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
//        com.orhanobut.logger.Logger.t(TAG).e("getItemCount: " + viewItemList.size());
        return viewItemList.size();
    }

    private void onBindFooterViewHolder(FooterViewHolder holder, int position) {
        holder.iv_no_more_videos.setImageResource(R.drawable.icon_cloud_error);
        holder.tv_no_more_videos.setText(R.string.cloud_no_more_videos);

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
        params.height = bottomMargin;
        holder.itemView.setLayoutParams(params);
        holder.itemView.requestLayout();
    }

    private void onBindLiveViewHolder(LiveViewHolder holder, int position) {
//        Logger.t(TAG).e("onBindLiveViewHolder");
        holder.iv_liveView.setVisibility(View.INVISIBLE);
    }

    private void onBindFleetViewHolder(VideoViewHolder holder, int position) {
        holder.ll_thumbnails.removeAllViews();
        ViewItem viewItem = viewItemList.get(position);

        EventBeanCluster eventBeanCluster = (EventBeanCluster) viewItem.itemObject;

        List<EventBeanPos> eventPosList = new ArrayList<>();

        for (int i = 0; i < eventBeanCluster.getClipSegment().size(); i++) {
            ClipSegment clipSegment = eventBeanCluster.getClipSegment().get(i);
            if (clipSegment.data != null && clipSegment.data instanceof EventBean) {
                EventBean eventBean = (EventBean) clipSegment.data;
                //todo ratio maybe error
                long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
                for (long j = thumbnailSize - 1; j >= 0; j--) {
                    EventBeanPos eventBeanPos = new EventBeanPos(eventBean, j * 30 * 8 * 1000 / clipSegment.ratio + clipSegment.startTime);
                    eventPosList.add(eventBeanPos);

                    ImageView imageView = new ImageView(mContext);
                    imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(thumbnailWidth, thumbnailHeight);
                    holder.ll_thumbnails.addView(imageView, layoutParams);
                }
            }
        }

        for (int i = 0; i < holder.ll_thumbnails.getChildCount(); i++) {
            ImageView childImageView = (ImageView) holder.ll_thumbnails.getChildAt(i);
            if (i >= eventPosList.size()) {
                break;
            }
            childImageView.setBackgroundColor(mContext.getResources().getColor(R.color.transparent));
        }

        holder.itemView.setOnTouchListener((v, event) -> false);

        List<ClipSegment> segments = eventBeanCluster.getClipSegment();

        int type = eventBeanCluster.getClipSegment().get(0).types;

//        Logger.t(LocalVideoAdapter.class.getSimpleName()).d("type = " + type);
        EventBean firstClip = (EventBean) segments.get(segments.size() - 1).data;

        String time;
        if (DateFormat.is24HourFormat(mContext)) {
            time = DateTime.get24HTimeWithoutSec(firstClip.getStartTime(), false);
        } else {
            time = DateTime.get12HTimeWithoutSec(firstClip.getStartTime(), false);
        }
        holder.tv_videoTime.setText(time);
//        holder.tv_videoTime.setText(DateTime.getInDayMinuteString(firstClip.getStartTimeMs() +
//                TimeZone.getDefault().getRawOffset() +
//                (TimeZone.getDefault().inDaylightTime(new Date(firstClip.getStartTimeMs())) ? 3600 * 1000 : 0)));

        holder.v_videoIndicator.setSegList(segments);

//        if (position == getItemCount() - 1) {
//            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
//            params.setMargins(0, 0, 0, bottomMargin);
//            holder.itemView.setLayoutParams(params);
//            holder.itemView.requestLayout();
//        } else
        if ((position < getItemCount() - 1) && (getItemViewType(position + 1) == TYPE_LIST_HEADER)) {
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
            params.setMargins(0, 0, 0, 0);
            holder.itemView.setLayoutParams(params);
            holder.itemView.requestLayout();
        } else {
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
            params.setMargins(0, 0, 0, ViewUtils.dp2px(24));
            holder.itemView.setLayoutParams(params);
            holder.itemView.requestLayout();
        }
        holder.selectLayout.removeAllViews();
        if (selectedEventBean != null && eventBeanCluster.getEventBeanList().contains(selectedEventBean)) {
            long totalClipTimeMs = 0;
            int totalHeight = thumbnailHeight * eventPosList.size();
            int firstSegmentIndex = -1;
            for (int i = 0; i < segments.size(); i++) {
                ClipSegment segment = segments.get(i);
                totalClipTimeMs += segment.getLength();
                if (segment.startTime + segment.duration <= (selectedEventBean.getStartTime() + selectedEventBean.getDuration()) && firstSegmentIndex < 0) {
                    firstSegmentIndex = i;
                }
            }
            float offset = 0;
            float height = 0;
            float scale = (float) totalHeight / totalClipTimeMs;

//            Logger.t(TAG).d("segments: " + segments.size());
//            Logger.t(TAG).d("firstSegmentIndex = " + firstSegmentIndex);
//            Logger.t(TAG).d("scale = " + scale);

            if (firstSegmentIndex >= 0 && totalClipTimeMs > 0) {
                for (int i = 0; i < firstSegmentIndex && i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    offset += scale * segment.getLength();
                }
                for (int i = firstSegmentIndex; i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    if (segment.startTime + segment.duration <= (selectedEventBean.getStartTime() + selectedEventBean.getDuration()) && segment.startTime >= selectedEventBean.getStartTime()) {
                        height += segment.getLength() * scale;
                    } else {
                        break;
                    }
                }
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (int) height);
                selectLayoutParams.setMargins(0, (int) offset, 0, 0);

                holder.selectLayout.addSelection(eventBeanCluster.getEventBeanList().indexOf(selectedEventBean), selectLayoutParams, false, null);
            } else {
                Logger.t(LocalVideoAdapter.class.getSimpleName()).d("here total length = " + totalHeight);
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, totalHeight);
                selectLayoutParams.setMargins(0, 0, 0, 0);

                holder.selectLayout.addSelection(eventBeanCluster.getEventBeanList().indexOf(selectedEventBean), selectLayoutParams, false, null);
            }
        }
    }

    private void onBindVideoViewHolder(VideoViewHolder holder, int position) {
        holder.ll_thumbnails.removeAllViews();
        ViewItem viewItem = viewItemList.get(position);

        ClipBeanCluster clipBeanCluster = (ClipBeanCluster) viewItem.itemObject;

        List<ClipBeanPos> clipPosList = new ArrayList<>();

        for (int i = 0; i < clipBeanCluster.getClipSegment().size(); i++) {
            ClipSegment clipSegment = clipBeanCluster.getClipSegment().get(i);
            if (clipSegment.data != null && clipSegment.data instanceof ClipBean) {
                ClipBean clip = (ClipBean) clipSegment.data;
                long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
                for (long j = thumbnailSize - 1; j >= 0; j--) {
                    //这里
                    ClipBeanPos clipPos = new ClipBeanPos(clip, j * 30 * 8 * 1000 / clipSegment.ratio + clipSegment.startTime);
                    clipPosList.add(clipPos);
                    //这里添加的image是红色选择背景框
                    ImageView imageView = new ImageView(mContext);
                    imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(thumbnailWidth, thumbnailHeight);
                    holder.ll_thumbnails.addView(imageView, layoutParams);
                }
            }
        }

//        Logger.t(LocalVideoAdapter.class.getSimpleName()).d("%s", "thumbnail size = " + clipPosList.size());

        for (int i = 0; i < holder.ll_thumbnails.getChildCount(); i++) {
            ImageView childImageView = (ImageView) holder.ll_thumbnails.getChildAt(i);
            if (i >= clipPosList.size()) {
                break;
            }
            childImageView.setBackgroundColor(mContext.getResources().getColor(R.color.transparent));
        }

        holder.itemView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return false;
            }
        });

        List<ClipSegment> segments = clipBeanCluster.getClipSegment();

        int type = clipBeanCluster.getClipSegment().get(0).types;

//        Logger.t(LocalVideoAdapter.class.getSimpleName()).d("type = " + type);
        ClipBean firstClip = (ClipBean) segments.get(segments.size() - 1).data;

        String time;
        if (DateFormat.is24HourFormat(mContext)) {
            time = DateTime.get24HTimeWithoutSec(firstClip.getStartTimeMs(), false);
        } else {
            time = DateTime.get12HTimeWithoutSec(firstClip.getStartTimeMs(), false);
        }
        holder.tv_videoTime.setText(time);
//        holder.tv_videoTime.setText(DateTime.getInDayMinuteString(firstClip.getStartTimeMs() +
//                TimeZone.getDefault().getRawOffset() +
//                (TimeZone.getDefault().inDaylightTime(new Date(firstClip.getStartTimeMs())) ? 3600 * 1000 : 0)));

        //set location
        ClipBean.Location location = firstClip.location;
//        Logger.t(TAG).e("location: " + location);
        if (location != null) {
            holder.tv_videoLocation.setText(location.route);
        } else {
            holder.tv_videoLocation.setText("");
        }

        holder.v_videoIndicator.setSegList(segments);

//        if (position == getItemCount() - 1) {
//            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
//            params.setMargins(0, 0, 0, bottomMargin);
//            holder.itemView.setLayoutParams(params);
//            holder.itemView.requestLayout();
//        } else
        if ((position < getItemCount() - 1) && (getItemViewType(position + 1) == TYPE_LIST_HEADER)) {
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
            params.setMargins(0, 0, 0, 0);
            holder.itemView.setLayoutParams(params);
            holder.itemView.requestLayout();
        } else {
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
            params.setMargins(0, 0, 0, ViewUtils.dp2px(24));
            holder.itemView.setLayoutParams(params);
            holder.itemView.requestLayout();
        }
        holder.selectLayout.removeAllViews();
        if (selectedClipBean != null && clipBeanCluster.getClipBeanList().contains(selectedClipBean)) {
            long totalClipTimeMs = 0;
            int totalHeight = thumbnailHeight * clipPosList.size();
            int firstSegmentIndex = -1;
            for (int i = 0; i < segments.size(); i++) {
                ClipSegment segment = segments.get(i);
                totalClipTimeMs += segment.getLength();
                if (segment.startTime + segment.duration <= (selectedClipBean.getStartTimeMs() + selectedClipBean.getDuration()) && firstSegmentIndex < 0) {
                    firstSegmentIndex = i;
                }
            }
            float offset = 0;
            float height = 0;
            float scale = (float) totalHeight / totalClipTimeMs;

//            Logger.t(TAG).d("segments: " + segments.size());
//            Logger.t(TAG).d("firstSegmentIndex = " + firstSegmentIndex);
//            Logger.t(TAG).d("scale = " + scale);

            if (firstSegmentIndex >= 0 && totalClipTimeMs > 0) {
                for (int i = 0; i < firstSegmentIndex && i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    offset += scale * segment.getLength();
                }
                for (int i = firstSegmentIndex; i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    if (segment.startTime + segment.duration <= (selectedClipBean.getStartTimeMs() + selectedClipBean.getDuration()) && segment.startTime >= selectedClipBean.getStartTimeMs()) {
                        height += segment.getLength() * scale;
                    } else {
                        break;
                    }
                }
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (int) height);
                selectLayoutParams.setMargins(0, (int) offset, 0, 0);

                holder.selectLayout.addSelection(clipBeanCluster.getClipBeanList().indexOf(selectedClipBean), selectLayoutParams, false, null);
            } else {
                Logger.t(LocalVideoAdapter.class.getSimpleName()).d("here total length = " + totalHeight);
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, totalHeight);
                selectLayoutParams.setMargins(0, 0, 0, 0);

                holder.selectLayout.addSelection(clipBeanCluster.getClipBeanList().indexOf(selectedClipBean), selectLayoutParams, false, null);
            }
        }

//        ClipBean clipBean = mClipClusterList.get(position).getClipBeanList().get(0);
//
//        if (true) {
//            for (int i = 1; i < mClipClusterList.get(position).getClipBeanList().size(); i++) {
//                ImageView imageView = new ImageView(mContext);
//                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
//                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewUtils.dp2px(160), ViewUtils.dp2px(90));
//                holder.ll_thumbnails.addView(imageView, layoutParams);
//            }
//        }
//        for (int i = 0; i < holder.ll_thumbnails.getChildCount(); i++) {
//            Logger.t(CloudVideoAdapter.class.getSimpleName()).e("thumbnail url = " + mClipClusterList.get(position).getClipBeanList().get(i).thumbnail);
//            ImageView childImageView = (ImageView) holder.ll_thumbnails.getChildAt(i);
//            Glide.with(mContext)
//                    .using(new OkHttpUrlLoader())
//                    .load(mClipClusterList.get(position).getClipBeanList().get(i).thumbnail)
//                    .diskCacheStrategy(DiskCacheStrategy.ALL)
//                    .crossFade()
//                    .placeholder(R.drawable.menu_360_album_n)
//                    .into(childImageView);
//        }
//
//        holder.itemView.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                ClipBean clipBean = mClipClusterList.get(position).getClipBeanList().get(0);
//                VideoPlayerActivity.launch(mContext, clipBean.url);
//            }
//        });
//
//        List<ClipSegment> segments = mClipClusterList.get(position).getClipSegment();
//
//        int total_length = holder.v_videoIndicator.getHeight();
//
//        int type = mClipClusterList.get(position).getClipSegment().get(0).types;
//
//        Logger.t(CloudVideoAdapter.class.getSimpleName()).d("type = " + type);
//
//        switch (type) {
//            case ClipBean.TYPE_STREAMING:
//                //holder.v_videoIndicator.setBackgroundColor(mContext.getColor(R.color.gray));
//            default:
//                //holder.v_videoIndicator.setBackgroundColor(mContext.getColor(R.color.yellow));
//        }
//        holder.v_videoIndicator.setSegList(segments);
    }

    private void onBindDateHeaderViewHolder(HeaderViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);
        long clipDate = (long) viewItem.itemObject;
        holder.tv_clipListDate.setText(getFormattedDate(clipDate));
        if (viewItem.extra == TOP_HEADER) {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, 0, 0, ViewUtils.dp2px(16));
        } else {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, ViewUtils.dp2px(16), 0, ViewUtils.dp2px(16));
        }
        holder.itemView.requestLayout();
    }

    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        if (holder instanceof VideoViewHolder) {
            VideoViewHolder videoViewHolder = (VideoViewHolder) holder;
            for (int i = 0; i < videoViewHolder.ll_thumbnails.getChildCount(); i++) {
                Glide.clear(videoViewHolder.ll_thumbnails.getChildAt(i));
            }
            videoViewHolder.ll_thumbnails.removeAllViews();
        }
    }

    static public class VideoViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_videoLocation)
        TextView tv_videoLocation;

        @BindView(R.id.ll_thumbnails)
        LinearLayout ll_thumbnails;

        @BindView(R.id.select_layout)
        SelectClipView selectLayout;

        @BindView(R.id.tv_videoTime)
        TextView tv_videoTime;

        @BindView(R.id.v_videoIndicator)
        MultiSegBar v_videoIndicator;

        public VideoViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }

    static public class LiveViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_liveView)
        ImageView iv_liveView;

        public LiveViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static public class HeaderViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_clipListDate)
        TextView tv_clipListDate;

        @BindView(R.id.ll_header)
        LinearLayout ll_header;

        public HeaderViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    static public class FooterViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_no_more_videos)
        ImageView iv_no_more_videos;

        @BindView(R.id.tv_no_more_videos)
        TextView tv_no_more_videos;

        public FooterViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public String getFormattedDate(long date) {
        SimpleDateFormat format = new SimpleDateFormat("MMM dd,yyyy", Locale.getDefault());
        format.setTimeZone(TimeZone.getTimeZone("UTC"));

        long currentTime = System.currentTimeMillis() + TimeZone.getDefault().getOffset(new Date().getTime());
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeZone(TimeZone.getTimeZone("UTC"));
        calendar.setTimeInMillis(date);
        int clipDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int clipDateYear = calendar.get(Calendar.YEAR);

        calendar.setTimeInMillis(currentTime);
        int currentDateDay = calendar.get(Calendar.DAY_OF_YEAR);
        int currentDateYear = calendar.get(Calendar.YEAR);

        String dateString = format.format(date);

        if (clipDateYear == currentDateYear) {
            if ((currentDateDay - clipDateDay) < 1) {
                dateString = mContext.getString(R.string.today);
            } else if ((currentDateDay - clipDateDay) < 2) {
                dateString = mContext.getString(R.string.yesterday);
            }
        }
        return dateString;
    }
}


