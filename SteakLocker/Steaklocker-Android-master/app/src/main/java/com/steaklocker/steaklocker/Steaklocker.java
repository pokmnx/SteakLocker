package com.steaklocker.steaklocker;



import android.content.Intent;
import android.content.SharedPreferences;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import android.content.Context;
import com.electricimp.blinkup.BlinkupController;
import com.parse.*;
import com.parse.ui.ParseOnLoadingListener;
import android.app.Application;
import android.os.PowerManager;
import java.util.ArrayList;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.content.BroadcastReceiver;


/**
 * Created by jashlock on 1/14/15.
 */
public class Steaklocker {

    public static final String TYPE_DRY_AGING = "Dry Aging";
    public static final String TYPE_DRY_AGING_MEAT = "meat";
    public static final String TYPE_CHARCUTERIE = "Charcuterie";

    private static boolean configLoaded = false;
    private static ParseObject _userDevice = null;
    private static List<ParseObject> _userDevices = null;
    private static List<ParseObject> _meatCuts = null;
    private static List<ParseObject> _vendors = null;
    private static List<ParseObject> _tipsDryAging = null;
    private static List<ParseObject> _tipsCharcuterie = null;
    private static ParseObject _latestMeasurement = null;


    private static Map <String,ParseObject> objectCache;
    public static Application app;

    public static PowerManager.WakeLock wakeLock = null;
    public static Double tempMin = 0.0;
    public static Double tempMax = 35.0;
    public static Double humidMin = 0.0;
    public static Double humidMax = 100.0;

    public static BlinkupController blinkup;
    public static String blinkUpSsid;
    public static String blinkUpPass;


    //define callback interface
    interface SteaklockerAsyncInterface {
        void onSuccess(ParseObject parseObject);
        void onError(ParseException e);
    }
    interface SteaklockerAsyncListInterface {
        void onSuccess(List<ParseObject> objects);
        void onError(ParseException e);
    }

    static public void init(Application app) {
        Steaklocker.objectCache = new HashMap<String,ParseObject>();
        Steaklocker.app = app;
    }

    static public String getAPIKey()
    {
        return "705968b5dacc03ff181386d9a474ffb6";
    }

    static public String getGlobalPlanId()
    {
        return "1a66a25bd8259841";
    }

    static public BlinkupController getBlinkup() {
        if (Steaklocker.blinkup == null) {
            Steaklocker.blinkup = BlinkupController.getInstance();
        }
        return Steaklocker.blinkup;
    }

    static public boolean isConnectedViaWifi() {
        return WifiReceiver.isConnectedViaWifi();
    }

    static public int getColorTemp() {
        return 0xffff7200;
    }

    static public int getColorHumid() {
        return 0xff00c0ff;
    }

    static public void setCacheObject(ParseObject parseObject) {
        Steaklocker.objectCache.put(parseObject.getObjectId(), parseObject);
    }
    static public ParseObject getCacheObject(String objectId) {
        ParseObject parseObject = Steaklocker.objectCache.get(objectId);
        return parseObject;
    }

    static public boolean isProUser()
    {
        ParseUser user = ParseUser.getCurrentUser();
        return user.getBoolean("isProUser");
    }

    static public void setUserDevice(ParseObject device) {
        Steaklocker._userDevice = device;
    }
    static public ParseObject getUserDevice() {
        if (Steaklocker._userDevice == null && Steaklocker.getDeviceCount() > 0) {
            Steaklocker._userDevice = Steaklocker._userDevices.get(0);
        }
        return Steaklocker._userDevice;
    }

    static public ParseObject getUserDeviceById(String objectId) {
        ParseObject ret = null;
        if (Steaklocker._userDevices != null) {
            for (ParseObject device : Steaklocker._userDevices) {
                if (device.getObjectId().equals(objectId)) {
                    ret = device;
                    break;
                }
            }
        }
        return ret;
    }

    static public ParseObject getUserDeviceByImpeeId(String impeeId) {
        ParseObject ret = null;
        if (Steaklocker._userDevices != null) {
            for (ParseObject device : Steaklocker._userDevices) {
                String deviceImpeeId = device.getString("impeeId");
                if (deviceImpeeId != null && deviceImpeeId.equals(impeeId)) {
                    ret = device;
                    break;
                }
            }
        }
        return ret;
    }

    static public List<ParseObject> getUserDevices()
    {
        return Steaklocker._userDevices;
    }

    static public int getDeviceCount()
    {
        return Steaklocker._userDevices != null ? Steaklocker._userDevices.size() : 0;
    }

    static public boolean isDeviceActive(ParseObject device)
    {
        ParseObject userDevice = Steaklocker.getUserDevice();
        return (userDevice != null && device != null && userDevice.getObjectId().equals(device.getObjectId()));
    }


