package com.mkgroup.camera.glide_adapter;

import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;

import java.io.InputStream;

/**
 * Created by doanvt on 2016/6/18.
 * Email: doanvt-hn@mk.com.vn
 */
public interface SnipeRequestFactory {
    VdbRequest<InputStream> create(ClipPos clipPos, VdbRequestFuture<InputStream> future, boolean isIgnorable);
}
