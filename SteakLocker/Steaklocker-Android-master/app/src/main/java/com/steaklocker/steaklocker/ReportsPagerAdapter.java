package com.steaklocker.steaklocker;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

/**
 * Created by jashlock on 1/31/15.
 */
public class ReportsPagerAdapter extends FragmentPagerAdapter {

    protected Context mContext;

    protected ReportGraph reportTemp;
    protected ReportGraph reportHumid;

    public ReportsPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        mContext = context;
        this.reportTemp = new ReportGraph();
        this.reportHumid = new ReportGraph();
    }

    @Override
    // This method returns the fragment associated with
    // the specified position.
    //
    // It is called when the Adapter needs a fragment
    // and it does not exists.
    public Fragment getItem(int position) {
        ReportsActivity parent = (ReportsActivity)mContext;
        Fragment fragment;

        if (position == 1) {
            fragment = this.reportHumid;

        }
        else if (position == 2) {
            fragment = new ReportGraph();
        }
        else {
            // Create fragment object
            fragment = this.reportTemp;
        }

/*
        // Attach some data to it that we'll
        // use to populate our fragment layouts
        Bundle b = new Bundle();

        b.putString("userObjectId", userObjectId);
        b.putString("objectId", objectId);

        // Set the arguments on the fragment
        // that will be fetched in DemoFragment@onCreateView
        fragment.setArguments(b);
        */

        return fragment;
    }


    @Override
    public int getCount() {
        return 2;
    }



    @Override
    public CharSequence getPageTitle(int position) {
        if (position == 0) {
            return "Temperature";
        }
        else if (position == 1) {
            return "Humidity";
        }

        return "Yield";
    }


}