package com.steaklocker.steaklocker;

import android.app.ProgressDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.ParseObject;

import org.json.JSONObject;

import java.util.List;

public class SetupConnectActivity extends SetupActivity implements View.OnClickListener {

    RelativeLayout  status;
    TextView        connectionDescription;
    LinearLayout    wifiCreds;
    Button          connect;
    EditText        ssidField;
    EditText        passwordField;
    Button          finish;

    ProgressDialog  progressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_connect);

        status = (RelativeLayout) findViewById(R.id.connection_status);
        connectionDescription = (TextView) findViewById(R.id.connection_status_description);
        wifiCreds = (LinearLayout) findViewById(R.id.wifi_creds);

        connect = (Button) findViewById(R.id.connect_button);
        connect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ELA.getSharedInstance().openWifiSettings(SetupConnectActivity.this);
            }
        });

        ssidField = (EditText) findViewById(R.id.ssid);
        passwordField = (EditText) findViewById(R.id.password);

        finish = (Button) findViewById(R.id.finish);
        finish.setOnClickListener(this);

        initializeForm();
    }

    void initializeForm() {
        String ssid = ELA.getSharedInstance().getWifiSSID(this);
        ELADevice device = ELA.getSharedInstance().getELADevice();

        updateStatusText(device);

        boolean connected = device.isConnectedToDeviceWifi(this);
        if (connected && device.uniqueId != null && device.uniqueId.equals("") != true)
        {
            wifiCreds.setVisibility(View.VISIBLE);
            if (!ssid.equals(ELA.getSharedInstance().steakDeviceWifiName())) {
                ssidField.setText(ssid);
            }

            LinearLayout macContainer = (LinearLayout) findViewById(R.id.mac_container);
            final String macAddress = ELA.getSharedInstance().getCurrentBSSID(this);
            if (macAddress == null) macContainer.setVisibility(View.INVISIBLE);
            else {
                Button copyToClipboard = (Button) findViewById(R.id.mac_address);
                final String buttonTxt = "Mac Address\n" + macAddress;
                copyToClipboard.setText(buttonTxt);

                copyToClipboard.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                        ClipData clip = android.content.ClipData.newPlainText(null, macAddress);
                        clipboard.setPrimaryClip(clip);
                    }
                });
            }
        }
        else {
            wifiCreds.setVisibility(View.INVISIBLE);
        }
    }

    void updateStatusText(final ELADevice device) {
        boolean connected = device.isConnectedToDeviceWifi(this);
        TextView statusText = (TextView) findViewById(R.id.connection_status_text);

        if (!connected) {
            statusText.setText("Steak Locker Not Connected");
            connectionDescription.setText("Oops, you're not connected to the Steak Locker Wifi. Please Connect and return to continue.");
        }
        else {
            boolean socketConnected = device.isConnectedToDeviceSocket();
            statusText.setText("Connected to Steak Locker WiFi");

            if ((device.uniqueId != null && device.uniqueId.equals("") != true) && socketConnected) {
                connectionDescription.setText("Perfect, we've found your device. One last step.");
                wifiCreds.setVisibility(View.VISIBLE);
                String ssid = ELA.getSharedInstance().getWifiSSID(this);
                if (!ssid.equals(ELA.getSharedInstance().steakDeviceWifiName())) {
                    ssidField.setText(ssid);
                }
            }
            else if (socketConnected) {
                connectionDescription.setText("Connecting to your locker... reading settings...");
                device.readSettings(new SocketResponseHandler() {
                    @Override
                    public void getResponse(String requestCmd, final JSONObject response) {
                        if (requestCmd.equals(REQUEST_CMD_READ)) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    updateStatusText(device);
                                }
                            });
                        }
                    }

                    @Override
                    public void getResponseFailed(String requestCmd, String errorMessage) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                hideProgress();
                                Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                            }
                        });
                    }

                    @Override
                    public void eventEmitted(String event) {

                    }
                });
            }
            else
                connectionDescription.setText("Connecting to your locker...");

            connect.setVisibility(View.INVISIBLE);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        initializeForm();
    }

    @Override
    public void onClick(View v) {
        hideKeyboard();

        final ELADevice device = ELA.getSharedInstance().getELADevice();
        device.ssid = ssidField.getText().toString();
        device.pass = passwordField.getText().toString();

        showProgress("Connecting locker to your account...");
        device.saveSettings(new SocketResponseHandler() {
            @Override
            public void getResponse(String requestCmd, JSONObject response) {
                if (requestCmd.equals(REQUEST_CMD_SAVE) && response != null) {

                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                Thread.sleep(1000);
                                apiConnect(device);
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                        }
                    }).start();
                }
            }

            @Override
            public void getResponseFailed(String requestCmd, String errorMessage) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        hideProgress();
                        Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void eventEmitted(String event) {}
        });
    }

    public void apiConnect(ELADevice device) {
        device.apiConnect(new SocketResponseHandler() {
            @Override
            public void getResponse(String requestCmd, JSONObject response) {

                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Thread.sleep(1000);
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    ELADevice elaDevice = ELA.getSharedInstance().getELADevice();
                                    initStatusCheck(elaDevice);
                                }
                            });
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();
            }

            @Override
            public void getResponseFailed(String requestCmd, String errorMessage) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        hideProgress();
                        Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                    }
                });
            }

            @Override
            public void eventEmitted(String event) {}
        });
    }

    public void initStatusCheck(ELADevice device) {
        device.initStatusCheck(new SocketResponseHandler() {
            @Override
            public void getResponse(String requestCmd, JSONObject response) {}

            @Override
            public void getResponseFailed(String requestCmd, String errorMessage) {}

            @Override
            public void eventEmitted(String event) {
                if (event.equals(EVENT_DEVICE_CONNECT_TIME_OUT)) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            hideProgress();
                            Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong, we ran out of time.", Toast.LENGTH_LONG).show();
                        }
                    });
                }
                else if (event.equals(EVENT_DEVICE_CONNECT)) {
                    onDeviceConnected();
                }
                else {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            hideProgress();
                            Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                        }
                    });
                }
            }
        });

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showProgress("Waiting for your locker to come online...");
            }
        });
    }

    public void onDeviceConnected() {
        final ELADevice elaDevice = ELA.getSharedInstance().getELADevice();
        Steaklocker.reloadUserDevices(new Steaklocker.SteaklockerAsyncListInterface() {
            @Override
            public void onSuccess(List<ParseObject> objects) {
                elaDevice.cancelStatusCheck();

                ParseObject device = Steaklocker.getUserDeviceByImpeeId(elaDevice.uniqueId);
                if (device != null) {
                    Steaklocker.setUserDevice(device);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            hideProgress();
                            Intent intent = new Intent(SetupConnectActivity.this, DashboardActivity.class);
                            startActivity(intent);
                        }
                    });
                }
                else {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            hideProgress();
                            Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                        }
                    });
                }
            }

            @Override
            public void onError(ParseException e) {
                elaDevice.cancelStatusCheck();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        hideProgress();
                        Toast.makeText(SetupConnectActivity.this, "Oops, something went wrong.", Toast.LENGTH_LONG).show();
                    }
                });
            }
        });
    }

    public void showProgress(String status) {
        if (progressDialog == null || progressDialog.isShowing() == false) {
            progressDialog = new ProgressDialog(SetupConnectActivity.this);
            progressDialog.setCancelable(false);
            progressDialog.setCanceledOnTouchOutside(false);
        }

        progressDialog.setMessage(status);
        progressDialog.show();
    }

    public void hideProgress() {
        if (progressDialog == null) return;
        progressDialog.dismiss();
    }

    public void hideKeyboard() {
        // Check if no view has focus:
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager inputManager = (InputMethodManager) this.getSystemService(Context.INPUT_METHOD_SERVICE);
            inputManager.hideSoftInputFromWindow(view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
}
