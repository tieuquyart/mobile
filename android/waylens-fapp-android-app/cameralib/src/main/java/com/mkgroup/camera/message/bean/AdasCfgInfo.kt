package com.mkgroup.camera.message.bean

import java.io.Serializable

/**
 * Created by cloud on 2021/8/22.
 */
data class AdasCfgInfo(
        // optional
        var enable: Boolean?, // ADAS_Enabled
        var fcw: Double?, // ForwardCollisionTTC 0.5s~5s
        var fcwr: Int?, // ForwardCollisionTR
        var hdw: Double?, // HeadwayMonitorTTC 0.5s~5s
        var hdwr: Int?, // HeadwayMonitorTR
        var cht: Double?, // CameraHeight
        var vwt: Double?, // VehicleWidth
        var rtc: Double? = null // RightOffsetToCenter
) : Serializable {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as AdasCfgInfo

        if (enable != other.enable) return false
        if (fcw != other.fcw) return false
        if (fcwr != other.fcwr) return false
        if (hdw != other.hdw) return false
        if (hdwr != other.hdwr) return false
        if (cht != other.cht) return false
        if (vwt != other.vwt) return false
        if (rtc != other.rtc) return false

        return true
    }

    override fun hashCode(): Int {
        var result = enable?.hashCode() ?: 0
        result = 31 * result + (fcw?.hashCode() ?: 0)
        result = 31 * result + (fcwr ?: 0)
        result = 31 * result + (hdw?.hashCode() ?: 0)
        result = 31 * result + (hdwr ?: 0)
        result = 31 * result + (cht?.hashCode() ?: 0)
        result = 31 * result + (vwt?.hashCode() ?: 0)
        result = 31 * result + (rtc?.hashCode() ?: 0)
        return result
    }
}