package com.steaklocker.steaklocker;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import com.parse.*;
import java.util.List;
import java.util.Map;

/**
 * Created by jashlock on 1/31/15.
 */
public class TipTrickPagerAdapter extends FragmentPagerAdapter {

    protected Context mContext;

    public TipTrickPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        mContext = context;
    }

    @Override
    // This method returns the fragment associated with
    // the specified position.
    //
    // It is called when the Adapter needs a fragment
    // and it does not exists.
    public Fragment getItem(int position) {
        TipsTricksActivity parent = (TipsTricksActivity)mContext;
        Fragment fragment;

        List<ParseObject> tipsTricks = Steaklocker.getTipsTricks();
        ParseObject tipTrick = (ParseObject)tipsTricks.get(position);


        fragment = TipTrickFragment.newInstance(tipTrick);

        return fragment;
    }


    @Override
    public int getCount() {
        List<ParseObject> tipsTricks = Steaklocker.getTipsTricks();
        if (tipsTricks != null) {
            return tipsTricks.size();
        }
        return 0;
    }

    @Override
    public float getPageWidth(int position)
    {
        return 0.85f;
    }

}