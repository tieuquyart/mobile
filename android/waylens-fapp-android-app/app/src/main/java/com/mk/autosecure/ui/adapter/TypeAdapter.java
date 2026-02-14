package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.graphics.Color;

import androidx.annotation.Nullable;

import android.view.View;
import android.widget.CheckBox;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.bean.VideoType;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by doanvt on 2018/12/26.
 * Email：doanvt-hn@mk.com.vn
 */

public class TypeAdapter extends BaseQuickAdapter<VideoType, TypeAdapter.TypeViewHolder> {

    private final static String TAG = TypeAdapter.class.getSimpleName();

    private Context mContext;

    public TypeAdapter(Context context, int layoutResId, @Nullable List<VideoType> data) {
        super(layoutResId, data);
        this.mContext = context;
    }

    @Override
    protected void convert(TypeViewHolder helper, VideoType item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(TypeViewHolder helper, VideoType item) {
        Logger.t(TAG).d("onBindViewHolder: " + item.toString());
        helper.cb_type.setBackgroundResource(item.getIcon());
        String event = item.getEvent();
        helper.tv_type.setText(event);

        helper.addOnClickListener(R.id.cb_type);

        helper.cb_type.setOnCheckedChangeListener((buttonView, isChecked) -> {
            item.setSelected(isChecked);

            if (mContext.getString(R.string.motion).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#EDD655"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            } else if (mContext.getString(R.string.bump).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#F3A92F"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            } else if (mContext.getString(R.string.impact).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#EB5A43"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            } else if (mContext.getString(R.string.video_type_highlight).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#1C6EF0"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            } else if (mContext.getString(R.string.video_type_buffered).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            } else if (mContext.getString(R.string.behavior).equals(event)) {
                if (isChecked) {
                    helper.tv_type.setTextColor(Color.parseColor("#C671CA"));
                } else {
                    helper.tv_type.setTextColor(Color.parseColor("#D6D9DD"));
                }
            }
        });
    }

    static class TypeViewHolder extends BaseViewHolder {

        @BindView(R.id.cb_type)
        CheckBox cb_type;

        @BindView(R.id.tv_type)
        TextView tv_type;

        public TypeViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }

        @Override
        protected void finalize() throws Throwable {
            super.finalize();
        }
    }
}
