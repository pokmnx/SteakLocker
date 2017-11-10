package com.steaklocker.steaklocker;


import android.content.Context;
import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.parse.ParseUser;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

import cz.msebera.android.httpclient.Header;

import static com.steaklocker.steaklocker.SocketResponseHandler.EVENT_DEVICE_CONNECT;
import static com.steaklocker.steaklocker.SocketResponseHandler.EVENT_DEVICE_CONNECT_TIME_OUT;
import static com.steaklocker.steaklocker.SocketResponseHandler.EVENT_DEVICE_STATUS_CHECK_FAILED;
import static com.steaklocker.steaklocker.SocketResponseHandler.REQUEST_CMD_API_CONNECT;
import static com.steaklocker.steaklocker.SocketResponseHandler.REQUEST_CMD_CONNECT;
import static com.steaklocker.steaklocker.SocketResponseHandler.REQUEST_CMD_READ;
import static com.steaklocker.steaklocker.SocketResponseHandler.REQUEST_CMD_SAVE;

public class ELADevice {

    public boolean hasSettings;
    public String ssid;
    public String pass;
    public String uniqueId;
    public String fwVersion;
    public String appId;
    public String interval;
    public String model;
    public boolean connected;

    public ELADevice() {
        hasSettings = false;
        ssid = null;
        pass = null;
        uniqueId = null;
        fwVersion = null;
        appId = null;
        interval = null;
        model = null;
        connected = false;
    }

    public boolean isConnectedToDeviceWifi(Context context) {
        String ssid = ELA.getSharedInstance().getWifiSSID(context);

        if (ssid != null && (ssid.equals(ELA.steakWifiSSID()) || ssid.equals(ELA.steakDeviceWifiName()))) {
            ELA.log("ConnectedToDeviceWifi - SSID: " + ssid);
            return true;
        }

        ELA.log("Not ConnectedToDeviceWifi");
        return false;
    }

    public boolean isConnectedToDeviceSocket() {
        return true;
    }

    public boolean connect() {
        try {
            socket = new Socket();
            InetAddress address = InetAddress.getByName(destIPAddr);
            socket.connect(new InetSocketAddress(address, port), (int) timeout);
            ELA.log("Socket Connected " + address + " " + port);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (socket != null && socket.isConnected()) {
                ELA.log("Socket Already Connected");
                return true;
            }
            else {
                ELA.log("Couldn't Connect Socket");
                return false;
            }
        }
    }

    public boolean sendData(JSONObject jsonObject) {
        if (socket == null || !socket.isConnected()) {
            ELA.log("Socket has not been created yet or not connected yet");
            connect();
        }
        ELA.log("Sending Data...");
        try {
            byte[] data = jsonObject.toString().getBytes(StandardCharsets.UTF_8);
            outputStream = socket.getOutputStream();
            outputStream.write(data);
            outputStream.flush();
            ELA.log("Send Data Completed");
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            ELA.log("Send Data Failed");
            return false;
        }
    }

    public JSONObject receiveData() {
        ELA.log("Ready to receive data from server socket");
        if (socket != null && socket.isConnected()) {
            try {
                byte[] data = new byte[1024];
                for (int i = 0; i < 1024; i++) data[i] = '\0';
                inputStream = socket.getInputStream();
                inputStream.read(data);
                String responseStr = new String(data, StandardCharsets.UTF_8);
                String realStr = "";
                int index = 0;
                for (int i = responseStr.length() - 1; i >= 0; i--){
                    char c = responseStr.charAt(i);
                    if (c == '}') {
                        index = i + 1;
                        break;
                    }
                }

                for (int i = 0; i < index; i++) {

                    realStr += responseStr.charAt(i);
                }

                realStr = realStr.replaceAll("\\r", "");
                realStr = realStr.replaceAll("\\n", "");
                realStr = realStr.replace("\"\"mac-address", "\",\"mac-address");
                int lastIndex = realStr.indexOf("}}") + 2;
                responseStr = realStr.substring(0, lastIndex);

                if (responseStr != null && responseStr.length() != 0) {
                    JSONObject jsonObject = new JSONObject(responseStr);
                    ELA.log("Received Data successfully.");
                    return jsonObject;
                }
                ELA.log("Received Data size is zero");
                return null;
            } catch (IOException e) {
                e.printStackTrace();
                ELA.log("Couldn't receive data.");
                return null;
            } catch (JSONException e) {
                e.printStackTrace();
                ELA.log("Couldn't receive data.");
                return null;
            }
        }
        ELA.log("Socket has not been created yet or not connected. So couldn't receive data.");
        return null;
    }

