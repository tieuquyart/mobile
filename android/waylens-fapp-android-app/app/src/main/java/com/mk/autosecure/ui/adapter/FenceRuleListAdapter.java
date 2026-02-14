package com.mk.autosecure.ui.adapter;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.ui.activity.settings.GeoFenceActivity;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by cloud on 2020/5/13.
 */
public class FenceRuleListAdapter extends BaseQuickAdapter<FenceRuleBean, FenceRuleListAdapter.FenceViewHolder> {

    private GeoFenceActivity.FenceOperationListener mListener;

    public FenceRuleListAdapter(int layoutResId) {
        super(layoutResId);
    }

    public void setOperationListener(GeoFenceActivity.FenceOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(FenceViewHolder helper, FenceRuleBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(FenceViewHolder helper, FenceRuleBean item) {
        List<String> type = item.getType();
        int resId = R.drawable.icon_enter_exit;
        String mode = "";
        if (type != null) {
            if (type.size() == 2) {
                resId = R.drawable.icon_enter_exit;
                mode = "Enter and Exit";
            } else if (type.contains("enter")) {
                resId = R.drawable.icon_enter;
                mode = "Enter";
            } else if (type.contains("exit")) {
                resId = R.drawable.icon_exit;
                mode = "Exit";
            }
            helper.tvFenceDesc.setText(String.format("Trigger mode: %s", mode));
        }
        helper.ivFenceRule.setImageResource(resId);
        helper.tvFenceName.setText(item.getName());
        helper.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(item);
            }
        });
    }

    public static class FenceViewHolder extends BaseViewHolder {

        @BindView(R.id.iv_fence_rule)
        ImageView ivFenceRule;

        @BindView(R.id.tv_fence_name)
        TextView tvFenceName;

        @BindView(R.id.tv_fence_description)
        TextView tvFenceDesc;

        public FenceViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
