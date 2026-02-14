package com.mkgroup.camera.command;

public class EvCamCommand {
    public final String category;
    public final String cmd;
    public final String param;

    public EvCamCommand(String category, String cmd, String param) {
        this.category = category;
        this.cmd = cmd;
        this.param = param;
    }

    @Override
    public String toString() {
        return "EvCamCommand{" +
                "category='" + category + '\'' +
                ", cmd='" + cmd + '\'' +
                ", param='" + param + '\'' +
                '}';
    }
}