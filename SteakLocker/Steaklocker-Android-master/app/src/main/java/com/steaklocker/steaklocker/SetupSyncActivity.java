package com.steaklocker.steaklocker;

import android.content.Intent;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.os.PowerManager;
import android.content.Context;

import com.parse.ParseException;
import com.electricimp.blinkup.BlinkupController;
import com.electricimp.blinkup.BlinkupController.*;
import org.json.*;
import android.view.WindowManager;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;

public class SetupSyncActivity extends SetupActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_sync);

        // Call this to init blinkup, stored in static Steaklocker.blinkup
        BlinkupController blinkup = Steaklocker.getBlinkup();

        final Button button = (Button) findViewById(R.id.next);
        button.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v) {
                if (Steaklocker.isConnectedViaWifi()) {
                    button.setText("Preparing...");
                    flashSSID(Steaklocker.blinkUpSsid, Steaklocker.blinkUpPass);
                }
                else {
                    Crouton.makeText(SetupSyncActivity.this, "You must be connected to WiFi", Style.ALERT).show();
                }

            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        Button button = (Button) findViewById(R.id.next);
        button.setText("Sync");
    }

    protected void flashSSID(String ssid, String pass) {
        WindowManager.LayoutParams settings = getWindow().getAttributes();
        settings.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_FULL;
        getWindow().setAttributes(settings);

        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);

        Steaklocker.wakeLock = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK, "ScreenOnForBlinkUp");
        if (Steaklocker.wakeLock != null) {
            Steaklocker.wakeLock.acquire();
        }

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);



        //Steaklocker.blinkup.setPlanID(Steaklocker.getGlobalPlanId());
        Steaklocker.blinkup.intentBlinkupComplete = new Intent(this, SetupCompleteActivity.class);


        Steaklocker.blinkup.setupDevice(SetupSyncActivity.this, ssid, pass,
            Steaklocker.getAPIKey(), new BlinkupController.ServerErrorHandler() {
                @Override
                public void onError(String message){
                    Crouton.makeText(SetupSyncActivity.this, message, Style.ALERT).show();
                }
            }
        );



    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Steaklocker.blinkup.handleActivityResult(this, requestCode, resultCode, data);
    }

}
