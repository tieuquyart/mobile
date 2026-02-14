package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.ui.adapter.LogTimeDrivingAdapter;
import com.mk.autosecure.ui.adapter.LogTimeStopAdapter;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.model.LogTimeDrivingBean;
import com.mk.autosecure.model.LogTimeStopBean;

import java.io.Serializable;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;

public class ViewLogActivity extends RxActivity{
    private List<LogTimeStopBean> timeStopBeans;
    private List<LogTimeDrivingBean> timeDrivingBeans;

    @BindView(R.id.mRecyclerView)
    RecyclerView mRecyclerView;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.tvTotalTimeStop)
    TextView tvTotalTimeStop;

    @BindView(R.id.ll_title)
    LinearLayout llTitleTimeStop;

    @BindView(R.id.ll_titleTimeDriving)
    LinearLayout llTitleTimeDriving;

    private LogTimeStopAdapter adapterTimeStop;
    private LogTimeDrivingAdapter adapterTimeDriving;

    ReportLogActivity.TYPELOG typelog;

    public static void launchTimeStop(Activity activity, List<LogTimeStopBean> beans, ReportLogActivity.TYPELOG type) {
        Intent intent = new Intent(activity, ViewLogActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.putExtra("LogTimeStop", (Serializable) beans);
        intent.putExtra("Type",type);
        activity.startActivity(intent);
    }

    public static void launchTimeDriving(Activity activity, List<LogTimeDrivingBean> beans, ReportLogActivity.TYPELOG type) {
        Intent intent = new Intent(activity, ViewLogActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.putExtra("LogTimeDriving", (Serializable) beans);
        intent.putExtra("Type",type);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_log);
        ButterKnife.bind(this);
        setupToolbar();
        if(getIntent() != null){
            timeStopBeans = (List<LogTimeStopBean>) getIntent().getSerializableExtra("LogTimeStop");
            timeDrivingBeans = (List<LogTimeDrivingBean>) getIntent().getSerializableExtra("LogTimeDriving");
            typelog = (ReportLogActivity.TYPELOG) getIntent().getSerializableExtra("Type");
        }

        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));

        if (timeStopBeans != null && typelog == ReportLogActivity.TYPELOG.DEFAULT){

            tvToolbarTitle.setText(getResources().getString(R.string.time_stop_title));
            double totalTimeStop = 0;
            for (LogTimeStopBean bean : timeStopBeans){
                totalTimeStop += bean.getTimeStop();
            }
            tvTotalTimeStop.setText(getString(R.string.total_time_stop, String.valueOf(Math.floor(totalTimeStop * 100)/100)));
            llTitleTimeStop.setVisibility(View.VISIBLE);
            llTitleTimeDriving.setVisibility(View.GONE);
            adapterTimeStop = new LogTimeStopAdapter(timeStopBeans);
            mRecyclerView.setAdapter(adapterTimeStop);
        }else if(timeDrivingBeans != null && typelog == ReportLogActivity.TYPELOG.TIME_DRIVING){

            tvToolbarTitle.setText(getResources().getString(R.string.time_driving_title));
            double totalTimeDriving = 0;
            for (LogTimeDrivingBean bean : timeDrivingBeans){
                totalTimeDriving += bean.getTimeDriving();
            }
            tvTotalTimeStop.setText(getString(R.string.total_time_driving, String.valueOf(Math.floor(totalTimeDriving * 100)/100)));
            adapterTimeDriving = new LogTimeDrivingAdapter(timeDrivingBeans);
            mRecyclerView.setAdapter(adapterTimeDriving);
            llTitleTimeStop.setVisibility(View.GONE);
            llTitleTimeDriving.setVisibility(View.VISIBLE);
        }
    }


    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
    }

}