    static public void loadUserDevices(final SteaklockerAsyncListInterface callback)
    {
        if (Steaklocker._userDevices != null) {
            callback.onSuccess(Steaklocker._userDevices);
        }
        else {
            ParseUser user = ParseUser.getCurrentUser();
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Device");
            query.whereEqualTo("user", user);
            query.findInBackground(new FindCallback<ParseObject>() {
                @Override
                public void done(List<ParseObject> objects, ParseException e) {
                    if (e == null) {
                        Steaklocker._userDevices = objects;
                        callback.onSuccess(Steaklocker._userDevices);
                    }
                    else {
                        callback.onError(e);
                    }
                }
            });
        }
    }

    static public void reloadUserDevices(final SteaklockerAsyncListInterface callback)
    {
        Steaklocker._userDevices = null;
        Steaklocker.loadUserDevices(callback);
    }


    static public void loadUserDevice(final SteaklockerAsyncInterface callback) {

        ParseObject device = Steaklocker.getUserDevice();
        if (device != null) {
            callback.onSuccess(device);
        }
        else {
            ParseUser user = ParseUser.getCurrentUser();
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Device");
            query.whereEqualTo("user", user);
            query.getFirstInBackground(new GetCallback<ParseObject>() {
                public void done(ParseObject object, ParseException e) {
                    if (object == null) {
                        callback.onError(e);
                    } else {
                        Steaklocker.setUserDevice(object);
                        callback.onSuccess(object);
                    }
                }
            });
        }
    }

    static public String getAgingType() {
        ParseObject device = getUserDevice();
        String agingType = TYPE_DRY_AGING;
        if (device != null) {
            String temp = TYPE_DRY_AGING;
            try {
                temp = device.getString("agingType");
                if (temp != null && temp.equalsIgnoreCase(TYPE_CHARCUTERIE)) {
                    agingType = TYPE_CHARCUTERIE;
                } else {
                    agingType = TYPE_DRY_AGING;
                }
            }
            catch (Exception e) {
                agingType = TYPE_DRY_AGING;
            }
        }
        return agingType;
    }

    static public Float getTemperatureSetting() {
        ParseObject device = getUserDevice();
        Float value = null;
        if (device != null) {
            value = Float.valueOf((float)device.getDouble("settingTemperature"));
        }
        return value;
    }
    static public Float getTemperatureSettingFahrenheit() {
        Float value = Steaklocker.getTemperatureSetting();
        return Steaklocker.celsiusToFahrenheit(value);
    }
    static public Float getHumiditySetting() {
        ParseObject device = getUserDevice();
        Float value = null;
        if (device != null) {
            value = Float.valueOf((float)device.getDouble("settingHumidity"));
        }
        return value;
    }

    static public boolean userHasCharcuterieEnabled() {
        ParseUser user = ParseUser.getCurrentUser();
        boolean enabled = user.getBoolean("charcuterieEnabled");
        return enabled;
    }

    static public void userEnableCharcuterie() {
        ParseUser user = ParseUser.getCurrentUser();
        user.put("charcuterieEnabled", true);
        user.saveInBackground();
    }

    static public void userSetAgingType(String agingType) {
        ParseObject device = getUserDevice();
        if (device != null) {
            device.put("agingType", agingType);
            device.saveInBackground();
        }
    }

    static public void userSetDeviceSettings(String agingType, Float tempF, Float humid) {
        ParseObject device = getUserDevice();
        if (device != null) {
            device.put("agingType", agingType);
            device.put("settingTemperature", Steaklocker.fahrenheitToCelsius(tempF));
            device.put("settingHumidity", humid);
            device.saveInBackground();
        }
    }



    static public void getUserImpeeId(final SteaklockerAsyncInterface callback) {
        Steaklocker.loadUserDevice(new SteaklockerAsyncInterface() {
            @Override
            public void onSuccess(ParseObject parseObject) {
                callback.onSuccess(parseObject);
            }

            @Override
            public void onError(ParseException e) {
                callback.onError(e);
            }
        });
    }



    static public void loadConfig(final SteaklockerAsyncInterface callback) {

        if (Steaklocker.configLoaded) {
            ParseConfig config = ParseConfig.getCurrentConfig();
            callback.onSuccess(null);
        }
        else {
            ParseConfig.getInBackground(new ConfigCallback() {
                @Override
                public void done(ParseConfig config, ParseException e) {
                    if (e != null) {
                        callback.onError(e);
                    } else {
                        callback.onSuccess(null);
                        Steaklocker.configLoaded = true;
                    }
                }
            });
        }

    }

