package com.mk.autosecure.rest.error;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.R;

import java.io.Serializable;

/**
 * Created by DoanVT on 2017/11/10.
 * Email: doanvt-hn@mk.com.vn
 */

public class ErrorEnvelope implements Serializable {

    //找不到指定 sn 相机详情
    public static final int UNSUPPORTED_PARAMETERS = 2;

    //认证失败，用户名/密码错 或 token过期或者无效
    public static final int ERROR_TOKEN_IS_INVALID = 23;

    //未认证
    public static final int ERROR_NOT_AUTHORIZED = 24;

    //用户名被注册不可用
    public static final int ERROR_USERNAME_ALREADY_EXISTED = 30;

    //邮箱已存在
    public static final int ERROR_EMAIL_ALREADY_EXISTED = 31;

    //邮箱不存在
    public static final int ERROR_EMAIL_NOT_EXIST = 32;

    //邮箱无效
    public static final int ERROR_EMAIL_IS_INVALID = 33;

    //
    public static final int ERROR_PASSWORD_IS_INCORRECT = 35;

    //密码无效
    public static final int ERROR_PASSWORD_IS_INVALID = 36;

    //账户已通过验证
    public static final int ERROR_EMAIL_ALREADY_VERIFIED = 37;

    //超过重发次数
    public static final int ERROR_EMAIL_EXCEED_RETRY_LIMIT = 39;

    //重发频率过高
    public static final int ERROR_EMAIL_NOT_REACH_RETRY_INTERVAL = 40;

    //验证码过期
    public static final int CHANGE_PWD_TOKEN_EXPIRED = 41;

    //验证码错误
    public static final int CHANGE_PWD_TOKEN_INCORRECT = 42;

    //
    public static final int ERROR_EMAIL_PASSWROD_INCORRECT = 43;

    //指定相机的密码错误
    public static final int CAMERA_PASSWORD_ERROR = 200;

    //指定相机已经被绑定到另一个用户了
    public static final int CAMERA_ALREADY_BOUND_OTHER = 201;

    //指定sn的相机不存在
    public static final int CAMERA_NOT_EXIST = 202;

    //指定相机已经绑定到当前用户了
    public static final int CAMERA_ALREADY_BOUND_YOUR = 203;

    //相机名不合法： 字符数超过128
    public static final int CAMERA_NAME_ILLEGAL = 204;

    //相机未绑定
    public static final int CAMERA_NOT_BOUND = 205;

    //相机不在线
    public static final int CAMERA_OFFLINE = 250;

    //相机在线，但还没上报状态
    public static final int CAMERA_NOT_REPORT_SIGNAL = 254;

    //
    public static final int NO_ICCID = 255;

    //sim卡不是waylens提供的
    public static final int SIM_CARD_ILLEGAL = 256;

    //相机已经绑定了个其他的iccid，或者 上报的iccid是属于别的camera
    public static final int ICCID_ALREADY_BOUND = 302;

    //其余（为相机绑定试用套餐失败等）
    public static final int UNEXPECTED_ERROR = 999;


    public static final int CHANGE_PWD_PASSWORD_INVALID = 36;


    public static final int CHANGE_PWD_EMAIL_NOT_EXIST = 32;

    //fleet start
    public static final int LACK_DEVICE_TOKEN = 3998;

    public static final int INCORRECT_USERNAME_PASSWORD = 3999;

    public static final int JSON_FORMAT_ERROR = 4000;

    public static final int FLEET_USER_NOT_EXIST = 4001;

    public static final int WRONG_OLD_PASSWORD = 4002;

    public static final int REACH_RETRY_INTERVAL = 4003;

    public static final int RETRY_EXCEED_LIMIT = 4004;

    public static final int VERIFICATION_TOKEN_EXPIRED = 4005;

    public static final int VERIFICATION_TOKEN_INCORRECT = 4006;

    public static final int DRIVER_ALREADY_HAS_EMAIL = 4008;

    public static final int BAD_REQUEST = 4100;

    public static final int FLEET_TOKEN_EXPIRED = 4101;

