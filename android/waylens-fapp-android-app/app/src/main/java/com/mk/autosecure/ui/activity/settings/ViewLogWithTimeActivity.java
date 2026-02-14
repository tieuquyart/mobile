package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mk.autosecure.ui.adapter.LogSpeedWithTimeAdapter;
import com.opencsv.CSVReader;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.DialogUtils;
import com.mk.autosecure.model.LogSpeedWithTimeBean;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import butterknife.BindView;
import butterknife.ButterKnife;

public class ViewLogWithTimeActivity extends RxActivity {

    private static final String TAG = ViewLogWithTimeActivity.class.getSimpleName();
    List<String[]> dataRead = null;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, ViewLogWithTimeActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        activity.startActivity(intent);
    }


    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.etTime)
    EditText etTime;

    @BindView(R.id.mRecyclerView)
    RecyclerView mRecyclerView;

    private LogSpeedWithTimeAdapter adapter;
    protected AppCompatDialog progressDialog;
    ArrayList<ArrayList<LogSpeedWithTimeBean>> listOfList = new ArrayList<>();
    ArrayList<LogSpeedWithTimeBean> speedBeans = new ArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_log_with_time);
        ButterKnife.bind(this);
        setupToolbar();

        tvToolbarTitle.setText(getResources().getString(R.string.log_speed));
        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new LogSpeedWithTimeAdapter(speedBeans);
        mRecyclerView.setAdapter(adapter);

        initData();

        etTime.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                adapter.getFilter().filter(charSequence);
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });

    }

    @Override
    protected void onResume() {
        super.onResume();
//        initData();
    }

    private void initData() {
        showProgress();
        File cameraLogsFile = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), "cameraLogs.txt");

        try (CSVReader reader = new CSVReader(new FileReader(cameraLogsFile.getAbsoluteFile()))) {
            dataRead = reader.readAll();
        } catch (IOException e) {
            hideProgress();
            Toast.makeText(ViewLogWithTimeActivity.this, "Lỗi đọc dữ liệu: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }

        if (dataRead != null && dataRead.size() != 0) {
            String[] line;
            for (int i = 0; i < dataRead.size(); i++) {
                line = dataRead.get(i);
//                Logger.t(TAG).i(Arrays.toString(line));
                if (!checkAZ(line[0])) {
                    if (line.length == 13) {
//                        Logger.t(TAG).i("doanvt: %s", Arrays.toString(line));
                        String[] arrSpeed = {line[3], line[4], line[5], line[6], line[7], line[8], line[9], line[10], line[11], line[12]};
                        String[] timeArr = line[0].split(" ");
                        String time = timeArr[1];
                        LogSpeedWithTimeBean speed = new LogSpeedWithTimeBean(time, line[1], line[2], arrSpeed);
                        speedBeans.add(speed);
                    }
                }
            }

            hideProgress();
            if (speedBeans.size() != 0) {
                tvToolbarTitle.setText(getResources().getString(R.string.log_speed));
                mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
                adapter = new LogSpeedWithTimeAdapter(speedBeans);
                mRecyclerView.setAdapter(adapter);
            } else {
                hideProgress();
                Toast.makeText(ViewLogWithTimeActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
            }
        } else {
            hideProgress();
            Toast.makeText(ViewLogWithTimeActivity.this, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
        }
    }

    private void showProgress() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(this);
        }
//        progressDialog.setMessage("Đang đọc dữ liệu");
        progressDialog.show();
    }

    private void hideProgress() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }

    public void setupToolbar() {
        toolbar.setNavigationIcon(R.drawable.ic_back);
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    private boolean checkAZ(String input) {
        Pattern pattern = Pattern.compile("[a-zA-Z]+");
        return pattern.matcher(input).find();
    }
}
