package com.mk.autosecure.libs.qualifiers;

/**
 * Created by DoanVT on 2017/7/25.
 */

import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import com.mk.autosecure.libs.ActivityViewModel;


/**
 * Created by doanvt on 2022/11/02.
 */
@Inherited
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresActivityViewModel {
    Class<? extends ActivityViewModel> value();
}
