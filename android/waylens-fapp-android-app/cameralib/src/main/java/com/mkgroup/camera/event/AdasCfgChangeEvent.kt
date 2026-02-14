package com.mkgroup.camera.event

import com.mkgroup.camera.message.bean.AdasCfgInfo
import com.mkgroup.camera.CameraWrapper


/**
 * Created by cloud on 2021/8/22.
 */
data class AdasCfgChangeEvent(
    val camera: CameraWrapper,
    val adasCfgInfo: AdasCfgInfo
) {
}