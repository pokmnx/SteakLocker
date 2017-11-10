package com.steaklocker.steaklocker;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.ViewGroup;

import java.lang.*;

public class GraphPagerAdapter extends PagerAdapter {

    private Context mContext;
    private View[] mViews;

    public GraphPagerAdapter(Context context, View... views) {
        this.mContext = context;
        this.mViews = views;
    }

    @Override
    public int getCount() {
        return mViews.length;
    }

    @Override
    public java.lang.Object instantiateItem(ViewGroup collection, int position) {
        View currentView = mViews[position];
        ((ViewPager) collection).addView(currentView);
        return currentView;
    }

    @Override
    public void destroyItem(ViewGroup collection, int position, java.lang.Object view) {
        ((ViewPager) collection).removeView((View) view);
    }

    @Override
    public boolean isViewFromObject(View view, java.lang.Object object) {
        return view == object;
    }
}

