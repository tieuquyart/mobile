package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.mk.autosecure.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import butterknife.BindView;
import butterknife.ButterKnife;


public class DriverFilterAdapter extends BaseAdapter {

    private Context context;
    private List<String> list;
    private Map<String, Boolean> map;

    public void setCheckItem(int position) {
        String s = list.get(position);
        Boolean status = map.get(s);
        map.put(s, !status);
        notifyDataSetChanged();
    }

    public List<String> getNameList() {
        List<String> tempList = new ArrayList<>();
        for (Map.Entry<String, Boolean> next : map.entrySet()) {
            if (next.getValue()) {
                tempList.add(next.getKey());
            }
        }
        return tempList;
    }

    public void clearDriver() {
        for (String next : map.keySet()) {
            map.put(next, false);
        }
        notifyDataSetChanged();
    }

    public DriverFilterAdapter(Context context, List<String> list) {
        this.context = context;
        this.list = list;
        map = new HashMap<>();
        for (String string : list) {
            map.put(string, false);
        }
    }

    public void setNewData(List<String> list) {
        this.list = list;
        for (String string : list) {
            map.put(string, false);
        }
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
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
            convertView = LayoutInflater.from(context).inflate(R.layout.item_driver_filter, null);
            viewHolder = new ViewHolder(convertView);
            convertView.setTag(viewHolder);
        }
        fillValue(position, viewHolder);
        return convertView;
    }

    private void fillValue(int position, ViewHolder viewHolder) {
        viewHolder.mText.setText(list.get(position));
        if (map.get(list.get(position))) {
            viewHolder.mText.setTextColor(context.getResources().getColor(R.color.colorBaseFleet));
            viewHolder.mText.setBackgroundResource(R.color.colorBackgroundWhite);
        } else {
            viewHolder.mText.setTextColor(context.getResources().getColor(R.color.colorPrimary));
            viewHolder.mText.setBackgroundResource(R.color.white);
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