    public static final int FLEET_CAMERA_NOT_EXIST = 4102;

    public static final int AUTHENTICATION_FIALED = 4103;

    public static final int UNSUPPORTED_PARAM = 4200;

    public static final int FILE_VALIDATION_ERROR = 4201;

    public static final int CAMERA_OPERATION_FAILED = 4202;

    public static final int CAMERA_ALREADY_ADDED = 4203;

    public static final int PLATE_NUMBER_ALREADY_ADDED = 4205;

    public static final int EMAIL_ALREADY_SIGNED = 4211;

    public static final int VEHICLEID_ALREADY_BOUND_DRIVERID = 4301;

    public static final int VEHICLEID_ALREADY_BOUND_CAMERASN = 4302;

    public static final int VEHICLE_DRIVER_NOT_BOUND = 4303;

    public static final int VEHICLE_CAMERA_NOT_BOUND = 4304;

    public static final int EMPTY_VEHICLEID_DRIVERID = 4305;

    public static final int CAMERA_IN_DRIVING = 4306;

    public static final int CAMERASN_ALREADY_BOUND = 4307;

    public static final int VEHICLEID_NOT_BOUND = 4308;

    public static final int DRIVERID_ALREADY_BOUND = 4309;

    public static final int EMPTY_VEHICLEID_CAMERASN = 4310;

    public static final int VEHICLEID_NOT_EXIST = 4311;

    public static final int DRIVERID_NOT_EXIST = 4312;

    public static final int CAMERASN_NOT_EXIST = 4313;

    public static final int INTERNAL_ERROR = 5000;
    //fleet end

    public int code;
    private String msg;

    public static @Nullable
    ErrorEnvelope fromThrowable(final @NonNull Throwable t) {
        if (t instanceof ApiException) {
            final ApiException exception = (ApiException) t;
            return exception.errorEnvelope();
        }
        return null;
    }

    public boolean isSendResetEmailErrorAcceptable() {
        return code == ERROR_EMAIL_EXCEED_RETRY_LIMIT || code == ERROR_EMAIL_NOT_REACH_RETRY_INTERVAL;
    }

    public boolean isSendResetEmailFatalError() {
        return code == ERROR_EMAIL_NOT_EXIST;
    }

    public boolean isChangePWDTokenError() {
        return code == CHANGE_PWD_TOKEN_EXPIRED || code == CHANGE_PWD_TOKEN_INCORRECT;
    }

    public boolean isResendEmailAlreadyVerified() {
        return code == ERROR_EMAIL_ALREADY_VERIFIED;
    }

    public boolean isNotResendEmailAlreadyVerified() {
        return code != ERROR_EMAIL_ALREADY_VERIFIED;
    }

    public boolean isAlreadyBoundYour() {
        return code == CAMERA_ALREADY_BOUND_YOUR;
    }

