package com.mk.autosecure.ui.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.R;
import com.mk.autosecure.model.LogSpeedWithTimeBean;

import java.util.ArrayList;
import java.util.List;

public class LogSpeedWithTimeAdapter extends RecyclerView.Adapter<LogSpeedWithTimeAdapter.ViewHolder> implements Filterable {
    private static final String TAG = LogSpeedWithTimeAdapter.class.getSimpleName();

    private List<LogSpeedWithTimeBean> speedWithTimeBeansOld;
    private List<LogSpeedWithTimeBean> speedWithTimeBeans;

    public LogSpeedWithTimeAdapter(List<LogSpeedWithTimeBean> speedWithTimeBeans) {
        this.speedWithTimeBeansOld = speedWithTimeBeans;
        this.speedWithTimeBeans = speedWithTimeBeans;
    }

    @NonNull
    @Override
    public LogSpeedWithTimeAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.item_logspeedwithtime,parent,false);
        LogSpeedWithTimeAdapter.ViewHolder viewHolder = new ViewHolder(v);
        return viewHolder;
    }

    @SuppressLint("SetTextI18n")
    @Override
    public void onBindViewHolder(@NonNull LogSpeedWithTimeAdapter.ViewHolder holder, int position) {
        LogSpeedWithTimeBean bean = speedWithTimeBeans.get(position);
        if (bean == null){
            return;
        }
        holder.tv_stt.setText(String.valueOf(position + 1));
        holder.tv_DateTime.setText(bean.getDateTime());
        holder.tv_GpsInfo.setText(bean.getLat() + ", "+bean.getLog());
        String[] speeds = bean.getSpeed();
        StringBuilder strSpeed = new StringBuilder();
        if (speeds.length != 0){
            for(String speed : speeds ){
                strSpeed.append(speed).append(", ");
            }
            holder.tv_Speed.setText(strSpeed);
        }
    }

    @Override
    public Filter getFilter() {
        return filterEx;
    }

    private Filter filterEx = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence charSequence) {
            List<LogSpeedWithTimeBean> filterList = new ArrayList<>();
            if (charSequence == null || charSequence.length() == 0) {
                filterList = speedWithTimeBeansOld;
            } else {
                String filterPattern = charSequence.toString().toLowerCase().trim();
                for (LogSpeedWithTimeBean bean : speedWithTimeBeansOld) {
                    Log.d(TAG, "filterString:= " + filterPattern);
                    if (bean.getDateTime().toLowerCase().contains(filterPattern)) {
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
            speedWithTimeBeans = (List<LogSpeedWithTimeBean>) filterResults.values;
            notifyDataSetChanged();
        }
    };

    @Override
    public int getItemCount() {
        return speedWithTimeBeans.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public TextView tv_stt;
        public TextView tv_DateTime;
        public TextView tv_GpsInfo;
        public TextView tv_Speed;

        public ViewHolder(View itemView) {
            super(itemView);
            tv_stt = itemView.findViewById(R.id.tv_stt);
            tv_DateTime = itemView.findViewById(R.id.tv_DateTime);
            tv_GpsInfo = itemView.findViewById(R.id.tv_GpsInfo);
            tv_Speed = itemView.findViewById(R.id.tv_Speed);
        }
    }
}
