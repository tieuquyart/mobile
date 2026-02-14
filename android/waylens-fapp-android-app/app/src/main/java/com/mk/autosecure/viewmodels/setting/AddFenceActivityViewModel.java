package com.mk.autosecure.viewmodels.setting;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.rest_fleet.bean.FenceDetailBean;
import com.mk.autosecure.rest_fleet.bean.FenceListBean;
import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;
import com.mk.autosecure.ui.activity.settings.AddFenceActivity;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

/**
 * deprecated - doanVT
 * */

public interface AddFenceActivityViewModel {

    interface Inputs {
        void proceed(int index);

        void loading(int visibility);

        void fenceName(String name);

        void fenceID(String fenceID);

        void fenceType(String[] fenceType);

        void fenceScope(String scope);

        void fenceListBean(FenceListBean listBean);

        void fenceRuleBean(FenceRuleBean ruleBean);

        void fenceDetailBean(FenceDetailBean detailBean);
    }

    interface Outputs {

        Observable<Integer> nextStep();

        Observable<Integer> showLoading();

        Observable<FenceDetailBean> detailBean();
    }

    final class ViewModel extends ActivityViewModel<AddFenceActivity> implements Inputs, Outputs {

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
        }

        private CurrentUser currentUser;
        private final BehaviorSubject<Integer> nextStep = BehaviorSubject.create();
        private final BehaviorSubject<Integer> showLoading = BehaviorSubject.create();

        public final Inputs inputs = this;
        public final Outputs outputs = this;

        public String fenceName;
        public String fenceID;
        public String[] fenceType;
        public String fenceScope;

        public boolean editMode;

        public FenceListBean listBean;
        public FenceRuleBean ruleBean;

        private final BehaviorSubject<FenceDetailBean> detailBean = BehaviorSubject.create();

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public Observable<Integer> nextStep() {
            return nextStep;
        }

        @Override
        public Observable<Integer> showLoading() {
            return showLoading;
        }

        @Override
        public Observable<FenceDetailBean> detailBean() {
            return detailBean;
        }

        @Override
        public void proceed(int index) {
            nextStep.onNext(index);
        }

        @Override
        public void loading(int visibility) {
            showLoading.onNext(visibility);
        }

        @Override
        public void fenceName(String name) {
            this.fenceName = name;
        }

        @Override
        public void fenceID(String fenceID) {
            this.fenceID = fenceID;
        }

        @Override
        public void fenceType(String[] fenceType) {
            this.fenceType = fenceType;
        }

        @Override
        public void fenceScope(String scope) {
            this.fenceScope = scope;
        }

        @Override
        public void fenceListBean(FenceListBean listBean) {
            this.listBean = listBean;
            this.editMode = true;
            if (listBean != null) {
                this.fenceName = listBean.getName();
                this.fenceID = listBean.getFenceID();
            }
        }

        @Override
        public void fenceRuleBean(FenceRuleBean ruleBean) {
            this.ruleBean = ruleBean;
            this.editMode = true;
            if (ruleBean != null) {
                this.fenceName = ruleBean.getName();
                this.fenceID = ruleBean.getFenceID();
                this.fenceScope = ruleBean.getScope();
                this.fenceType = ruleBean.getType().toArray(new String[0]);
            }
        }

        @Override
        public void fenceDetailBean(FenceDetailBean detailBean) {
            Logger.t("test").d("fenceDetailBean: " + detailBean);
            this.detailBean.onNext(detailBean);
        }
    }
}