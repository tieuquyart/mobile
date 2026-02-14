package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.ui.adapter.FenceListAdapter;
import android.widget.Toast;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.BooleanResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.FenceListBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.rest_fleet.response.FenceListResponse;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class DraftBoxActivity extends RxFragmentActivity {

    private final static String TAG = DraftBoxActivity.class.getSimpleName();

    public static void launch(Context context) {
        Intent intent = new Intent(context, DraftBoxActivity.class);
        context.startActivity(intent);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.refresh_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.rv_draft_box)
    RecyclerView rvDraftBox;

    private FenceListAdapter mFenceAdapter;
    private List<FenceListBean> fenceListBeans = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_draft_box);
        ButterKnife.bind(this);

        setupToolbar();
        initView();
    }

    @Override
    protected void onResume() {
        super.onResume();

        requestData();
    }

    @SuppressLint("CheckResult")
    private void requestData() {
        refreshLayout.setRefreshing(true);

        ApiClient.createApiService().getFenceList("unbind")
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .doFinally(() -> refreshLayout.setRefreshing(false))
                .subscribe(this::onFenceList,
                        throwable -> Logger.t(TAG).e("getFenceList throwable: " + throwable.getMessage()));
    }

    private void onFenceList(FenceListResponse response) {
        fenceListBeans = response.getFenceList();
        mFenceAdapter.setNewData(fenceListBeans);
    }

    private void initView() {
        refreshLayout.setOnRefreshListener(() -> {
            Logger.t(TAG).d("onRefresh");
            requestData();
        });

        rvDraftBox.setLayoutManager(new LinearLayoutManager(this));
        rvDraftBox.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
        mFenceAdapter = new FenceListAdapter(R.layout.item_draft_box_wrap);
        mFenceAdapter.setOperationListener(new FenceOperationListener() {
            @SuppressLint("CheckResult")
            @Override
            public void onClickItem(FenceListBean bean) {
                Logger.t(TAG).d("onClickItem: " + bean);
                ApiClient.createApiService().getFenceRuleList()
                        .subscribeOn(Schedulers.newThread())
                        .observeOn(AndroidSchedulers.mainThread())
                        .compose(bindToLifecycle())
                        .subscribe(response -> {
                            List<FenceRuleBean> ruleList = response.getFenceRuleList();
                            if (ruleList.size() >= 32) {
                                Toast.makeText(DraftBoxActivity.this, R.string.fence_reached_the_limit, Toast.LENGTH_SHORT).show();
                            } else {
                                AddFenceActivity.launch(DraftBoxActivity.this, bean);
                            }
                        }, throwable -> AddFenceActivity.launch(DraftBoxActivity.this, bean));
            }

            @Override
            public void onDeleteItem(FenceListBean bean) {
                if (bean != null) {
                    deleteFence(bean);
                }
            }
        });
        rvDraftBox.setAdapter(mFenceAdapter);
    }

    private void deleteFence(FenceListBean bean) {
        ApiClient.createApiService().deleteFence(bean.getFenceID())
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<BooleanResponse>() {
                    @Override
                    protected void onHandleSuccess(BooleanResponse data) {
                        if (data.result) {
                            mFenceAdapter.remove(fenceListBeans.indexOf(bean));
                        }
                    }
                });
    }

    private void setupToolbar() {
        tvToolbarTitle.setText(R.string.draft_box);
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    public interface FenceOperationListener {
        void onClickItem(FenceListBean bean);

        void onDeleteItem(FenceListBean bean);
    }
}
