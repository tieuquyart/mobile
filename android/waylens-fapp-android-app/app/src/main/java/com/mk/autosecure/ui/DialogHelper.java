package com.mk.autosecure.ui;

import static com.mk.autosecure.libs.utils.Constants.KEY_SHOW_UPDATE;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Point;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.afollestad.materialdialogs.MaterialDialog;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.DataCleanManager;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.libs.utils.ViewUtils;
import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.ui.activity.settings.FirmwareUpdateActivity;
import com.mk.autosecure.ui.fragment.interfaces.PopupWindowCallback;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.Logger;

import java.util.Locale;

import io.reactivex.functions.Action;

/**
 * Created by DoanVT on 2017/12/18.
 * Email: doanvt-hn@mk.com.vn
 */
@SuppressLint("NewApi")
public class DialogHelper {

    private final static String TAG = DialogHelper.class.getSimpleName();

    /**
     * func show popUp when click item vehicle
     *
     * @param context  this activity
     * @param object   VehicleInfoBean or ...
     * @param parent   point show View
     * @param callback handle item popup click callback
     */
    public static void showPopupMenu(final Activity context, View parent, Object object, PopupWindowCallback callback) {
        int[] location = new int[2];
        parent.getLocationOnScreen(location);

        //Initialize the Point with x, and y positions
        Point point = new Point();
        point.x = location[0];
        point.y = location[1];
        // Inflate the popup_layout.xml
        LayoutInflater layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        PopupWindow changeStatusPopUp = new PopupWindow(context);
        View layout = null;
        if (object instanceof VehicleInfoBean) {
            VehicleInfoBean bean = (VehicleInfoBean) object;
            layout = layoutInflater.inflate(R.layout.popup_menu_custom_layout, null);
            // Creating the PopupWindow
            changeStatusPopUp.setContentView(layout);
            changeStatusPopUp.setWidth(ViewUtils.dp2px(156));
            changeStatusPopUp.setHeight(LinearLayout.LayoutParams.WRAP_CONTENT);
            changeStatusPopUp.setFocusable(true);

            LinearLayout llGoDetail = layout.findViewById(R.id.ll_go_detail);
            llGoDetail.setVisibility(View.GONE);
            LinearLayout llGoEdit = layout.findViewById(R.id.ll_go_edit);
            LinearLayout llRemove = layout.findViewById(R.id.ll_remove);
            LinearLayout llAddDriver = layout.findViewById(R.id.ll_add_driver);
            TextView tv_add_driver = layout.findViewById(R.id.tv_add_driver);
            TextView tv_add_camera = layout.findViewById(R.id.tv_add_camera);
            LinearLayout llAddCamera = layout.findViewById(R.id.ll_add_camera);

            tv_add_driver.setText(context.getString(R.string.assign_driver));
            tv_add_camera.setText(StringUtils.isEmpty(bean.getCameraSn()) ? context.getString(R.string.add_camera) : context.getString(R.string.replace_camera));

            //setOnClick
            llGoDetail.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llGoEdit.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llRemove.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llAddDriver.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llAddCamera.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
        } else if (object instanceof FleetCameraBean) {
            FleetCameraBean bean = (FleetCameraBean) object;
            layout = layoutInflater.inflate(R.layout.popup_menu_device_layout, null);
            // Creating the PopupWindow
            changeStatusPopUp.setContentView(layout);
            changeStatusPopUp.setWidth(ViewUtils.dp2px(156));
            changeStatusPopUp.setHeight(LinearLayout.LayoutParams.WRAP_CONTENT);
            changeStatusPopUp.setFocusable(true);

            LinearLayout llGoDetail = layout.findViewById(R.id.ll_go_detail);
            LinearLayout llGoEdit = layout.findViewById(R.id.ll_go_edit);
            LinearLayout llRemove = layout.findViewById(R.id.ll_remove);
            LinearLayout llActive = layout.findViewById(R.id.ll_go_active);

            if (bean.getStatus() == 0) {
                llActive.setVisibility(View.VISIBLE);
                llGoEdit.setVisibility(View.VISIBLE);
            } else {
                llActive.setVisibility(View.GONE);
                llGoEdit.setVisibility(View.GONE);
            }

            //setOnClick
            llGoDetail.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llGoEdit.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llRemove.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llActive.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
        } else if (object instanceof DriverInfoBean) {
            DriverInfoBean infoBean = (DriverInfoBean) object;
            layout = layoutInflater.inflate(R.layout.popup_menu_driver_layout, null);
            changeStatusPopUp.setContentView(layout);
            changeStatusPopUp.setWidth(ViewUtils.dp2px(156));
            changeStatusPopUp.setHeight(LinearLayout.LayoutParams.WRAP_CONTENT);
            changeStatusPopUp.setFocusable(true);

            LinearLayout llGoDetail = layout.findViewById(R.id.ll_go_detail);
            LinearLayout llGoEdit = layout.findViewById(R.id.ll_go_edit);
            LinearLayout llRemove = layout.findViewById(R.id.ll_remove);

            //setOnClick
            llGoDetail.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llGoEdit.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
            llRemove.setOnClickListener(v -> onClickItemPopup(changeStatusPopUp, v.getId(), callback));
        }


        // Some offset to align the popup a bit to the left, and a bit down, relative to button's position.
        int widthPopup = 0;
        int OFFSET_Y = 70;

        //Clear the default translucent background
        changeStatusPopUp.setBackgroundDrawable(new BitmapDrawable());

        // Displaying the popup at the specified location, + offsets.
        if (layout != null)
            changeStatusPopUp.showAtLocation(layout, Gravity.NO_GRAVITY, point.x + widthPopup, point.y + OFFSET_Y);
    }

