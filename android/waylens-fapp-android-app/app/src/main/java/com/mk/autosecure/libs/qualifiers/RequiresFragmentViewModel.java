package com.mk.autosecure.libs.qualifiers;

import com.mk.autosecure.libs.FragmentViewModel;

import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by DoanVT on 2017/7/25.
 */

@Inherited
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresFragmentViewModel {
    Class<? extends FragmentViewModel> value();
}
