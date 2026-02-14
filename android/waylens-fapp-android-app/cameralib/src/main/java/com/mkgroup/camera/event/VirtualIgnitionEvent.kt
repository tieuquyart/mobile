package com.mkgroup.camera.event

import com.mkgroup.camera.CameraWrapper

/**
 * Created by cloud on 2021/8/22.
 */
data class VirtualIgnitionEvent(
    val camera: CameraWrapper,
    val enable: Boolean
) {
}