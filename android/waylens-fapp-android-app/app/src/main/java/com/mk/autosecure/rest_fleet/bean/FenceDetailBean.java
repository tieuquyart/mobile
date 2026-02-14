package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.List;

/**
 * Created by cloud on 2020/5/20.
 */
public class FenceDetailBean implements Serializable {

    /**
     * fenceID : 4148c1b5df
     * name : frontRule
     * polygon : [[31.19339,121.59829],[31.19528,121.60974],[31.19067,121.61029],[31.18876,121.60036],[31.19339,121.59829]]
     */

    private String fenceID;
    private String name;
    private String description;
    private List<List<Double>> polygon;

    /**
     * center : [121.66227,31.14342]
     * radius : 1609
     */

    private int radius;
    private List<Double> center;

    /**
     * createTime : 1589959504936
     * fenceRuleList : ["9f69df281c6d48b3b9d4933428631c7b"]
     */

    private long createTime;
    private List<FenceRuleBean> fenceRuleList;

    /**
     * address : {"country":"China","region":"Shanghai Shi","city":"","route":"Fang Dian Lu","streetNumber":"","address":"Fang Dian Lu, Pudong Xinqu, Shanghai Shi, China"}
     */

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

    public List<List<Double>> getPolygon() {
        return polygon;
    }

    public void setPolygon(List<List<Double>> polygon) {
        this.polygon = polygon;
    }

    public int getRadius() {
        return radius;
    }

    public void setRadius(int radius) {
        this.radius = radius;
    }

    public List<Double> getCenter() {
        return center;
    }

    public void setCenter(List<Double> center) {
        this.center = center;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public List<FenceRuleBean> getFenceRuleList() {
        return fenceRuleList;
    }

    public void setFenceRuleList(List<FenceRuleBean> fenceRuleList) {
        this.fenceRuleList = fenceRuleList;
    }

    public AddressBean getAddress() {
        return address;
    }

    public void setAddress(AddressBean address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "FenceDetailBean{" +
                "fenceID='" + fenceID + '\'' +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", polygon=" + polygon +
                ", radius=" + radius +
                ", center=" + center +
                ", createTime=" + createTime +
                ", fenceRuleList=" + fenceRuleList +
                ", address=" + address +
                '}';
    }
}
