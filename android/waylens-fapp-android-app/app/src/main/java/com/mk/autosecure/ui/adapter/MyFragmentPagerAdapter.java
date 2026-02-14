package com.mk.autosecure.ui.adapter;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

import java.util.ArrayList;
import java.util.List;

public class MyFragmentPagerAdapter extends FragmentPagerAdapter {

    private final static String TAG = MyFragmentPagerAdapter.class.getSimpleName();

    private FragmentManager fm;

    private List<Fragment> mFragmentList;

    private List<String> mFragmentTitles;

    public MyFragmentPagerAdapter(FragmentManager fm) {
        super(fm);
        this.fm = fm;

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
    public Fragment getItem(int i) {
        return mFragmentList.get(i);
    }

    @Override
    public int getCount() {
        return mFragmentList.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return mFragmentTitles.get(position);
    }

}
