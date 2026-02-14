package com.mk.autosecure.libs;

/**
 * Created by DoanVT on 2017/7/25.
 */

import static com.mk.autosecure.libs.utils.Constants.KEY_SHOW_UPDATE;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Pair;

import androidx.annotation.AnimRes;
import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.BundleUtils;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.NetworkUtils;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.AppLastVersionBean;
import com.mk.autosecure.ui.DialogHelper;
import com.mk.autosecure.ui.data.ActivityResult;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.android.ActivityEvent;
import com.trello.rxlifecycle2.components.support.RxFragmentActivity;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Action;
import io.reactivex.subjects.PublishSubject;

@SuppressLint("CheckResult")
public abstract class BaseActivity<ViewModelType extends ActivityViewModel> extends RxFragmentActivity implements ActivityLifecycleType {

    private final PublishSubject<Optional<Void>> back = PublishSubject.create();
    private static final String VIEW_MODEL_KEY = "viewModel";
    protected ViewModelType viewModel;

    private static final String TAG = BaseActivity.class.getSimpleName();

    /**
     * Get viewModel.
     */
    public ViewModelType viewModel() {
        return viewModel;
    }

    /**
     * Sends activity result data to the view model.
     */
    @CallSuper
    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final @Nullable Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        viewModel.activityResult(ActivityResult.create(requestCode, resultCode, intent));
    }

    @CallSuper
    @Override
    protected void onCreate(final @Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Logger.d("onCreate %s", this.toString());
        assignViewModel(savedInstanceState);
        viewModel.intent(getIntent());
        if(NetworkUtils.isNetworkConnected(this) || NetworkUtils.isMobileConnected(this)){
            checkAppLastVersion();
        }
    }

    private void checkAppLastVersion() {
        if(!Constants.isShowUpdate()) {
            new Thread(() -> ApiClient.createApiService().getAppLastVersion()
                    .observeOn(AndroidSchedulers.mainThread())
                    .compose(bindToLifecycle())
                    .subscribe(response -> {
                        if (response.isSuccess()) {
                            AppLastVersionBean bean = response.data;
                            if (bean.versionCode > BuildConfig.VERSION_CODE) {
                                DialogHelper.showPopupUpdateApp(BaseActivity.this, bean.forceUpdate, () -> {
                                    if (!StringUtils.isEmpty(bean.storeUrl)) {
                                        startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(bean.storeUrl)));
                                        PreferenceUtils.putBoolean(KEY_SHOW_UPDATE, !bean.forceUpdate);
                                    }
                                });
                            }
                        } else {
                            NetworkErrorHelper.handleExpireToken(BaseActivity.this, response);
                        }
                    }, new ServerErrorHandler(TAG))).start();
        }
    }

    /**
     * Called when an activity is set to `singleTop` and it is relaunched while at the top of the activity stack.
     */
    @CallSuper
    @Override
    protected void onNewIntent(final Intent intent) {
        super.onNewIntent(intent);
        viewModel.intent(intent);
    }

    @CallSuper
    @Override
    protected void onStart() {
        super.onStart();
        Logger.d("onStart %s", this.toString());

        back.compose(bindUntilEvent(ActivityEvent.STOP))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(__ -> goBack(), new ServerErrorHandler());
    }

    @CallSuper
    @Override
    protected void onResume() {
        super.onResume();
        Logger.d("onResume %s", this.toString());
//        checkAppLastVersion();
        assignViewModel(null);
        if (viewModel != null) {
            viewModel.onResume(this);
        }
    }

    @CallSuper
    @Override
    protected void onPause() {
        super.onPause();
        Logger.d("onPause %s", this.toString());

        if (viewModel != null) {
            viewModel.onPause();
        }
    }

    @CallSuper
    @Override
    protected void onStop() {
        super.onStop();
        Logger.d("onStop %s", this.toString());
    }

    @CallSuper
    @Override
    protected void onDestroy() {
        super.onDestroy();
        Logger.d("onDestroy %s", this.toString());
        if (isFinishing()) {
            if (viewModel != null) {
                ActivityViewModelManager.getInstance().destroy(viewModel);
                viewModel = null;
            }
        }
    }

    /**
     * @deprecated Use {@link #back()} instead.
     * <p>
     * In rare situations, onBackPressed can be triggered after {@link #onSaveInstanceState(Bundle)} has been called.
     * This causes an {@link IllegalStateException} in the fragment manager's `checkStateLoss` method, because the
     * UI state has changed after being saved. The sequence of events might look like this:
     * <p>
     * onSaveInstanceState -> onStop -> onBackPressed
     * <p>
     * To avoid that situation, we need to ignore calls to `onBackPressed` after the activity has been saved. Since
     * the activity is stopped after `onSaveInstanceState` is called, we can create an observable of back events,
     * and a subscription that calls super.onBackPressed() only when the activity has not been stopped.
     */
    @CallSuper
    @Override
    @Deprecated
    public void onBackPressed() {
        back();
    }

    /**
     * Call when the user wants triggers a back event, e.g. clicking back in a toolbar or pressing the device back button.
     */
    public void back() {
        back.onNext(Optional.empty());
    }

    /**
     * Override in subclasses for custom exit transitions. First item in pair is the enter animation,
     * second item in pair is the exit animation.
     */
    protected @Nullable
    Pair<Integer, Integer> exitTransition() {
        return null;
    }

    @CallSuper
    @Override
    protected void onSaveInstanceState(final @NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        Logger.d("onSaveInstanceState %s", this.toString());

        final Bundle viewModelEnvelope = new Bundle();
        if (viewModel != null) {
            ActivityViewModelManager.getInstance().save(viewModel, viewModelEnvelope);
        }

        outState.putBundle(VIEW_MODEL_KEY, viewModelEnvelope);
    }

    protected final void startActivityWithTransition(final @NonNull Intent intent, final @AnimRes int enterAnim,
                                                     final @AnimRes int exitAnim) {
        startActivity(intent);
        overridePendingTransition(enterAnim, exitAnim);
    }

    /**
     * Returns the {@link HornApplication} instance.
     */
    protected @NonNull
    HornApplication application() {
        return (HornApplication) getApplication();
    }

    /**
     * Triggers a back press with an optional transition.
     */
    protected void goBack() {
        super.onBackPressed();

        final Pair<Integer, Integer> exitTransitions = exitTransition();
        if (exitTransitions != null) {
            overridePendingTransition(exitTransitions.first, exitTransitions.second);
        }
    }

    private void assignViewModel(final @Nullable Bundle viewModelEnvelope) {
        if (viewModel == null) {
            final RequiresActivityViewModel annotation = getClass().getAnnotation(RequiresActivityViewModel.class);
            final Class<ViewModelType> viewModelClass = annotation == null ? null : (Class<ViewModelType>) annotation.value();
            if (viewModelClass != null) {
                viewModel = ActivityViewModelManager.getInstance().fetch(this,
                        viewModelClass,
                        BundleUtils.maybeGetBundle(viewModelEnvelope, VIEW_MODEL_KEY));
            }
        }
    }

}
