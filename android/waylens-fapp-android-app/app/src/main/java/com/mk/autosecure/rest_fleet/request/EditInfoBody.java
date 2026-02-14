package com.mk.autosecure.rest_fleet.request;

import java.util.List;

public class EditInfoBody {

    public String email;

    public String name;

    public String phoneNumber;

    public List<String> role;

    public EditInfoBody(String email, String name, String phoneNumber) {
        this.email = email;
        this.name = name;
        this.phoneNumber = phoneNumber;
    }

    public void setRole(List<String> role) {
        this.role = role;
    }
}
