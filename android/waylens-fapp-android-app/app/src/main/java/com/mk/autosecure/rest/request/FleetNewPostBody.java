package com.mk.autosecure.rest.request;

public class FleetNewPostBody {
    public String contactEmail;
    public String contactMobile;
    public String contactName;
    public String name;

    public FleetNewPostBody(String contactEmail, String contactMobile, String contactName, String name) {
        this.contactEmail = contactEmail;
        this.contactMobile = contactMobile;
        this.contactName = contactName;
        this.name = name;
    }

    @Override
    public String toString() {
        return "FleetNewPostBody{" +
                "contactEmail='" + contactEmail + '\'' +
                ", contactMobile='" + contactMobile + '\'' +
                ", contactName='" + contactName + '\'' +
                ", name='" + name + '\'' +
                '}';
    }
}
