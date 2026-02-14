package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.adapter.PersonnelAdapter;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.UsersBean;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class PersonnelActivity extends RxAppCompatActivity {

    private final static String TAG = PersonnelActivity.class.getSimpleName();

    @BindView(R.id.refresh_personnel_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_personnel)
    RecyclerView rvPersonnel;

    @OnClick(R.id.btn_add_member)
    public void addMember() {
        Logger.t(TAG).d("addMember");
        MemberInfoActivity.launch(this, null);
    }

    private PersonnelAdapter adapter;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, PersonnelActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_personnel);
        ButterKnife.bind(this);

        initView();
    }

    private void setToolbar() {
        ((Toolbar) findViewById(R.id.toolbar)).setNavigationOnClickListener(v -> finish());
    }

    @Override
    protected void onResume() {
        super.onResume();

        requestData();
    }

    @SuppressLint("CheckResult")
    private void requestData() {
        refreshLayout.setRefreshing(true);

        ApiClient.createApiService().getUserList(HornApplication.getComponent().currentUser().getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(userListResponse -> {
                    Logger.t(TAG).d("personnelBeans: " + userListResponse);
                    List<UsersBean>userList = userListResponse.getData();
                    adapter.setNewData(userList);
                }, throwable -> {
                    Logger.t(TAG).e("personnelBeans throwable: " + throwable.getMessage());
                    NetworkErrorHelper.handleCommonError(PersonnelActivity.this, throwable);
                });

    }

    private void initView() {
        setToolbar();

        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            requestData();
        });

        rvPersonnel.setLayoutManager(new LinearLayoutManager(this));
        rvPersonnel.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));

        adapter = new PersonnelAdapter(this);
        rvPersonnel.setAdapter(adapter);
        adapter.setOperationListener(bean -> {
            Logger.t(TAG).d("onClickItem: " + bean);
            MemberInfoActivity.launch(PersonnelActivity.this, bean);
        });
    }

    public interface OperationListener {
        void onClickItem(UsersBean bean);
    }

}
