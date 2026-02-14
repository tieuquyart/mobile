package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;

public class UserLogin implements Serializable {
    private String id;
    private String avatar;
    private String fleetId;
    private String fleetName;
    private String userName;
    private String realName;
    private String token;
    private Boolean twoStepEnabled;
    private String lastLogin;
    private String lastFaultyLogin;
    private int subscribed;
    private String createTime;
    private String updateTime;
    private int[] roleIds;
    private String roleIdString;
    private String[] roleNames;

    public Object getSubscribed() {
        return subscribed;
    }

    public void setSubscribed(int subscribed) {
        this.subscribed = subscribed;
    }

    public String getFleetId() {
        return fleetId;
    }

    public void setFleetId(String fleetId) {
        this.fleetId = fleetId;
    }

    public String getFleetName() {
        return fleetName;
    }

    public void setFleetName(String fleetName) {
        this.fleetName = fleetName;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = realName;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Boolean getTwoStepEnabled() {
        return twoStepEnabled;
    }

    public void setTwoStepEnabled(Boolean twoStepEnabled) {
        this.twoStepEnabled = twoStepEnabled;
    }

    public String getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(String lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getLastFaultyLogin() {
        return lastFaultyLogin;
    }

    public void setLastFaultyLogin(String lastFaultyLogin) {
        this.lastFaultyLogin = lastFaultyLogin;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    public int[] getRoleIds() {
        return roleIds;
    }

    public void setRoleIds(int[] roleIds) {
        this.roleIds = roleIds;
    }

    public String getRoleIdString() {
        return roleIdString;
    }

    public void setRoleIdString(String roleIdString) {
        this.roleIdString = roleIdString;
    }

    public String[] getRoleNames() {
        return roleNames;
    }

    public void setRoleNames(String[] roleNames) {
        this.roleNames = roleNames;
    }
}
