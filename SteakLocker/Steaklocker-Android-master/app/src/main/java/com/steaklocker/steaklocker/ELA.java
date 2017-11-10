package com.steaklocker.steaklocker;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

public class ELA {

    private static ELA sharedInstance;

    private ELADevice elaDevice;

    public ELA() {

    }

    public static ELA getSharedInstance() {
        if (sharedInstance == null) {
            sharedInstance = new ELA();
        }
        return sharedInstance;
    }

    public ELADevice getELADevice() {
        if (elaDevice == null) elaDevice = new ELADevice();
        return elaDevice;
    }

    public void openWifiSettings(Context context) {
        if (context == null) return;
        context.startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
    }

    public String getWifiSSID(Context context) {
        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        WifiInfo info = wifiManager.getConnectionInfo();
        String ssid  = info.getSSID();
        if (ssid.startsWith("\"") && ssid.startsWith("\"")) {
            ssid = ssid.substring(1, ssid.length() - 1);
        }
        return ssid;
    }

    public String getCurrentBSSID(Context context) {
        if (context == null) {
            return null;
        }

        String ssid = null;
        ConnectivityManager connManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (networkInfo.isConnected()) {
            final WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
            final WifiInfo connectionInfo = wifiManager.getConnectionInfo();
            if (connectionInfo != null && !TextUtils.isEmpty(connectionInfo.getSSID())) {
                ssid = connectionInfo.getBSSID();
            }
        }

        return ssid;
    }

    static public String steakWifiSSID() {
        byte[] cowface = new byte[] {-16, -97, -112, -82};
        String cowfaceStr = new String(cowface, StandardCharsets.UTF_8);
        String ssid = cowfaceStr + " Steak Locker JARED";
        return ssid;
    }

    static public String steakDeviceWifiName() {
        byte[] cowface = new byte[] {-16, -97, -112, -82};
        String cowfaceStr = new String(cowface, StandardCharsets.UTF_8);
        String ssid = cowfaceStr + " Steak Locker";
        return ssid;
    }

    static public String getLockerType() {
        return "steakLocker";
    }

    static public void log(String message) {
        Log.d("STEAK_LOCKER", message);
    }
}
