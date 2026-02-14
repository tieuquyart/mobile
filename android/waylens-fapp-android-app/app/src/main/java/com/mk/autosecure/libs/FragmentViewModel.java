package com.mk.autosecure.libs; /**
 * Created by DoanVT on 2017/7/25.
 * Email: doanvt-hn@mk.com.vn
 */


import android.content.Context;
import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.AppComponent;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.FragmentEvent;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.utils.ObjectUtils;

import io.reactivex.Observable;
import io.reactivex.ObservableTransformer;
import io.reactivex.subjects.PublishSubject;

/**
 * A view model bound to the lifecycle and arguments of a Fragment, from ATTACH to DETACH.
 */
public class FragmentViewModel<ViewType extends FragmentLifecycleType> {

    private final PublishSubject<ViewType> viewChange = PublishSubject.create();
    private final Observable<ViewType> view = viewChange.filter(ObjectUtils::isNotNull);

    private final PublishSubject<Optional<Bundle>> arguments = PublishSubject.create();

    public FragmentViewModel(AppComponent appComponent) {
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
        dropView();
    }

    @CallSuper
    protected void onDetach() {
        Logger.d("onDetach %s", this.toString());
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

    protected final
    @NonNull
    Observable<ViewType> view() {
        return view;
    }

    /**
     * Takes bundle arguments from the view.
     */
    public void arguments(final @NonNull Optional<Bundle> bundleOptional) {
        this.arguments.onNext(bundleOptional);
    }

    protected
    @NonNull
    Observable<Optional<Bundle>> arguments() {
        return arguments;
    }

    /**
     * By composing this transformer with an observable you guarantee that every observable in your view model
     * will be properly completed when the view model completes.
     * <p>
     * It is required that *every* observable in a view model do `.compose(bindToLifecycle())` before calling
     * `subscribe`.
     */
    public
    @NonNull
    <T> ObservableTransformer<T, T> bindToLifecycle() {
        return (Observable<T> source) -> source.takeUntil(
                view.switchMap(FragmentLifecycleType::lifecycle)
                        .filter(FragmentEvent.DETACH::equals)
        );
    }
}
