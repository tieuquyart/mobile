package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.List;

/**
 * Created by cloud on 2020/5/14.
 */
public class FenceRuleBean implements Serializable {

    /**
     * fenceRuleID : 4a3092ec888c4be99b93c46b3ac71f9d
     * name : New Zone (edited
     * fenceID : 17d92b2a2d
     * type : ["exit"]
     * scope : specific
     * createTime : 1589956075000
     * vehicleList : ["6b26462cf925cd5f7fd2210184cf1af6","655ce3fed1173c79c12e2bc95948ec94","fd8a230e5b6462db935ac7b6fd9fda2b","64e7d64b0488855beddbdf586bb89db5","6e00e092ba3d33385a8e4c2abdc42c5c","7ce2cfd743076f68ed5ec68f441710f7","d49fd2a45b8fbb1531e1e8403723a22b"]
     */

    private String fenceRuleID;
    private String name;
    private String fenceID;
    private String scope;
    private long createTime;
    private List<String> type;
    private List<String> vehicleList;

    public String getFenceRuleID() {
        return fenceRuleID;
    }

    public void setFenceRuleID(String fenceRuleID) {
        this.fenceRuleID = fenceRuleID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getFenceID() {
        return fenceID;
    }

    public void setFenceID(String fenceID) {
        this.fenceID = fenceID;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public List<String> getType() {
        return type;
    }

    public void setType(List<String> type) {
        this.type = type;
    }

    public List<String> getVehicleList() {
        return vehicleList;
    }

    public void setVehicleList(List<String> vehicleList) {
        this.vehicleList = vehicleList;
    }

    @Override
    public String toString() {
        return "FenceRuleBean{" +
                "fenceRuleID='" + fenceRuleID + '\'' +
                ", name='" + name + '\'' +
                ", fenceID='" + fenceID + '\'' +
                ", scope='" + scope + '\'' +
                ", createTime=" + createTime +
                ", type=" + type +
                ", vehicleList=" + vehicleList +
                '}';
    }
}
