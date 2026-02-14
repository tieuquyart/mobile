package com.mk.autosecure.libs.account;

import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.mk.autosecure.libs.qualifiers.AutoGson;

import auto.parcel.AutoParcel;

/**
 */

@AutoGson
@AutoParcel
public abstract class User implements Parcelable {
    public abstract String avatar();

    public abstract String id();

    public abstract String name();

    public abstract String displayName();

    public abstract Boolean verified();

    @AutoParcel.Builder
    public abstract static class Builder {
        public abstract Builder avatar(String __);

        public abstract Builder id(String __);

        public abstract Builder name(String __);

        public abstract Builder displayName(String __);

        public abstract Builder verified(Boolean __);

        public abstract User build();
    }

    public static Builder builder() {
        return new AutoParcel_User.Builder();
    }

    public @NonNull
    String param() {
        return String.valueOf(this.id());
    }

    public abstract Builder toBuilder();

    public static User create(String avatar, String id, String name, String displayName, Boolean verified) {
        return builder()
                .avatar(avatar)
                .id(id)
                .name(name)
                .displayName(displayName)
                .verified(verified)
                .build();
    }
}