    static public int getConfigInt(String key) {
        ParseConfig config = ParseConfig.getCurrentConfig();
        return config.getInt(key);
    }
    static public double getConfigFloat(String key) {
        ParseConfig config = ParseConfig.getCurrentConfig();
        return config.getDouble(key);
    }
    static public boolean getConfigBool(String key) {
        ParseConfig config = ParseConfig.getCurrentConfig();
        return config.getBoolean(key);
    }
    static public String getConfigString(String key) {
        return getConfigString(key, null);
    }
    static public String getConfigString(String key, String defaultValue) {
        ParseConfig config = ParseConfig.getCurrentConfig();
        return config.getString(key, defaultValue);
    }


    static public void loadMeatCuts(final SteaklockerAsyncListInterface callback) {
        ParseUser user = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Object");
        String[] names = {Steaklocker.TYPE_DRY_AGING_MEAT, Steaklocker.TYPE_CHARCUTERIE};
        query.whereContainedIn("type", java.util.Arrays.asList(names));
        query.whereEqualTo("active", true);
        query.orderByAscending("title");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> results, ParseException e) {
                if (e != null) {
                    Steaklocker._meatCuts = new ArrayList<ParseObject>();
                    // There was an error
                    callback.onError(e);
                } else {
                    Steaklocker._meatCuts = new ArrayList<ParseObject>(results);
                    // results have all the Posts the current user liked.
                    callback.onSuccess(Steaklocker._meatCuts);
                }
            }
        });
    }
    static public List<ParseObject> getCuts() {
        return _meatCuts;
    }

    static public void loadVendors(final SteaklockerAsyncListInterface callback) {
        ParseUser user = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Vendor");
        query.whereEqualTo("active", true);
        query.orderByAscending("title");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> results, ParseException e) {
                if (e != null) {
                    Steaklocker._vendors = new ArrayList<ParseObject>();
                    // There was an error
                    callback.onError(e);
                } else {
                    Steaklocker._vendors = new ArrayList<ParseObject>(results);
                    // results have all the Posts the current user liked.
                    callback.onSuccess(Steaklocker._vendors);
                }
            }
        });
    }
    static public List<ParseObject> getVendors() {
        return _vendors;
    }

    static public float celsiusToFahrenheit(float celsius) {
        return ((celsius * 9.0f) / 5.0f) + 32.0f;
    }
    static public Float celsiusToFahrenheit(Float celsius) {
        if (celsius != null) {
            return Float.valueOf(Steaklocker.celsiusToFahrenheit(celsius.floatValue()));
        }
        return null;
    }
    static public float fahrenheitToCelsius(float fahrenheit) {
        float val = (fahrenheit - 32.0f) / 1.8f;
        return val;
    }
    static public Float fahrenheitToCelsius(Float fahrenheit) {
        if (fahrenheit != null) {
            return Float.valueOf(Steaklocker.fahrenheitToCelsius(fahrenheit.floatValue()));
        }
        return null;
    }

    static public void loadTipsTricks(final SteaklockerAsyncListInterface callback) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("TipTrick");
        query.whereEqualTo("active", Boolean.valueOf(true));
        query.whereEqualTo("forAgingType", Steaklocker.TYPE_DRY_AGING);
        query.orderByAscending("rank");
        query.orderByDescending("createdAt");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> results, ParseException e) {
                if (e != null) {
                    Steaklocker._tipsDryAging = new ArrayList<ParseObject>();
                    // There was an error
                    callback.onError(e);
                } else {
                    Steaklocker._tipsDryAging = new ArrayList<ParseObject>(results);
                    callback.onSuccess(Steaklocker._tipsDryAging);
                }
            }
        });

        query = ParseQuery.getQuery("TipTrick");
        query.whereEqualTo("active", Boolean.valueOf(true));
        query.whereEqualTo("forAgingType", Steaklocker.TYPE_CHARCUTERIE);
        query.orderByAscending("rank");
        query.orderByDescending("createdAt");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> results, ParseException e) {
                if (e != null) {
                    Steaklocker._tipsDryAging = new ArrayList<ParseObject>();
                    // There was an error
                    callback.onError(e);
                } else {
                    Steaklocker._tipsCharcuterie = new ArrayList<ParseObject>(results);
                    callback.onSuccess(Steaklocker._tipsCharcuterie);
                }
            }
        });
    }
    static public List<ParseObject> getTipsTricks() {
        String agingType = Steaklocker.getAgingType();
        return agingType.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE) ? _tipsCharcuterie : _tipsDryAging;
    }

    static public ParseObject getLatestMeasurement() {
        return Steaklocker._latestMeasurement;
    }

    static public void loadLatestMeasurement(String impeeId, final SteaklockerAsyncInterface callback) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Measurement");
        query.whereEqualTo("impeeId", impeeId);
        query.orderByDescending("createdAt");
        query.getFirstInBackground(new GetCallback<ParseObject>() {
            public void done(ParseObject object, ParseException e) {
                if (object == null) {
                    callback.onError(e);
                } else {
                    Steaklocker._latestMeasurement = object;
                    callback.onSuccess(object);
                }
            }
        });
    }

    static public Double getTempPercentage(Double value) {
        Double spread = Steaklocker.tempMax - Steaklocker.tempMin;
        Double perc = (value - Steaklocker.tempMin) / spread;
        return perc * 100.0;



        //return 100.0 * (value - Steaklocker.tempMin) / spread;
    }
    static public Double getHumidPercentage(Double value) {
        Double spread = Steaklocker.humidMax - Steaklocker.humidMin;
        Double perc = (value - Steaklocker.humidMin) / spread;
        return perc * 100.0;
    }

    static public boolean showConnectionWarning() {
        ParseObject device = getUserDevice();
        if (device == null)
            return false;

        Date lastUpdatedTimestamp = device.getDate("lastMeasurementAt");
        if (lastUpdatedTimestamp == null)
            return false;

        long interval = (new Date().getTime() - lastUpdatedTimestamp.getTime()) / 1000;
        if (interval > 30 * 60)
            return true;

        return false;
    }

    static public boolean showTempWarning() {
        ParseObject device = getUserDevice();
        if (device == null) return false;

        Double lastTemp = device.getDouble("lastTemperature");

        boolean bStarted = device.getBoolean("warningTemp");
        if (lastTemp > 7.22222) {
            device.put("warningTemp", true);
            if (bStarted == false) {
                Date lastUpdatedTimestamp = device.getDate("lastMeasurementAt");
                if (lastUpdatedTimestamp == null) {
                    device.put("warningStartTemp", new Date());
                }
                else {
                    device.put("warningStartTemp", lastUpdatedTimestamp);
                }
                device.saveInBackground();
                return false;
            }
            else {
                Date startDate = device.getDate("warningStartTemp");
                if (startDate == null) return false;
                long interval = (new Date().getTime() - startDate.getTime()) / 1000;
                if (interval > 60 * 60)
                    return true;
                else
                    return false;
            }
        }

        return false;
    }

    static public boolean showHumidityWarning() {
        ParseObject device = getUserDevice();
        if (device == null) return false;

        Double lastTemp = device.getDouble("lastHumidity");

        boolean bStarted = device.getBoolean("warningHumidity");
        if (lastTemp < 60) {
            device.put("warningHumidity", true);
            if (bStarted == false) {
                Date lastUpdatedTimestamp = device.getDate("lastMeasurementAt");
                if (lastUpdatedTimestamp == null) {
                    device.put("warningStartHum", new Date());
                }
                else {
                    device.put("warningStartHum", lastUpdatedTimestamp);
                }
                device.saveInBackground();
                return false;
            }
            else {
                Date startDate = device.getDate("warningStartHum");
                if (startDate == null) return false;
                long interval = (new Date().getTime() - startDate.getTime()) / 1000;
                if (interval > 60 * 60)
                    return true;
                else
                    return false;
            }
        }

        return false;
    }


    static public void saveDevice(final Context context, String impeeId, String planId, String agentUrl) {

        ParseUser user = ParseUser.getCurrentUser();
        user.put("planId", planId);
        user.put("impeeId", impeeId);
        user.saveInBackground();

        Device device = new Device();
        device.setUser(user);
        device.put("type", "steaklocker");
        device.setPlanId(planId);
        device.setImpeeId(impeeId);
        device.setAgentUrl(agentUrl);

        Steaklocker.setUserDevice(device);

        device.saveInBackground(new SaveCallback() {
            @Override
            public void done(ParseException e) {
                Steaklocker.loadUserDevices(new SteaklockerAsyncListInterface() {
                    @Override
                    public void onSuccess(List<ParseObject> objects) {
                        Steaklocker.blinkup.cancelTokenStatusPolling();
                        SetupCompleteActivity activity = (SetupCompleteActivity)context;
                        activity.startActivity(new Intent(activity, DashboardActivity.class));
                    }

                    @Override
                    public void onError(ParseException e) {
                        Steaklocker.blinkup.cancelTokenStatusPolling();
                    }
                });
            }
        });
    }


    static public Intent logout(Context context, boolean startIntent) {
        ParseUser user = ParseUser.getCurrentUser();
        if (user != null) {
            ParseUser.logOut();
        }
        Intent intent = new Intent(context, MainActivity.class);
        if (startIntent) {
            context.startActivity(intent);
        }
        return intent;
    }

}



