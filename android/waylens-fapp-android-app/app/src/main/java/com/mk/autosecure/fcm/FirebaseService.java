package com.mk.autosecure.fcm;

import static com.mk.autosecure.ui.activity.settings.NotiManageActivity.KEY_HAS_TRANS;

import android.annotation.SuppressLint;
import android.app.Application;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.MainActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.ui.activity.LocalLiveActivity;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.orhanobut.logger.Logger;

import java.util.Map;
import java.util.Objects;


/**
 * Created by doanvt on 2022/11/02.
 */

public class FirebaseService extends FirebaseMessagingService {
    private final String TAG = FirebaseService.class.getSimpleName();

    String id = "com.mkgroup.fms";

    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);
        Logger.t(TAG).d(".onNewToken: ".concat(s));
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        super.onMessageReceived(message);
        sendNotification(message);
    }

    @SuppressLint({"LaunchActivityFromNotification", "WrongConstant"})
    private void sendNotification(RemoteMessage message) {
        Map<String, String> data = message.getData();
        Logger.t(TAG).d("onMessageFireBase: " + data);
        String notiId = data.get("notificationId");
        if (!TextUtils.isEmpty(notiId)) {
            Constants.has_push_notification = true;
            LocalLiveActivity.notificationID = notiId;
            Intent intent = new Intent(Constants.KEY_PUSH_CHANNEL);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            int flag = PendingIntent.FLAG_UPDATE_CURRENT;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                flag |= PendingIntent.FLAG_MUTABLE;
            }
            PendingIntent pendingIntent = PendingIntent.getBroadcast(this, 0 /* Request code */, intent,
                    flag);

            Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle(Objects.requireNonNull(message.getNotification()).getTitle())
                    .setContentText(message.getNotification().getBody())
                    .setAutoCancel(true)
                    .setChannelId(id)
                    .setSound(defaultSoundUri)
                    .setContentIntent(pendingIntent);

            NotificationManager notificationManager =
                    (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // The id of the channel.

                CharSequence name = "channel_name";

                String description = "channel_description";

                int importance = NotificationManager.IMPORTANCE_LOW;

                NotificationChannel mChannel = new NotificationChannel(id, name, importance);

                // Configure the notification channel.
                mChannel.setDescription(description);

                mChannel.enableLights(true);
                mChannel.setLightColor(Color.RED);

                mChannel.enableVibration(true);
                mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});

                notificationManager.createNotificationChannel(mChannel);
            }
            registerReceiver(receiver, new IntentFilter(Constants.KEY_PUSH_CHANNEL));

            notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
        } else {
            Constants.has_push_notification = false;
        }
    }

    public BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Logger.t(TAG).d("test receiver " + intent.getData());
            if (intent.getAction().equals(Constants.KEY_PUSH_CHANNEL)) {
                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
            }
            unregisterReceiver(receiver);
        }
    };


}
