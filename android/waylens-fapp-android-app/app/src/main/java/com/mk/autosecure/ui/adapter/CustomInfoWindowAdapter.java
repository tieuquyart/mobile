package com.mk.autosecure.ui.adapter;

import android.app.Activity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;
import com.mk.autosecure.rest_fleet.bean.NotificationBean;
import com.mk.autosecure.R;

public class CustomInfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

    private Activity activity;
    private NotificationBean bean;
    public OnClickListener onClickListener;

    public void setOnClickListener(OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    public CustomInfoWindowAdapter(Activity activity/*, NotificationBean bean*/) {
        this.activity = activity;
//        this.bean = bean;
    }

    @Nullable
    @Override
    public View getInfoContents(@NonNull Marker marker) {
        return null;
    }

    @Nullable
    @Override
    public View getInfoWindow(@NonNull Marker marker) {
        View view = activity.getLayoutInflater().inflate(R.layout.custominfowindow, null);

        TextView tvTitle = (TextView) view.findViewById(R.id.tv_title);
        TextView tvSubTitle = (TextView) view.findViewById(R.id.tv_subtitle);
        Button btnPlay = view.findViewById(R.id.btnPlay);

        tvTitle.setText(marker.getTitle());
        tvSubTitle.setText(marker.getSnippet());
        btnPlay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onClickListener.onPlayClip();
            }
        });

        return view;
    }

    public interface OnClickListener{
        public void onPlayClip();
    }
}
