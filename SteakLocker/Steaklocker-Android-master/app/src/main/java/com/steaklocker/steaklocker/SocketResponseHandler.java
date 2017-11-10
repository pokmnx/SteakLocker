package com.steaklocker.steaklocker;


import org.json.JSONObject;

public interface SocketResponseHandler {
    static final String REQUEST_CMD_READ = "read-data";
    static final String REQUEST_CMD_SAVE = "save-data";
    static final String REQUEST_CMD_API_CONNECT = "api-connect";
    static final String REQUEST_CMD_CONNECT = "connect";

    static final String EVENT_DEVICE_CONNECT = "deviceConnected";
    static final String EVENT_DEVICE_CONNECT_TIME_OUT = "deviceConnectionTimeout";
    static final String EVENT_DEVICE_STATUS_CHECK_FAILED = "deviceStatusCheckFailed";

    public void getResponse(String requestCmd, JSONObject response);
    public void getResponseFailed(String requestCmd, String errorMessage);
    public void eventEmitted(String event);
}
