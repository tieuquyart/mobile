package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.bean.Notifications;
import com.mk.autosecure.ui.fragment.AlertsFragment;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

public class MessageAdapter extends BaseQuickAdapter<Notifications, MessageAdapter.MessageViewHolder> {

    private final static String TAG = MessageAdapter.class.getSimpleName();

    private final static int spaceTime = 1500;

    private WeakReference<Context> mReference;

    private AlertsFragment.MessageOperationListener mListener;

    private long lastClickTime = 0;

    public MessageAdapter(Context context) {
        super(R.layout.item_message);
        mReference = new WeakReference<>(context);
    }

    public void setMessageOperationListener(AlertsFragment.MessageOperationListener listener) {
        mListener = listener;
    }

    @Override
    protected void convert(MessageViewHolder helper, Notifications item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(MessageViewHolder holder, Notifications item) {
        Boolean read = item.isRead();
        if (read != null && read) {
            holder.tvMsgTitle.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
        } else {
            holder.tvMsgTitle.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
        }

        Long createTime = item.getCreateTime();
        if (createTime != null) {
            transform(holder, createTime);
        }

        Notifications.NotificationContent content = item.getContent();
        if (content != null) {
            String titleLocKey = content.getTitleLocKey();
            String bodyLocKey = content.getBodyLocKey();
//            Logger.t(TAG).e("titleLocKey: " + titleLocKey + " bodyLocKey: " + bodyLocKey);
            if (!TextUtils.isEmpty(titleLocKey) && !TextUtils.isEmpty(bodyLocKey)) {
                try {
                    Context context = mReference.get();

                    int titleIdentifier = context.getResources().getIdentifier(titleLocKey, "string", context.getPackageName());
                    holder.tvMsgTitle.setText(titleIdentifier);

                    int bodyIdentifier = context.getResources().getIdentifier(bodyLocKey, "string", context.getPackageName());
                    holder.tvMsgDescribe.setText(context.getString(bodyIdentifier, content.getBodyLocArgs().toArray()));
                } catch (Exception ex) {
                    Logger.t(TAG).e("getIdentifier exception: " + ex.getMessage());
                }
            } else {
                holder.tvMsgTitle.setText(content.getTitle());
                holder.tvMsgDescribe.setText(content.getBody());
            }

            String image = content.getImage();
            if (TextUtils.isEmpty(image)) {
                Glide.with(mReference.get())
                        .load(R.drawable.bg_single_thumbnail)
                        .error(R.drawable.bg_single_thumbnail)
                        .into(holder.ivMsgThumbnail);
            } else {
                Glide.with(mReference.get())
                        .load(image)
                        .diskCacheStrategy(DiskCacheStrategy.ALL)
                        .placeholder(R.drawable.bg_single_thumbnail)
                        .error(R.drawable.bg_single_thumbnail)
                        .into(holder.ivMsgThumbnail);
            }
        }

        holder.itemView.setOnClickListener(v -> {
            long currentTimeMillis = System.currentTimeMillis();
            if (currentTimeMillis - lastClickTime < spaceTime) {
                return;
            } else {
                lastClickTime = currentTimeMillis;
            }

            if (mListener != null) {
                mListener.markReaded(item);
            }
        });
    }

    private void transform(MessageViewHolder holder, long createTime) {
        long currentTimeMillis = System.currentTimeMillis();
        long l = currentTimeMillis - createTime;
//        Logger.t(TAG).e("currentTimeMillis - createTime: " + l / 1000);

        if (l <= 60 * 1000) {
            holder.tvMsgDate.setText(R.string.one_minute_ago);
        } else if (l <= 3600 * 1000) {
            holder.tvMsgDate.setText(mReference.get().getString(R.string.minutes_ago, l / 60 / 1000));
        } else if (l <= 3600 * 1000 * 2) {
            holder.tvMsgDate.setText(R.string.one_hour_ago);
        } else if (l <= 3600 * 1000 * 24) {
            holder.tvMsgDate.setText(mReference.get().getString(R.string.hours_ago, l / 3600 / 1000));
        } else {
            boolean isZh = Locale.getDefault().getLanguage().equals("zh");
//            Logger.t(TAG).d("isZh: " + isZh + "--" + Locale.getDefault().getLanguage());
            SimpleDateFormat format = new SimpleDateFormat(isZh ? "yyyy, MMM d" : "MMM d, yyyy", Locale.getDefault());
            holder.tvMsgDate.setText(format.format(new Date(createTime)));
        }
    }

    static public class MessageViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_msg_title)
        TextView tvMsgTitle;

        @BindView(R.id.tv_msg_describe)
        TextView tvMsgDescribe;

        @BindView(R.id.tv_msg_date)
        TextView tvMsgDate;

        @BindView(R.id.iv_msg_thumbnail)
        ImageView ivMsgThumbnail;

        public MessageViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }
}
