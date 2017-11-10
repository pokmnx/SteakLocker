package com.steaklocker.steaklocker;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBar.TabListener;
import android.support.v7.app.ActionBar.Tab;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ImageView;

import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;
import com.parse.ParseUser;




public class SteakActivity extends AppCompatActivity implements ActionBar.TabListener {

    private ViewPager viewPager;
    private SteakPagerAdapter mAdapter;
    private PagerTabStrip actionBar;

    public UserObject mUserObject;
    public Object mObject;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_steak);

        Bundle b = getIntent().getExtras();
        String userObjectId = b.getString("userObjectId");
        String objectId = b.getString("objectId");

        mUserObject = (userObjectId.isEmpty()) ? null : (UserObject)Steaklocker.getCacheObject(userObjectId);
        mObject = (objectId.isEmpty()) ? null : (Object)Steaklocker.getCacheObject(objectId);

        String title = (mUserObject==null) ? "No Name" : mUserObject.getDisplayName();
        ActionBar bar = getSupportActionBar();

        bar.setTitle(title);
        bar.setHomeButtonEnabled(true);

        ParseFile imageFile = null;
        ParseImageView imageView = (ParseImageView)findViewById(R.id.steakImage);
        Drawable d = getResources().getDrawable(R.drawable.steak_default);
        imageView.setPlaceholder(d);

        if (mObject != null) {
            imageFile = mObject.getParseFile("image");
        }
        if (imageFile != null) {
            imageView.setParseFile(imageFile);
            imageView.loadInBackground(new GetDataCallback() {
                public void done(byte[] data, ParseException e) {
                    // nothing to do
                }
            });
            imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }
        else {
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        }

        viewPager = (ViewPager) findViewById(R.id.pager);
        actionBar = (PagerTabStrip)findViewById(R.id.steakTabs);
        mAdapter = new SteakPagerAdapter(getSupportFragmentManager(), this);
        viewPager.setAdapter(mAdapter);

        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }





        /**
         * on swiping the viewpager make respective tab selected
         * */
        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {

            @Override
            public void onPageSelected(int position) {
                // on changing the page
                // make respected tab selected
                //actionBar.setSelectedNavigationItem(position);
            }

            @Override
            public void onPageScrolled(int arg0, float arg1, int arg2) {
            }

            @Override
            public void onPageScrollStateChanged(int arg0) {
            }
        });
    }


    @Override
    public void onTabReselected(Tab tab, FragmentTransaction ft) {
    }

    @Override
    public void onTabSelected(Tab tab, FragmentTransaction ft) {
        // on tab selected
        // show respected fragment view
        viewPager.setCurrentItem(tab.getPosition());
    }

    @Override
    public void onTabUnselected(Tab tab, FragmentTransaction ft) {

    }
}
