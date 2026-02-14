package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.interfaces.datasets.IBarDataSet;
import com.github.mikephil.charting.listener.OnChartValueSelectedListener;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.BaseLazyLoadFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.DashboardUtil;
import com.mk.autosecure.libs.utils.DayAxisValueFormatter;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.Utils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.libs.utils.XDatePickerDialog;
import com.mk.autosecure.libs.utils.XYMarkerView;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.reponse.DriverStatusReportResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.rest_fleet.bean.EventListBean;
import com.mk.autosecure.rest_fleet.bean.HoursListBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.request.DrivingTimeBody;
import com.mk.autosecure.rest_fleet.request.TotalExportBody;
import com.mk.autosecure.rest_fleet.request.VehicleFleetBody;
import com.mk.autosecure.rest_fleet.response.Response;

import android.widget.Toast;

import com.mk.autosecure.ui.CustomBarChartRender;
import com.mk.autosecure.viewmodels.fragment.DashFleetViewModel;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.R;

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
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.subjects.PublishSubject;
import okhttp3.ResponseBody;


@SuppressLint({"NewApi", "NonConstantResourceId", "CheckResult"})
@RequiresFragmentViewModel(DashFleetViewModel.ViewModel.class)
public class DashFleetFragment extends BaseLazyLoadFragment<DashFleetViewModel.ViewModel>
        implements XDatePickerDialog.OnDateSetListener, OnChartValueSelectedListener {

    private final static String TAG = DashFleetFragment.class.getSimpleName();

    private final static int[] TYPES = new int[]{R.string.miles, R.string.hours, R.string.events};

    private long fromUtcDateTime, toUtcDateTime, fromUtcDateTimeRp, toUtcDateTimeRp, minUtcDateTime, maxUtcDateTime;

    private SimpleDateFormat dateFormat;

    private TimeZone mTimeZone;

    private int currentDash = 0;

    private TextView tvDashMiles, tvDashHours, tvDashEvents;

    private DayAxisValueFormatter valueFormatter;

    private XYMarkerView markerView;

    private final PublishSubject<Throwable> networkError = PublishSubject.create();

    private List<HoursListBean> hoursBeanList = new ArrayList<>();

    private List<EventListBean> eventsBeanList = new ArrayList<>();

    private List<HoursListBean> milesBeanList = new ArrayList<>();

    private DriverStatusReportResponse.Data dataBean;

//    private DashFleetAdapter mFleetAdapter;

    private final List<DetailBean.Record> mDetailBeanRecordList = new ArrayList<>();

    private BarDataSet barDataSet;

    private final List<String> plateNoList = new ArrayList<>();

    private final List<String> driverNameList = new ArrayList<>();

    private String plateNo;

    private String driverName;

    private final List<String> plateNos = new ArrayList<>();

    private final List<Integer> driverIds = new ArrayList<>();

    private final List<String> listPlateNo = new ArrayList<>();

    private final List<Integer> listDriverId = new ArrayList<>();

    private int currentTabIndex = 0;

    private boolean isTimeDriving = false;

    String[] statusDriving;

    private boolean isContinuous = false;

    enum TypeReport {JOURNEY, SPEED, CONTINUOUS, STOP, TOTAL_REPORT, DETAIL_PICTURE}

    private TypeReport typeReport;


    boolean isPickerRp;

    String[] timeReports;

    @BindView(R.id.refresh_fleet_layout)
    SwipeRefreshLayout refreshFleetLayout;

    @BindView(R.id.ll_dash_fleet)
    LinearLayout llDashFleet;

    @BindView(R.id.tv_date_picker)
    TextView tvDatePicker;

    @BindView(R.id.tv_date_report)
    TextView tvDateReport;

    @BindView(R.id.magic_indicator)
    MagicIndicator magicIndicator;

    @BindView(R.id.barChart)
    BarChart barChart;

    @BindView(R.id.rg_sort_type)
    RadioGroup rgSortType;

    @BindView(R.id.rbJourney)
    RadioButton rbJourney;

    @BindView(R.id.rbSpeed)
    RadioButton rbSpeed;

    @BindView(R.id.rb_continuous_driving_time)
    RadioButton rbContinuousDrivingTime;

    @BindView(R.id.rb_stop)
    RadioButton rbStop;

    @BindView(R.id.rb_totalReport)
    RadioButton rbTotalReport;

    @BindView(R.id.rb_detailPicture)
    RadioButton rbDetailPicture;

    @BindView(R.id.spTimeReport)
    Spinner spTimeReport;

    @OnClick(R.id.ll_date_picker)
    void datePicker() {
        isPickerRp = false;
        Calendar from = DashboardUtil.getCalendar(mTimeZone, fromUtcDateTime);
        Calendar to = DashboardUtil.getCalendar(mTimeZone, toUtcDateTime);

        XDatePickerDialog dialog = XDatePickerDialog.newInstance(this,
                from.get(Calendar.YEAR), from.get(Calendar.MONTH), from.get(Calendar.DAY_OF_MONTH),
                to.get(Calendar.YEAR), to.get(Calendar.MONTH), to.get(Calendar.DAY_OF_MONTH));

        Calendar minDate = DashboardUtil.getCalendar(mTimeZone, minUtcDateTime);
        Calendar maxDate = DashboardUtil.getCalendar(mTimeZone, maxUtcDateTime);

        dialog.setMinDate(minDate);
        dialog.setMaxDate(maxDate);

        dialog.vibrate(false);
        dialog.setAutoHighlight(true);
        dialog.show(getChildFragmentManager(), "XDatePickerDialog");
    }

    @OnClick(R.id.ll_date_picker_report)
    void datePickerRp() {
        isPickerRp = true;
        Calendar from = DashboardUtil.getCalendar(mTimeZone, fromUtcDateTimeRp);
        Calendar to = DashboardUtil.getCalendar(mTimeZone, toUtcDateTimeRp);

        XDatePickerDialog dialog = XDatePickerDialog.newInstance(this,
                from.get(Calendar.YEAR), from.get(Calendar.MONTH), from.get(Calendar.DAY_OF_MONTH),
                to.get(Calendar.YEAR), to.get(Calendar.MONTH), to.get(Calendar.DAY_OF_MONTH));

        Calendar minDate = DashboardUtil.getCalendar(mTimeZone, minUtcDateTime);
        Calendar maxDate = DashboardUtil.getCalendar(mTimeZone, maxUtcDateTime);

        dialog.setMinDate(minDate);
        dialog.setMaxDate(maxDate);

        dialog.vibrate(false);
        dialog.setAutoHighlight(true);
        dialog.show(getChildFragmentManager(), "XDatePickerDialog");
    }

    @BindView(R.id.spTypeReport)
    Spinner spTypeReport;

    @BindView(R.id.txTitleReport)
    TextView txTitleReport;

    @BindView(R.id.llPlateNo)
    LinearLayout llPlateNo;

    @BindView(R.id.llRadioButton)
    LinearLayout llRadioButton;

    @BindView(R.id.llRadioB5)
    LinearLayout llRadio5;

    @BindView(R.id.rdB21)
    RadioButton rdB21;

    @BindView(R.id.rdB22)
    RadioButton rdB22;

    @BindView(R.id.rdB51)
    RadioButton rdB51;

    @BindView(R.id.rdB52)
    RadioButton rdB52;

    public static DashFleetFragment newInstance() {
        return new DashFleetFragment();
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
        valueFormatter.setDateTime(fromUtcDateTime, toUtcDateTime);

        enterLoadStatus();

        viewModel.inputQueryTime(dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime)));
        viewModel.queryStatusReport();
        viewModel.queryVehicleList();

        XDatePickerDialog dpd = (XDatePickerDialog) getChildFragmentManager().findFragmentByTag("XDatePickerDialog");
        if (dpd != null) dpd.setOnDateSetListener(this);
    }

    @Override
    protected void onFragmentFirstVisible() {
        if (barChart != null) {
            barChart.animateY(1500);
        }
    }

    @Override
    protected int getLayoutRes() {
        return R.layout.fragment_dashboard_fleet;
    }

    @Override
    protected void initView(View rootView) {
        ButterKnife.bind(this, rootView);

        refreshFleetLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            viewModel.queryStatusReport();
        });

        statusDriving = new String[]{getContext().getString(R.string.time_driving_out_4h), getContext().getString(R.string.all)};
        timeReports = new String[]{getContext().getString(R.string.select), getString(R.string.one_week), getContext().getString(R.string.one_month)};

        getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);

        //这里得到的timezone是自动支持夏令时的
        mTimeZone = TimeZone.getDefault();

        toUtcDateTime = maxUtcDateTime = System.currentTimeMillis();
        toUtcDateTimeRp = maxUtcDateTime = System.currentTimeMillis();

        fromUtcDateTime = Math.max(DashboardUtil.getZeroFromTime(14, toUtcDateTime), 0);
        fromUtcDateTimeRp = Math.max(DashboardUtil.getZeroFromTime(14, toUtcDateTimeRp), 0);
        minUtcDateTime = Math.max(DashboardUtil.getZeroFromTime(90, toUtcDateTime), 0);

        dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        dateFormat.setTimeZone(mTimeZone);

        tvDatePicker.setText(String.format("%s to %s",
                dateFormat.format(new Date(fromUtcDateTime)),
                dateFormat.format(new Date(toUtcDateTime))));

        tvDateReport.setText(String.format("%s to %s",
                dateFormat.format(new Date(fromUtcDateTimeRp)),
                dateFormat.format(new Date(toUtcDateTimeRp))));

        rgSortType.setOnCheckedChangeListener((group, checkedId) -> onCheckedRadio(checkedId));
        rgSortType.check(rbJourney.getId());

        ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(getContext(), R.layout.item_custom_spinner, timeReports);
        spTimeReport.setAdapter(dropdownAdapter);
        spTimeReport.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getTimeWithIndex(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        initEvent();
        initMagic();
        initChart();
        initB2RadioButton();
    }

    private void getTimeWithIndex(int index) {

//        toUtcDateTime = Instant.now().toEpochMilli();
        Calendar calendar = Calendar.getInstance();
        toUtcDateTime = calendar.getTimeInMillis();

        if (index == 1) {
//            Calendar firstMonDay = Calendar.getInstance(Locale.US);
//            firstMonDay.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
            int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
            int timeOfWeek = dayOfWeek * 24* 60 * 60 * 1000;

            fromUtcDateTime = (long) (toUtcDateTime - timeOfWeek);
//            fromUtcDateTime = (long) firstMonDay.getTimeInMillis();
        } else if (index == 2) {
            int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
            long timeOfMonth = (long) dayOfMonth * 24 * 60 * 60 * 1000;
            fromUtcDateTime = toUtcDateTime - timeOfMonth;
        }

        Logger.t(TAG).d("now: " + dateFormat.format(new Date(toUtcDateTime)) + "--week: " + dateFormat.format(new Date(fromUtcDateTime)));

        tvDatePicker.setText(String.format("%s to %s",
                dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime))));

        valueFormatter.setDateTime(fromUtcDateTime, toUtcDateTime);

        if (barDataSet != null){
            barDataSet.setLabel(DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));
        }

        enterLoadStatus();

        viewModel.inputQueryTime(dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime)));
        viewModel.queryStatusReport();
    }

    private void initB2RadioButton() {

        rdB21.setOnClickListener(view -> {
            rdB21.setChecked(true);
            if (rdB22.isChecked()) rdB22.setChecked(false);
        });

        rdB22.setOnClickListener(view -> {
            rdB22.setChecked(true);
            if (rdB21.isChecked()) rdB21.setChecked(false);
        });

        rdB51.setOnClickListener(view -> {
            rdB51.setChecked(true);
            txTitleReport.setText(getString(R.string.plate_number));
            if (rdB52.isChecked()) rdB52.setChecked(false);
            initSpinner();
        });

        rdB52.setOnClickListener(view -> {
            rdB52.setChecked(true);
            txTitleReport.setText(getString(R.string.driver_name));
            if (rdB51.isChecked()) rdB51.setChecked(false);
            initSpinner();
        });
    }


    /**
     * export file report ra excel with typeReport
     */
    @SuppressLint("CheckResult")
    @OnClick(R.id.btnExportReport)
    public void exportReportWithType() {
        Logger.t(TAG).i("typeReport %s", typeReport);

        switch (typeReport) {
            case JOURNEY: { // 1
                showDialog();
                VehicleFleetBody body = new VehicleFleetBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", plateNo);
                ApiClient.createApiService().vehicleFleet(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(data -> {
                            dismissDialog();
                            if (availableData(data.body())) {
                                boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.vehicleFleetFileName, plateNo);
                                Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                if (writtenToDisk)
                                    Toast.makeText(getActivity(), "Tải & lưu dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                else

                                    Toast.makeText(getActivity(), "Tải & lưu dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                            }

                        }, throwable -> {
                            new ServerErrorHandler(TAG);
                            dismissDialog();
                        });
            }
            break;
            case SPEED: {//2
                showDialog();
                if (rdB21.isChecked()) {//2.1
                    VehicleFleetBody body = new VehicleFleetBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", plateNo);
                    ApiClient.createApiService().vehicleSpeed(body, HornApplication.getComponent().currentUser().getAccessToken())
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(data -> {
                                dismissDialog();
                                if (availableData(data.body())) {
                                    boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.vehicleSpeedFileName, plateNo);
                                    Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                    if (writtenToDisk)
                                        Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                    else

                                        Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                                } else {
                                    Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                                }

                            }, throwable -> {
                                new ServerErrorHandler(TAG);
                                dismissDialog();
                            });
                } else if (rdB22.isChecked()) {//2.2
                    VehicleFleetBody body = new VehicleFleetBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", plateNo);
                    ApiClient.createApiService().overSpeed(body, HornApplication.getComponent().currentUser().getAccessToken())
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(data -> {
                                dismissDialog();
                                if (availableData(data.body())) {
                                    boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.overSpeedFileName, plateNo);
                                    Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                    if (writtenToDisk)
                                        Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                    else

                                        Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                                } else {
                                    Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                                }

                            }, throwable -> {
                                new ServerErrorHandler(TAG);
                                dismissDialog();
                            });
                }
            }
            break;
            case STOP: {//3
                showDialog();
                VehicleFleetBody body = new VehicleFleetBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", plateNo);
                ApiClient.createApiService().stopVehicle(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(data -> {
                            dismissDialog();
                            if (availableData(data.body())) {
                                boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.stopVehicleFileName, plateNo);
                                Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                if (writtenToDisk)
                                    Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                else

                                    Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                            }

                        }, throwable -> {
                            new ServerErrorHandler(TAG);
                            dismissDialog();
                        });
            }
            break;
            case CONTINUOUS: {//4
                showDialog();
                DrivingTimeBody body = new DrivingTimeBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", isContinuous);
                ApiClient.createApiService().drivingTime(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(data -> {
                            dismissDialog();
                            if (availableData(data.body())) {
                                boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.drivingTimeFileName, plateNo);
                                Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                if (writtenToDisk)
                                    Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                else

                                    Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                            }

                        }, throwable -> {
                            new ServerErrorHandler(TAG);
                            dismissDialog();
                        });
            }
            break;
            case TOTAL_REPORT: {
                showDialog();
                if (rdB51.isChecked()) {//5.1
                    TotalExportBody body = new TotalExportBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", listPlateNo, "");
                    ApiClient.createApiService().b51Report(body, HornApplication.getComponent().currentUser().getAccessToken())
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(data -> {
                                dismissDialog();
                                if (availableData(data.body())) {
                                    boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.b51report, plateNo);
                                    Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                    if (writtenToDisk)
                                        Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                    else

                                        Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                                } else {
                                    Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                                }

                            }, throwable -> {
                                new ServerErrorHandler(TAG);
                                dismissDialog();
                            });
                } else if (rdB52.isChecked()) {//5.2
                    TotalExportBody body = new TotalExportBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", listDriverId);
                    ApiClient.createApiService().b52report(body, HornApplication.getComponent().currentUser().getAccessToken())
                            .compose(Transformers.switchSchedulers())
                            .compose(bindToLifecycle())
                            .subscribe(data -> {
                                dismissDialog();
                                if (availableData(data.body())) {
                                    boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.b52report, driverName);
                                    Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                    if (writtenToDisk)
                                        Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                    else

                                        Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                                } else {
                                    Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                                }

                            }, throwable -> {
                                new ServerErrorHandler(TAG);
                                dismissDialog();
                            });
                }
            }
            break;
            case DETAIL_PICTURE: {//6
                showDialog();
                VehicleFleetBody body = new VehicleFleetBody(dateFormat.format(new Date(toUtcDateTimeRp)) + "T23:59:59+07:00", dateFormat.format(new Date(fromUtcDateTimeRp)) + "T00:00:00+07:00", null);
                ApiClient.createApiService().detailPicture(body, HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(data -> {
                            dismissDialog();
                            if (availableData(data.body())) {
                                boolean writtenToDisk = viewModel.writeResponseBodyToDisk(data.body(), FileUtils.detailPictureTimeFileName, "");
                                Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                                if (writtenToDisk)
                                    Toast.makeText(getActivity(), "Tải dữ liệu thành công", Toast.LENGTH_SHORT).show();
                                else

                                    Toast.makeText(getActivity(), "Tải dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(getActivity(), "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                            }

                        }, throwable -> {
                            new ServerErrorHandler(TAG);
                            dismissDialog();
                        });
            }
            break;
        }
    }

    private boolean availableData(ResponseBody body) {
        return body != null && body.contentLength() != 0;
    }

    ProgressDialog pDialog;

    private void showDialog() {
        pDialog = new ProgressDialog(getActivity());
        pDialog.setMessage("Downloading file. Please waiting...");
        pDialog.setCancelable(false);
        pDialog.show();
    }

    private void dismissDialog() {
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
    }

    private void setRadioButtonTextColor(int index) {
        rbJourney.setTextColor(getResources().getColor(index == 0 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbSpeed.setTextColor(getResources().getColor(index == 1 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbContinuousDrivingTime.setTextColor(getResources().getColor(index == 2 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbStop.setTextColor(getResources().getColor(index == 3 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbTotalReport.setTextColor(getResources().getColor(index == 4 ? R.color.colorBaseFleet : R.color.colorPrimary));
        rbDetailPicture.setTextColor(getResources().getColor(index == 5 ? R.color.colorBaseFleet : R.color.colorPrimary));
        exportWithType(index);
    }

    private void exportWithType(int index) {
        currentTabIndex = index;
        if (plateNoList != null && plateNoList.size() != 0) {
            if (index == 4) {
                plateNoList.add(0, "Tất cả");
            } else {
                if (plateNoList.get(0).toLowerCase(Locale.ROOT).trim().contains("Tất cả".toLowerCase(Locale.ROOT).trim())) {
                    plateNoList.remove(0);
                }
            }
        }
        if (index == 0) {
            llPlateNo.setVisibility(View.VISIBLE);
            llRadioButton.setVisibility(View.GONE);
            llRadio5.setVisibility(View.GONE);
            txTitleReport.setText(getString(R.string.plate_number));
            typeReport = TypeReport.JOURNEY;
            isTimeDriving = false;
        } else if (index == 1) {
            llRadio5.setVisibility(View.GONE);
            llRadioButton.setVisibility(View.VISIBLE);
            llPlateNo.setVisibility(View.VISIBLE);
            rdB21.setText(getString(R.string.b2_1_vehicleSpeed));
            rdB22.setText(getString(R.string.b2_2_overSpeed));
            txTitleReport.setText(getString(R.string.plate_number));
            typeReport = TypeReport.SPEED;
            isTimeDriving = false;
        } else if (index == 2) {
            llRadio5.setVisibility(View.GONE);
            llPlateNo.setVisibility(View.VISIBLE);
            llRadioButton.setVisibility(View.GONE);
            txTitleReport.setText(getString(R.string.driven_status));
            typeReport = TypeReport.CONTINUOUS;
            isTimeDriving = true;
        } else if (index == 3) {
            llRadio5.setVisibility(View.GONE);
            llPlateNo.setVisibility(View.VISIBLE);
            llRadioButton.setVisibility(View.GONE);
            txTitleReport.setText(getString(R.string.plate_number));
            typeReport = TypeReport.STOP;
            isTimeDriving = false;
        } else if (index == 4) {
            llRadio5.setVisibility(View.VISIBLE);
            llPlateNo.setVisibility(View.VISIBLE);
            llRadioButton.setVisibility(View.GONE);
            rdB51.setText(getString(R.string.b5_1));
            rdB52.setText(getString(R.string.b5_2));
            if (rdB51.isChecked()) {
                txTitleReport.setText(getString(R.string.plate_number));
            } else if (rdB52.isChecked()) {
                txTitleReport.setText(getString(R.string.driver_name));
            }
            typeReport = TypeReport.TOTAL_REPORT;
            isTimeDriving = false;
        } else if (index == 5) {
            llRadio5.setVisibility(View.GONE);
            llRadioButton.setVisibility(View.GONE);
            llPlateNo.setVisibility(View.GONE);
            typeReport = TypeReport.DETAIL_PICTURE;
            isTimeDriving = false;
        }

        initSpinner();
    }

    private void initSpinner() {
        //init spinner
        if (isTimeDriving) {
            ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<String>(getActivity(), R.layout.item_spinner_report, statusDriving);
            spTypeReport.setAdapter(dropdownAdapter);
            spTypeReport.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                    isContinuous = i == 0;
                }

                @Override
                public void onNothingSelected(AdapterView<?> adapterView) {
                }
            });
        } else if (currentTabIndex == 4) {
            if (rdB52.isChecked()) {
                Logger.t(TAG).d("driverNameSize: " + driverNameList.size());
                Logger.t(TAG).d("driverIdSize: " + driverIds.size());
                ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(getActivity(), R.layout.item_spinner_report, driverNameList);
                spTypeReport.setAdapter(dropdownAdapter);
                spTypeReport.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                        if (i == 0) {
                            listDriverId.clear();
                            driverName = "All";
                            listDriverId.addAll(driverIds);
                        } else {
                            int driverId = driverIds.get(i - 1);
                            Logger.t(TAG).d("driverIdSize: " + driverIds.size() + "driverId:= " + driverId);
                            listDriverId.clear();
                            listDriverId.add(driverId);
                            driverName = driverNameList.get(i);
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> adapterView) {
                    }
                });
            } else if (rdB51.isChecked()) {
                ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(getActivity(), R.layout.item_spinner_report, plateNoList);
                spTypeReport.setAdapter(dropdownAdapter);
                spTypeReport.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                        if (i == 0) {
                            listPlateNo.clear();
                            listPlateNo.addAll(plateNos);
                            plateNo = "All";
                        } else {
                            listPlateNo.clear();
                            listPlateNo.add(plateNos.get(i - 1));
                            plateNo = plateNoList.get(i);
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> adapterView) {
                    }
                });
            }
        } else {
            ArrayAdapter<String> dropdownAdapter = new ArrayAdapter<>(getActivity(), R.layout.item_spinner_report, plateNoList);
            spTypeReport.setAdapter(dropdownAdapter);
            spTypeReport.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                    plateNo = plateNoList.get(i);
                }

                @Override
                public void onNothingSelected(AdapterView<?> adapterView) {
                }
            });
        }

    }

    private void sortFleetViewBeanList(int index) {
        if (mDetailBeanRecordList.size() == 0) {
            return;
        }

        Collections.sort(mDetailBeanRecordList, (o1, o2) -> {
            switch (index) {
                case 0:
                    int compare = 0;
                    if (!o1.getDriverName().equals("") && o1.getDriverName() != null && !o2.getDriverName().equals("") && o2.getDriverName() != null) {
                        compare = o1.getDriverName().compareToIgnoreCase(o2.getDriverName());
                    }
                    return compare != 0 ? compare : (int) (o2.getDistanceTotal() - o1.getDistanceTotal());
                case 1:
                    return (int) (o2.getDistanceTotal() - o1.getDistanceTotal());
                case 2:
                    int offsetDuration = (int) (o2.getHoursTotal() - o1.getHoursTotal());
                    return offsetDuration != 0 ? offsetDuration : (int) (o2.getDistanceTotal() - o1.getDistanceTotal());
                case 3:
                    int offsetEvent = (int) (o2.getEventTotal() - o1.getEventTotal());
                    return offsetEvent != 0 ? offsetEvent : (int) (o2.getDistanceTotal() - o1.getDistanceTotal());
            }
            return 0;
        });

//        mFleetAdapter.setNewData(mDetailBeanRecordList);
    }

    @Override
    public void onDateSet(XDatePickerDialog view, int year, int monthOfYear, int dayOfMonth, int yearEnd, int monthOfYearEnd, int dayOfMonthEnd) {
        String from = year + "-" + (++monthOfYear) + "-" + dayOfMonth;
        String to = yearEnd + "-" + (++monthOfYearEnd) + "-" + dayOfMonthEnd;
        Logger.t(TAG).d("onDateSet: " + from + " " + to);

        try {
            if (isPickerRp) {

                fromUtcDateTimeRp = Objects.requireNonNull(dateFormat.parse(from)).getTime();
                toUtcDateTimeRp = DashboardUtil.getEndTime(1, dateFormat.parse(to).getTime());

                tvDateReport.setText(String.format("%s to %s",
                        dateFormat.format(new Date(fromUtcDateTimeRp)), dateFormat.format(new Date(toUtcDateTimeRp))));
                viewModel.inputQueryData(plateNo, dateFormat.format(new Date(fromUtcDateTimeRp)), dateFormat.format(new Date(toUtcDateTimeRp)));
            } else {

                fromUtcDateTime = dateFormat.parse(from).getTime();
                toUtcDateTime = DashboardUtil.getEndTime(1, dateFormat.parse(to).getTime());

                tvDatePicker.setText(String.format("%s to %s",
                        dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime))));

                valueFormatter.setDateTime(fromUtcDateTime, toUtcDateTime);

                barDataSet.setLabel(DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));

                enterLoadStatus();

                viewModel.inputQueryTime(dateFormat.format(new Date(fromUtcDateTime)), dateFormat.format(new Date(toUtcDateTime)));
                viewModel.queryStatusReport();
            }
        } catch (ParseException e) {
            Logger.t(TAG).e("onDateSet ParseException: " + e.getMessage());
        }
    }

    private void initChart() {
        barChart.setOnChartValueSelectedListener(this);

        barChart.setDrawBarShadow(false);
        barChart.setDoubleTapToZoomEnabled(false);
        barChart.setDrawValueAboveBar(false);

        barChart.getDescription().setEnabled(false);

        // scaling can now only be done on x- and y-axis separately
        barChart.setPinchZoom(false);

        barChart.setDrawGridBackground(false);

        valueFormatter = new DayAxisValueFormatter(barChart, mTimeZone, fromUtcDateTime, toUtcDateTime);

        XAxis xAxis = barChart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setDrawGridLines(false);
        xAxis.setGranularity(1f); // only intervals of 1 day
        xAxis.setLabelCount(7);
        xAxis.setXOffset(ViewUtils.dp2px(4));
        xAxis.setValueFormatter(valueFormatter);

        barChart.getAxisLeft().setDrawGridLines(false);
        barChart.getAxisLeft().setDrawAxisLine(false);
        barChart.getAxisRight().setEnabled(false);

        YAxis leftAxis = barChart.getAxisLeft();
        leftAxis.setLabelCount(5, false);
        leftAxis.setPosition(YAxis.YAxisLabelPosition.OUTSIDE_CHART);
        leftAxis.setSpaceTop(15f);
        leftAxis.setAxisMinimum(0f); // this replaces setStartAtZero(true)

        Legend l = barChart.getLegend();
        l.setVerticalAlignment(Legend.LegendVerticalAlignment.BOTTOM);
        l.setHorizontalAlignment(Legend.LegendHorizontalAlignment.CENTER);
        l.setOrientation(Legend.LegendOrientation.HORIZONTAL);
        l.setDrawInside(false);
        l.setTextSize(10f);

        l.setForm(Legend.LegendForm.NONE);
        l.setFormToTextSpace(0f);
        l.setFormSize(0f);

        markerView = new XYMarkerView(getActivity(), valueFormatter);
        markerView.setChartView(barChart); // For bounds control
        barChart.setMarker(markerView); // Set the marker to the chart

    }

    private void initMagic() {
        magicIndicator.setBackgroundResource(R.color.transparent);

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
        viewModel.vehicleList()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onVehicleList, new ServerErrorHandler(TAG));

        viewModel.statusReportResponse()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onStatusReport, new ServerErrorHandler(TAG));

        networkError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));

        viewModel.responseErr()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onExpireToken, new ServerErrorHandler(TAG));


    }

    private void onDashFleet(List<DetailBean.Record> records) {
        Logger.t(TAG).d("onDashFleet: " + records.size());
        exitLoadStatus();

        mDetailBeanRecordList.clear();
        mDetailBeanRecordList.addAll(records);

        onCheckedRadio(rgSortType.getCheckedRadioButtonId());
    }

    private void onCheckedRadio(int checkedId) {
        if (checkedId == rbJourney.getId()) {
            setRadioButtonTextColor(0);
        } else if (checkedId == rbSpeed.getId()) {
            setRadioButtonTextColor(1);
        } else if (checkedId == rbContinuousDrivingTime.getId()) {
            setRadioButtonTextColor(2);
        } else if (checkedId == rbStop.getId()) {
            setRadioButtonTextColor(3);
        } else if (checkedId == rbTotalReport.getId()) {
            setRadioButtonTextColor(4);
        } else if (checkedId == rbDetailPicture.getId()) {
            setRadioButtonTextColor(5);
        }
    }

    private void onExpireToken(Response response) {
        NetworkErrorHelper.handleExpireToken(getActivity(), response);
    }

    private void handleNetworkError(Throwable throwable) {
        NetworkErrorHelper.handleCommonError(getActivity(), throwable);
    }

    private void onVehicleList(List<VehicleInfoBean> beanList) {
        if (beanList != null && beanList.size() != 0) {
            plateNoList.clear();
            driverNameList.clear();
            driverIds.clear();
            plateNos.clear();
            driverNameList.add(0, "Tất cả");
            for (VehicleInfoBean bean : beanList) {
                Logger.t(TAG).i("VehicleBean plateNo:= " + bean.getPlateNo());
                if (!TextUtils.isEmpty(bean.getPlateNo())) plateNoList.add(bean.getPlateNo());
                Logger.t(TAG).i("VehicleBean driverName:= " + bean.getDriverName());
                if (!TextUtils.isEmpty(bean.getDriverName()))
                    driverNameList.add(bean.getDriverName());
                Logger.t(TAG).i("VehicleBean driverId:= " + bean.getDriverId());
                driverIds.add(bean.getDriverId());
                plateNos.add(bean.getPlateNo());
            }
        }
    }

    private void onStatusReport(Optional<DriverStatusReportResponse> optional) {
        exitLoadStatus();

        DriverStatusReportResponse response = optional.getIncludeNull();
        if (response != null) {

            DriverStatusReportResponse.Data dataBean = response.getData();
            Logger.t(TAG).d("onDashboard beanList: " + dataBean.getHoursList());
//            this.hoursBeanList = dataBean.getHoursList();
//            this.eventsBeanList = dataBean.getEventsList();
//            this.milesBeanList = dataBean.getMilesList();
            hoursBeanList.clear();
            milesBeanList.clear();
            eventsBeanList.clear();
            List<String> daysInRange = Utils.getDatesIsRange(dateFormat,fromUtcDateTime,toUtcDateTime);
            //init list with all day
            for(int i = 0; i < daysInRange.size(); i++){
                this.hoursBeanList.add(i,new HoursListBean(daysInRange.get(i)));
                this.milesBeanList.add(i,new HoursListBean(daysInRange.get(i)));
                this.eventsBeanList.add(i,new EventListBean(daysInRange.get(i)));
            }


            Logger.t(TAG).d("daysSize: " + daysInRange.size());

            //check day and set data to list
            for (int i = 0; i < milesBeanList.size(); i++){
                for(HoursListBean mileBean : dataBean.getMilesList()){
                    if (milesBeanList.get(i).getSummaryTime().equals(mileBean.getSummaryTime())) {
                        milesBeanList.set(i,mileBean);
                    }
                }
            }

            Logger.t(TAG).d("mileSize: " + milesBeanList.size());

            for (int i = 0; i < hoursBeanList.size(); i++){
                for(HoursListBean hourBean : dataBean.getHoursList()){
                    if (hoursBeanList.get(i).getSummaryTime().equals(hourBean.getSummaryTime())) {
                        hoursBeanList.set(i,hourBean);
                    }
                }
            }

            Logger.t(TAG).d("hoursSize: " + hoursBeanList.size());

            for (int i = 0; i < eventsBeanList.size(); i++){
                for(EventListBean bean : dataBean.getEventsList()){
                    if (eventsBeanList.get(i).getSummaryTime().equals(bean.getSummaryTime())) {
                        eventsBeanList.set(i,bean);
                    }
                }
            }


            Logger.t(TAG).d("eventSize: " + eventsBeanList.size());

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
            onDashFleet(dataBean.getDriversList().getRecords());
        }
    }

    private void setData() {
        ArrayList<BarEntry> values = new ArrayList<>();
        float value;
        if (currentDash == 0) {
            for (int i = 0; i < milesBeanList.size(); i++) {
                Logger.t(TAG).d("dateOfMilesList: " + milesBeanList.get(i).getSummaryTime());
                double mileage = milesBeanList.get(i).getDistanceTotal();
                value = (float) mileage / 1000;
                values.add(new BarEntry(i, value, milesBeanList));
            }
        } else if (currentDash == 1) {
            for (int i = 0; i < hoursBeanList.size(); i++) {
                double duration = hoursBeanList.get(i).getHoursTotal();
                value = (float) duration;
                values.add(new BarEntry(i, value, hoursBeanList));
            }
        } else {
            for (int i = 0; i < eventsBeanList.size(); i++) {
                value = (float) eventsBeanList.get(i).getEventTotal();
                values.add(new BarEntry(i, value, eventsBeanList));
            }
        }

        if (barChart.getData() != null &&
                barChart.getData().getDataSetCount() > 0) {

            barDataSet = (BarDataSet) barChart.getData().getDataSetByIndex(0);
            barDataSet.setValues(values);
            barChart.getData().notifyDataChanged();
            barChart.notifyDataSetChanged();

        } else {
            barDataSet = new BarDataSet(values,
                    DashboardUtil.getBarLabel(mTimeZone, fromUtcDateTime, toUtcDateTime));

            barDataSet.setDrawIcons(false);
            barDataSet.setDrawValues(false);
            barDataSet.setColor(ContextCompat.getColor(getContext(), R.color.colorChart));
            barDataSet.setHighLightColor(ContextCompat.getColor(getContext(), R.color.colorBaseFleet));
            barDataSet.setHighLightAlpha(255);

            ArrayList<IBarDataSet> dataSets = new ArrayList<>();
            dataSets.add(barDataSet);

            BarData data = new BarData(dataSets);
            barChart.setData(data);
            //test border barchart
//            CustomBarChartRender barChartRender = new CustomBarChartRender(barChart, barChart.getAnimator(), barChart.getViewPortHandler());
//            barChartRender.setRadius(35);
//
//            barChart.setRenderer(barChartRender);
        }

        barChart.invalidate();
    }

    private void enterLoadStatus() {
        refreshFleetLayout.setRefreshing(true);
        llDashFleet.setVisibility(View.GONE);
    }

    private void exitLoadStatus() {
        refreshFleetLayout.setRefreshing(false);
        llDashFleet.setVisibility(View.VISIBLE);
    }
}
