package com.steaklocker.steaklocker;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.parse.ParseUser;

import java.util.ArrayList;

public class ChooserActivity extends SetupActivity {

    final String series[] = new String[] {"Home Series", "Professional Series"};
    final String homeModel[] = new String[] {"SL103", "SL150"};
    final String professionalModel[] = new String[] {"SL520"};

    public boolean  isHome;
    public boolean  isModelChooser;
    public int      selectedIndex;

    public ChooserActivity() {

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_model_chooser);

        isHome = getIntent().getBooleanExtra("isHome", true);
        isModelChooser = getIntent().getBooleanExtra("isModelChooser", false);
        selectedIndex = getIntent().getIntExtra("selectedIndex", 0);

        final ListView list = (ListView) findViewById(R.id.model_list_view);
        if (!isModelChooser) {
            list.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_single_choice, series));
        }
        else {
            if (isHome) {
                list.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_single_choice, homeModel));
            }
            else {
                list.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_single_choice, professionalModel));
            }
        }

        list.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        list.setItemChecked(selectedIndex, true);

        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                selectedIndex = position;
                list.setItemChecked(selectedIndex, true);
                Intent intent = new Intent();

                if (isModelChooser) {
                    if (isHome)
                        intent.putExtra("Model", homeModel[selectedIndex]);
                    else
                        intent.putExtra("Model", professionalModel[selectedIndex]);
                }
                else
                    intent.putExtra("Series", series[selectedIndex]);
                setResult(RESULT_OK, intent);
                finish();
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Intent intent = null;
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
            return super.onOptionsItemSelected(item);
        }
        else
            finish();

        return true;
    }

}
