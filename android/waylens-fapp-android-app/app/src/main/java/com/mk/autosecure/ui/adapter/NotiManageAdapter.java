package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Typeface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

@SuppressLint({"NotifyDataSetChanged", "SetTextI18n"})
public class NotiManageAdapter extends RecyclerView.Adapter<NotiManageAdapter.NotiManagerViewHolder> implements Filterable {
    public static final String TAG = NotiManageAdapter.class.getSimpleName();

    ArrayList<NotificationBean> listNotification = new ArrayList<>();
    ArrayList<NotificationBean> listNotificationOld = new ArrayList<>();

    WeakReference<Context> mReference;

    onNotiItemClickListener listener;

    public void setListener(onNotiItemClickListener listener) {
        this.listener = listener;
    }

    public NotiManageAdapter(Context context) {
        this.mReference = new WeakReference<>(context);
    }

    synchronized public void setListNotification(ArrayList<NotificationBean> listBean) {
        listNotification.clear();
        listNotificationOld.clear();
        listNotification.addAll(listBean);
        listNotificationOld.addAll(listBean);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public NotiManagerViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_notification, parent, false);
        return new NotiManagerViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull NotiManagerViewHolder holder, int position) {
        onBindNotification(holder, position);
    }

    private void onBindNotification(NotiManagerViewHolder viewHolder, int position) {
        NotificationBean bean = listNotification.get(position);
        if (bean != null) {
            initUnread(viewHolder, bean.getMarkRead());
            Logger.t(TAG).d("beanNoti: " + bean.getCategory());
            viewHolder.tvAlert.setText("Thông báo sự kiện " + VideoEventType.dealCategory(mReference.get(), bean.getCategory()));
//            viewHolder.tvPlateNo.setVisibility((bean.getPlateNo() != null && !bean.getPlateNo().isEmpty()) ? View.VISIBLE : View.GONE);
//            viewHolder.tvPlateNo.setText((bean.getPlateNo() != null && !bean.getPlateNo().isEmpty()) ? "Biển số xe: " + bean.getPlateNo() : "");
            viewHolder.tvPlateNo.setVisibility(View.VISIBLE);
            viewHolder.tvPlateNo.setText(showWithCategory(bean));

            Logger.t(TAG).d("eventType: " +bean.getEventType());
            initStatus(viewHolder.tvStatus, VideoEventType.dealEventType(mReference.get(), bean.getEventType()));
            viewHolder.tvEventTime.setText(!StringUtils.isEmpty(bean.getEventTime()) ? bean.getEventTime().replace("T"," ") : "");
            viewHolder.itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onClickNoti(bean);
                }
            });

            viewHolder.imageView.setImageResource(bean.getCategory().equals("PAYMENT") || bean.getCategory().equals("ACCOUNT") ? R.drawable.avatar_n : R.drawable.icon_vehicle);
        }
    }

    private String showWithCategory(NotificationBean bean) {
        String category = bean.getCategory();
        if ("ACCOUNT".equals(category)) {
            return (bean.getEventType().equals("SIMCARDINFOCHANGED") || bean.getEventType().equals("CAMERATILTED_CHECKORIENTATION")) ? "Số seri: " + bean.getCameraSn() : "Tài khoản: " + bean.getAccountName();
        } else if ("PAYMENT".equals(category)) {
            return "Sản phẩm: " + bean.getSubscriptionName();
        } else {
            return "Biển số: " + bean.getPlateNo();
        }
    }

    @SuppressLint("NewApi")
    private void initStatus(TextView textView, String e) {
        if (StringUtils.isEmpty(e)) {
            textView.setVisibility(View.GONE);
            return;
        }
        textView.setText(VideoEventType.dealEventType(mReference.get(), e));
        String event = e.toLowerCase(Locale.ROOT);

        if (event.contains("thành công") || event.contains("đăng nhập") || event.contains("đăng xuất") || event.contains("lái xe")) {
            textView.setTextColor(mReference.get().getColor(R.color.color_txt_success));
            textView.setBackgroundResource(R.drawable.border_status_success);
        } else if (event.contains("lỗi") || event.contains("thất bại")) {
            textView.setTextColor(mReference.get().getColor(R.color.color_txt_failure));
            textView.setBackgroundResource(R.drawable.border_status_err);
        } else {
            textView.setTextColor(mReference.get().getColor(R.color.color_txt_warning));
            textView.setBackgroundResource(R.drawable.border_status_warning);
        }
    }

    private void initUnread(NotiManagerViewHolder holder, boolean markRead) {
        if (markRead) {
            holder.tvAlert.setTypeface(Typeface.DEFAULT);
//            holder.tvCategory.setTypeface(Typeface.DEFAULT);
            holder.tvPlateNo.setTypeface(Typeface.DEFAULT);
            holder.llUnread.setVisibility(View.GONE);
        } else {
            holder.llUnread.setVisibility(View.VISIBLE);
            holder.tvPlateNo.setTypeface(holder.tvPlateNo.getTypeface(), Typeface.BOLD);
            holder.tvAlert.setTypeface(holder.tvAlert.getTypeface(), Typeface.BOLD);
//            holder.tvCategory.setTypeface(holder.tvAlert.getTypeface(), Typeface.BOLD);
        }
        holder.tvEventTime.setTypeface(Typeface.DEFAULT);
    }

    @Override
    public int getItemCount() {
        return listNotification.size();
    }

    @Override
    public Filter getFilter() {
        return filterCategory;
    }

    public void refreshData() {
        listNotification.clear();
        listNotification = listNotificationOld;
        notifyDataSetChanged();
    }

    private Filter filterCategory = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence charSequence) {
            List<NotificationBean> filterList = new ArrayList<>();
            if (charSequence == null || charSequence.length() == 0) {
                filterList = listNotificationOld;
            } else {
                String filterPattern = charSequence.toString().toLowerCase().trim();
                for (NotificationBean bean : listNotificationOld) {
                    Log.d(TAG, "filterString:= " + filterPattern);
                    if ("ALL".toLowerCase().contains(filterPattern)) {
                        filterList.add(bean);
                    } else if (bean.getCategory().toLowerCase().contains(filterPattern)) {
                        filterList.add(bean);
                    }

                }
            }

            FilterResults results = new FilterResults();
            results.values = filterList;
            Log.d(TAG, filterList.toString());
            return results;
        }

        @Override
        protected void publishResults(CharSequence charSequence, FilterResults filterResults) {
            listNotification = (ArrayList<NotificationBean>) filterResults.values;
            notifyDataSetChanged();
        }
    };

    static class NotiManagerViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tvAlert)
        TextView tvAlert;

        @BindView(R.id.imgAvatar)
        ImageView imageView;

        @BindView(R.id.tvEventTime)
        TextView tvEventTime;

        @BindView(R.id.tvPlateNo)
        TextView tvPlateNo;

        @BindView(R.id.llUnread)
        RelativeLayout llUnread;

        @BindView(R.id.tvStatus)
        TextView tvStatus;

        public NotiManagerViewHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

    public interface onNotiItemClickListener {
        void onClickNoti(NotificationBean bean);
    }
}
