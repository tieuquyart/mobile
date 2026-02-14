package com.mk.autosecure.rest_fleet.request;

public class UserRoleBody {
    public int[] selectedRoles;
    public int userId;

    public UserRoleBody(int[] selectedRoles, int userId) {
        this.selectedRoles = selectedRoles;
        this.userId = userId;
    }
}
