package com.steaklocker.steaklocker;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;

import com.parse.ParseUser;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;


public class SetupActivity extends ActionBarActivity {


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_setup, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        String className = this.getLocalClassName();

        Intent intent = null;

        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        switch (item.getItemId()) {
            case R.id.action_start_over:
                intent = new Intent(this, SetupStartActivity.class);
                break;

            case R.id.action_logout:
                ParseUser user = ParseUser.getCurrentUser();
                if (user != null) {
                    ParseUser.logOut();
                }
                intent = new Intent(this, MainActivity.class);
                break;

        }

        if (intent != null) {
            this.startActivity(intent);
        }

        return super.onOptionsItemSelected(item);
    }
}
