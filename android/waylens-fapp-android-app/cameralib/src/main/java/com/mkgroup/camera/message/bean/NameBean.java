package com.mkgroup.camera.message.bean;

public class NameBean {

    /**
     * name : Waylens
     */

    private String name;

    public NameBean(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "NameBean{" +
                "name='" + name + '\'' +
                '}';
    }
}
