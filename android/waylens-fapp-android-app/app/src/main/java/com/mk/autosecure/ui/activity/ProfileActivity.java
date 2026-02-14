package com.mk.autosecure.ui.activity;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.ViewAnimator;

import androidx.appcompat.widget.Toolbar;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.CircleTransform;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.rest.ApiService;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.bean.UserProfile;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.request.LogInPostBody;
import com.mk.autosecure.rest_fleet.response.LogInResponse;
import com.mk.autosecure.service.job.UploadDataEvent;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.activity.settings.ChangePwdActivity;

import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.RxActivity;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.ui.activity.settings.UsernameActivity;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import retrofit2.Response;

/**
 * Created by DoanVT on 2017/8/10.
 * Email: doanvt-hn@mk.com.vn
 */

public class ProfileActivity extends RxActivity {

    private static final String TAG = ProfileActivity.class.getSimpleName();

    public static void launch(Context context) {
        Intent intent = new Intent(context, ProfileActivity.class);
        context.startActivity(intent);
    }

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.va_account)
    ViewAnimator vaAccount;

    //horn
    @BindView(R.id.logout_button)
    Button btnLogout;

    @BindView(R.id.tv_username)
    TextView tv_username;

    @BindView(R.id.tv_email)
    TextView tv_email;

    @BindView(R.id.iv_avatar)
    ImageView iv_avatar;

    @BindView(R.id.pb_avatar_upload)
    ProgressBar pbAvatarUpload;

    @BindView(R.id.tv_name_fleet)
    TextView tvNameFleet;

    @BindView(R.id.tv_userName_fleet)
    TextView tvUserNameFleet;

    @BindView(R.id.tv_role_fleet)
    TextView tvRoleFleet;

    @BindView(R.id.tv_email_fleet)
    TextView tvEmailFleet;

    @BindView(R.id.toolbar)
    Toolbar toolbar;


    @OnClick(R.id.iv_avatar)
    public void onBtnAvatarClicked() {
        //AvatarActivity.launch(this, false);
    }

    @OnClick(R.id.btn_addPhoto)
    public void onBtnAddPhotoClicked() {
        //AvatarActivity.launch(this, true);
        showBottomMenu();
    }

    @OnClick(R.id.rl_account_name)
    public void onAccountNameClicked() {
        UsernameActivity.launch(this);
    }

    @OnClick(R.id.ll_account_change_password)
    public void onChangePwdClicked() {
        ChangePwdActivity.launch(this);
    }

    @OnClick(R.id.logout_button)
    public void logOut() {
        DialogHelper.showLogoutConfirmDialog(ProfileActivity.this,
                () -> {
                    currentUser.logout();
                    LoginActivity.launchClearTask(this);
//                    RxBus.getDefault().post(new AlertChangeEvent(AlertChangeEvent.TYPE_LOG_OUT, null));
                });
    }

    private CurrentUser currentUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        ButterKnife.bind(this);

        initToolbar();
        currentUser = HornApplication.getComponent().currentUser();

        initView();
    }

    private void initToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
        tvToolbarTitle.setText(getString(R.string.account_info));
    }

    private void initView() {

        if (Constants.isFleet()) {
            tvEmailFleet.setVisibility(View.GONE);
            vaAccount.setDisplayedChild(1);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        initEvent();
    }

    @SuppressLint("CheckResult")
    private void initEvent() {
        currentUser.observable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::refreshUserInfo, new ServerErrorHandler(TAG));

        currentUser.profileObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::refreshUserProfile, new ServerErrorHandler(TAG));

        currentUser.userLoginObservable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::refreshUserLoginInfo, new ServerErrorHandler(TAG));

        RxBus.getDefault()
                .toObservable(UploadDataEvent.class)
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onUploadAvatarEvent, new ServerErrorHandler(TAG));
    }

    private void onUploadAvatarEvent(UploadDataEvent uploadDataEvent) {
        Logger.t(TAG).d("onUploadAvatarEvent: " + uploadDataEvent.getWhat());
        switch (uploadDataEvent.getWhat()) {
            case UPLOAD_WHAT_START:
            case UPLOAD_WHAT_PROGRESS:
                if (pbAvatarUpload.getVisibility() != View.VISIBLE) {
                    pbAvatarUpload.setVisibility(View.VISIBLE);
                }
                break;
            case UPLOAD_WHAT_FINISHED:
                pbAvatarUpload.setVisibility(View.GONE);
//                fetchUserProfile();
                break;
            case UPLOAD_WHAT_ERROR:
                pbAvatarUpload.setVisibility(View.GONE);
                Toast.makeText(this, R.string.error_network_unknown, Toast.LENGTH_SHORT).show();
                break;
            default:
                break;
        }
    }

    private void refreshUserInfo(Optional<User> userOptional) {
        User user = userOptional.getIncludeNull();
        if (user != null) {
            tv_username.setText(!TextUtils.isEmpty(user.displayName()) ? user.displayName() : user.name());
            btnLogout.setVisibility(View.VISIBLE);

            Logger.t(TAG).e("user avatar = " + user.avatar());

            Glide.with(this)
                    .load(user.avatar())
                    .centerCrop()
                    .transform(new CircleTransform(this))
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.setting_user)
                    .crossFade()
                    .into(iv_avatar);
        } else {
            tv_username.setText("");
            btnLogout.setVisibility(View.GONE);
            Glide.clear(iv_avatar);
            iv_avatar.setImageDrawable(null);
        }
    }

    private void showBottomMenu() {
        BottomSheetDialog bottomSheetDialog = new BottomSheetDialog(this);
        View view = getLayoutInflater().inflate(R.layout.dialog_choose_avatar, null);
        bottomSheetDialog.setContentView(view);
        View tvChoosePhoto = bottomSheetDialog.findViewById(R.id.tv_choose_photo);
        View tvTakePhoto = bottomSheetDialog.findViewById(R.id.tv_take_photo);
        View tvCancel = bottomSheetDialog.findViewById(R.id.tv_cancel);

        if (tvTakePhoto != null) {
            tvTakePhoto.setOnClickListener(v -> {
                AvatarActivity.launch(ProfileActivity.this, true);
                bottomSheetDialog.dismiss();
            });
        }
        if (tvChoosePhoto != null) {
            tvChoosePhoto.setOnClickListener(v -> {
                AvatarActivity.launch(ProfileActivity.this, false);
                bottomSheetDialog.dismiss();
            });
        }
        if (tvCancel != null) {
            tvCancel.setOnClickListener(v -> bottomSheetDialog.dismiss());
        }
        bottomSheetDialog.show();
    }

    private void refreshUserProfile(Optional<UserProfile> userProfileOptional) {
        UserProfile userProfile = userProfileOptional.getIncludeNull();
        Logger.t(TAG).d("user profile = " + ToStringUtils.toString(userProfile));
    }

    /**
     * hiển thị thông tin userLogin
     *
     * @param userOptional data userLogin
     */
    private void refreshUserLoginInfo(Optional<UserLogin> userOptional) {
        UserLogin userLogin = userOptional.getIncludeNull();
        if (userLogin != null) {
            tvNameFleet.setText(userLogin.getFleetName());

            tvUserNameFleet.setText(userLogin.getUserName());
            tvRoleFleet.setText(userLogin.getRoleNames()[0]);

        } else {
            tvNameFleet.setText("");

            tvUserNameFleet.setText("");
            tvRoleFleet.setText("");
        }
    }

    private void fetchUserProfile() {
        if (Constants.isFleet()) {
            LogInPostBody body = new LogInPostBody("doanvt", "doanvt");
            ApiClient.createApiService().logInFleet(body)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<Response<LogInResponse>>() {
                        @Override
                        protected void onHandleSuccess(Response<LogInResponse> data) {
                            Logger.t(TAG).d("getUserInfo: " + data.toString());
                            HornApplication.getComponent().currentUser().refreshProfile(data.body().getUserLogin());
                        }
                    });
        } else {
            ApiService.createApiService().getMyProfile()
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<UserProfile>() {
                        @Override
                        protected void onHandleSuccess(UserProfile data) {
                            Logger.t(TAG).d("getMyProfile: " + data.toString());
                            HornApplication.getComponent().currentUser().refreshProfile(data);
                        }
                    });
        }
    }

}