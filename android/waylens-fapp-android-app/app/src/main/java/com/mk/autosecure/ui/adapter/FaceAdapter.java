package com.mk.autosecure.ui.adapter;

import android.view.View;
import android.widget.TextView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.mkgroup.camera.model.dms.FaceList;
import com.mk.autosecure.R;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by cloud on 2021/2/7.
 */
public class FaceAdapter extends BaseQuickAdapter<FaceList.FaceItem, FaceAdapter.FaceViewHolder> {

    private final static String TAG = FaceAdapter.class.getSimpleName();

    private FaceOperationListener mListener;

    public FaceAdapter() {
        super(R.layout.item_face_info);
    }

    public void setOperationListener(FaceOperationListener listener) {
        this.mListener = listener;
    }

    @Override
    protected void convert(FaceViewHolder helper, FaceList.FaceItem item) {
        helper.tvFaceId.setText(String.format("id: %s", item.faceID));
        helper.tvFaceName.setText(String.format("name: %s", item.name));

        helper.itemView.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onItemRemove(item);
            }
        });
    }

    static class FaceViewHolder extends BaseViewHolder {

        @BindView(R.id.tv_face_id)
        TextView tvFaceId;

        @BindView(R.id.tv_face_name)
        TextView tvFaceName;

        public FaceViewHolder(View view) {
            super(view);
            ButterKnife.bind(this, view);
        }
    }

    public interface FaceOperationListener {
        void onItemRemove(FaceList.FaceItem faceItem);
    }
}
