package com.mk.autosecure.rest_fleet.bean;

import java.util.List;

public class NonDriverInfoBean {

    /**
     * name : frontManagerName
     * email : Manager@wayelns.com
     * isVerified : false
     * isOwner : false
     * phoneNumber : 123
     * role : ["FleetManager"]
     */

    private String name;
    private String email;
    private boolean isVerified;
    private boolean isOwner;
    private String phoneNumber;
    private List<String> role;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isIsVerified() {
        return isVerified;
    }

    public void setIsVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }

    public boolean isIsOwner() {
        return isOwner;
    }

    public void setIsOwner(boolean isOwner) {
        this.isOwner = isOwner;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public List<String> getRole() {
        return role;
    }

    public void setRole(List<String> role) {
        this.role = role;
    }
}
