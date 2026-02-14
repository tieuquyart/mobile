package com.mk.autosecure.rest_fleet.request;

/**
 * Created by cloud on 2020/6/29.
 */
public class CreateInstallerBody {
    public String name;
    public String password;
    public String email;

    public CreateInstallerBody(String name, String password, String email) {
        this.name = name;
        this.password = password;
        this.email = email;
    }
}
