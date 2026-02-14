package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;

/**
 * Created by cloud on 2020/5/13.
 */
public class FenceListBean implements Serializable {

    /**
     * fenceID : 9a15d4fbe8
     * name : 圆形3
     * description :
     * createTime : 1589943247772
     * address : {"country":"China","region":"Shanghai Shi","city":"","route":"Fang Dian Lu","streetNumber":"","address":"Fang Dian Lu, Pudong Xinqu, Shanghai Shi, China"}
     */

    private String fenceID;
    private String name;
    private String description;
    private long createTime;
    private AddressBean address;

    public String getFenceID() {
        return fenceID;
    }

    public void setFenceID(String fenceID) {
        this.fenceID = fenceID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public AddressBean getAddress() {
        return address;
    }

    public void setAddress(AddressBean address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "FenceListBean{" +
                "fenceID='" + fenceID + '\'' +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", createTime=" + createTime +
                ", address=" + address +
                '}';
    }
}
