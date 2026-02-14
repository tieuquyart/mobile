package com.mk.autosecure.libs.qualifiers;

/**
 * Created by DoanVT on 2017/8/10.
 */

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import auto.parcel.AutoParcel;

/**
 * Marks an {@link AutoParcel @AutoParcel}-annotated type for proper Gson serialization.
 * <p>
 * This annotation is needed because the {@linkplain Retention retention} of {@code @AutoParcel}
 * does not allow reflection at runtime.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface AutoGson {
}