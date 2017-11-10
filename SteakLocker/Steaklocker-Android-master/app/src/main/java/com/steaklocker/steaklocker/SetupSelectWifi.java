package com.steaklocker.steaklocker;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;


public class SetupSelectWifi extends SetupActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_select_wifi);


        EditText textSsid = (EditText)findViewById(R.id.ssid);
        if (Steaklocker.blinkUpSsid != null && !Steaklocker.blinkUpSsid.isEmpty()) {
            textSsid.setText(Steaklocker.blinkUpSsid);
        }
        else {
            String ssidDefault = Steaklocker.blinkup.getCurrentWifiSSID(this);
            textSsid.setText(ssidDefault);
        }

        EditText textPass = (EditText)findViewById(R.id.pass);
        if (Steaklocker.blinkUpPass != null && !Steaklocker.blinkUpPass.isEmpty()) {
            textPass.setText(Steaklocker.blinkUpPass);
        }

        Button button = (Button) findViewById(R.id.next);
        button.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                EditText ssid = (EditText)findViewById(R.id.ssid);
                Steaklocker.blinkUpSsid = ssid.getText().toString();
                EditText pass = (EditText)findViewById(R.id.pass);
                Steaklocker.blinkUpPass = pass.getText().toString();

                Intent intent = new Intent(SetupSelectWifi.this, SetupSyncActivity.class);
                startActivity(intent);

            }
        });
    }


}
