package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatDialog;

import com.mk.autosecure.R;

/**
 * Created by DoanVT on 2017/11/21.
 * Email: doanvt-hn@mk.com.vn
 */

public class DialogUtils {

    public static AppCompatDialog createProgressDialog(Context context) {
        AppCompatDialog dialog = new AppCompatDialog(context);
        View dialogView = LayoutInflater.from(context).inflate(R.layout.dialog_progress, null);
        TextView textView = dialogView.findViewById(R.id.tvMsg);
        textView.setVisibility(View.GONE);
        //dialog.setCanceledOnTouchOutside(false);
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {

            }
        });

        dialog.setContentView(dialogView);

        View view = (View) dialogView.getParent();
        if (view != null) {
            view.setBackgroundResource(android.R.color.transparent);
        }
        return dialog;
    }

    public static AppCompatDialog createProgressDialogWithMsg(Context context, String msg) {
        AppCompatDialog dialog = new AppCompatDialog(context);
        View dialogView = LayoutInflater.from(context).inflate(R.layout.dialog_progress, null);
        TextView textView = dialogView.findViewById(R.id.tvMsg);
        textView.setText(msg);
        dialog.setCanceledOnTouchOutside(false);
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {

            }
        });

        dialog.setContentView(dialogView);

        View view = (View) dialogView.getParent();
        if (view != null) {
            view.setBackgroundResource(android.R.color.transparent);
        }
        return dialog;
    }

}
