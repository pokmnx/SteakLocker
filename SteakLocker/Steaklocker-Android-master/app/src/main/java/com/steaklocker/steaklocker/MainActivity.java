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

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import com.parse.*;
import com.parse.ui.*;
import com.electricimp.blinkup.BlinkupController;
import com.parse.ui.ParseLoginBuilder;

import java.util.List;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;


public class MainActivity extends SteaklockerActivity {

    private ParseUser currentUser;

    private boolean configLoaded = false;
    private boolean deviceLoaded = false;


    public void onStart() {
        super.onStart();


        currentUser = ParseUser.getCurrentUser();
        if (currentUser != null) {
            showProfileLoggedIn();
        } else {
            showProfileLoggedOut();
        }
    }

    /**
     * Shows the profile of the given user.
     */
    private void startDeviceSetup() {
        startActivity(new Intent(this, SetupStartActivity.class));
    }

    /**
     * Shows the profile of the given user.
     */
    private void showProfileLoggedIn() {
        final MainActivity context = this;
        Steaklocker.loadUserDevices(new Steaklocker.SteaklockerAsyncListInterface() {
            @Override
            public void onSuccess(List<ParseObject> objects) {
                if (objects.size() == 0) {
                    startDeviceSetup();
                }
                else {
                    context.deviceLoaded = true;
                    if (context.deviceLoaded && context.configLoaded) {
                        context.onReadyForDashboard();
                    }
                }
            }

            @Override
            public void onError(ParseException e) {

            }
        });


        Steaklocker.loadConfig(new Steaklocker.SteaklockerAsyncInterface() {
            @Override
            public void onSuccess(ParseObject parseObject) {
                context.configLoaded = true;
                if (context.deviceLoaded && context.configLoaded) {
                    context.onReadyForDashboard();
                }
            }

            @Override
            public void onError(ParseException e) {

            }
        });

    }

    private void onReadyForDashboard() {
        startActivity(new Intent(this, DashboardActivity.class));
    }

    /**
     * Show a message asking the user to log in, toggle login/logout button text.
     */
    private void showProfileLoggedOut() {
        ParseLoginBuilder builder = new ParseLoginBuilder(this);
        builder.setAppLogo(R.drawable.logo_login);
        startActivityForResult(builder.build(), 0);
    }



    private BlinkupController.ServerErrorHandler errorHandler = new BlinkupController.ServerErrorHandler() {
        @Override
        public void onError(String errorMsg) {
            Crouton.makeText(MainActivity.this, errorMsg, Style.ALERT).show();
        }
    };



}