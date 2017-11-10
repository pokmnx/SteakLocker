package com.steaklocker.steaklocker;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

/**
 * Created by jashlock on 1/31/15.
 */
public class SteakPagerAdapter extends FragmentPagerAdapter {

    protected Context mContext;

    public SteakPagerAdapter(FragmentManager fm, Context context) {
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
        SteakActivity parent = (SteakActivity)mContext;
        Fragment fragment;

        if (position == 1) {
            fragment = new NutritionFragment();
        }
        else if (position == 2) {
            fragment = new SteakInfoFragment();
        }
        else {
            // Create fragment object
            fragment = new DaysLeftFragment();
        }

        String userObjectId = (parent.mUserObject==null) ? "" : parent.mUserObject.getObjectId();
        String objectId = (parent.mObject==null) ? "" : parent.mObject.getObjectId();

                // Attach some data to it that we'll
        // use to populate our fragment layouts
        Bundle b = new Bundle();

        b.putString("userObjectId", userObjectId);
        b.putString("objectId", objectId);

        // Set the arguments on the fragment
        // that will be fetched in DemoFragment@onCreateView
        fragment.setArguments(b);

        return fragment;
    }


    @Override
    public int getCount() {
        return 3;
    }



    @Override
    public CharSequence getPageTitle(int position) {
        if (position == 0) {
            SteakActivity parent = (SteakActivity)mContext;
            return parent.mUserObject.getDaysLeftString();
        }
        else if (position == 1) {
            return "Nutrition";
        }

        return "Information";
    }


}