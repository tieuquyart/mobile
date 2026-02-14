package com.mk.autosecure.ui.adapter;

import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by DoanVT on 2017/8/21.
 */

public class MyFragmentStatePagerAdapter extends FragmentStatePagerAdapter {
    private List<Fragment> mFragmentList;
    private List<String> mFragmentTitles;

    public MyFragmentStatePagerAdapter(FragmentManager fm) {
        super(fm);

        mFragmentList = new ArrayList<>();
        mFragmentTitles = new ArrayList<>();
    }

    public void addFragment(Fragment fragment) {
        addFragment(fragment, "");
    }

    public void addFragment(Fragment fragment, String title) {
        mFragmentList.add(fragment);
        mFragmentTitles.add(title);
        notifyDataSetChanged();
    }

    public void clearFragments() {
        mFragmentList.clear();
        mFragmentTitles.clear();
        notifyDataSetChanged();
    }

    @Override
    public Fragment getItem(int position) {
        return mFragmentList.get(position);
    }

    @Override
    public int getCount() {
        return mFragmentList.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return mFragmentTitles.get(position);
    }

    @Override
    public int getItemPosition(@NonNull Object object) {
        return POSITION_NONE;
    }

    @Nullable
    @Override
    public Parcelable saveState() {
        return null;
    }
}
