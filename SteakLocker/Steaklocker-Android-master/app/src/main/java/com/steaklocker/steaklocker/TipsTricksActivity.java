

/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.steaklocker.steaklocker;

import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.MenuItem;
import java.util.List;
import android.os.Handler;

import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.ParseFile;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.*;

public class TipsTricksActivity extends SteaklockerActivity implements OnRefreshListener {
    private ViewPager tipsTricksPager=null;
    private TipTrickPagerAdapter mAdapterTipsTricks=null;

    SwipeRefreshLayout swipeLayout;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        System.gc();

        setContentView(R.layout.activity_tipstricks);


        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }

        if (swipeLayout == null) {
            swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_container_tipstricks);
            swipeLayout.setOnRefreshListener(this);
            swipeLayout.setColorSchemeColors(Steaklocker.getColorTemp());
        }
    }
    @Override
    public void onRefresh() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

            }
        }, 1000);
    }

    public void initTipsTricks() {
        if (tipsTricksPager == null) {
            tipsTricksPager = (ViewPager) findViewById(R.id.tipsTricksPager);
            if (mAdapterTipsTricks == null) {
                mAdapterTipsTricks = new TipTrickPagerAdapter(getSupportFragmentManager(), this);
                tipsTricksPager.setAdapter(mAdapterTipsTricks);
            }
            else {
                mAdapterTipsTricks.notifyDataSetChanged();
            }
        }
        else {
            if (mAdapterTipsTricks == null) {
                mAdapterTipsTricks = new TipTrickPagerAdapter(getSupportFragmentManager(), this);
                tipsTricksPager.setAdapter(mAdapterTipsTricks);
            }
            else {
                mAdapterTipsTricks.notifyDataSetChanged();
            }
        }

        List<ParseObject> tips = Steaklocker.getTipsTricks();
        if (tips == null) {
            Steaklocker.loadTipsTricks(new Steaklocker.SteaklockerAsyncListInterface() {
                @Override
                public void onSuccess(List<ParseObject> objects) {
                    if (mAdapterTipsTricks != null) {
                        mAdapterTipsTricks.notifyDataSetChanged();
                    }
                }

                @Override
                public void onError(ParseException e) {
                    if (mAdapterTipsTricks != null) {
                        mAdapterTipsTricks.notifyDataSetChanged();
                    }
                }
            });
        } else {
            if (mAdapterTipsTricks != null) {
                mAdapterTipsTricks.notifyDataSetChanged();
            }
        }
    }

    public void unloadTipsTricks(){
        mAdapterTipsTricks = null;

        if (tipsTricksPager != null) {
            tipsTricksPager.setAdapter(null);
        }
    }


    public void onStart() {
        super.onStart();

        initTipsTricks();

    }

    public void onStop() {
        super.onStop();

        unloadTipsTricks();
    }



}