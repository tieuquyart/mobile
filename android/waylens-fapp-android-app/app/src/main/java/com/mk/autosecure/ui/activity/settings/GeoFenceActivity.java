package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.ui.adapter.FenceRuleListAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.rest_fleet.response.FenceRuleListResponse;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class GeoFenceActivity extends RxFragmentActivity {

    private final static String TAG = GeoFenceActivity.class.getSimpleName();

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, GeoFenceActivity.class);
        activity.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.refresh_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_fencing)
    RecyclerView rvFencing;

    @OnClick(R.id.ll_draft_box)
    public void intentDraft() {
        DraftBoxActivity.launch(this);
    }

    private FenceRuleListAdapter mFenceAdapter;

    public void test() {
//        AddFenceBody body = new AddFenceBody();
//        body.fenceType = "designated";
//        body.name = "test";
//        body.center = new ArrayList<>();
//        body.center.add(121.601385);
//        body.center.add(31.1910802);
//        body.radius = 1000;
//
//        ApiClient.createApiService().addFence(body)
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe();

//        ApiClient.createApiService().deleteFence("43facb1a13")
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe();

//        ApiClient.createApiService().getFenceDetail("43facb1a13")
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe();

//        FenceStatusBody body = new FenceStatusBody();
//        body.enable = false;
//        ApiClient.createApiService().setFenceStatus("e3c379a40f", body)
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_geo_fence);
        ButterKnife.bind(this);

        setToolbar();
        initView();
    }

    @SuppressLint("CheckResult")
    private void setToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
        toolbar.getMenu().clear();
        toolbar.inflateMenu(R.menu.menu_add_fence);
        toolbar.setOnMenuItemClickListener(item -> {
            if (item.getItemId() == R.id.add) {
                ApiClient.createApiService().getFenceRuleList()
                        .subscribeOn(Schedulers.newThread())
                        .observeOn(AndroidSchedulers.mainThread())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            List<FenceRuleBean> ruleList = response.getFenceRuleList();
                            if (ruleList.size() >= 32) {
                                Toast.makeText(GeoFenceActivity.this, R.string.fence_reached_the_limit, Toast.LENGTH_SHORT).show();
                            } else {
                                AddFenceActivity.launch(GeoFenceActivity.this);
                            }
                        }, throwable -> AddFenceActivity.launch(GeoFenceActivity.this));
            }
            return false;
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

//        ApiClient.createApiService().getFenceList("bind")
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe(this::onFenceList,
//                        throwable -> Logger.t(TAG).e("getFenceList throwable: " + throwable.getMessage()));

        requestData();
    }

    @SuppressLint("CheckResult")
    private void requestData() {
        refreshLayout.setRefreshing(true);

        ApiClient.createApiService().getFenceRuleList()
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(this::onFenceRuleList,
                        throwable -> Logger.t(TAG).e("getFenceRuleList throwable: " + throwable.getMessage()));
    }

    private void onFenceRuleList(FenceRuleListResponse response) {
        List<FenceRuleBean> fenceRuleList = response.getFenceRuleList();
        mFenceAdapter.setNewData(fenceRuleList);
    }

    private void initView() {
        tvToolbarTitle.setText(R.string.geo_fencing);

        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            requestData();
        });

        rvFencing.setLayoutManager(new LinearLayoutManager(this));
        rvFencing.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
        mFenceAdapter = new FenceRuleListAdapter(R.layout.item_fence_rule);
        mFenceAdapter.setOperationListener(new FenceOperationListener() {
            @Override
            public void onClickItem(FenceRuleBean bean) {
                Logger.t(TAG).d("onClickItem: " + bean);
                FenceDetailActivity.launch(GeoFenceActivity.this, bean);
            }
        });
        rvFencing.setAdapter(mFenceAdapter);

//        ApiClient.createApiService().getFences(0, 20)
//                .compose(Transformers.switchSchedulers())
//                .compose(bindToLifecycle())
//                .subscribe();
    }

//    private void onFenceList(FenceListResponse response) {
//        List<FenceListBean> fenceList = response.getFenceList();
//        mFenceAdapter.setNewData(fenceList);
//    }

    public interface FenceOperationListener {
        void onClickItem(FenceRuleBean bean);
    }
}
