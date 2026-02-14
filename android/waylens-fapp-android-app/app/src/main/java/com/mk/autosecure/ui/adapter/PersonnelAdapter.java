package com.mk.autosecure.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mk.autosecure.R;
import com.mk.autosecure.rest_fleet.bean.UsersBean;
import com.mk.autosecure.ui.activity.settings.PersonnelActivity;

import java.lang.ref.WeakReference;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

public class PersonnelAdapter extends BaseQuickAdapter<UsersBean, PersonnelAdapter.PersonnelViewHolder> {

    private final static String TAG = PersonnelAdapter.class.getSimpleName();

    private WeakReference<Context> mReference;

    private PersonnelActivity.OperationListener mListener;

    public PersonnelAdapter(Context context) {
        super(R.layout.item_personnel);
        mReference = new WeakReference<>(context);
    }

    public void setOperationListener(PersonnelActivity.OperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(PersonnelViewHolder helper, UsersBean item) {
        onBindViewHolder(helper, item);
    }

    private void onBindViewHolder(PersonnelViewHolder holder, UsersBean bean) {
        holder.tvUserName.setText((bean.getUserName() != null && bean.getUserName() != "") ? bean.getUserName() : bean.getRealName());

            holder.ivNextEdit.setVisibility(View.VISIBLE);
            holder.tvUserStatus.setVisibility(View.GONE);
            holder.tvUserStatus.setBackgroundResource(R.drawable.background_not_verified);

        List<String> role = bean.getRoleNames();
        if (role != null && role.size() > 0) {
            holder.tvUserRole.setText(role.get(0));
        } else {
            holder.tvUserRole.setText("");
        }

        holder.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onClickItem(bean);
            }
        });
    }

    public class PersonnelViewHolder extends BaseViewHolder {

        @BindView(R.id.iv_user_avatar)
        ImageView ivUserAvatar;

        @BindView(R.id.tv_user_name)
        TextView tvUserName;

        @BindView(R.id.tv_user_status)
        TextView tvUserStatus;

        @BindView(R.id.tv_user_role)
        TextView tvUserRole;

        @BindView(R.id.iv_next_edit)
        ImageView ivNextEdit;

        public PersonnelViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }
}