    public String getErrorMessage() {
        Context context = HornApplication.getContext();
        switch (code) {
            case ERROR_EMAIL_IS_INVALID:
                return context.getString(R.string.invalid_email);
            case ERROR_PASSWORD_IS_INVALID:
                return context.getString(R.string.invalid_password);
            case ERROR_EMAIL_ALREADY_EXISTED:
                return context.getString(R.string.email_has_registered);

            case ERROR_PASSWORD_IS_INCORRECT:
                return context.getString(R.string.password_incorrect);

            case ERROR_EMAIL_PASSWROD_INCORRECT:
                return context.getString(R.string.email_password_incorrect);

            case ERROR_EMAIL_ALREADY_VERIFIED:
                return context.getString(R.string.account_already_verified);

            case ERROR_USERNAME_ALREADY_EXISTED:
                return context.getString(R.string.username_has_registered);

            case ERROR_EMAIL_NOT_EXIST:
                return context.getString(R.string.email_not_exist);
            case ERROR_EMAIL_EXCEED_RETRY_LIMIT:
                return context.getString(R.string.retry_exceed_limit);
            case ERROR_EMAIL_NOT_REACH_RETRY_INTERVAL:
                return context.getString(R.string.reach_max_interval);

            case CHANGE_PWD_TOKEN_EXPIRED:
                return context.getString(R.string.token_expired);
            case CHANGE_PWD_TOKEN_INCORRECT:
                return context.getString(R.string.token_incorrect);

            case CAMERA_NOT_EXIST:
            case FLEET_CAMERA_NOT_EXIST:
                return Constants.isFleet() ? context.getString(R.string.fleet_camera_not_exist) : context.getString(R.string.camera_not_exist);
            case CAMERA_PASSWORD_ERROR:
                return context.getString(R.string.password_error);
            case CAMERA_ALREADY_BOUND_OTHER:
                return context.getString(R.string.camera_already_bound_user);
            case CAMERA_ALREADY_BOUND_YOUR:
                return context.getString(R.string.camera_already_bound_your);

            case CAMERA_NAME_ILLEGAL:
                return context.getString(R.string.camera_name_illegal);

            case CAMERA_OFFLINE:
                return context.getString(R.string.camera_is_offline);
            case CAMERA_NOT_REPORT_SIGNAL:
                return context.getString(R.string.camera_not_report);

            case NO_ICCID:
                return context.getString(R.string.no_iccid_found);

            //fleet start
            case LACK_DEVICE_TOKEN:
            case JSON_FORMAT_ERROR:
            case AUTHENTICATION_FIALED:
            case UNSUPPORTED_PARAM:
            case CAMERA_OPERATION_FAILED:
            case EMPTY_VEHICLEID_DRIVERID:
            case EMPTY_VEHICLEID_CAMERASN:
            case VEHICLEID_NOT_EXIST:
            case DRIVERID_NOT_EXIST:
            case CAMERASN_NOT_EXIST:
            case INTERNAL_ERROR:
                return context.getString(R.string.fleet_default_error);
            case INCORRECT_USERNAME_PASSWORD:
                return context.getString(R.string.incorrect_username_password);
            case FLEET_USER_NOT_EXIST:
                return context.getString(R.string.fleet_user_not_exist);
            case WRONG_OLD_PASSWORD:
                return context.getString(R.string.incorrect_old_password);
            case REACH_RETRY_INTERVAL:
                return context.getString(R.string.reach_retry_limit);
            case RETRY_EXCEED_LIMIT:
                return context.getString(R.string.fleet_retry_exceed_limit);
            case VERIFICATION_TOKEN_EXPIRED:
                return context.getString(R.string.verification_token_expired);
            case VERIFICATION_TOKEN_INCORRECT:
                return context.getString(R.string.verification_token_incorrect);
            case DRIVER_ALREADY_HAS_EMAIL:
                return context.getString(R.string.driver_already_has_email);
            case CAMERA_ALREADY_ADDED:
                return context.getString(R.string.camera_already_added);
            case PLATE_NUMBER_ALREADY_ADDED:
                return context.getString(R.string.plate_number_already_added);
            case EMAIL_ALREADY_SIGNED:
                return context.getString(R.string.email_already_signed);
            case VEHICLEID_ALREADY_BOUND_DRIVERID:
                return context.getString(R.string.vehicle_id_already_bound_driver_id);
            case VEHICLEID_ALREADY_BOUND_CAMERASN:
                return context.getString(R.string.vehicle_id_already_bound_camera_sn);
            case VEHICLE_DRIVER_NOT_BOUND:
                return context.getString(R.string.vehicle_driver_not_bound);
            case VEHICLE_CAMERA_NOT_BOUND:
                return context.getString(R.string.vehicle_camera_not_bound);
            case CAMERA_IN_DRIVING:
                return context.getString(R.string.camera_in_driving_mode);
            case CAMERASN_ALREADY_BOUND:
                return context.getString(R.string.camera_sn_already_bound);
            case VEHICLEID_NOT_BOUND:
                return context.getString(R.string.vehicle_id_not_bound);
            case DRIVERID_ALREADY_BOUND:
                return context.getString(R.string.driver_id_already_bound);
            //fleet end

            default:
                return msg;
        }
    }

}
