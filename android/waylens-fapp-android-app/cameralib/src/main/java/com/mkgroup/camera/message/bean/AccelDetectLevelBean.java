package com.mkgroup.camera.message.bean;

public class AccelDetectLevelBean {

    /**
     * levels : ["soft", "normal", "hard"]
     * level : normal
     */

    private String levels;
    private String level;

    public AccelDetectLevelBean(String level) {
        this.level = level;
    }

    public String getLevels() {
        return levels;
    }

    public void setLevels(String levels) {
        this.levels = levels;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }
}
