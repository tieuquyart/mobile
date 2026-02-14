package com.mk.autosecure.libs.account;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.libs.utils.ObjectUtils;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.rest_fleet.bean.UserLogin;
import com.mk.autosecure.rest_fleet.response.LogInResponse;

import io.reactivex.Observable;

/**
 * Created by DoanVT on 2017/8/9.
 */

public abstract class CurrentUserType {

    /**
     * Call when a user has logged in. The implementation of `CurrentUserType` is responsible
     * for persisting the user and access token.
     */
    public abstract void login(final @NonNull User newUser, final @NonNull String accessToken);

    public abstract void login(final @NonNull String accessToken);

    public abstract void login(final @NonNull LogInResponse logInResponse);
    /**
     * Call when a user should be logged out.
     */
    public abstract void logout();

    /*

     */

    /**
     * Get the logged in user's access token.
     */
    public abstract @Nullable
    String getAccessToken();

    /**
     * Updates the persisted current user with a fresh, new user.
     */
    public abstract void refreshUser(final @NonNull User user);

    public abstract void refreshUserLogin(final @NonNull UserLogin userLogin);

    /**
     * Returns an observable representing the current user. It emits immediately
     * with the current user, and then again each time the user is updated.
     */
    public abstract @NonNull
    Observable<Optional<User>> observable();

    /**
     * Returns the most recently emitted user from the user observable.
     *
     * @deprecated Prefer {@link #observable()}
     */

    public abstract @Nullable
    User getUser();

//    public abstract @Nullable
//    FleetUser getFleetUser();

    public abstract @Nullable
    UserLogin getUserLogin();
    /**
     * Returns a boolean that determines if there is a currently logged in user or not.
     *
     * @deprecated Prefer {@link #observable()}
     */

    public boolean exists() {
        return getUser() != null;
    }

    /**
     * Emits a boolean that determines if the user is logged in or not. The returned
     * observable will emit immediately with the logged in state, and then again
     * each time the current user is updated.
     */
    public @NonNull
    Observable<Boolean> isLoggedIn() {
        return observable().map(ObjectUtils::isNotNull);
    }

    /**
     * Emits only values of a logged in user. The returned observable may never emit.
     */
    public @NonNull
    Observable<Optional<User>> loggedInUser() {
        return observable().filter(ObjectUtils::isNotNull);
    }

    /**
     * Emits only values of a logged out user. The returned observable may never emit.
     */
    public @NonNull
    Observable<Optional<User>> loggedOutUser() {
        return observable().filter(ObjectUtils::isNull);
    }
}
