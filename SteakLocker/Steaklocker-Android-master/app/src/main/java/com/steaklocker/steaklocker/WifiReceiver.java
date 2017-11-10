package com.steaklocker.steaklocker;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;

/**
 * Created by jashlock on 6/11/15.
 */
public class WifiReceiver extends BroadcastReceiver {
    static boolean isConnected;
    static boolean isInitialized=false;

    static boolean isConnectedViaWifi() {
        if (!WifiReceiver.isInitialized) {
            ConnectivityManager connManager = (ConnectivityManager) Steaklocker.app.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo mWifi = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
            WifiReceiver.isConnected = mWifi.isConnected();
        }
        return WifiReceiver.isConnected;
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        NetworkInfo info = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
        if(info != null) {
            WifiReceiver.isConnected = info.isConnected();
        }
    }
}
