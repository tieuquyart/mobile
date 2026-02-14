package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;
import java.util.List;

public class PersonnelBean implements Serializable {

    public String name;

    public List<String> role;

    public boolean isVerified;

    public boolean isOwner;

    public String email;

    public String phoneNumber;

    public String driverID;

    public PersonnelBean(String name, List<String> role, boolean isVerified, boolean isOwner,
                         String email, String phoneNumber, String driverID) {
        this.name = name;
        this.role = role;
        this.isVerified = isVerified;
        this.isOwner = isOwner;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.driverID = driverID;
    }

    @Override
    public String toString() {
        return "PersonnelBean{" +
                "name='" + name + '\'' +
                ", role=" + role +
                ", isVerified=" + isVerified +
                ", isOwner=" + isOwner +
                ", email='" + email + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", driverID='" + driverID + '\'' +
                '}';
    }
}
