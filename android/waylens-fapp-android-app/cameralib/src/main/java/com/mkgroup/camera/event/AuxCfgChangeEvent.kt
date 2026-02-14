package com.mkgroup.camera.event

import com.mkgroup.camera.CameraWrapper
import com.mkgroup.camera.message.bean.AuxCfgModel

/**
 * Created by cloud on 2022/4/20.
 */
data class AuxCfgChangeEvent(
    val camera: CameraWrapper,
    val auxCfgModel: AuxCfgModel
) {
}