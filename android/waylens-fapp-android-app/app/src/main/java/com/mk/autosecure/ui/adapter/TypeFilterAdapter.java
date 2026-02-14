package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.mk.autosecure.R;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;


public class TypeFilterAdapter extends BaseAdapter {

    private Context context;
    private List<String> dataList;
    private List<Boolean> statusList;

    public void setCheckItem(int position) {
        statusList.set(position, !statusList.get(position));
        notifyDataSetChanged();
    }

    public List<Boolean> getStatusList() {
        return statusList;
    }

    public int getStatusCount() {
        int count = 0;
        for (Boolean status : statusList) {
            if (status) {
                count++;
            }
        }
        return count;
    }

    public void clearStatus() {
        for (int i = 0; i < statusList.size(); i++) {
            statusList.set(i, false);
        }
        notifyDataSetChanged();
    }

    public TypeFilterAdapter(Context context, List<String> dataList) {
        this.context = context;
        this.dataList = dataList;
        statusList = new ArrayList<>();
        for (int i = 0; i < dataList.size(); i++) {
            statusList.add(i, false);
        }
    }

    @Override
    public int getCount() {
        return dataList.size();
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder viewHolder;
        if (convertView != null) {
            viewHolder = (ViewHolder) convertView.getTag();
        } else {
            convertView = LayoutInflater.from(context).inflate(R.layout.item_type_filter, null);
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        }
        fillValue(position, viewHolder);
        return convertView;
    }

    private void fillValue(int position, ViewHolder viewHolder) {
        viewHolder.mText.setText(dataList.get(position));
        if (statusList.get(position)) {
            viewHolder.mText.setTextColor(context.getResources().getColor(R.color.colorBaseFleet));
            viewHolder.mText.setBackgroundResource(R.drawable.bg_check_filter);
        } else {
            viewHolder.mText.setTextColor(context.getResources().getColor(R.color.colorPrimary));
            viewHolder.mText.setBackgroundResource(R.drawable.bg_uncheck_filter);
        }
    }

    static class ViewHolder {
        @BindView(R.id.text)
        TextView mText;

        ViewHolder(View view) {
            ButterKnife.bind(this, view);
        }
    }
}
