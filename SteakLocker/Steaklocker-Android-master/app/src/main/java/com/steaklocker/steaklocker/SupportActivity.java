package com.steaklocker.steaklocker;


import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.content.Intent;
import android.content.Context;
import android.net.Uri;
import android.widget.TextView;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import com.parse.ParseConfig;

public class SupportActivity extends SteaklockerActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_support);


        TextView textVersion = (TextView)findViewById(R.id.textVersion);
        String version = "";
        try {
            PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            version = "Version "+ pInfo.versionName + "."+ pInfo.versionCode;
        }
        catch(PackageManager.NameNotFoundException e) {

        }

        textVersion.setText(version);


        Button button = (Button) findViewById(R.id.supportButton);
        button.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                /* Create the Intent */
                final Intent emailIntent = new Intent(Intent.ACTION_SEND);

                ParseConfig config = ParseConfig.getCurrentConfig();

                // Fill it with Data
                emailIntent.setType("plain/text");
                emailIntent.putExtra(android.content.Intent.EXTRA_EMAIL, new String[]{config.getString("supportEmail", "info@steaklocker.com")});
                emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, "Steaklocker Android App Support");
                startActivity(Intent.createChooser(emailIntent, "Send mail..."));

            }
        });
    }


}

