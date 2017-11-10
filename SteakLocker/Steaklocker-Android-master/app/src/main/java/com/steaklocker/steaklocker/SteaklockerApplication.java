package com.steaklocker.steaklocker;

import android.app.Application;
import android.content.IntentFilter;
import android.net.wifi.WifiManager;
import com.parse.*;
import com.parse.Parse;

public class SteaklockerApplication extends Application {
    public WifiReceiver broadcastReceiver;

    @Override
    public void onCreate() {
        super.onCreate();



        Steaklocker.init(this);

        broadcastReceiver = new WifiReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
        registerReceiver(broadcastReceiver, intentFilter);

		/*
		 * In this tutorial, we'll subclass ParseObject for convenience to
		 * create and modify Meal objects
		 */
        ParseObject.registerSubclass(Object.class);
        ParseObject.registerSubclass(UserObject.class);
        ParseObject.registerSubclass(Device.class);
        ParseObject.registerSubclass(Vendor.class);


        Parse.Configuration conf = new Parse.Configuration.Builder(this)
                .applicationId(getString(R.string.parse_app_id))
                .clientKey(getString(R.string.parse_client_key))
                .server(getString(R.string.parse_url))
                .build();

        try {
            Parse.initialize(conf);
        }
        catch (Exception e)
        {
            String msg = e.getMessage();
            if (msg.equals("")) {

            }
        }


        ParseUser currUser = ParseUser.getCurrentUser();
        if (currUser != null) {
            ParseInstallation install = ParseInstallation.getCurrentInstallation();
            install.put("user", currUser);
            install.saveEventually();
        }

        ParsePush.subscribeInBackground("", new SaveCallback() {
            @Override
            public void done(ParseException e) {
                if (e == null) {

                } else {

                }
            }
        });

        /*
        // Create our Installation query
        ParseQuery pushQuery = ParseInstallation.getQuery();
        pushQuery.whereEqualTo("deviceType", "android");


        ParsePush push = new ParsePush();
        push.setQuery(pushQuery); // Set our Installation query
        push.setMessage("Willie Hayes injured by own pop fly.");
        push.sendInBackground();
        */

        boolean isDebuggable =  ( 0 != ( getApplicationInfo().flags & android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE ) );

        if (isDebuggable) {
            Parse.setLogLevel(Parse.LOG_LEVEL_DEBUG);
        }

		/*
		 * For more information on app security and Parse ACL:
		 * https://www.parse.com/docs/android_guide#security-recommendations
		 */
        ParseACL defaultACL = new ParseACL();

		/*
		 * If you would like all objects to be private by default, remove this
		 * line
		 */
        defaultACL.setPublicReadAccess(true);

        ParseACL.setDefaultACL(defaultACL, true);
    }

}
