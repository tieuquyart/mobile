package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mk.autosecure.R;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

public class VinMirrorActivity extends AppCompatActivity {

    private final static String TAG = VinMirrorActivity.class.getSimpleName();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, VinMirrorActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.ll_mirror_first)
    LinearLayout llMirrorFirst;

    @BindView(R.id.tv_first)
    TextView tvFirst;

    @BindView(R.id.ll_mirror_second)
    LinearLayout llMirrorSecond;

    @BindView(R.id.tv_second)
    TextView tvSecond;

    @BindView(R.id.ll_mirror_third)
    LinearLayout llMirrorThird;

    @BindView(R.id.tv_third)
    TextView tvThird;

    private EvCamera mCamera;

    private List<String> mVinMirrorList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vin_mirror);
        ButterKnife.bind(this);

        setToolbar();
        initView();
    }

    private void setToolbar() {
        ((Toolbar) (findViewById(R.id.toolbar))).setNavigationOnClickListener(v -> finish());
    }

    private void initView() {
        tvToolbarTitle.setText(R.string.vin_mirror);

        mCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
        if (mCamera != null) {
            mVinMirrorList = mCamera.getVinMirrorList();
            Logger.t(TAG).d("vinMirrorList: " + mVinMirrorList);

            tvFirst.setText(mVinMirrorList.get(0));
            tvSecond.setText(mVinMirrorList.get(1));
            tvThird.setText(mVinMirrorList.get(2));
        }

        llMirrorFirst.setOnClickListener(v -> showMirrorSettings(0));
        llMirrorSecond.setOnClickListener(v -> showMirrorSettings(1));
        llMirrorThird.setOnClickListener(v -> showMirrorSettings(2));
    }

    private void showMirrorSettings(int index) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        final String[] items = new String[]{getString(R.string.normal), getString(R.string.horz_vert)};

        String mode = mVinMirrorList.get(index);
        Logger.t(TAG).d("mode: " + mode);
        int choice = "normal".equals(mode) ? 0 : 1;

        builder.setSingleChoiceItems(items, choice, (dialog, which) -> {
            Logger.t(TAG).d("setVinMirrorList: " + which);
            String s = which == 0 ? "normal" : "horz_vert";

            if (index == 0) {
                tvFirst.setText(s);
            } else if (index == 1) {
                tvSecond.setText(s);
            } else if (index == 2) {
                tvThird.setText(s);
            }

            mVinMirrorList.set(index, s);
            mCamera.setVinMirrorList(mVinMirrorList);
            dialog.dismiss();
        });

        builder.show();
    }
}
