package com.mkgroup.camera.message.bean

class InoutBean {
    var loginRQ: Int? = null
    var logoutRQ: Int? = null

    constructor(loginRQ: Int?, logoutRQ: Int?) {
        this.loginRQ = loginRQ
        this.logoutRQ = logoutRQ
    }


}