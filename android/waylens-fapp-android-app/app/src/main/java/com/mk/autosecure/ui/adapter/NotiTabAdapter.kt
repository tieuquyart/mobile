package com.mk.autosecure.ui.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.mk.autosecure.ui.fragment.ADSFragment
import com.mk.autosecure.ui.fragment.NotiFragment

class NotiTabAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm) {

    override fun getPageTitle(position: Int): CharSequence  = when (position){
        0 -> "Danh sách thông báo"
        1 -> "Tin quảng cáo"
        else -> ""
    }

    override fun getCount(): Int = 2

    override fun getItem(position: Int): Fragment = when (position) {
        0 -> NotiFragment.newInstance()
        1 -> ADSFragment.newInstance()
        else -> NotiFragment.newInstance()
    }
}