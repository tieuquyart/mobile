package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.R;
import com.mk.autosecure.model.LogTimeStopBean;

import java.util.List;

public class LogTimeStopAdapter extends RecyclerView.Adapter<LogTimeStopAdapter.ViewHolder> {
    private List<LogTimeStopBean> timeStopBeans;

    public LogTimeStopAdapter(List<LogTimeStopBean> timeStopBeans) {
        this.timeStopBeans = timeStopBeans;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.item_logtimestop,parent,false);
        ViewHolder viewHolder = new ViewHolder(v);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        LogTimeStopBean timeStopBean = timeStopBeans.get(position);
        if (timeStopBean == null){
            return;
        }
        holder.tv_stt.setText(String.valueOf(position + 1));
        holder.tv_timeStart.setText(timeStopBean.getTimeStart());
        holder.tv_timeFinish.setText(timeStopBean.getTimeFinish());
        holder.tv_timeStop.setText(String.valueOf(timeStopBean.getTimeStop()));
    }

    @Override
    public int getItemCount() {
        return timeStopBeans.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public TextView tv_stt;
        public TextView tv_timeStart;
        public TextView tv_timeFinish;
        public TextView tv_timeStop;

        public ViewHolder(View itemView) {
            super(itemView);
            tv_stt = itemView.findViewById(R.id.tv_stt);
            tv_timeStart = itemView.findViewById(R.id.tv_timeStart);
            tv_timeFinish = itemView.findViewById(R.id.tv_timeFinish);
            tv_timeStop = itemView.findViewById(R.id.tv_timeStop);
        }
    }
}
