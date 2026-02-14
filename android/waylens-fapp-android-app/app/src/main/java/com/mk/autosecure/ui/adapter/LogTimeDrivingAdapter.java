package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.R;
import com.mk.autosecure.model.LogTimeDrivingBean;

import java.util.List;

public class LogTimeDrivingAdapter extends RecyclerView.Adapter<LogTimeDrivingAdapter.ViewHolder> {
    private List<LogTimeDrivingBean> timeDrivingBeans;

    public LogTimeDrivingAdapter(List<LogTimeDrivingBean> timeDrivingBeans) {
        this.timeDrivingBeans = timeDrivingBeans;
    }

    @NonNull
    @Override
    public LogTimeDrivingAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.item_logtimedriving,parent,false);
        LogTimeDrivingAdapter.ViewHolder viewHolder = new LogTimeDrivingAdapter.ViewHolder(v);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull LogTimeDrivingAdapter.ViewHolder holder, int position) {
        LogTimeDrivingBean timeDrivingBean = timeDrivingBeans.get(position);
        if (timeDrivingBean == null){
            return;
        }
        holder.tv_stt.setText(String.valueOf(position + 1));
        holder.tv_driverName.setText(timeDrivingBean.getDriverName());
        holder.tv_timeStart.setText(timeDrivingBean.getTimeStart());
        holder.tv_timeFinish.setText(timeDrivingBean.getTimeFinish());
        holder.tv_timeStop.setText(String.valueOf(timeDrivingBean.getTimeDriving()));
    }

    @Override
    public int getItemCount() {
        return timeDrivingBeans.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public TextView tv_stt;
        public TextView tv_driverName;
        public TextView tv_timeStart;
        public TextView tv_timeFinish;
        public TextView tv_timeStop;

        public ViewHolder(View itemView) {
            super(itemView);
            tv_stt = itemView.findViewById(R.id.tv_stt);
            tv_driverName = itemView.findViewById(R.id.tv_driverName);
            tv_timeStart = itemView.findViewById(R.id.tv_timeStart);
            tv_timeFinish = itemView.findViewById(R.id.tv_timeFinish);
            tv_timeStop = itemView.findViewById(R.id.tv_timeStop);
        }
    }
}
