package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.alibaba.android.arouter.launcher.ARouter;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;
import com.github.mikephil.charting.listener.OnChartValueSelectedListener;
import com.mk.autosecure.ui.adapter.DashDriverAdapter;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.DayAxisValueFormatter;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.libs.utils.XDatePickerDialog;
import com.mk.autosecure.libs.utils.XYMarkerView;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.DriverStatusReportResponse;
import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.rest_fleet.bean.EventListBean;
import com.mk.autosecure.rest_fleet.bean.HoursListBean;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.viewmodels.fragment.DashDriverViewModel;

import net.lucode.hackware.magicindicator.MagicIndicator;
import net.lucode.hackware.magicindicator.buildins.UIUtil;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.CommonNavigatorAdapter;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerTitleView;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.indicators.LinePagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.CommonPagerTitleView;

import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.subjects.PublishSubject;

@RequiresFragmentViewModel(DashDriverViewModel.ViewModel.class)
public class DashDriverFragment extends BaseLazyLoadFragment<DashDriverViewModel.ViewModel>
        implements XDatePickerDialog.OnDateSetListener, OnChartValueSelectedListener {

    private final static String TAG = DashDriverFragment.class.getSimpleName();

    private final static int[] TYPES = new int[]{R.string.miles, R.string.hours, R.string.events};

    @BindView(R.id.refresh_driver_layout)
    SwipeRefreshLayout refreshDriverLayout;

    @BindView(R.id.ll_dash_driver)
    LinearLayout llDashDriver;

    @BindView(R.id.tv_date_picker)
    TextView tvDatePicker;

    @BindView(R.id.magic_indicator)
    MagicIndicator magicIndicator;

    @BindView(R.id.lineChart)
    LineChart lineChart;

    @BindView(R.id.rv_dash_driver)
    RecyclerView rvDashDriver;

    @OnClick(R.id.ll_date_picker)
    void datePicker() {
        Calendar from = DashboardUtil.getCalendar(mTimeZone, fromUtcDateTime);
        Calendar to = DashboardUtil.getCalendar(mTimeZone, toUtcDateTime);

        XDatePickerDialog dialog = XDatePickerDialog.newInstance(this,
                from.get(Calendar.YEAR), from.get(Calendar.MONTH), from.get(Calendar.DAY_OF_MONTH),
                to.get(Calendar.YEAR), to.get(Calendar.MONTH), to.get(Calendar.DAY_OF_MONTH));

        Calendar minCalendar = DashboardUtil.getCalendar(mTimeZone, minUtcDateTime);
        Calendar maxCalendar = DashboardUtil.getCalendar(mTimeZone, maxUtcDateTime);

        dialog.setMinDate(minCalendar);
        dialog.setMaxDate(maxCalendar);

        dialog.vibrate(false);
        dialog.setAutoHighlight(true);
        dialog.show(getChildFragmentManager(), "XDatePickerDialog");
    }

    private long fromUtcDateTime, toUtcDateTime, minUtcDateTime, maxUtcDateTime;

    private int driverID;

    private String cameraSn;

    private String driverName;

    private String plateNumber;

    private SimpleDateFormat dateFormat;

    private TimeZone mTimeZone;

    private int currentDash = 0;

    private TextView tvDashMiles, tvDashHours, tvDashEvents;

    private DayAxisValueFormatter valueFormatter;

    private XYMarkerView markerView;

    private List<HoursListBean> hoursBeanList = new ArrayList<>();
    private List<EventListBean> eventsBeanList = new ArrayList<>();
    private List<HoursListBean> milesBeanList = new ArrayList<>();

    private DriverStatusReportResponse.Data dataBean;

    private PublishSubject<Throwable> networkError = PublishSubject.create();

    private DashDriverAdapter mDriverAdapter;

    private LineDataSet lineDataSet;

    public static DashDriverFragment newInstance() {
        return new DashDriverFragment();
    }

    void setArgs(int driverID, String cameraSn, long fromDateTime, long toDateTime, String driverName, String plateNumber) {
        this.driverID = driverID;
        this.fromUtcDateTime = fromDateTime;
        this.toUtcDateTime = toDateTime;
        this.driverName = driverName;
        this.plateNumber = plateNumber;
        this.cameraSn = cameraSn;
    }

    @Override
    public void onValueSelected(Entry e, Highlight h) {
    }

    @Override
    public void onNothingSelected() {
    }

    @Override
    protected void onFragmentPause() {
    }

    @Override
    protected void onFragmentResume() {
        Logger.t(TAG).d("onFragmentResume");
        tvDatePicker.setText(String.format("%s to %s",
                dateFormat.format(new Date(fromUtcDateTime)),
                dateFormat.format(new Date(toUtcDateTime))));

        valueFormatter.setDateTime(fromUtcDateTime, toUtcDateTime);

        enterLoadStatus();

        viewModel.inputQueryTime(driverID, dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime)));
        viewModel.queryStatusReportWithDriverId();

        XDatePickerDialog dpd = (XDatePickerDialog) getChildFragmentManager().findFragmentByTag("XDatePickerDialog");
        if (dpd != null) dpd.setOnDateSetListener(this);
    }

    @Override
    protected void onFragmentFirstVisible() {
        lineChart.animateX(1500);
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_dashboard_driver;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        refreshDriverLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            viewModel.queryStatusReportWithDriverId();
        });