    public void updateSettingsFromDevice(JSONObject jsonObject) {
        if (jsonObject == null) return;

        JSONObject data = null;
        try {
            data = jsonObject.getJSONObject("data");
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }

        if (data == null) return;

        try {
            this.ssid = data.getString("ssid");
        } catch (JSONException e) {e.printStackTrace();}

        try {
            this.pass = data.getString("password");
        } catch (JSONException e) {e.printStackTrace();}

        try {
            String id = data.getString("unique-id");
            if (id != null) this.uniqueId = id;
        } catch (JSONException e) {e.printStackTrace();}

        try {
            this.fwVersion = data.getString("fw-version");
        } catch (JSONException e) {e.printStackTrace();}

        try {
            this.appId = data.getString("application-id");
        } catch (JSONException e) {e.printStackTrace();}

        try {
            this.interval = data.getString("interval");
        } catch (JSONException e) {e.printStackTrace();}
    }

    public static boolean bSocketWorking = false;

    public void readSettings(final SocketResponseHandler socketResponseHandler) {
        ELA.log("Begin Reading Settings");
        if (bSocketWorking) return;
        final Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    bSocketWorking = true;
                    JSONObject request = new JSONObject();
                    request.put("request", "read-data");
                    JSONObject data = new JSONObject();
                    data.put("request-field", "all");
                    request.put("data", data);

                    boolean bSuccess = sendData(request);
                    if (bSuccess == false) {
                        ELA.log("Read Settings Failed - Request Error");
                        bSocketWorking = false;
                        socketResponseHandler.getResponseFailed(REQUEST_CMD_READ, REQUEST_ERROR);
                    }
                    else {
                        JSONObject response = receiveData();
                        bSocketWorking = false;
                        if (response == null) {
                            ELA.log("Read Settings Failed - Response Error - Null");
                            socketResponseHandler.getResponseFailed(REQUEST_CMD_READ, RESPONSE_ERROR);
                        }
                        else {
                            ELA.log("Read Settings Success");
                            updateSettingsFromDevice(response);
                            socketResponseHandler.getResponse(REQUEST_CMD_READ, response);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    ELA.log("Read Settings Failed - JSON Parse Error");
                    bSocketWorking = false;
                    socketResponseHandler.getResponseFailed(REQUEST_CMD_READ, e.getMessage());
                }
            }
        });
        thread.start();
    }

    public void saveSettings(final SocketResponseHandler socketResponseHandler) {
        ELA.log("Begin Save Settings");
        if (bSocketWorking) return;
        final Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                bSocketWorking = true;
                JSONObject request = new JSONObject();
                try {
                    request.put("request", "save-data");
                    JSONObject data = new JSONObject();
                    data.put("ssid", ssid);
                    data.put("password", pass);
                    data.put("application-id", "MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI");
                    data.put("post-address", "http://steaklocker.herokuapp.com/parse/classes/Measurement");
                    request.put("data", data);

                    boolean bSuccess = sendData(request);
                    if (bSuccess == false) {
                        ELA.log("Save Settings Failed - Request Error");
                        bSocketWorking = false;
                        socketResponseHandler.getResponseFailed(REQUEST_CMD_SAVE, REQUEST_ERROR);
                    }
                    else {
                        JSONObject response = receiveData();
                        bSocketWorking = false;
                        if (response == null) {
                            ELA.log("Save Settings Failed - Response Error - Null");
                            socketResponseHandler.getResponseFailed(REQUEST_CMD_SAVE, RESPONSE_ERROR);
                        }
                        else {
                            ELA.log("Save Settings Success");
                            socketResponseHandler.getResponse(REQUEST_CMD_SAVE, response);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    ELA.log("Save Settings Failed - JSON Parse Error");
                    bSocketWorking = false;
                    socketResponseHandler.getResponseFailed(REQUEST_CMD_SAVE, e.getMessage());
                }
            }
        });
        thread.start();
    }

    public void apiConnect(final SocketResponseHandler socketResponseHandler) {
        ELA.log("Begin Api Connect");
        if (bSocketWorking) return;
        final Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                bSocketWorking = true;
                ParseUser user = ParseUser.getCurrentUser();
                String url = String.format("http://steaklocker.herokuapp.com/device/connect/%s/%s/%s/%s", ELA.getLockerType(), user.getObjectId(), uniqueId, model);

                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("request", "api-connect");
                    JSONObject data = new JSONObject();
                    data.put("nonce", uniqueId);
                    data.put("url", url);
                    jsonObject.put("data", data);

                    boolean bSuccess = sendData(jsonObject);
                    if (bSuccess == false) {
                        ELA.log("Api_Connect Failed - Request Error");
                        bSocketWorking = false;
                        socketResponseHandler.getResponseFailed(REQUEST_CMD_API_CONNECT, REQUEST_ERROR);
                    }
                    else {
                        JSONObject response = receiveData();
                        bSocketWorking = false;
                        if (response == null) {
                            ELA.log("Api_Connect Failed - Response Error - Null");
                            socketResponseHandler.getResponseFailed(REQUEST_CMD_API_CONNECT, RESPONSE_ERROR);
                        }
                        else {
                            ELA.log("Api_Connect Success");
                            socketResponseHandler.getResponse(REQUEST_CMD_API_CONNECT, response);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    ELA.log("Api_Connect Failed - JSON Parse Error");
                    bSocketWorking = false;
                    socketResponseHandler.getResponseFailed(REQUEST_CMD_API_CONNECT, e.getMessage());
                }
            }
        });
        thread.start();
    }

    Handler checkHandler;
    Runnable checkRunnable;

    Handler timeoutHandler;
    Runnable timeoutRunnable;

    public void initStatusCheck(final SocketResponseHandler socketResponseHandler) {
        ELA.log("Begin status checking");
        checkHandler = new Handler();
        checkRunnable = new Runnable() {
            @Override
            public void run() {
                if (!connected) {
                    makeStatusCall(socketResponseHandler);
                    checkHandler.postDelayed(checkRunnable, 7000);
                }
                else {
                    checkHandler.removeCallbacksAndMessages(null);
                }
            }
        };
        checkHandler.post(checkRunnable);

        timeoutHandler = new Handler();
        timeoutRunnable = new Runnable() {
            @Override
            public void run() {
                if (!connected) {
                    ELA.log("Timeout - Status Checking");
                    socketResponseHandler.eventEmitted(EVENT_DEVICE_CONNECT_TIME_OUT);
                    cancelStatusCheck();
                }
            }
        };
        timeoutHandler.postDelayed(timeoutRunnable, 60000);
    }

    public void cancelStatusCheck() {
        ELA.log("Cancel Status Check");
        if (checkHandler != null) checkHandler.removeCallbacksAndMessages(null);
        if (timeoutHandler != null) timeoutHandler.removeCallbacksAndMessages(null);
    }

    private static final int TIME_OUT = 70000;
    public void makeStatusCall(final SocketResponseHandler socketResponseHandler) {
        ELA.log("Making Status Call");
        AsyncHttpClient client = new AsyncHttpClient();
        client.setTimeout(TIME_OUT);
        client.setConnectTimeout(TIME_OUT);
        client.setResponseTimeout(TIME_OUT);
        client.addHeader("accept", "application/json");

        ParseUser user = ParseUser.getCurrentUser();
        String url = String.format("https://steaklocker.herokuapp.com/device/status/%s/%s/%s", ELA.getLockerType(), user.getObjectId(), uniqueId);
        client.post(url, new JsonHttpResponseHandler() {
            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                try {
                    int status = response.getInt("status");
                    ELA.log("Device Status - " + status);
                    if (status > 0)
                    {
                        connected = true;
                        cancelStatusCheck();
                        socketResponseHandler.eventEmitted(EVENT_DEVICE_CONNECT);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                ELA.log("Device Status Checking Failed " + errorResponse.toString());
                socketResponseHandler.eventEmitted(EVENT_DEVICE_STATUS_CHECK_FAILED);
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
                ELA.log("Device Status Checking Failed " + responseString);
                socketResponseHandler.eventEmitted(EVENT_DEVICE_STATUS_CHECK_FAILED);
            }
        });
    }

    public boolean needToReadSettings() {
        if (ssid == null || pass == null || uniqueId == null)
            return true;
        return false;
    }

    private String destIPAddr = "192.168.1.1";
    private int port = 80;
    private Socket socket;
    private long timeout = 7000;
    private OutputStream outputStream;
    private InputStream inputStream;

    public static String REQUEST_ERROR = "SOCKET_SEND_REQUEST_ERROR";
    public static String RESPONSE_ERROR = "SOCKET_RECEIVE_RESPONSE_ERROR";

}
