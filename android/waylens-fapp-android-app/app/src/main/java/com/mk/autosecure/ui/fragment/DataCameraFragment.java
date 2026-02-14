package com.mk.autosecure.ui.fragment;

import android.view.View;
import android.widget.TextView;

import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.ui.adapter.DataCameraAdapter;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.viewmodels.fragment.DataCameraFragmentViewModel;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;

@RequiresFragmentViewModel(DataCameraFragmentViewModel.ViewModel.class)
public class DataCameraFragment extends BaseLazyLoadFragment<DataCameraFragmentViewModel.ViewModel> {

    private final static String TAG = DataCameraFragment.class.getSimpleName();

    @BindView(R.id.tv_cycle_date)
    TextView tvCycleDate;

    @BindView(R.id.tv_camera_size)
    TextView tvCameraSize;

    @BindView(R.id.rv_data_usage)
    RecyclerView rvDataUsage;

    @BindView(R.id.tv_total_usage)
    TextView tvTotalUsage;

    @BindView(R.id.tv_expected_charge)
    TextView tvExpectedCharge;

    private DataCameraAdapter cameraAdapter;

    private BillingDataBean mDataBean;

    public static DataCameraFragment newInstance() {
        return new DataCameraFragment();
    }

    @Override
    protected void onFragmentPause() {

    }

    @Override
    protected void onFragmentResume() {
        Logger.t(TAG).d("onFragmentResume: " + mDataBean);

        String cycleDate;
        String totalMbString;
        SimpleDateFormat format = new SimpleDateFormat("MMMM dd", Locale.getDefault());

        if (mDataBean != null) {
            cycleDate = String.format("%s - %s",
                    format.format(mDataBean.getCycleStartDate()),
                    format.format(mDataBean.getCycleEndDate()));

            float totalMB = 0;
            DecimalFormat decimalFormat = new DecimalFormat("0.00");

            for (BillingDataBean.CamerasBean camerasBean : mDataBean.getCameras()) {
                totalMB += camerasBean.getDataVolumeInMB();
            }
            totalMbString = decimalFormat.format(totalMB / 1024);

        } else {
            long currentTimeMillis = System.currentTimeMillis();

            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
            calendar.setTimeInMillis(currentTimeMillis);

            int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
            if (dayOfMonth == 19) {
                cycleDate = String.format("%s - %s",
                        format.format(currentTimeMillis),
                        format.format(currentTimeMillis));
            } else {
                calendar.add(Calendar.MONTH, -1);
                cycleDate = String.format("%s - %s",
                        format.format(calendar.getTimeInMillis()),
                        format.format(currentTimeMillis));
            }

            totalMbString = "0.00";
        }

        tvCycleDate.setText(cycleDate);
        tvTotalUsage.setText(totalMbString);
        tvExpectedCharge.setText(String.format("$%s", mDataBean != null ? mDataBean.getTotalCharge() : "0.00"));
        tvCameraSize.setText(String.format("%s cameras", mDataBean != null ? mDataBean.getCameras().size() : 0));

        cameraAdapter.setNewData(mDataBean != null ? mDataBean.getCameras() : new ArrayList<>());
    }

    @Override
    protected void onFragmentFirstVisible() {

    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_data_camera;
    }

    @Override
    protected void initView(View rootView) {
        Logger.t(TAG).d("initView");
        ButterKnife.bind(this, rootView);

        rvDataUsage.setLayoutManager(new LinearLayoutManager(getContext()));
        rvDataUsage.addItemDecoration(new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL));

        cameraAdapter = new DataCameraAdapter(getContext());
        rvDataUsage.setAdapter(cameraAdapter);
    }

    public void setArgs(BillingDataBean dataBean) {
        Logger.t(TAG).d("setArgs: " + dataBean);
        this.mDataBean = dataBean;
    }
}
