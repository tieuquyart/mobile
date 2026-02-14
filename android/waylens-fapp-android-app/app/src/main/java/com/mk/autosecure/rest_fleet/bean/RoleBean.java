package com.mk.autosecure.rest_fleet.bean;

public class RoleBean {
    private String createTime;
    private int createUserId;
    private String description;
    private int id;
    private String roleName;
    private String sortno;
    private String updateTime;

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public int getCreateUserId() {
        return createUserId;
    }

    public void setCreateUserId(int createUserId) {
        this.createUserId = createUserId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getSortno() {
        return sortno;
    }

    public void setSortno(String sortno) {
        this.sortno = sortno;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    @Override
    public String toString() {
        return "RoleBean{" +
                "createTime='" + createTime + '\'' +
                ", createUserId=" + createUserId +
                ", description='" + description + '\'' +
                ", id=" + id +
                ", roleName='" + roleName + '\'' +
                ", sortno='" + sortno + '\'' +
                ", updateTime='" + updateTime + '\'' +
                '}';
    }
}
