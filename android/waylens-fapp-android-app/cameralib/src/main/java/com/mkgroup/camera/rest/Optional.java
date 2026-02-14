package com.mkgroup.camera.rest;

import java.util.NoSuchElementException;
import java.util.Objects;

/**
 * Created by doanvt on 2018/11/9.
 * Email：doanvt-hn@mk.com.vn
 */

public final class Optional<M> {

    private static final Optional<?> EMPTY = new Optional<>();
    private final M value; // 接收到的返回结果

    private Optional() {
        this.value = null;
    }

    private Optional(M var1) {
        this.value = Objects.requireNonNull(var1);
    }

    public static <M> Optional<M> empty() {
        return (Optional<M>) EMPTY;
    }

    public static <M> Optional<M> of(M var0) {
        return new Optional<>(var0);
    }

    public static <M> Optional<M> ofNullable(M var0) {
        return var0 == null ? empty() : of(var0);
    }

    // 判断返回结果是否为null
    public boolean isEmpty() {
        return this.value == null;
    }

    // 获取不能为null的返回结果，如果为null，直接抛异常，经过二次封装之后，这个异常最终可以在走向RxJava的onError()
    public M get() {
        if (this.value == null) {
            throw new NoSuchElementException("No value present");
        } else {
            return this.value;
        }
    }

    // 获取可以为null的返回结果
    public M getIncludeNull() {
        return value;
    }

}
