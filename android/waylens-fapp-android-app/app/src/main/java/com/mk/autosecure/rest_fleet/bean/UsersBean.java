package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.Arrays;
import java.util.List;

public class UsersBean implements Serializable {
    private String avatar;
    private String createTime;
    private int id;
    private String lastFaultyLogin;
    private String lastLogin;
    private String realName;
    private String roleIdString;
    private int[] roleIds;
    private List<String> roleNames;
    private String token;
    private Boolean trueStepEnabled;
    private String updateTime;
    private String userName;

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLastFaultyLogin() {
        return lastFaultyLogin;
    }

    public void setLastFaultyLogin(String lastFaultyLogin) {
        this.lastFaultyLogin = lastFaultyLogin;
    }

    public String getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(String lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = realName;
    }

    public String getRoleIdString() {
        return roleIdString;
    }

    public void setRoleIdString(String roleIdString) {
        this.roleIdString = roleIdString;
    }

    public int[] getRoleIds() {
        return roleIds;
    }

    public void setRoleIds(int[] roleIds) {
        this.roleIds = roleIds;
    }

    public List<String> getRoleNames() {
        return roleNames;
    }

    public void setRoleNames(List<String> roleNames) {
        this.roleNames = roleNames;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Boolean getTrueStepEnabled() {
        return trueStepEnabled;
    }

    public void setTrueStepEnabled(Boolean trueStepEnabled) {
        this.trueStepEnabled = trueStepEnabled;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    @Override
    public String toString() {
        return "UsersBean{" +
                "avatar='" + avatar + '\'' +
                ", createTime='" + createTime + '\'' +
                ", id=" + id +
                ", lastFaultyLogin='" + lastFaultyLogin + '\'' +
                ", lastLogin='" + lastLogin + '\'' +
                ", realName='" + realName + '\'' +
                ", roleIdString='" + roleIdString + '\'' +
                ", roleIds=" + Arrays.toString(roleIds) +
                ", roleNames=" + roleNames +
                ", token='" + token + '\'' +
                ", trueStepEnabled=" + trueStepEnabled +
                ", updateTime='" + updateTime + '\'' +
                ", userName='" + userName + '\'' +
                '}';
    }
}
