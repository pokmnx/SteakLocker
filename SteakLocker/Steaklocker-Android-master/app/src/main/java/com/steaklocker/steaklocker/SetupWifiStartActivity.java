package com.steaklocker.steaklocker;

import android.content.Intent;
import android.os.Bundle;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

public class SetupWifiStartActivity extends SetupActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wifi_setup_start);

        Display display = getWindowManager().getDefaultDisplay();
        int width = display.getWidth();

        ImageView wifiImageView = (ImageView) findViewById(R.id.wifi_image);
        int imageWidth = (int) (width * 0.5);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(imageWidth, imageWidth);
        params.gravity = Gravity.CENTER_HORIZONTAL;
        params.setMargins(50, 50, 50, 50);
        wifiImageView.setLayoutParams(params);

        Button next = (Button) findViewById(R.id.next);
        next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(SetupWifiStartActivity.this, SetupConnectActivity.class);
                startActivity(intent);

                ELADevice device = ELA.getSharedInstance().getELADevice();
                if (!device.isConnectedToDeviceWifi(SetupWifiStartActivity.this)) {
                    ELA.getSharedInstance().openWifiSettings(SetupWifiStartActivity.this);
                }
            }
        });
    }
}
