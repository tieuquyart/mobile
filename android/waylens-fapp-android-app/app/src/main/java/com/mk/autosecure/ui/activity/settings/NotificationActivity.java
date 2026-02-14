package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.Switch;

import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.NotificationSetting;

import java.util.ArrayList;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.subjects.PublishSubject;

public class NotificationActivity extends RxActivity {

    private final static String TAG = NotificationActivity.class.getSimpleName();

    public static void launch(Activity activity, String sn) {
        Intent intent = new Intent(activity, NotificationActivity.class);
        intent.putExtra(IntentKey.SERIAL_NUMBER, sn);
        activity.startActivity(intent);
    }

    @BindView(R.id.rl_shadow)
    RelativeLayout rl_shadow;

    @BindView(R.id.ll_total)
    LinearLayout ll_total;

    @BindView(R.id.switch_total)
    Switch switch_total;

    @BindView(R.id.switch_park_motion)
    Switch switch_park_motion;

    @BindView(R.id.switch_park_bump)
    Switch switch_park_bump;

    @BindView(R.id.switch_park_impact)
    Switch switch_park_impact;

    @BindView(R.id.switch_drive_bump)
    Switch switch_drive_bump;

    @BindView(R.id.switch_drive_impact)
    Switch switch_drive_impact;

    private PublishSubject<Throwable> networkError = PublishSubject.create();

    private String sn;

    private NotificationSetting notification;

    private ArrayList<Switch> switchList;

    //设置是否发生改变
    private boolean modify = false;

    //是否弹出提示框
    private boolean needShowDialog = false;

