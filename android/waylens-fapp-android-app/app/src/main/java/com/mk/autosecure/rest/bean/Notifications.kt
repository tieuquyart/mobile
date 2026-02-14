package com.mk.autosecure.rest.bean

import java.io.Serializable

/**
 * Created by doanvt on 2022/11/02.
 */
class Notifications : Serializable {

    var notificationID: Long? = null

    var cameraSN: String? = null

    var content: NotificationContent? = null

    var isRead: Boolean? = null

    var createTime: Long? = null // timestamp

    class NotificationContent : Serializable {

        var notificationType: String? = null // DataUsage, DataPlan, OnlineStatus, AppVersion, Firmware, General

        var deviceType: String? = null // all, android, ios

        var link: String? = null

        var image: String? = null

        var message: String? = null

        var title: String? = null

        var body: String? = null

        var messageLocKey: String? = null

        var messageLocArgs: List<String>? = null

        var titleLocKey: String? = null

        var titleLocArgs: List<String>? = null

        var bodyLocKey: String? = null

        var bodyLocArgs: List<String>? = null

    }
}
