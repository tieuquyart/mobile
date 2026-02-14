package com.mk.autosecure.ui.adapter;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.tubb.smrv.SwipeHorizontalMenuLayout;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.FenceListBean;
import com.mk.autosecure.ui.activity.settings.DraftBoxActivity;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by cloud on 2020/5/13.
 */
public class FenceListAdapter extends BaseQuickAdapter<FenceListBean, FenceListAdapter.FenceViewHolder> {

    private DraftBoxActivity.FenceOperationListener mListener;

    public FenceListAdapter(int layoutResId) {
        super(layoutResId);
    }

    public void setOperationListener(DraftBoxActivity.FenceOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(FenceViewHolder helper, FenceListBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(FenceViewHolder helper, FenceListBean item) {
        helper.tvFenceName.setText(item.getName());

        if (helper.sml.isSwipeEnable()) {
            helper.sml.smoothCloseEndMenu();
        }

        helper.llDelete.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onDeleteItem(item);
            }
            helper.sml.smoothCloseEndMenu();
        });

        helper.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(item);
            }
        });
    }

    public static class FenceViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_fence_name)
        TextView tvFenceName;

        @BindView(R.id.sml)
        SwipeHorizontalMenuLayout sml;

        @BindView(R.id.ll_delete)
        LinearLayout llDelete;

        public FenceViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
