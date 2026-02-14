package com.mk.autosecure.eid

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentTransaction
import com.mk.autosecure.R
import com.mkgroup.camera.utils.StringUtils
import java.util.*

class Utils{

    companion object{

        var NFC_available = 2
        var NFC_is_not_enabled = 1
        var NFC_is_not_supported = 0
        fun showNFCNotReady(context: Context?,message: String) {
            Toast.makeText(context,message, Toast.LENGTH_LONG).show()
        }
        fun replace(
            transaction: FragmentTransaction,
            canBack: Boolean,
            animation: Boolean,
            fragment: Fragment?,
            tag: String?
        ) {
            if (animation) transaction.setCustomAnimations(
                R.anim.right_in, R.anim.out_left, R.anim.left_in, R.anim.out_right
            )
            if (canBack) transaction.addToBackStack(tag)
            transaction.replace(R.id.content, fragment!!).commitAllowingStateLoss()
        }

        fun replaceFragment(transaction: FragmentTransaction, fragment: Fragment?, tag: String?){
            replace(transaction, true, true, fragment, tag)
        }

        fun set1stFragment(transaction: FragmentTransaction, fragment: Fragment?, tag: String?) {
            replace(transaction, false, false, fragment, tag)
        }

        fun initLanguage(context: Context?) {
            val res = Objects.requireNonNull(context)?.resources
            val conf = res?.configuration
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR1) {
                conf?.setLocale(Locale(UserPreference.getInstance().loadLanguage()))
            }
            res?.updateConfiguration(conf, null)
        }

         fun refreshResource(viewGroup: ViewGroup, context: Context?) {
            val count = viewGroup.childCount
            for (i in 0 until count) {
                val view = viewGroup.getChildAt(i)
                if (view is ViewGroup) refreshResource(view, context) else {
                    if (view.tag == null) {
                        continue
                    }
                    val resId: Int = context!!.resources.getIdentifier(
                        view.tag.toString(),
                        "string",
                        context.packageName
                    )
                    if (view is EditText) {
                        view.hint = context.getString(resId)
                    } else if (view is TextView) {
                        view.text = context.getString(resId)
                    } else if (view is Button) {
                        view.text = context.getString(resId)
                    }
                }
            }
        }


        fun isNetworkConnected(context: Context): Boolean {
            val connectivityManager =
                context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val info = connectivityManager.activeNetworkInfo
            return if (info != null && info.isConnected) {
                val detailedState = info.detailedState
                when (detailedState) {
                    NetworkInfo.DetailedState.VERIFYING_POOR_LINK -> {
                        false
                    }
                    NetworkInfo.DetailedState.BLOCKED -> {
                        false
                    }
                    NetworkInfo.DetailedState.DISCONNECTED -> {
                        false
                    }
                    NetworkInfo.DetailedState.DISCONNECTING -> {
                        false
                    }
                    else -> detailedState != NetworkInfo.DetailedState.SUSPENDED
                }
            } else {
                false
            }
        }
    }


}