    private static void onClickItemPopup(PopupWindow popupWindow, int id, PopupWindowCallback callback) {
        assert popupWindow != null;
        popupWindow.dismiss();
        callback.onCallback(id);
    }

    /**
     * popup update app
     */
    public static MaterialDialog showPopupUpdateApp(@NonNull final Context context, boolean isForceUpdate, Action posClick) {
        return !isForceUpdate ? new MaterialDialog.Builder(context)
                .title(R.string.new_app_version_title)
                .content(R.string.app_new_version_content)
                .positiveText(R.string.dialog_action_download)
                .negativeText(R.string.cancel)
                .onPositive(((dialog, which) -> {
                    if (posClick != null){
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }))
                .onNegative(((dialog, which) -> {
                    PreferenceUtils.putBoolean(KEY_SHOW_UPDATE,true);
                }))
                .cancelListener(new DialogInterface.OnCancelListener() {
                    @Override
                    public void onCancel(DialogInterface dialog) {
                        PreferenceUtils.putBoolean(KEY_SHOW_UPDATE,true);
                    }
                })
                .cancelable(false)
                .show() : new MaterialDialog.Builder(context)
                .title(R.string.new_app_version_title)
                .content(R.string.app_new_version_content_force_update)
                .positiveText(R.string.dialog_action_download)
                .onPositive(((dialog, which) -> {
                    if (posClick != null){
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }))
                .cancelable(false)
                .show();
    }

    public static MaterialDialog showDownloadFirmwareConfirmDialog(final Context context, final String sn, final Firmware firmware) {
        boolean isZh = Locale.getDefault().getLanguage().equals("zh");
        Logger.t(TAG).d("isZh: " + isZh + "--" + Locale.getDefault().getLanguage());
        return new MaterialDialog.Builder(context)
                .title(R.string.found_new_firmware)
                .content(isZh ? firmware.description.zh : firmware.description.en)
                .positiveText(R.string.dialog_action_download)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> FirmwareUpdateActivity.launch((Activity) context, sn, firmware))
                .show();
    }


    public static MaterialDialog showUpgradeFirmwareConfirmDialog(final Context context, Action posClick, Action negClick) {
        return new MaterialDialog.Builder(context)
                .title(R.string.camera_updating)
                .content(R.string.camera_may_reboot)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negClick != null) {
                        try {
                            negClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .cancelable(false)
                .show();
    }

    public static MaterialDialog showPopupDialog(final Context context, String title, String content, Action posClick) {
        return new MaterialDialog.Builder(context)
                .title(title)
                .content(content)
                .positiveText(R.string.ok)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .cancelable(false)
                .show();
    }

    public static MaterialDialog showLogoutConfirmDialog(Context context, final Action positiveClickListener) {
        return new MaterialDialog.Builder(context)
                .content(R.string.logout_confirm)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (positiveClickListener != null) {
                        try {
                            positiveClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog showUnbindConfirmDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.camera_setting_unbind)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showCleanCacheDialog(Context context, final Action positiveClickListener) {
        String cacheSize = "0KB";
        try {
            cacheSize = DataCleanManager.getTotalCacheSize(context);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return new MaterialDialog.Builder(context)
                .content(String.format(context.getString(R.string.clear_cache_string), cacheSize))
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (positiveClickListener != null) {
                        try {
                            positiveClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog showSwtichServerDialog(Context context, Action positiveClickListener,
                                                        Action negativeClickListener) {
        return new MaterialDialog.Builder(context)
                .content(R.string.switch_server_alert)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (positiveClickListener != null) {
                        try {
                            positiveClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negativeClickListener != null) {
                        try {
                            negativeClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showSwitchCameraServerDialog(Context context, Action posAction,
                                                              Action negAction) {
        return new MaterialDialog.Builder(context)
                .content(R.string.switch_camera_server_alert)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posAction != null) {
                        try {
                            posAction.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negAction != null) {
                        try {
                            negAction.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showFactoryResetDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.camera_setting_factory_reset)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog showFormatDialog(Context context, Action positiveClickListener) {
        return new MaterialDialog.Builder(context)
                .title(R.string.format_alert_title)
                .content(R.string.format_alert_content)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (positiveClickListener != null) {
                        try {
                            positiveClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog showNotificationDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.notify_setting_request)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog markNotificationDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.mark_all_alert)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }).show();
    }

    public static MaterialDialog showPermissionDialog(Context context, Action posClick, Action negaClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.permission_setting_request)
                .canceledOnTouchOutside(false)
                .positiveText(R.string.permission_setting_go)
                .negativeText(R.string.permission_setting_close)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negaClick != null) {
                        try {
                            negaClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showCloseNotifyDialog(Context context, Action posClick, Action negaClick) {
        return new MaterialDialog.Builder(context)
                .canceledOnTouchOutside(false)
                .content(R.string.notification_total_closed)
                .positiveText(R.string.notification_total_closed_ensure)
                .negativeText(R.string.notification_total_closed_refuse)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negaClick != null) {
                        try {
                            negaClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showBetaTesterDialog(Context context, int titleRes, int contentRes, int postiveRes, Action posClick) {
        return new MaterialDialog.Builder(context)
                .title(titleRes)
                .content(contentRes)
                .positiveText(postiveRes)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showWifiTroubleDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.wifi_trouble_des)
                .positiveText(R.string.enable)
                .negativeText(R.string.go_back)
                .negativeColorRes(R.color.colorNaviText)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showSwtichWifiDialog(Context context, Action positiveClickListener,
                                                      Action negativeClickListener) {
        return new MaterialDialog.Builder(context)
                .canceledOnTouchOutside(false)
                .content(R.string.switch_wifi_alert)
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (positiveClickListener != null) {
                        try {
                            positiveClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negativeClickListener != null) {
                        try {
                            negativeClickListener.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showRemovePersonnelDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(context.getString(R.string.remove_personnel_tips))
                .positiveText(R.string.ok)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showActivateCameraDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(context.getString(R.string.activate_camera_tips))
                .positiveText(R.string.activate)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    //test
    public static MaterialDialog showMsg(Context context, String msg){
        return new MaterialDialog.Builder(context)
                .title("NotificationResponse")
                .content(""+msg)
                .negativeText("OK")
                .show();
    }

    public static MaterialDialog showUnbindDeviceDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(context.getString(R.string.warning_unbind_device))
                .positiveText(R.string.unbind)
                .positiveColor(context.getColor(R.color.holo_red_light))
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showRemoveVehicleDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(context.getString(R.string.warning_remove_vehicle))
                .positiveText(R.string.remove)
                .negativeText(R.string.cancel)
                .positiveColor(context.getColor(R.color.holo_red_light))
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showRemoveDriverDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(context.getString(R.string.warning_remove_driver))
                .positiveText(R.string.remove)
                .positiveColor(context.getColor(R.color.holo_red_light))
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showExtremeModeDialog(Context context, Action posClick, Action negaClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.utilizing_extreme_mode)
                .positiveText(R.string.support_beta_tester_yes)
                .negativeText(R.string.cancel)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .onNegative((dialog, which) -> {
                    if (negaClick != null) {
                        try {
                            negaClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }

    public static MaterialDialog showDeleteGeoFenceDialog(Context context, Action posClick) {
        return new MaterialDialog.Builder(context)
                .content(R.string.are_you_sure_to_remove_this_geo_fence)
                .positiveText(R.string.support_beta_tester_yes)
                .negativeText(R.string.no)
                .onPositive((dialog, which) -> {
                    if (posClick != null) {
                        try {
                            posClick.run();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .show();
    }
}
