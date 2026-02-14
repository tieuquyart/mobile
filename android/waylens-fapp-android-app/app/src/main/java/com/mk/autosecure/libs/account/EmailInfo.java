package com.mk.autosecure.libs.account;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.preference.StringPreference;
import com.mkgroup.camera.preference.StringPreferenceType;
import com.mkgroup.camera.rest.Optional;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/11/13.
 * Email: doanvt-hn@mk.com.vn
 */

public class EmailInfo {
    private static final String TAG = EmailInfo.class.getSimpleName();

    private final StringPreferenceType emailPreference;
    private final Gson gson;
    private final BehaviorSubject<Optional<Data>> emailData = BehaviorSubject.create();

    public EmailInfo(final @NonNull StringPreference emailPreference, final @NonNull Gson gson) {
        this.emailPreference = emailPreference;
        this.gson = gson;

        emailData.skip(1)
                .filter(dataOptional -> dataOptional.getIncludeNull() != null)
                .subscribe(d -> emailPreference.set(gson.toJson(d.get(), Data.class)));

        emailData.onNext(Optional.ofNullable(gson.fromJson(emailPreference.get(), Data.class)));
    }

    public @Nullable
    Optional<Data> getData() {
        return emailData.getValue();
    }

    public void refresh(final @NonNull Data info) {
        Logger.t(TAG).d("email %s", info.email);
        emailPreference.set(gson.toJson(info, Data.class));
        emailData.onNext(Optional.ofNullable(info));
    }

    public Observable<Optional<Data>> asObservable() {
        return emailData.hide();
    }

    public static class Data {
        public String email;
        public long resetTimeStamp;

        public Data(String email, long resetTimeStamp) {
            this.email = email;
            this.resetTimeStamp = resetTimeStamp;
        }
    }
}