//        UserLogin userLogin = viewModel.getCurrentUser().getUserLogin();
        mTimeZone =  TimeZone.getDefault();

        toUtcDateTime = maxUtcDateTime = System.currentTimeMillis();
        fromUtcDateTime = Math.max(DashboardUtil.getZeroFromTime(14, toUtcDateTime), 0);
        minUtcDateTime = Math.max(DashboardUtil.getZeroFromTime(90, toUtcDateTime), 0);

        dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        dateFormat.setTimeZone(mTimeZone);

        mDriverAdapter = new DashDriverAdapter(getContext());
        rvDashDriver.setAdapter(mDriverAdapter);
        rvDashDriver.setLayoutManager(new LinearLayoutManager(getContext()));
        rvDashDriver.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, ViewUtils.dp2px(16));
            }
        });

        mDriverAdapter.setOperationListener(bean -> {
            Logger.t(TAG).d("onClick: " + bean);
            ARouter.getInstance().build("/ui/activity/TimelineActivity")
                    .withString(IntentKey.FLEET_CAMERA_SN, cameraSn)
                    .withString(IntentKey.FLEET_DRIVER_NAME, driverName)
                    .withString(IntentKey.FLEET_PLATE_NUMBER, plateNumber)
                    .withString(IntentKey.FLEET_FROM_TIME, bean.getSummaryTime())
                    .navigation();
        });

        initMagic();
        initChart();
        initEvent();
    }

    @Override
    public void onDateSet(XDatePickerDialog view, int year, int monthOfYear, int dayOfMonth, int yearEnd, int monthOfYearEnd, int dayOfMonthEnd) {
        String from = year + "-" + (++monthOfYear) + "-" + dayOfMonth;
        String to = yearEnd + "-" + (++monthOfYearEnd) + "-" + dayOfMonthEnd;
        Logger.t(TAG).d("onDateSet: " + from + " " + to);

        try {
            fromUtcDateTime = dateFormat.parse(from).getTime();
            toUtcDateTime = DashboardUtil.getEndTime(1, dateFormat.parse(to).getTime());

            tvDatePicker.setText(String.format("%s to %s",
                    dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime))));

            valueFormatter.setDateTime(fromUtcDateTime, toUtcDateTime);

            lineDataSet.setLabel(DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));

            enterLoadStatus();

            viewModel.inputQueryTime(driverID, dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime)));
            viewModel.queryStatusReportWithDriverId();
        } catch (ParseException e) {
            Logger.t(TAG).e("onDateSet ParseException: " + e.getMessage());
        }
    }

    private void initChart() {
        lineChart.setOnChartValueSelectedListener(this);

//        lineChart.setDrawBarShadow(false);
        lineChart.setDoubleTapToZoomEnabled(false);
//        lineChart.setDrawValueAboveBar(false);

        lineChart.getDescription().setEnabled(false);

        // enable touch gestures
        lineChart.setTouchEnabled(true);

        // scaling can now only be done on x- and y-axis separately
        lineChart.setPinchZoom(false);

        lineChart.setScaleEnabled(false);

        lineChart.setDrawGridBackground(false);

        valueFormatter = new DayAxisValueFormatter(lineChart, mTimeZone, fromUtcDateTime, toUtcDateTime);

        XAxis xAxis = lineChart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setDrawGridLines(false);
        xAxis.setGranularity(1f); // only intervals of 1 day
        xAxis.setLabelCount(7);
        xAxis.setXOffset(ViewUtils.dp2px(4));
        xAxis.setValueFormatter(valueFormatter);

        lineChart.getAxisLeft().setDrawGridLines(false);
        lineChart.getAxisLeft().setDrawAxisLine(false);
        lineChart.getAxisRight().setEnabled(false);

        YAxis leftAxis = lineChart.getAxisLeft();
        leftAxis.setLabelCount(5, false);
        leftAxis.setPosition(YAxis.YAxisLabelPosition.OUTSIDE_CHART);
        leftAxis.setSpaceTop(15f);
        leftAxis.setAxisMinimum(0f); // this replaces setStartAtZero(true)

        Legend l = lineChart.getLegend();
        l.setVerticalAlignment(Legend.LegendVerticalAlignment.BOTTOM);
        l.setHorizontalAlignment(Legend.LegendHorizontalAlignment.CENTER);
        l.setOrientation(Legend.LegendOrientation.HORIZONTAL);
        l.setDrawInside(false);
        l.setForm(Legend.LegendForm.NONE);
        l.setTextSize(10f);

        markerView = new XYMarkerView(getActivity(), valueFormatter);
        markerView.setChartView(lineChart); // For bounds control
        lineChart.setMarker(markerView); // Set the marker to the chart
    }

    private void initMagic() {
        magicIndicator.setBackgroundColor(Color.WHITE);

        CommonNavigator commonNavigator = new CommonNavigator(getActivity());
        commonNavigator.setAdjustMode(true);

        commonNavigator.setAdapter(new CommonNavigatorAdapter() {
            @Override
            public int getCount() {
                return TYPES.length;
            }

            @Override
            public IPagerTitleView getTitleView(Context context, int index) {
                Logger.t(TAG).d("getTitleView: " + index);
                CommonPagerTitleView commonPagerTitleView = new CommonPagerTitleView(context);

                View view = LayoutInflater.from(context).inflate(R.layout.layout_dash_title, null);
                TextView tvDashTitle = view.findViewById(R.id.tv_dash_title);
                TextView tvDashType = view.findViewById(R.id.tv_dash_type);
                View viewLine = view.findViewById(R.id.view_line);
                tvDashType.setText(TYPES[index]);
                switch (index) {
                    case 0:
                        tvDashMiles = tvDashTitle;
                        break;
                    case 1:
                        tvDashHours = tvDashTitle;
                        break;
                    case 2:
                        tvDashEvents = tvDashTitle;
                        viewLine.setVisibility(View.GONE);
                        break;
                }

                commonPagerTitleView.setContentView(view);
                commonPagerTitleView.setOnPagerTitleChangeListener(new CommonPagerTitleView.OnPagerTitleChangeListener() {
                    @Override
                    public void onSelected(int index, int totalCount) {
                        tvDashTitle.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                    }

                    @Override
                    public void onDeselected(int index, int totalCount) {
                        tvDashTitle.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    }

                    @Override
                    public void onLeave(int index, int totalCount, float leavePercent, boolean leftToRight) {
                    }

                    @Override
                    public void onEnter(int index, int totalCount, float enterPercent, boolean leftToRight) {
                        Logger.t(TAG).d("onEnter: " + index);
                        currentDash = index;
                        markerView.setCurrentDash(index);
                        setData();
                    }
                });
                commonPagerTitleView.setOnClickListener(v -> {
                    if (index != 3) {
                        commonNavigator.onPageSelected(index);
                    }
                });
                return commonPagerTitleView;
            }

            @Override
            public IPagerIndicator getIndicator(Context context) {
                LinePagerIndicator indicator = new LinePagerIndicator(context);
                indicator.setStartInterpolator(new AccelerateInterpolator());
                indicator.setEndInterpolator(new DecelerateInterpolator(1f));
                indicator.setXOffset(UIUtil.dip2px(context, 23));
                indicator.setYOffset(UIUtil.dip2px(context, 61));
                indicator.setLineHeight(UIUtil.dip2px(context, 4));
                indicator.setColors(Color.parseColor("#4A90E2"));
                return indicator;
            }
        });
        magicIndicator.setNavigator(commonNavigator);
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        viewModel.statusReportWithDriverId()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onStatusReportWithDriverIdboard, new ServerErrorHandler(TAG));

        networkError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));

        viewModel.responseErr()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onExpireToken, new ServerErrorHandler(TAG));
    }

    private void onExpireToken(Response response){
        NetworkErrorHelper.handleExpireToken(getActivity(),response);
    }

    private void handleNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(getActivity(), throwable);
    }

    private void onStatusReportWithDriverIdboard(Optional<DriverStatusReportResponse> optional) {
        exitLoadStatus();

        DriverStatusReportResponse response = optional.getIncludeNull();
        if (response != null) {

            DriverStatusReportResponse.Data dataBean = response.getData();
            Logger.t(TAG).d("onDashboard beanList: " + dataBean.getHoursList());

            ArrayList<DetailBean.Record> recordsList = new ArrayList<>(dataBean.getDriversList().getRecords());
            Collections.sort(recordsList, (o1, o2) -> ((o2.getEventTotal() - o1.getEventTotal()) > 0) ? 1 : -1);
            mDriverAdapter.setNewData(recordsList);

            this.hoursBeanList = dataBean.getHoursList();
            this.eventsBeanList = dataBean.getEventsList();
            this.milesBeanList = dataBean.getMilesList();

            this.dataBean = dataBean;

            double miles = dataBean.getMilesTotal();
            double hours = dataBean.getHoursTotal();
            double events = dataBean.getEventTotal();

            Logger.t(TAG).d("tvDashMiles: " + miles
                    + " tvDashHours: " + hours
                    + " tvDashEvents: " + events);
            // DoanVT-convert to Km
            DecimalFormat decimalFormat = new DecimalFormat("0.00");
            tvDashMiles.setText(decimalFormat.format((float) miles / 1000));


            double tempHours = hours;
            String hoursString = String.valueOf(tempHours);
            tvDashHours.setText(hoursString);


            double tempEvents = events;
            String eventsString = String.valueOf(tempEvents);
            tvDashEvents.setText(eventsString);


            setData();
        }
    }

    private void setData() {
        ArrayList<Entry> values = new ArrayList<>();



            float value;

            if (currentDash == 0) {
                for (int i = 0; i < milesBeanList.size(); i++) {
                    double mileage = milesBeanList.get(i).getDistanceTotal();
                    value = (float) mileage / 1000;
                    values.add(new Entry(i, value, milesBeanList));
                }
            } else if (currentDash == 1) {
                for (int i= 0; i < hoursBeanList.size(); i++) {
                    double duration = hoursBeanList.get(i).getHoursTotal();
                    value = (float) duration;
                    values.add(new Entry(i, value, hoursBeanList));
                }
            } else {
                for (int i= 0; i < eventsBeanList.size(); i++) {
                    value = (float) eventsBeanList.get(i).getEventTotal();
                    values.add(new Entry(i, value, eventsBeanList));
                }
            }

        if (lineChart.getData() != null &&
                lineChart.getData().getDataSetCount() > 0) {

            lineDataSet = (LineDataSet) lineChart.getData().getDataSetByIndex(0);
            lineDataSet.setValues(values);
            lineDataSet.setLabel(DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));
            lineChart.getData().notifyDataChanged();
            lineChart.notifyDataSetChanged();

        } else {
            lineDataSet = new LineDataSet(values,
                    DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));

            lineDataSet.setFillAlpha(255);
            lineDataSet.setDrawFilled(true);
            lineDataSet.setDrawIcons(false);
            lineDataSet.setDrawValues(false);
            lineDataSet.setHighlightLineWidth(1);
            lineDataSet.setDrawHorizontalHighlightIndicator(false);
            lineDataSet.setColor(ContextCompat.getColor(getContext(), R.color.colorChart));
            lineDataSet.setFillColor(ContextCompat.getColor(getContext(), R.color.colorChart));
            lineDataSet.setCircleColor(ContextCompat.getColor(getContext(), R.color.colorBaseFleet));
            lineDataSet.setHighLightColor(ContextCompat.getColor(getContext(), R.color.colorBaseFleet));

            ArrayList<ILineDataSet> dataSets = new ArrayList<>();
            dataSets.add(lineDataSet);

            LineData data = new LineData(dataSets);
            lineChart.setData(data);
        }

        lineChart.invalidate();
    }

    private void enterLoadStatus() {
        refreshDriverLayout.setRefreshing(true);
        llDashDriver.setVisibility(View.GONE);
    }

    private void exitLoadStatus() {
        refreshDriverLayout.setRefreshing(false);
        llDashDriver.setVisibility(View.VISIBLE);
    }

    public interface OperationListener {
        void onClick(DetailBean.Record bean);
    }
}
