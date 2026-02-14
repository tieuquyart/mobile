package com.mk.autosecure.libs;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.TypeAdapter;
import com.google.gson.TypeAdapterFactory;
import com.google.gson.reflect.TypeToken;
import com.mk.autosecure.libs.qualifiers.AutoGson;

/**
 * Created by DoanVT on 2017/8/10.
 */


public final class AutoParcelAdapterFactory implements TypeAdapterFactory {
    @SuppressWarnings("unchecked")
    @Override
    public <T> TypeAdapter<T> create(final @NonNull Gson gson, final @NonNull TypeToken<T> type) {
        final Class<? super T> rawType = type.getRawType();
        if (!rawType.isAnnotationPresent(AutoGson.class)) {
            return null;
        }

        final String packageName = rawType.getPackage().getName();
        final String className = rawType.getName().substring(packageName.length() + 1).replace('$', '_');
        final String autoParcelName = packageName + ".AutoParcel_" + className;

        try {
            final Class<?> autoParcelType = Class.forName(autoParcelName);
            return (TypeAdapter<T>) gson.getAdapter(autoParcelType);
        } catch (final ClassNotFoundException e) {
            throw new RuntimeException("Could not load AutoParcel type " + autoParcelName, e);
        }
    }
}
