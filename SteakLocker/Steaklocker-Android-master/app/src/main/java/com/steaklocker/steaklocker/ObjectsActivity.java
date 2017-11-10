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

public class ObjectsActivity extends SteaklockerActivity implements OnRefreshListener {
    private int measurementState = 0;

    SwipeRefreshLayout swipeLayout;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ParseUser user = ParseUser.getCurrentUser();
        if (user == null) {
            Steaklocker.logout(this, true);
            return;
        }

        System.gc();

        setContentView(R.layout.activity_objects);


        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }

        if (swipeLayout == null) {
            swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_container_objects);
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




}