package com.mk.autosecure.viewmodels.fragment;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.BillingDataBean;
import com.mk.autosecure.rest_fleet.response.BillingDataResponse;
import com.mk.autosecure.ui.fragment.DataFleetFragment;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.rest.BaseObserver;

import java.util.List;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
public interface DataFleetFragmentViewModel {

    interface Inputs {
        void getHistoryBillingData();

        void getNowBillingData();
    }

    interface Outputs {
        Observable<List<BillingDataBean>> historyBillingData();

        Observable<BillingDataBean> nowBillingData();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();
    }

    final class ViewModel extends FragmentViewModel<DataFleetFragment> implements Inputs, Outputs, Errors {

        private static final String TAG = DataFleetFragmentViewModel.ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private BehaviorSubject<List<BillingDataBean>> historyBillingDataList = BehaviorSubject.create();

        private BehaviorSubject<BillingDataBean> nowBillingData = BehaviorSubject.create();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }

        @Override
        public void getHistoryBillingData() {
            ApiClient.createApiService().getHistoryDataBilling()
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<BillingDataResponse>() {
                        @Override
                        protected void onHandleSuccess(BillingDataResponse data) {
                            List<BillingDataBean> billings = data.getBillings();
                            historyBillingDataList.onNext(billings);
                        }
                    });
        }

        @Override
        public void getNowBillingData() {
            ApiClient.createApiService().getNowDataBilling()
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new BaseObserver<BillingDataBean>() {
                        @Override
                        protected void onHandleSuccess(BillingDataBean data) {
                            nowBillingData.onNext(data);
                        }
                    });
        }

        @Override
        public Observable<List<BillingDataBean>> historyBillingData() {
            return historyBillingDataList;
        }

        @Override
        public Observable<BillingDataBean> nowBillingData() {
            return nowBillingData;
        }
    }
}
