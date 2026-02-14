package com.mk.autosecure.eid.view_model

import android.content.Context
import android.graphics.Bitmap
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

class InforViewModel(context: Context) : ViewModel() {


    var checkSuccess = MutableLiveData<Boolean>().apply { false }
    var checkReloadNfc = MutableLiveData<Boolean>().apply { false }
    var checkShowLoadingNfc = MutableLiveData<Boolean>().apply { false }

    var checkMoc = MutableLiveData<Boolean>().apply { false }
    var checkSod = MutableLiveData<Boolean>().apply { false }

    var checkReloadCamera = MutableLiveData<Boolean>().apply { false }

    var checkNfcReady = MutableLiveData<Int>().apply { 0 }


    fun setSuccess(check: Boolean) {
        checkSuccess.value = check
    }

    fun setReloadNfc(check: Boolean) {
        checkReloadNfc.value = check
    }

    fun setShowLoadingNfc(check: Boolean) {
        checkShowLoadingNfc.value = check
    }

    fun setCheckMoc(check: Boolean) {
        checkMoc.value = check
    }

    fun setCheckSod(check: Boolean) {
        checkSod.value = check
    }


    fun setNfcReady(check: Int) {
        checkNfcReady.value = check
    }

    fun setReloadCamera(check: Boolean) {
        checkReloadCamera.value = check
    }


    internal class InforFactory(private val context: Context) : ViewModelProvider.Factory {
        override fun <T : ViewModel?> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(InforViewModel::class.java)) {
                return InforViewModel(context) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }
}