package com.mk.autosecure.libs;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxFragment;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.BundleUtils;

public class BaseFragment<ViewModelType extends FragmentViewModel> extends RxFragment implements FragmentLifecycleType {

    private static final String VIEW_MODEL_KEY = "FragmentViewModel";
    protected ViewModelType viewModel;

    /**
     * Called before `onCreate`, when a fragment is attached to its context.
     */
    @CallSuper
    @Override
    public void onAttach(final @NonNull Context context) {
        super.onAttach(context);
        Logger.d("onAttach %s", this.toString());
    }

    @CallSuper
    @Override
    public void onCreate(final @Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Logger.d("onCreate %s", this.toString());

        assignViewModel(savedInstanceState);

        if (viewModel != null) {
            viewModel.arguments(Optional.ofNullable(getArguments()));
        }
    }

    /**
     * Called when a fragment instantiates its user interface view, between `onCreate` and `onActivityCreated`.
     * Can return null for non-graphical fragments.
     */
    @CallSuper
    @Override
    public @Nullable
    View onCreateView(final @NonNull LayoutInflater inflater, final @Nullable ViewGroup container,
                      final @Nullable Bundle savedInstanceState) {
        final View view = super.onCreateView(inflater, container, savedInstanceState);
        Logger.d("onCreateView %s", this.toString());
        return view;
    }

    @CallSuper
    @Override
    public void onStart() {
        super.onStart();
        Logger.d("onStart %s", this.toString());
    }

    @CallSuper
    @Override
    public void onResume() {
        super.onResume();
        Logger.d("onResume %s", this.toString());

        assignViewModel(null);
        if (viewModel != null) {
            viewModel.onResume(this);
        }
    }

    @CallSuper
    @Override
    public void onPause() {
        super.onPause();
        Logger.d("onPause %s", this.toString());

        if (viewModel != null) {
            viewModel.onPause();
        }
    }

    @CallSuper
    @Override
    public void onStop() {
        super.onStop();
        Logger.d("onStop %s", this.toString());
    }

    /**
     * Called when the view created by `onCreateView` has been detached from the fragment.
     * The lifecycle subject must be pinged before it is destroyed by the fragment.
     */
    @CallSuper
    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

    @CallSuper
    @Override
    public void onDestroy() {
        super.onDestroy();
        Logger.d("onDestroy %s", this.toString());

        if (viewModel != null) {
            viewModel.onDestroy();
        }
    }

    /**
     * Called after `onDestroy` when the fragment is no longer attached to its activity.
     */
    @CallSuper
    @Override
    public void onDetach() {
        Logger.d("onDetach %s", this.toString());
        super.onDetach();

        if (getActivity() != null && getActivity().isFinishing()) {
            if (viewModel != null) {
                // Order of the next two lines is important: the lifecycle should update before we
                // complete the view publish subject in the view model.
                viewModel.onDetach();

                FragmentViewModelManager.getInstance().destroy(viewModel);
                viewModel = null;
            }
        }
    }

    @CallSuper
    @Override
    public void onSaveInstanceState(final @NonNull Bundle outState) {
        super.onSaveInstanceState(outState);

        final Bundle viewModelEnvelope = new Bundle();
        if (viewModel != null) {
            FragmentViewModelManager.getInstance().save(viewModel, viewModelEnvelope);
        }

        outState.putBundle(VIEW_MODEL_KEY, viewModelEnvelope);
    }

    synchronized private void assignViewModel(final @Nullable Bundle viewModelEnvelope) {
        if (viewModel == null) {
            final RequiresFragmentViewModel annotation = getClass().getAnnotation(RequiresFragmentViewModel.class);
            final Class<ViewModelType> viewModelClass = annotation == null ? null : (Class<ViewModelType>) annotation.value();
            if (viewModelClass != null) {
                viewModel = FragmentViewModelManager.getInstance().fetch(getActivity(),
                        viewModelClass,
                        BundleUtils.maybeGetBundle(viewModelEnvelope, VIEW_MODEL_KEY));
            }
        }
    }

    //assign ViewModel in advance
    synchronized public void setViewModel(Context context) {
        if (viewModel == null) {
            final RequiresFragmentViewModel annotation = getClass().getAnnotation(RequiresFragmentViewModel.class);
            final Class<ViewModelType> viewModelClass = annotation == null ? null : (Class<ViewModelType>) annotation.value();
            if (viewModelClass != null) {
                viewModel = FragmentViewModelManager.getInstance().fetch(context,
                        viewModelClass,
                        BundleUtils.maybeGetBundle(null, VIEW_MODEL_KEY));
            }
        }
    }

    public ViewModelType viewModel() {
        return viewModel;
    }
}
