package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mkgroup.camera.constant.VideoStreamType;
import com.mk.autosecure.R;
import com.mk.autosecure.ui.activity.ExportActivity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by cloud on 2020/6/17.
 */
public class StreamTypeAdapter extends RecyclerView.Adapter<StreamTypeAdapter.ViewHolder> {

    private Context mContext;

    private List<String> stringList = new ArrayList<>();

    private SparseBooleanArray checkArray = new SparseBooleanArray();

    private ExportActivity.StreamTypeChangeListener mListener;

    public StreamTypeAdapter(Context context, List<String> list, int mStreamIndex) {
        mContext = context;

        for (String string : list) {
            if ("STREAMING".equals(string)) {
                stringList.add(context.getString(R.string.mode_combined));
            } else if ("FRONT_HD".equals(string)) {
                stringList.add(context.getString(R.string.mode_road));
            } else if ("INCABIN_HD".equals(string)) {
                stringList.add(context.getString(R.string.mode_cabin));
            } else if ("DMS".equals(string)) {
                stringList.add(context.getString(R.string.mode_driver));
            }
        }
        Collections.sort(stringList, (o1, o2) -> {
            if (context.getString(R.string.mode_combined).equals(o1)) {
                return -1;
            } else if (context.getString(R.string.mode_combined).equals(o2)) {
                return 1;
            }
            return 0;
        });
        checkArray.put(0, true);
    }

    public void setStreamTypeListener(ExportActivity.StreamTypeChangeListener listener) {
        this.mListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_stream_type, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        String s = stringList.get(position);
        holder.tvStreamType.setText(s);

        if (checkArray.get(position)) {
            holder.tvStreamType.setTextColor(mContext.getResources().getColor(R.color.colorBaseFleet));
            holder.tvStreamType.setBackgroundResource(R.drawable.bg_stream_type_s);
        } else {
            holder.tvStreamType.setTextColor(mContext.getResources().getColor(R.color.colorPrimary));
            holder.tvStreamType.setBackgroundResource(R.drawable.bg_stream_type_n);
        }

        holder.itemView.setOnClickListener(v -> {
            checkArray.clear();
            checkArray.put(position, true);
            notifyDataSetChanged();

            if (mListener != null) {
                VideoStreamType streamType = VideoStreamType.valueOf("Panorama");
                if (mContext.getString(R.string.mode_combined).equals(s)) {
                    streamType = VideoStreamType.valueOf("Panorama");
                } else if (mContext.getString(R.string.mode_road).equals(s)) {
                    streamType = VideoStreamType.valueOf("Road");
                } else if (mContext.getString(R.string.mode_cabin).equals(s)) {
                    streamType = VideoStreamType.valueOf("Incab");
                } else if (mContext.getString(R.string.mode_driver).equals(s)) {
                    streamType = VideoStreamType.valueOf("Driver");
                }
                mListener.onStreamType(streamType);
            }
        });
    }

    @Override
    public int getItemCount() {
        return stringList.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {

        @BindView(R.id.tv_stream_type)
        TextView tvStreamType;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}
