package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.mk.autosecure.ui.view.SelectClipView;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.model.rawdata.GpsData;
import com.mkgroup.camera.model.rawdata.RawDataItem;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.DateTime;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.ClipClusterGroupHelper;
import com.mk.autosecure.libs.utils.ClipClusterHelper;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.model.ClipCluster;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.reponse.LocationResponse;
import com.mk.autosecure.ui.view.MultiSegBar;

import java.lang.ref.WeakReference;
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
 * Created by DoanVT on 2017/9/8.
 * Email: doanvt-hn@mk.com.vn
 */

public class LocalVideoAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final static String TAG = LocalVideoAdapter.class.getSimpleName();

    public final static int dividerMarginTop = ViewUtils.dp2px(48);

    public final static int playerTimeTolerance = 3000;

    /**
     * in milli-seconds
     */

    private final static int thumbnailWidth = ViewUtils.dp2px(100);

    public final static int thumbnailHeight = ViewUtils.dp2px(56);

    private RxFragmentActivity mActivity;

    private Map<String, Integer> mClipCount = new HashMap<>();

    private List<List<ClipCluster>> mClipClusterGroupList = new ArrayList<>();
    private Clip selectedClip;

    private static final int TYPE_LIVE = 0x00;
    public static final int TYPE_CLIP = 0x01;
    public static final int TYPE_LIST_HEADER = 0x02;
    private static final int TYPE_FOOTER = 0x03;

    private static final int NORMAL_HEADER = 0;
    private static final int TOP_HEADER = 1;

    public class ViewItem {
        public int itemType;
        public Object itemObject;
        public int extra;
    }

    private List<ViewItem> viewItemList = new ArrayList<>();

    private int bottomMargin;

    public LocalVideoAdapter(RxFragmentActivity activity) {
        this.mActivity = activity;
        this.bottomMargin = ViewUtils.dp2px(240);
    }

    public void setSelectedClip(Clip clip) {
        this.selectedClip = clip;
        notifyDataSetChanged();
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

    public void clearData() {
        viewItemList.clear();
        mClipCount.clear();
        ViewItem liveItem = new ViewItem();
        liveItem.itemType = TYPE_LIVE;
        viewItemList.add(liveItem);
        selectedClip = null;
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
//        Logger.t(TAG).e("size = " + clipList.size() + "--" + mClipClusterList.size() + "--" + mClipClusterGroupList.size());
        recalculateViewItemList();
        notifyDataSetChanged();
    }

    private void recalculateViewItemList() {
        if (mClipClusterGroupList == null) {
            return;
        }

        viewItemList.clear();
        mClipCount.clear();
        ViewItem liveItem = new ViewItem();
        liveItem.itemType = TYPE_LIVE;
        viewItemList.add(liveItem);

        for (int in = 0; in < mClipClusterGroupList.size(); in++) {
            List<ClipCluster> clipClusterList = mClipClusterGroupList.get(in);
            ViewItem headItem = new ViewItem();
            headItem.itemType = TYPE_LIST_HEADER;
            headItem.itemObject = clipClusterList.get(0).getStartTime() + clipClusterList.get(0).getClipList().get(0).getOffset();
            headItem.extra = in == 0 ? TOP_HEADER : NORMAL_HEADER;
            viewItemList.add(headItem);

            int count = 0;
            for (ClipCluster clipCluster : clipClusterList) {
                count += clipCluster.getClipList().size();
            }

            mClipCount.put(getFormattedDate(clipClusterList.get(0).getStartTime() + clipClusterList.get(0).getClipList().get(0).getOffset()), count);

            for (ClipCluster clipCluster : clipClusterList) {
                ViewItem clipItem = new ViewItem();
                clipItem.itemType = TYPE_CLIP;
                clipItem.itemObject = clipCluster;
                viewItemList.add(clipItem);
            }
        }

        ViewItem btmItem = new ViewItem();
        btmItem.itemType = TYPE_FOOTER;
        viewItemList.add(btmItem);
    }

    public Clip getSelectedClip() {
        return selectedClip;
    }


    public Map<String, Integer> getClipCountMap() {
        return mClipCount;
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


    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case TYPE_LIVE:
                return new LiveViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_local_live_view, parent, false));
            case TYPE_LIST_HEADER:
                return new HeaderViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_clip_cluster_list_header, parent, false));
            case TYPE_FOOTER:
                return new FooterViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_no_more_videos, parent, false));
            default:
                if (Constants.isFleet()) {
                    return new VideoViewHolder(parent.getContext(), LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cloud_video_fleet, parent, false));
                } else {
                    return new VideoViewHolder(parent.getContext(), LayoutInflater.from(parent.getContext()).inflate(R.layout.item_cloud_video, parent, false));
                }
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
            case TYPE_CLIP:
                onBindVideoViewHolder((VideoViewHolder) holder, position);
                break;
            case TYPE_FOOTER:
                onBindFooterViewHolder((FooterViewHolder) holder);
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

    private void onBindFooterViewHolder(FooterViewHolder holder) {
        holder.iv_no_more_videos.setImageResource(R.drawable.icon_sdcard_empty);
        holder.tv_no_more_videos.setText(R.string.sdcard_no_more_videos);

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(holder.itemView.getLayoutParams());
        params.height = bottomMargin;
        holder.itemView.setLayoutParams(params);
        holder.itemView.requestLayout();
    }

    private void onBindLiveViewHolder(LiveViewHolder holder) {
        holder.iv_liveView.setVisibility(View.INVISIBLE);
    }

    private void onBindDateHeaderViewHolder(HeaderViewHolder holder, int position) {
        ViewItem viewItem = viewItemList.get(position);
        Long clipDate = (Long) viewItemList.get(position).itemObject;
        holder.tv_clipListDate.setText(getFormattedDate(clipDate));
        if (viewItem.extra == TOP_HEADER) {
            holder.tv_clipListDate.setVisibility(View.GONE);
            holder.ll_header.setPadding(0, 0, 0, ViewUtils.dp2px(16));
        } else {
            holder.tv_clipListDate.setVisibility(View.VISIBLE);
            holder.ll_header.setPadding(0, ViewUtils.dp2px(16), 0, ViewUtils.dp2px(16));
        }
        holder.itemView.requestLayout();
    }

    @SuppressLint("CheckResult")
    private void onBindVideoViewHolder(VideoViewHolder holder, int position) {

        holder.ll_thumbnails.removeAllViews();

        ViewItem viewItem = viewItemList.get(position);

        ClipCluster clipCluster = (ClipCluster) viewItem.itemObject;

        List<ClipPos> clipPosList = new ArrayList<>();

        for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
            ClipSegment clipSegment = clipCluster.getClipSegment().get(i);
            if (clipSegment.data instanceof Clip) {
                Clip clip = (Clip) clipSegment.data;
                long thumbnailSize = (long) Math.ceil((double) clipSegment.duration * clipSegment.ratio / (30 * 8 * 1000));
                for (long j = thumbnailSize - 1; j >= 0; j--) {
                    ClipPos clipPos = new ClipPos(clip, j * 30 * 8 * 1000 / clipSegment.ratio + clipSegment.startTime - clip.getClipDateWithDST());
                    clipPosList.add(clipPos);

                    Context context = holder.weakReference.get();
                    if (context != null) {
                        ImageView imageView = new ImageView(context);
                        imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(thumbnailWidth, thumbnailHeight);
                        holder.ll_thumbnails.addView(imageView, layoutParams);
                    }
                }
            }
        }


        for (int i = 0; i < holder.ll_thumbnails.getChildCount(); i++) {
            ImageView childImageView = (ImageView) holder.ll_thumbnails.getChildAt(i);
            if (i >= clipPosList.size()) {
                break;
            }
            childImageView.setBackgroundColor(mActivity.getResources().getColor(R.color.transparent));
        }

        holder.itemView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                v.performClick();
            }
            return false;
        });

        List<ClipSegment> segments = clipCluster.getClipSegment();

        Clip firstClip = (Clip) segments.get(segments.size() - 1).data;

        String time;
        if (DateFormat.is24HourFormat(mActivity)) {
            time = DateTime.get24HTimeWithoutSec(firstClip.getStartTimeMsAbs() + firstClip.getOffset(), true);
        } else {
            time = DateTime.get12HTimeWithoutSec(firstClip.getStartTimeMsAbs() + firstClip.getOffset(), true);
        }
        holder.tv_videoTime.setText(time);

        //set location
        String location = firstClip.location;
        if (TextUtils.isEmpty(location)) {
            SnipeApi.getRawDataBlockRx(firstClip, RawDataItem.DATA_TYPE_GPS,
                    firstClip.getStartTimeMs(), 5 * 60 * 1000)
                    .compose(Transformers.switchSchedulers())
                    .compose(mActivity.bindUntilEvent(ActivityEvent.STOP))
                    .subscribe(rawDataBlock -> {
                        List<RawDataItem> rawDataBlockItemList = rawDataBlock.getItemList();

                        GpsData gpsData = null;
                        for (RawDataItem item : rawDataBlockItemList) {
                            gpsData = (GpsData) item.data;
                            if (gpsData != null) {
                                break;
                            }
                        }

                        GpsData.Coord coord = getCoord(gpsData);
//                    Logger.t(TAG).d("coord: " + coord);

                        if (coord == null) {
                            holder.tv_videoLocation.setText("");
                        } else {
                            double lat = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", coord.lat));
                            double lng = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", coord.lng));
                            ApiService.createApiService().getLocation(lat, lng)
                                    .compose(Transformers.switchSchedulers())
                                    .compose(mActivity.bindUntilEvent(ActivityEvent.STOP))
                                    .subscribe((LocationResponse response) -> {
                                        LocationResponse.AddressBean address = response.getAddress();
                                        if (address != null && !TextUtils.isEmpty(address.getRoute())) {
                                            firstClip.location = address.getRoute();
                                            holder.tv_videoLocation.setText(address.getRoute());
                                        } else {
                                            holder.tv_videoLocation.setText("");
                                        }
                                    }, throwable -> {
                                        holder.tv_videoLocation.setText("");
                                        Logger.t(TAG).e("throwable: " + throwable.getMessage());
                                    });
                        }
                    }, throwable -> {
                        holder.tv_videoLocation.setText("");
                        Logger.t(TAG).e("throwable: " + throwable.getMessage());
                    });
        } else {
            holder.tv_videoLocation.setText(location);
        }

        holder.v_videoIndicator.setSegList(segments);

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
        if (selectedClip != null && clipCluster.getClipList().contains(selectedClip)) {
            long totalClipTimeMs = 0;
            int totalHeight = thumbnailHeight * clipPosList.size();
            int firstSegmentIndex = -1;
            for (int i = 0; i < segments.size(); i++) {
                ClipSegment segment = segments.get(i);
                totalClipTimeMs += segment.getLength();
                if (segment.startTime + segment.duration <= selectedClip.getEndTimeMsAbs() && firstSegmentIndex < 0) {
                    firstSegmentIndex = i;
                }
            }
            float offset = 0;
            float height = 0;
            float scale = (float) totalHeight / totalClipTimeMs;

            Logger.t(LocalVideoAdapter.class.getSimpleName()).d("segments: " + segments.size());
            Logger.t(LocalVideoAdapter.class.getSimpleName()).d("firstSegmentIndex = " + firstSegmentIndex);
            Logger.t(LocalVideoAdapter.class.getSimpleName()).d("scale = " + scale);

            if (firstSegmentIndex >= 0 && totalClipTimeMs > 0) {
                for (int i = 0; i < firstSegmentIndex && i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    offset += scale * segment.getLength();
                }
                for (int i = firstSegmentIndex; i < segments.size(); i++) {
                    ClipSegment segment = segments.get(i);
                    if (segment.startTime + segment.duration <= selectedClip.getEndTimeMsAbs() && segment.startTime >= selectedClip.getStartTimeMsAbs()) {
                        height += segment.getLength() * scale;
                    } else {
                        break;
                    }
                }
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (int) height);
                selectLayoutParams.setMargins(0, (int) offset, 0, 0);
                holder.selectLayout.addSelection(selectedClip.index, selectLayoutParams, false, null);
            } else {
                Logger.t(LocalVideoAdapter.class.getSimpleName()).d("here total length = " + totalHeight);
                FrameLayout.LayoutParams selectLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, totalHeight);
                selectLayoutParams.setMargins(0, 0, 0, 0);
                holder.selectLayout.addSelection(selectedClip.index, selectLayoutParams, false, null);
            }
        }
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder viewHolder) {
        if (viewHolder instanceof VideoViewHolder) {
            VideoViewHolder videoViewHolder = (VideoViewHolder) viewHolder;
            for (int i = 0; i < videoViewHolder.ll_thumbnails.getChildCount(); i++) {
                Glide.clear(videoViewHolder.ll_thumbnails.getChildAt(i));
            }
            videoViewHolder.ll_thumbnails.removeAllViews();
        }
    }

    private GpsData.Coord getCoord(GpsData gpsData) {
        if (gpsData == null) {
            return null;
        }
        return gpsData.coord;
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
                dateString = mActivity.getString(R.string.today);
            } else if ((currentDateDay - clipDateDay) < 2) {
                dateString = mActivity.getString(R.string.yesterday);
            }
        }
        return dateString;
    }

    static class VideoViewHolder extends RecyclerView.ViewHolder {

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

        WeakReference<Context> weakReference;

        private VideoViewHolder(Context context, View itemView) {
            super(itemView);
            this.weakReference = new WeakReference<>(context);
            ButterKnife.bind(this, itemView);
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

    class FooterViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.iv_no_more_videos)
        ImageView iv_no_more_videos;

        @BindView(R.id.tv_no_more_videos)
        TextView tv_no_more_videos;

        private FooterViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}


