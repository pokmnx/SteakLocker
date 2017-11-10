package com.steaklocker.steaklocker;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;


public class SetupStartActivity extends SetupActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_start);

        Button button = (Button) findViewById(R.id.next);
        button.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                //Intent intent = new Intent(SetupStartActivity.this, SetupSelectWifi.class);
                Intent intent = new Intent(SetupStartActivity.this, SetupChooserActivity.class);
                startActivity(intent);

            }
        });

    }

}
