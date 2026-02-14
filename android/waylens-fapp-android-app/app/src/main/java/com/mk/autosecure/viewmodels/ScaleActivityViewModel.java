package com.mk.autosecure.viewmodels;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.ScaleActivity;
import com.mkgroup.camera.model.ClipPos;

import io.reactivex.Observable;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by doanvt on 2018/5/17.
 * Email：doanvt-hn@mk.com.vn
 */

public interface ScaleActivityViewModel {

    interface Inputs {
        void updateVideoTime(long absTime /* in millis*/);

        void clipPosChanged(ClipPos clipPos);

        void startPosChanged(int startPos);

        void endPosChanged(int endPos);
    }

    interface Outputs {
        Observable<Long> playTime();

        Observable<ClipPos> clipPosChanged();

        Observable<Integer> startPos();

        Observable<Integer> endPos();
    }

    final class ViewModel extends ActivityViewModel<ScaleActivity> implements Inputs, Outputs {

        private final static String TAG = ViewModel.class.getSimpleName();

        private final PublishSubject<Long> playTime = PublishSubject.create();
        private final PublishSubject<ClipPos> clipPos = PublishSubject.create();
        private final PublishSubject<Integer> startPos = PublishSubject.create();
        private final PublishSubject<Integer> endPos = PublishSubject.create();

        public final ScaleActivityViewModel.Inputs inputs = this;
        public final ScaleActivityViewModel.Outputs outputs = this;

        public ViewModel(AppComponent component) {
            super(component);
        }

        @Override
        public void updateVideoTime(long absTime) {
            this.playTime.onNext(absTime);
        }

        @Override
        public void clipPosChanged(ClipPos clipPos) {
            this.clipPos.onNext(clipPos);
        }

        @Override
        public void startPosChanged(int startPos) {
            this.startPos.onNext(startPos);
        }

        @Override
        public void endPosChanged(int endPos) {
            this.endPos.onNext(endPos);
        }

        @Override
        public Observable<Long> playTime() {
            return playTime;
        }

        @Override
        public Observable<ClipPos> clipPosChanged() {
            return clipPos;
        }

        @Override
        public Observable<Integer> startPos() {
            return startPos;
        }

        @Override
        public Observable<Integer> endPos() {
            return endPos;
        }
    }
}
