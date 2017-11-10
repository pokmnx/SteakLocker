package com.steaklocker.steaklocker;

import android.support.v7.app.ActionBarActivity;

import android.util.Log;
import android.util.LogPrinter;
import android.view.Menu;
import android.view.MenuItem;
import android.content.Intent;

import com.parse.ParseUser;

public class SteaklockerActivity extends ActionBarActivity {



    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_global, menu);
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
            case R.id.action_add_object:
                intent = new Intent(this, AddSteakActivity.class);
                break;

            case R.id.action_dashboard:
                intent = new Intent(this, DashboardActivity.class);
                break;
            case R.id.action_objects:
                intent = new Intent(this, ObjectsActivity.class);
                break;

            case R.id.action_reports:
                intent = new Intent(this, ReportsActivity.class);
                break;

            case R.id.action_tipstricks:
                intent = new Intent(this, TipsTricksActivity.class);
                break;

            case R.id.action_profile:
                intent = new Intent(this, ProfileActivity.class);
                break;

            case R.id.action_settings:
                intent = new Intent(this, SettingsActivity.class);
                break;

/*            case R.id.action_support:
                intent = new Intent(this, SupportActivity.class);
                break;
*/
            case R.id.action_logout:
                intent = Steaklocker.logout(this, false);
                break;

        }

        if (intent != null) {
            this.startActivity(intent);
        }

        return super.onOptionsItemSelected(item);
    }
}
