package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class INOUTBody implements Serializable {
    int loginRQ;
    int logoutRQ;


    public INOUTBody(int loginRQ, int logoutRQ) {
        this.loginRQ = loginRQ;
        this.logoutRQ = logoutRQ;
    }

    public int getLoginRQ() {
        return loginRQ;
    }

    public void setLoginRQ(int loginRQ) {
        this.loginRQ = loginRQ;
    }

    public int getLogoutRQ() {
        return logoutRQ;
    }

    public void setLogoutRQ(int logoutRQ) {
        this.logoutRQ = logoutRQ;
    }
}
