package com.mk.autosecure.rest.bean;

import java.io.Serializable;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class UserProfile implements Serializable {
    public String userID;
    public String userName;
    public String displayName;
    public String email;
    public String gender;
    public String birthday;
    public String region;
    public boolean isVerified;
    public String avatarUrl;
    public String avataThumbnailUrl;
    public Integer socialProviders;

    @Override
    public String toString() {
        return "UserProfile{" +
                "userID='" + userID + '\'' +
                ", userName='" + userName + '\'' +
                ", displayName='" + displayName + '\'' +
                ", email='" + email + '\'' +
                ", gender='" + gender + '\'' +
                ", birthday='" + birthday + '\'' +
                ", region='" + region + '\'' +
                ", isVerified=" + isVerified +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", avataThumbnailUrl='" + avataThumbnailUrl + '\'' +
                ", socialProviders=" + socialProviders +
                '}';
    }
}
