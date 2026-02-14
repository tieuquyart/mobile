package com.mk.autosecure;

import android.annotation.SuppressLint;
import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.activity.DebugMenuActivity;
import com.mk.autosecure.ui.activity.ProfileActivity;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;


/**
 * Created by DoanVT on 2017/7/24.
 * Email: doanvt-hn@mk.com.vn
 */

public class SimpleFragment extends Fragment {
    public static final String TAG = SimpleFragment.class.getSimpleName();

    Context context;

    AppComponent component;

    @BindView(R.id.user_avatar)
    ImageView iv_userAvatar;

    @BindView(R.id.user_name)
    TextView tv_userName;

    @OnClick(R.id.ll_alerts)
    public void onAlertsClicked() {
//        AlertActivity.launch(this.getActivity());
    }

    @OnClick(R.id.ll_debug)
    public void onDebugClicked() {
        DebugMenuActivity.launch(this.getActivity());
    }

    @OnClick(R.id.ll_devices)
    public void onDevicesClicked() {
    }

    @OnClick(R.id.ll_account)
    public void onAccountClicked() {
        if (component.currentUser().getUser() == null) {
            //LoginActivity.launch(this.getActivity());
        } else {
            ProfileActivity.launch(this.getActivity());
        }
    }

    @SuppressLint("CheckResult")
    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_simple, container, false);
        ButterKnife.bind(this, view);
        context = getActivity();
        component = HornApplication.getComponent();

        component.currentUser().observable()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::updateUserInfo, new ServerErrorHandler(TAG));

        return view;
    }
/**
 * Cập nhật thông tin user
 */
    public void updateUserInfo(Optional<User> userOptional) {
        User user = userOptional.getIncludeNull();
        if (user == null) {
            Logger.t(TAG).d("user == null");
            tv_userName.setText("");
            iv_userAvatar.setImageDrawable(getResources().getDrawable((R.drawable.ic_person_outline_black_24dp)));
            return;
        }
        Glide.with(this)
                .load(user.avatar())
                .centerCrop()
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .placeholder(R.drawable.ic_person_outline_black_24dp)
                .into(iv_userAvatar);

        tv_userName.setText(!TextUtils.isEmpty(user.displayName()) ? user.displayName() : user.name());
    }
}