    private PopupWindow popupWindow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notification);
        ButterKnife.bind(this);
        setupToolbar();

        sn = getIntent().getStringExtra(IntentKey.SERIAL_NUMBER);
        initPop();
        initView();

        networkError
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::handleNetworkError, new ServerErrorHandler(TAG));
    }

    private void handleNetworkError(Throwable throwable) {
        rl_shadow.setVisibility(View.GONE);
        NetworkErrorHelper.handleCommonError(this, throwable);
    }

    private void initPop() {
        View view = new View(this);
        view.setBackgroundResource(R.color.text_transparent_light);
        popupWindow = new PopupWindow(view, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, false);
    }

    private void initView() {
        if (!TextUtils.isEmpty(sn)) {
            ApiService.createApiService().getNotify(sn)
                    .compose(Transformers.switchSchedulers())
                    .compose(Transformers.pipeErrorsTo(networkError))
                    .compose(Transformers.neverError())
                    .compose(bindToLifecycle())
                    .subscribe(this::onNotifySetting);
        }

        switchList = new ArrayList<>();
        switchList.add(switch_park_motion);
        switchList.add(switch_park_bump);
        switchList.add(switch_park_impact);
        switchList.add(switch_drive_bump);
        switchList.add(switch_drive_impact);

        switch_total.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            Logger.t(TAG).d("switch_total: " + isChecked);

            if (isChecked) {
                updateUI(true);
                needShowDialog = true;
                NotificationActivity.this.modify = true;
            } else {
                if (needShowDialog) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        updateUI(false);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_total.setChecked(true);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                }
            }
        });

        switch_park_motion.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            boolean motion = isChecked(notification.PARKING_MOTION);
            Logger.t(TAG).d("switch_park_motion: " + isChecked);
            Logger.t(TAG).d("motion: " + motion);

            if (isChecked != motion) {
                if (checkCloseTotal()) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        switch_total.setChecked(false);
                        if (popupWindow != null) {
                            popupWindow.showAsDropDown(ll_total);
                        }
                        notification.PARKING_MOTION = setChecked(isChecked);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_park_motion.setChecked(!isChecked);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                } else {
                    notification.PARKING_MOTION = setChecked(isChecked);
                    NotificationActivity.this.modify = true;
                }
            }
        });

        switch_park_bump.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            boolean bump = isChecked(notification.PARKING_HIT);
            Logger.t(TAG).d("switch_park_bump: " + isChecked);
            Logger.t(TAG).d("bump: " + bump);

            if (isChecked != bump) {
                if (checkCloseTotal()) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        switch_total.setChecked(false);
                        if (popupWindow != null) {
                            popupWindow.showAsDropDown(ll_total);
                        }
                        notification.PARKING_HIT = setChecked(isChecked);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_park_bump.setChecked(!isChecked);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                } else {
                    notification.PARKING_HIT = setChecked(isChecked);
                    NotificationActivity.this.modify = true;
                }
            }
        });

        switch_park_impact.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            boolean impact = isChecked(notification.PARKING_HEAVY_HIT);
            Logger.t(TAG).d("switch_park_impact: " + isChecked);
            Logger.t(TAG).d("impact: " + impact);

            if (isChecked != impact) {
                if (checkCloseTotal()) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        switch_total.setChecked(false);
                        if (popupWindow != null) {
                            popupWindow.showAsDropDown(ll_total);
                        }
                        notification.PARKING_HEAVY_HIT = setChecked(isChecked);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_park_impact.setChecked(!isChecked);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                } else {
                    notification.PARKING_HEAVY_HIT = setChecked(isChecked);
                    NotificationActivity.this.modify = true;
                }
            }
        });

        switch_drive_bump.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            boolean bump = isChecked(notification.DRIVING_HIT);
            Logger.t(TAG).d("switch_drive_bump: " + isChecked);
            Logger.t(TAG).d("bump: " + bump);

            if (isChecked != bump) {
                if (checkCloseTotal()) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        switch_total.setChecked(false);
                        if (popupWindow != null) {
                            popupWindow.showAsDropDown(ll_total);
                        }
                        notification.DRIVING_HIT = setChecked(isChecked);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_drive_bump.setChecked(!isChecked);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                } else {
                    notification.DRIVING_HIT = setChecked(isChecked);
                    NotificationActivity.this.modify = true;
                }
            }
        });

        switch_drive_impact.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (notification == null) {
                return;
            }

            boolean impact = isChecked(notification.DRIVING_HEAVY_HIT);
            Logger.t(TAG).d("switch_drive_impact: " + isChecked);
            Logger.t(TAG).d("impact: " + impact);

            if (isChecked != impact) {
                if (checkCloseTotal()) {
                    DialogHelper.showCloseNotifyDialog(NotificationActivity.this, () -> {
                        needShowDialog = false;
                        switch_total.setChecked(false);
                        if (popupWindow != null) {
                            popupWindow.showAsDropDown(ll_total);
                        }
                        notification.DRIVING_HEAVY_HIT = setChecked(isChecked);
                        NotificationActivity.this.modify = true;
                    }, () -> {
                        switch_drive_impact.setChecked(!isChecked);
                        Logger.t(TAG).e("notification: " + notification.toString());
                    });
                } else {
                    notification.DRIVING_HEAVY_HIT = setChecked(isChecked);
                    NotificationActivity.this.modify = true;
                }
            }
        });
    }


    private void onNotifySetting(NotificationSetting notification) {
        Logger.t(TAG).d("onNotifySetting: " + notification.toString());
        this.notification = notification;
        rl_shadow.setVisibility(View.GONE);

        boolean motion = isChecked(notification.PARKING_MOTION);
        boolean bump = isChecked(notification.PARKING_HIT) || isChecked(notification.DRIVING_HIT);
        boolean impact = isChecked(notification.PARKING_HEAVY_HIT) || isChecked(notification.DRIVING_HEAVY_HIT);
        boolean total = motion || bump || impact;

        needShowDialog = total;
        switch_total.setChecked(total);

        updateUI(total);
    }

    private void updateUI(boolean isChecked) {
        if (notification == null) {
            return;
        }
        //根据总开关状态设置UI
        if (isChecked) {
            if (popupWindow.isShowing()) {
                popupWindow.dismiss();
            }

            switch_park_motion.setChecked(isChecked(notification.PARKING_MOTION));
            switch_park_bump.setChecked(isChecked(notification.PARKING_HIT));
            switch_park_impact.setChecked(isChecked(notification.PARKING_HEAVY_HIT));
            switch_drive_bump.setChecked(isChecked(notification.DRIVING_HIT));
            switch_drive_impact.setChecked(isChecked(notification.DRIVING_HEAVY_HIT));
        } else {
            if (popupWindow != null) {
                popupWindow.showAsDropDown(ll_total);
            }

            switch_park_motion.setChecked(false);
            switch_park_bump.setChecked(false);
            switch_park_impact.setChecked(false);
            switch_drive_bump.setChecked(false);
            switch_drive_impact.setChecked(false);
        }
    }

    private boolean checkAllClosed() {
        //遍历状态值，判断是否关闭总开关
        boolean allClosed = true;
        for (Switch item : switchList) {
            boolean checked = item.isChecked();
            if (checked) {
                allClosed = false;
                break;
            }
        }
        return allClosed;
    }

    private boolean checkCloseTotal() {
        boolean allClosed = checkAllClosed();
        return switch_total.isChecked() && allClosed;
    }

    private boolean isChecked(String check) {
        return "on".equals(check);
    }

    private String setChecked(boolean check) {
        return check ? "on" : "off";
    }

    private void setupToolbar() {
        ((androidx.appcompat.widget.Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> {
            if (!TextUtils.isEmpty(sn) && notification != null) {
                uploadNotify();
            } else {
                finish();
            }
        });
    }

    @Override
    public void onBackPressed() {
        if (!TextUtils.isEmpty(sn) && notification != null) {
            uploadNotify();
        } else {
            finish();
        }
    }

    private void uploadNotify() {
        Logger.t(TAG).d("uploadNotify: " + modify + "--" + notification.toString());
        if (modify) {
            ApiService.createApiService().setNotify(sn, notification)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .doFinally(this::finish)
                    .subscribe(booleanResponse -> Logger.t(TAG).d("setNotify: " + booleanResponse.result),
                            throwable -> Logger.t(TAG).e("setNotify throwable: " + throwable.getMessage()));
        } else {
            finish();
        }
    }

}
