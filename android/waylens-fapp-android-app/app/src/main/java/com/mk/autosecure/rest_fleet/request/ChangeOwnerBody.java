package com.mk.autosecure.rest_fleet.request;

public class ChangeOwnerBody {

    public String targetOwnerEmail;

    public String currentOwnerPassword;

    public ChangeOwnerBody(String targetOwnerEmail, String currentOwnerPassword) {
        this.targetOwnerEmail = targetOwnerEmail;
        this.currentOwnerPassword = currentOwnerPassword;
    }
}
