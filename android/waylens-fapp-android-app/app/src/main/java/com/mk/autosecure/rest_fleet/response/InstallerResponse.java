package com.mk.autosecure.rest_fleet.response;

/**
 * Created by cloud on 2020/6/29.
 */
public class InstallerResponse {
    private String username;
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "InstallerResponse{" +
                "username='" + username + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}
