package com.mk.autosecure.ui.adapter;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.util.SparseBooleanArray;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.Space;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.FileProvider;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.Postcard;
import com.alibaba.android.arouter.launcher.ARouter;
import com.bumptech.glide.DrawableRequestBuilder;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.activity.ExportActivity;
import com.mk.autosecure.ui.activity.VideoPlayerActivity;
import com.mk.autosecure.ui.data.IntentKey;
import com.mk.autosecure.ui.view.FixedAspectRatioFrameLayout;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.db.LocalVideoDaoManager;
import com.mkgroup.camera.db.VideoItem;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.R;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.libs.utils.Constants;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

import static com.mkgroup.camera.db.VideoItem.KEY_NEED_DEWARP;
import static com.mkgroup.camera.model.Clip.LENS_NORMAL;

/**
 * Created by DoanVT on 2017/9/28.
 * Email: doanvt-hn@mk.com.vn
 */

public class DownloadItemAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final String TAG = DownloadItemAdapter.class.getSimpleName();

    private final Activity mActivity;

    private List<VideoItem> mDownloadedFileList;

    private NumberChangeListener mListenerReference;

    private boolean mSelectTag = false;

    private SparseBooleanArray mCheckStates = new SparseBooleanArray();

    public DownloadItemAdapter(Activity activity, NumberChangeListener callback) {
        this.mActivity = activity;
        setListener(callback);
        mDownloadedFileList = LocalVideoDaoManager.getInstance().getVideoList();
        if (mListenerReference != null) {
            mListenerReference.onVideoNumberChanged(getItemCount());
        }
    }

    public void refresh() {
        mDownloadedFileList = LocalVideoDaoManager.getInstance().getVideoList();
        notifyDataSetChanged();
        if (mListenerReference != null) {
            mListenerReference.onVideoNumberChanged(getItemCount());
            mListenerReference.onSelectNumberChanged(mCheckStates.size());
        }
    }

    public boolean getAllChecked() {
        return mCheckStates.size() == getItemCount();
    }

    public SparseBooleanArray getCheckStates() {
        return mCheckStates;
    }

    public List<VideoItem> getDownloadedFileList() {
        return mDownloadedFileList;
    }

    public void setCheckStates(boolean states) {
        if (states) {
            for (int i = 0; i < getItemCount(); i++) {
                mCheckStates.put(i, true);
            }
        } else {
            mCheckStates.clear();
        }
    }

    public void setSelectTag(boolean tag) {
        this.mSelectTag = tag;
    }

    private void setListener(NumberChangeListener listener) {
        mListenerReference = listener;
    }


    @Override
    public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onDetachedFromRecyclerView(recyclerView);
        Logger.t(TAG).d("detached from recycler view");
    }


    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_video_simple, parent, false);

        return new DownloadVideoItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        onBindDownloadedViewHolder(holder, position);
    }

    private void onBindDownloadedViewHolder(RecyclerView.ViewHolder holder, final int position) {
        final DownloadVideoItemViewHolder viewHolder = (DownloadVideoItemViewHolder) holder;

        viewHolder.cbDelete.setTag(position);

        VideoItem videoItem = mDownloadedFileList.get(position);

        viewHolder.llChoice.setVisibility(mSelectTag ? View.VISIBLE : View.GONE);

        viewHolder.llAction.setVisibility(mSelectTag ? View.GONE : View.VISIBLE);
        viewHolder.spaceEnd.setVisibility(mSelectTag ? View.GONE : View.VISIBLE);

        if (mSelectTag) {
            viewHolder.cbDelete.setChecked(mCheckStates.get(position, false));
        } else {
            viewHolder.cbDelete.setChecked(false);
            mCheckStates.clear();
        }

        viewHolder.cbDelete.setOnCheckedChangeListener((buttonView, isChecked) -> {
            int pos = (int) buttonView.getTag();
            if (isChecked) {
                mCheckStates.put(pos, true);
            } else {
                mCheckStates.delete(pos);
            }
            if (mListenerReference != null) {
                mListenerReference.onSelectNumberChanged(mCheckStates.size());
            }
        });

        File file;
        String rawVideoPath = videoItem.getRawVideoPath();
        String transcodeVideoPath = videoItem.getTranscodeVideoPath();
        if (TextUtils.isEmpty(rawVideoPath)) {
            file = new File(transcodeVideoPath);
            viewHolder.btnShare.setVisibility(View.GONE);

            Glide.with(mActivity)
                    .loadFromMediaStore(Uri.fromFile(file))
                    .diskCacheStrategy(DiskCacheStrategy.RESULT)
                    .placeholder(R.color.dark_gray)
//                    .crossFade()
                    .into(viewHolder.videoCover);
        } else {
            file = new File(rawVideoPath);
            if (!file.exists()) {
                file = new File(transcodeVideoPath);
                viewHolder.btnShare.setVisibility(View.GONE);
            } else {
                viewHolder.btnShare.setVisibility(View.VISIBLE);
            }

//            Glide.with(mActivity)
//                    .loadFromMediaStore(Uri.fromFile(file))
//                    .transform(new TwoDirectionTransform(mActivity, LENS_NORMAL.equals(videoItem.getLensMode())))
//                    .diskCacheStrategy(DiskCacheStrategy.RESULT)
//                    .placeholder(R.color.dark_gray)
////                    .crossFade()
//                    .into(viewHolder.videoCover);

            DrawableRequestBuilder<Uri> placeholder = Glide.with(mActivity)
                    .loadFromMediaStore(Uri.fromFile(file))
                    .diskCacheStrategy(DiskCacheStrategy.RESULT)
                    .placeholder(R.color.dark_gray);

            if (getNeedDewarp(videoItem)) {
                placeholder.transform(new TwoDirectionTransform(mActivity, LENS_NORMAL.equals(videoItem.getLensMode())));
            }

            placeholder.into(viewHolder.videoCover);
        }

        DateFormat format;
        if (android.text.format.DateFormat.is24HourFormat(mActivity)) {
            format = new SimpleDateFormat("HH:mm MMMM d yyyy", Locale.getDefault());
        } else {
            format = new SimpleDateFormat("KK:mm a MMMM d yyyy", Locale.getDefault());
        }
        String timeString = format.format(videoItem.getCreateTime());

        String eventType = VideoEventType.getEventTypeForString(videoItem.getType());
        viewHolder.viewVideoType.setBackgroundResource(VideoEventType.getEventDrawable(eventType));

        viewHolder.tvVideoTime.setText(timeString);

        boolean needDewarp = getNeedDewarp(videoItem);
        int mXRadio, mYRadio;
        if (needDewarp) {
            mXRadio = 16;
            mYRadio = 9;
        } else {
            mXRadio = 32;
            mYRadio = 27;
        }
        viewHolder.mMediaWindow.setRatio(mXRadio, mYRadio);

        viewHolder.tvVideoLocation.setText(videoItem.getLocation());

        if (mSelectTag) {
            viewHolder.itemView.setOnClickListener(null);
        } else {
            File finalFile = file;
            viewHolder.itemView.setOnClickListener(view -> {
                if (!TextUtils.isEmpty(rawVideoPath) && new File(rawVideoPath).exists()) {
                    VideoPlayerActivity.launch(mActivity, rawVideoPath, "",
                            videoItem.getCreateTime(), "", videoItem.getLensMode(),
                            getNeedDewarp(videoItem), true);
                } else {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        intent.setDataAndType(FileProvider.getUriForFile(HornApplication.getContext(),
                                BuildConfig.APPLICATION_ID + ".provider", finalFile), "video/mp4");
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);//临时授权
                    } else {
                        intent.setDataAndType(Uri.fromFile(finalFile), "video/mp4");
                    }
                    //     java.lang.SecurityException: UID 10379 does not have permission to content://com.mk.autosecure.provider/storage%2Femulated%2F0/waylens/fleet/video/Fleet_2020-07-10_16-10-47.mp4 [user 0]
                    mActivity.startActivity(intent);
                }
            });
        }

        viewHolder.btnDelete.setOnClickListener(v -> showDeleteDialog(viewHolder, videoItem));

        viewHolder.btnShare.setOnClickListener(v -> showDialog(viewHolder, videoItem));
    }

    private boolean getNeedDewarp(VideoItem videoItem) {
        String general = videoItem.getGeneral();
        boolean needDewarp = true;
        if (!TextUtils.isEmpty(general)) {
            try {
                JSONObject jsonObject = new JSONObject(general);
                needDewarp = jsonObject.getBoolean(KEY_NEED_DEWARP);
            } catch (JSONException e) {
                Logger.t(TAG).e("getBoolean needDewarp error: " + e.getMessage());
            }
        }
        return needDewarp;
    }

    private void showDialog(DownloadVideoItemViewHolder viewHolder, VideoItem videoItem) {
        View view;
        if (Constants.isFleet()) {
            view = LayoutInflater.from(mActivity).inflate(R.layout.layout_album_share_fleet, null);
        } else {
            view = LayoutInflater.from(mActivity).inflate(R.layout.layout_album_share, null);
        }

        PopupWindow popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                true);

        Postcard postcard = ARouter.getInstance().build("/ui/activity/ExportActivity")
                .withString(ExportActivity.URL, videoItem.getRawVideoPath())
                .withLong(ExportActivity.CREATE_TIME, videoItem.getCreateTime())
                .withInt(ExportActivity.DURATION, (int) videoItem.getDuration())
                .withString(ExportActivity.ROTATE, videoItem.getLensMode())
                .withInt(ExportActivity.TYPE, videoItem.getType())
                .withString(ExportActivity.LOCATION, videoItem.getLocation())
                .withBoolean(Constants.isFleet() ? IntentKey.FLEET_NEED_DEWARP : ExportActivity.NEED_DEWARP, getNeedDewarp(videoItem));

        view.findViewById(R.id.ll_save_library).setOnClickListener(v -> {
            postcard.withInt(ExportActivity.CHOICE, 1).navigation();

            popupWindow.dismiss();
        });

        view.findViewById(R.id.ll_share_waylens).setOnClickListener(v -> {
            postcard.withInt(ExportActivity.CHOICE, 2).navigation();

            popupWindow.dismiss();
        });

        view.findViewById(R.id.btn_export_cancel).setOnClickListener(v -> popupWindow.dismiss());

        popupWindow.showAsDropDown(viewHolder.itemView);
    }

    private void showDeleteDialog(DownloadVideoItemViewHolder viewHolder, VideoItem videoItem) {
        View view = LayoutInflater.from(mActivity).inflate(R.layout.layout_delete_confirm, null);

        ((TextView) view.findViewById(R.id.tv_delete_tips)).setText(R.string.album_delete_tips);

        PopupWindow deletePop = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.WRAP_CONTENT,
                true);

        view.findViewById(R.id.btn_delete).setOnClickListener(v -> {

            String rawVideoPath = videoItem.getRawVideoPath();
            if (!TextUtils.isEmpty(rawVideoPath)) {
                File file = new File(rawVideoPath);
                if (file.exists()) {
                    boolean delete = file.delete();
                    Logger.t(TAG).e("RawVideo: " + delete);
                    FileUtils.callMediaScanner(file);
                }
            }

            LocalVideoDaoManager.getInstance().delete(videoItem);

            refresh();
            deletePop.dismiss();
        });

        view.findViewById(R.id.btn_delete_cancel).setOnClickListener(v -> deletePop.dismiss());

        deletePop.showAtLocation(viewHolder.itemView, Gravity.BOTTOM, 0, 0);
    }

    @Override
    public int getItemCount() {
        return mDownloadedFileList.size();
    }


    class DownloadVideoItemViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.ll_choice)
        LinearLayout llChoice;

        @BindView(R.id.cb_delete)
        CheckBox cbDelete;

        @BindView(R.id.view_video_type)
        View viewVideoType;

        @BindView(R.id.tv_video_time)
        TextView tvVideoTime;

        @BindView(R.id.tv_video_location)
        TextView tvVideoLocation;

        @BindView(R.id.media_window)
        FixedAspectRatioFrameLayout mMediaWindow;

        @BindView(R.id.video_cover)
        ImageView videoCover;

        @BindView(R.id.ll_action)
        LinearLayout llAction;

        @BindView(R.id.btn_delete)
        ImageButton btnDelete;

        @BindView(R.id.btn_share)
        ImageButton btnShare;

        @BindView(R.id.space_end)
        Space spaceEnd;

        DownloadVideoItemViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public interface NumberChangeListener {
        void onVideoNumberChanged(int count);

        void onSelectNumberChanged(int count);
    }
}
