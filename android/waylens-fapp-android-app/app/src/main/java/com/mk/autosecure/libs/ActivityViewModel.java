package com.mk.autosecure.libs;

/**
 * Created by DoanVT on 2017/7/25.
 */

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.util.Pair;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.ui.data.ActivityResult;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.mk.autosecure.libs.utils.ObjectUtils;

import io.reactivex.Observable;
import io.reactivex.ObservableTransformer;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.subjects.PublishSubject;

public class ActivityViewModel<ViewType extends ActivityLifecycleType> {

    private final PublishSubject<ViewType> viewChange = PublishSubject.create();
    private final Observable<ViewType> view = viewChange.filter(ObjectUtils::isNotNull);

    private final CompositeDisposable disposable = new CompositeDisposable();

    private final PublishSubject<ActivityResult> activityResult = PublishSubject.create();

    private final PublishSubject<Intent> intent = PublishSubject.create();

    public ActivityViewModel(AppComponent component) {
    }

    @CallSuper
    protected void onCreate(final @NonNull Context context, final @Nullable Bundle savedInstanceState) {
        Logger.d("onCreate %s", this.toString());
        dropView();
    }

    @CallSuper
    protected void onResume(final @NonNull ViewType view) {
        Logger.d("onResume %s", this.toString());
        onTakeView(view);
    }

    @CallSuper
    protected void onPause() {
        Logger.d("onPause %s", this.toString());
        dropView();
    }

    @CallSuper
    protected void onDestroy() {
        Logger.d("onDestroy %s", this.toString());

        disposable.clear();
        viewChange.onComplete();
    }

    private void onTakeView(final @NonNull ViewType view) {
//        Logger.d("onTakeView %s %s", this.toString(), view.toString());
        viewChange.onNext(view);
    }

    private void dropView() {
//        Logger.d("dropView %s", this.toString());
//        viewChange.onNext(null);
    }

    protected @NonNull
    Observable<ActivityResult> activityResult() {
        return activityResult;
    }

    /**
     * Takes activity result data from the activity.
     */
    public void activityResult(final @NonNull ActivityResult activityResult) {
        this.activityResult.onNext(activityResult);
    }

    protected @NonNull
    Observable<Intent> intent() {
        return intent;
    }

    /**
     * Takes intent data from the view.
     */
    public void intent(final @NonNull Intent intent) {
        this.intent.onNext(intent);
    }

    /**
     * By composing this transformer with an observable you guarantee that every observable in your view model
     * will be properly completed when the view model completes.
     * <p>
     * It is required that *every* observable in a view model do `.compose(bindToLifecycle())` before calling
     * `subscribe`.
     */
    public @NonNull
    <T> ObservableTransformer<T, T> bindToLifecycle() {
        return (Observable<T> source) -> source.takeUntil(
                view.switchMap(v -> v.lifecycle().map(e -> Pair.create(v, e)))
                        .filter(ve -> isFinished(ve.first, ve.second))
        );
    }

    /**
     * Determines from a view and lifecycle event if the view's life is over.
     */
    private boolean isFinished(final @NonNull ViewType view, final @NonNull ActivityEvent event) {

        if (view instanceof BaseActivity) {
            return event == ActivityEvent.DESTROY && ((BaseActivity) view).isFinishing();
        }

        return event == ActivityEvent.DESTROY;
    }
}
