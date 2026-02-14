package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.appcompat.widget.Toolbar;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.event.TCVNEvent;
import com.mkgroup.camera.message.bean.CarrierBean;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.DialogUtils;
import com.mk.autosecure.rest.ServerErrorHandler;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

@SuppressLint("CheckResult")
public class CheckSimDataActivity extends RxActivity {

    public static final String TAG = CheckSimDataActivity.class.getSimpleName();

    public static void launch(Activity activity){
        Intent intent = new Intent(activity,CheckSimDataActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        activity.startActivity(intent);
    }

    public static void launch(Activity activity, CarrierBean bean){
        Intent intent = new Intent(activity,CheckSimDataActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.putExtra("Carrier",bean.getValue());
        activity.startActivity(intent);
    }
    //val
    private EvCamera mEVCamera = null;
    protected AppCompatDialog progressDialog;
    private boolean isLoading;

    //bindview
    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView toolbarTitle;
    //end


    @BindView(R.id.etPhoneNo)
    EditText etPhoneNo;

    @BindView(R.id.etContent)
    EditText etContent;

    @BindView(R.id.tvMsgSimData)
    TextView msgSimData;

    @BindView(R.id.llMsg)
    LinearLayout llMsg;

    @BindView(R.id.btn_checkSimData)
    Button btnCheckSimData;

    @OnClick(R.id.btn_checkSimData)
    public void checkSimData() {
        checkEnableButton(false);
        if (TextUtils.isEmpty(etPhoneNo.getText()) || TextUtils.isEmpty(etContent.getText())) {
            Toast.makeText(this, "Vui lòng điển đầy đủ thông tin", Toast.LENGTH_SHORT).show();
            return;
        }
        if (mEVCamera != null) {
            llMsg.setVisibility(View.GONE);
            mEVCamera.checkSimData(etPhoneNo.getText().toString().trim(), etContent.getText().toString().trim());
            showLoadingDialog();
            RxBus.getDefault().toObservable(TCVNEvent.class)
                    .compose(bindToLifecycle())
                    .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
                    .timeout(30, TimeUnit.SECONDS)
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeOn(Schedulers.io())
                    .subscribe(event -> {
                        Logger.t(TAG).i("initListener checkDataSIM= " +event.getDataSIM().getDataSIM());
                        hideLoadingDialog();
                        llMsg.setVisibility(View.VISIBLE);
                        msgSimData.setText(event.getDataSIM().getDataSIM());
                        checkEnableButton(true);
                    }, throwable -> {
                        checkEnableButton(true);
                        hideLoadingDialog();
                        new ServerErrorHandler(TAG);
                    });
        }
    }

    private void checkEnableButton(boolean enable){
        btnCheckSimData.setEnabled(enable);
    }

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.check_sim_data_activity);
        ButterKnife.bind(this);
        initToolbar();
        checkEnableButton(true);
        llMsg.setVisibility(View.GONE);
        VdtCameraManager.getManager().currentCamera()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(cameraOptional -> onCurrentCamera(cameraOptional.getIncludeNull()), new ServerErrorHandler(TAG));

        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            String title = bundle.getString("Carrier");
            if (!TextUtils.isEmpty(title)){
                toolbarTitle.setText(title);
            }else{
                toolbarTitle.setText(getString(R.string.check_data_4g));
            }
        }
    }

    @Override
    protected void onDestroy() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        super.onDestroy();
    }

    public void initToolbar(){
        toolbar.setNavigationOnClickListener(v -> finish());
        toolbarTitle.setText(getString(R.string.check_sim_card));
    }

    private void onCurrentCamera(CameraWrapper cameraWrapper) {
        Logger.t(TAG).d("onCurrentCamera: " + cameraWrapper);
        mEVCamera = (EvCamera) cameraWrapper;

    }


    private void showLoadingDialog() {
        if (progressDialog == null) {
            progressDialog = DialogUtils.createProgressDialog(this);
        }
        progressDialog.show();
    }

    private void hideLoadingDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            try {
                progressDialog.hide();
                progressDialog.dismiss();
                progressDialog = null;
            } catch (Exception ex) {
                Logger.t(TAG).d("error" + ex.getMessage());
            }
        }
    }
}
