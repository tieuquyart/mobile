package com.mk.autosecure.rest.reponse

import com.mk.autosecure.rest.bean.Notifications

/**
 * Created by cchen on 2019/6/10.
 */

class NotificationListResponse {

    var notifications: List<Notifications>? = null
    var hasMore: Boolean? = null
    var unreadCount: Int? = null

    override fun toString(): String {
        return "NotificationListResponse{" +
                "notifications=" + notifications +
                ", hasMore=" + hasMore +
                ", unreadCount=" + unreadCount +
                '}'.toString()
    }
}
