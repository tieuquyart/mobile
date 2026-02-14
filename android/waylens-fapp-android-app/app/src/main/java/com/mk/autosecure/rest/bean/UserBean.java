package com.mk.autosecure.rest.bean;

import com.mk.autosecure.libs.account.User;

import java.io.Serializable;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class UserBean implements Serializable {
    public String userID;

    public String userName;

    public String displayName;

    public String avatarUrl;

    public boolean isVerified;

    public User toUser() {
        return User.builder()
                .id(userID)
                .name(userName)
                .displayName(displayName)
                .avatar(avatarUrl)
                .verified(isVerified)
                .build();
    }
}