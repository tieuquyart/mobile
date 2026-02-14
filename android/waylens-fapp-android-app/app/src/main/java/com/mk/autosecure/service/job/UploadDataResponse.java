package com.mk.autosecure.service.job;

import com.mkgroup.camera.utils.ToStringUtils;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class UploadDataResponse {
    public int result;
    public String jid;
    public String guid;
    public int moment_id;

    @Override
    public String toString() {
        return ToStringUtils.getString(this);
    }
}
