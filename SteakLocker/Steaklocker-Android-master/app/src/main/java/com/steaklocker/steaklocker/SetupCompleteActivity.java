package com.steaklocker.steaklocker;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.TextView;

import com.electricimp.blinkup.BlinkupController;
import com.electricimp.blinkup.BlinkupController.TokenStatusCallback;

public class SetupCompleteActivity extends Activity {
    private BlinkupController blinkup;

    private View progressBar;
    private TextView status;

    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.US);

    private TokenStatusCallback callback = new TokenStatusCallback() {
        @Override
        public void onSuccess(JSONObject json) {
            try {
                if (Steaklocker.wakeLock != null) {
                    Steaklocker.wakeLock.release();
                    Steaklocker.wakeLock = null;
                }

                String claimedAt = json.getString("claimed_at"); claimedAt = claimedAt .replace("Z", "+0:00");
                String agentUrl = json.getString("agent_url");
                String impeeId = json.getString("impee_id");
                String planId = json.getString("plan_id");

                if (impeeId != null) impeeId = impeeId.trim();
                Steaklocker.saveDevice(SetupCompleteActivity.this, impeeId, planId, agentUrl);

                //finish();
            } catch (JSONException e) {
                onError(e.getMessage());
            }
        }

        public void onError(String errorMsg) {
            if (Steaklocker.wakeLock != null) {
                Steaklocker.wakeLock.release();
                Steaklocker.wakeLock = null;
            }
            progressBar.setVisibility(View.GONE);
            status.setText(errorMsg);
            finish();
        }

        @Override
        public void onTimeout() {
            if (Steaklocker.wakeLock != null) {
                Steaklocker.wakeLock.release();
                Steaklocker.wakeLock = null;
            }
            progressBar.setVisibility(View.GONE);
            status.setText("Timeout");
            finish();
        }

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_complete);

        progressBar = findViewById(R.id.progress_bar);
        status = (TextView) findViewById(R.id.status);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Steaklocker.blinkup.getTokenStatus(callback, 10*1000);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Steaklocker.blinkup.cancelTokenStatusPolling();
    }
}