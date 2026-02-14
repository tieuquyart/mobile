package com.mk.autosecure.ui.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.ui.fragment.AlbumFragment;

/**
 * Created by doanvt on 2022/11/02.
 */
public class AlbumActivity extends AppCompatActivity {

    private final static String TAG = AlbumActivity.class.getSimpleName();

    private AlbumFragment mAlbumFragment;

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, AlbumActivity.class);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_album);

        if (savedInstanceState != null) {
            mAlbumFragment = (AlbumFragment) getSupportFragmentManager().getFragment(savedInstanceState, AlbumFragment.class.getSimpleName());
        } else {
            mAlbumFragment = new AlbumFragment();
        }

        try {
            getSupportFragmentManager().beginTransaction().replace(R.id.frameLayout, mAlbumFragment).commitNow();
        } catch (Exception ex) {
            Logger.t(TAG).e("commitNow exception: " + ex.getMessage());
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        getSupportFragmentManager().putFragment(outState, AlbumFragment.class.getSimpleName(), mAlbumFragment);
    }
}
