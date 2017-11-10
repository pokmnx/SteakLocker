package com.steaklocker.steaklocker;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Spinner;
import android.widget.EditText;
import android.widget.Button;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;



public class ProfileActivity extends SteaklockerActivity {
    private EditText editName;
    private EditText editEmail;
    private EditText editPass;
    private Button btnSave;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }

        initForm();
    }


    // get the selected dropdown list value
    public void initForm() {
        ParseUser user = ParseUser.getCurrentUser();

        editName = (EditText) findViewById(R.id.editName);
        editEmail = (EditText) findViewById(R.id.editEmail);
        editPass = (EditText) findViewById(R.id.editPass);
        btnSave = (Button) findViewById(R.id.buttonProfileSave);


        editName.setText(user.getString("name"));
        editEmail.setText(user.getEmail());



        btnSave.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ParseUser user = ParseUser.getCurrentUser();


                user.setEmail(editEmail.getText().toString());
                user.put("name", editName.getText().toString());
                String pass = editPass.getText().toString();

                if (pass.length() > 0) {
                    user.setPassword(pass);
                }

                Crouton.makeText(ProfileActivity.this, "Saving User...", Style.INFO).show();
                user.saveInBackground(new SaveCallback() {
                    @Override
                    public void done(ParseException e) {
                        if (e == null) {
                            Crouton.makeText(ProfileActivity.this, "User Saved", Style.CONFIRM).show();
                        }
                        else {
                            Crouton.makeText(ProfileActivity.this, "User Save Failed", Style.ALERT).show();
                        }
                    }
                });



            }

        });
    }

}
