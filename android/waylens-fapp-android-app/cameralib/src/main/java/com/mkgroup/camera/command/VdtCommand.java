package com.mkgroup.camera.command;

/**
 * Created by DoanVT on 2017/7/27.
 */

public class VdtCommand {
    public final int domain;
    public final int cmdType;
    public final String parameter1;
    public final String parameter2;

    public VdtCommand(int domain, int cmd, String p1, String p2) {
        this.domain = domain;
        cmdType = cmd;
        parameter1 = p1;
        parameter2 = p2;
    }
}