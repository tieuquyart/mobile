package com.mk.autosecure.eid

import android.content.Context
import android.icu.text.CaseMap
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.mk.autosecure.R

abstract class BaseFragment : Fragment() {
    val TAG = javaClass.simpleName
    companion object var activity: ReadCardActivity? = null

    private var frManager: FragmentManager? = null
    protected var tvBar: TextView? = null
    protected var back: ImageView? = null
    protected var setting: ImageView? = null
    override fun onAttach(context: Context) {
        super.onAttach(context)
        activity = context as ReadCardActivity
        this.frManager = fragmentManager
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        back = activity!!.findViewById(R.id.back)
//        tvBar = activity!!.findViewById(R.id.tvBar)
//        setting = activity!!.findViewById(R.id.setting)


        if (titleId() != 0){
            tvBar?.setText(titleId())
            tvBar?.tag = tagTitle()
        }

        if (!backCheck()) {
            back?.visibility = View.INVISIBLE
        } else {
            back?.visibility = View.VISIBLE
        }
        back?.setOnClickListener(View.OnClickListener {
            activity!!.supportFragmentManager.popBackStack()
        })

        if (!settingCheck()) {
            setting?.visibility = View.INVISIBLE
        } else {
            setting?.visibility = View.VISIBLE
        }
//        setting?.setOnClickListener(View.OnClickListener {
//            val transaction = activity!!.supportFragmentManager.beginTransaction()
//            Utils.replaceFragment(transaction, SettingFragment(), TAG_SETTING)
//        })
        val root: View?
        root = if (layoutId() != 0) {
            inflater.inflate(layoutId(), null)
        } else super.onCreateView(inflater, container, savedInstanceState)
        return root
    }

    fun showSettingButton() {
        setting?.visibility = View.VISIBLE
    }

    fun setTitile(value:String, tag:String){
        tvBar?.text = value
        tvBar?.tag = tag
    }

    protected abstract fun backCheck(): Boolean
    protected abstract fun settingCheck(): Boolean

    protected abstract fun layoutId(): Int
    protected abstract fun titleId(): Int
    protected abstract fun tagTitle(): String

    protected fun refreshFragment() {
        frManager!!.beginTransaction()
            .detach(this).attach(this).commitAllowingStateLoss()
    }

    fun backFragment() {
        activity!!.onBackPressed()
    }
}