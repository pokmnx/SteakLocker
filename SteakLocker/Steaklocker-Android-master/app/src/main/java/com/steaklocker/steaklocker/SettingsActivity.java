package com.steaklocker.steaklocker;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Spinner;
import android.widget.Button;
import android.view.View;
import java.util.List;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Map;
import java.lang.Float;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.EditText;
import android.text.InputType;
import android.content.Intent;
import android.net.Uri;
import android.net.MailTo;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.widget.LinearLayout;
import android.view.Gravity;
import com.parse.ParseCloud;
import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.FunctionCallback;

import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.rengwuxian.materialedittext.MaterialEditText;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;
import io.realm.internal.TableView;


public class SettingsActivity extends SteaklockerActivity {
    private TableLayout lockerListTable;
    private Spinner settingTempUnits;
    private Spinner settingAgingType;
    private Spinner settingTemperatureDryAging;
    private Spinner settingTemperatureCharcuterie;
    private Spinner settingHumidityDryAging;
    private Spinner settingHumidityCharcuterie;
    private Spinner settingAlerts;
    private Button btnSave;
    private boolean temperatureEnabled=false;
    private boolean humidityEnabled=false;
    private String enableFeatureMessage = "";

    static List<String> agingTypeOptions;
    Map<Float, String> tempOptionsDryAging = new HashMap<>();
    Map<Float, String> tempOptionsCharcuterie = new HashMap<>();
    Map<Float, String> humidOptionsDryAging = new HashMap<>();
    Map<Float, String> humidOptionsCharcuterie = new HashMap<>();
    List<Float> tempArrayDryAging = null;
    List<Float> tempArrayCharcuterie = null;
    List<Float> humidArrayDryAging = null;
    List<Float> humidArrayCharcuterie = null;


    public static Float getKeyByValue(Map<Float, String> map, String value) {
        for (Entry<Float, String> entry : map.entrySet()) {
            String entryVal = entry.getValue();
            if (value.equals(entryVal)) {
                return entry.getKey();
            }
        }
        return null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);


        if (agingTypeOptions == null) {
            agingTypeOptions = Arrays.asList((getResources().getStringArray(R.array.agingTypeOptions)));
        }
        settingTempUnits = (Spinner) findViewById(R.id.settingTempUnit);
        settingAgingType = (Spinner) findViewById(R.id.settingAgingType);
        settingTemperatureDryAging = (Spinner) findViewById(R.id.settingTemperatureDryAging);
        settingTemperatureCharcuterie = (Spinner) findViewById(R.id.settingTemperatureCharcuterie);
        settingHumidityDryAging = (Spinner) findViewById(R.id.settingHumidityDryAging);
        settingHumidityCharcuterie = (Spinner) findViewById(R.id.settingHumidityCharcuterie);
        settingAlerts = (Spinner) findViewById(R.id.settingNotification);
        btnSave = (Button) findViewById(R.id.buttonSettingsSave);


        lockerListTable = (TableLayout)findViewById(R.id.lockerList);


        ParseObject currDevice = Steaklocker.getUserDevice();
        List<ParseObject> lockers = Steaklocker.getUserDevices();

        for (ParseObject locker : lockers) {
            String nickname = locker.getString("nickname");

            // Inflate your row "template" and fill out the fields.
            TableRow row = (TableRow) LayoutInflater.from(this).inflate(R.layout.locker_settings_row, null);
            ((TextView) row.findViewById(R.id.locker_row_name)).setText(nickname);

            /*
            if (currDevice.getObjectId().equals(locker.getObjectId())) {
                ((TextView) row.findViewById(R.id.locker_is_active)).setText("Active");
            }
            */
            lockerListTable.addView(row);




        }


        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }

        Steaklocker.loadConfig(new Steaklocker.SteaklockerAsyncInterface() {
            @Override
            public void onSuccess(ParseObject parseObject) {
                ParseConfig config = ParseConfig.getCurrentConfig();

                temperatureEnabled = config.getBoolean("setTemperatureEnabled");
                humidityEnabled = config.getBoolean("setHumidityEnabled");
                enableFeatureMessage = config.getString("enableFeatureMessage");

                tempArrayDryAging = SettingsActivity.this.setupSpinner("temp", "DryAging", settingTemperatureDryAging, tempOptionsDryAging);
                tempArrayCharcuterie = SettingsActivity.this.setupSpinner("temp", "Charcuterie", settingTemperatureCharcuterie, tempOptionsCharcuterie);
                humidArrayDryAging = SettingsActivity.this.setupSpinner("humid", "DryAging", settingHumidityDryAging, humidOptionsDryAging);
                humidArrayCharcuterie = SettingsActivity.this.setupSpinner("humid", "Charcuterie", settingHumidityCharcuterie, humidOptionsCharcuterie);

                String agingType = Steaklocker.getAgingType();
                if (temperatureEnabled) {
                    Float currTemp = Steaklocker.getTemperatureSettingFahrenheit();
                    int pos;
                    if (agingType.equals(Steaklocker.TYPE_CHARCUTERIE)) {
                        settingTemperatureCharcuterie.setSelection(tempArrayCharcuterie.indexOf(currTemp));
                    } else {
                        settingTemperatureDryAging.setSelection(tempArrayDryAging.indexOf(currTemp));
                    }
                }
                if (humidityEnabled) {
                    Float currHumid = Steaklocker.getHumiditySetting();
                    int pos;
                    if (agingType.equals(Steaklocker.TYPE_CHARCUTERIE)) {
                        settingHumidityCharcuterie.setSelection(humidArrayCharcuterie.indexOf(currHumid));
                    } else {
                        settingHumidityDryAging.setSelection(humidArrayDryAging.indexOf(currHumid));
                    }
                }
            }
            @Override public void onError(ParseException e) { }
       });

        addListenerOnButton();
        addListenerOnSpinnerItemSelection();
    }

    public List<Float> setupSpinner(String type, String agingKey, Spinner spinner, Map<Float, String> options) {
        int min = Steaklocker.getConfigInt(String.format("%s%sMin", type, agingKey));
        int max = Steaklocker.getConfigInt(String.format("%s%sMax", type, agingKey));
        float f;
        String[] spinnerArray = new String[max-min+1];
        Float[] floatArray= new Float[max-min+1];
        String s;
        for(int i=0; min<=max; i++) {
            if (type.equalsIgnoreCase("temp")) {
                f = Steaklocker.fahrenheitToCelsius((float) min);
                s = String.format("%d° F  /  %.2f° C", min, f);
            }
            else {
                s = String.format("%d %%", min);
            }

            options.put(Float.valueOf(min), s);
            spinnerArray[i] = s;
            floatArray[i] = Float.valueOf(min);
            min++;
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, spinnerArray);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);

        return Arrays.asList(floatArray);
    }

    public void resetAgingType() {
        setAgingType(Steaklocker.TYPE_DRY_AGING);
    }
    public void setAgingType(String agingType) {
        int pos = agingTypeOptions.indexOf(agingType);
        settingAgingType.setSelection(pos);
        updateSettingVisibility(agingType);
    }

    public void addListenerOnSpinnerItemSelection() {
        int pos;

        settingTempUnits.setSelection(SharedPrefs.getInt(SettingsActivity.this, "useFahrenheit", 0));


        String agingType = Steaklocker.getAgingType();
        pos = agingTypeOptions.indexOf(agingType);
        settingAgingType.setSelection(pos);

        updateSettingVisibility(agingType);

        settingAlerts.setSelection(SharedPrefs.getInt(SettingsActivity.this, "alertsEnabled", 0));
    }

    public void updateSettingVisibility(String agingType) {
        if (temperatureEnabled) {
            if (agingType.equalsIgnoreCase("Charcuterie")) {
                settingTemperatureDryAging.setVisibility(View.GONE);
                settingTemperatureCharcuterie.setVisibility(View.VISIBLE);
            } else {
                settingTemperatureDryAging.setVisibility(View.VISIBLE);
                settingTemperatureCharcuterie.setVisibility(View.GONE);
            }
        }
        else {
            settingTemperatureDryAging.setVisibility(View.GONE);
            settingTemperatureCharcuterie.setVisibility(View.GONE);
            TextView label = (TextView) findViewById(R.id.settingTemperatureLabel);
            label.setVisibility(View.GONE);
        }
        if (humidityEnabled) {
            if (agingType.equalsIgnoreCase("Charcuterie")) {
                settingHumidityDryAging.setVisibility(View.GONE);
                settingHumidityCharcuterie.setVisibility(View.VISIBLE);
            } else {
                settingHumidityDryAging.setVisibility(View.VISIBLE);
                settingHumidityCharcuterie.setVisibility(View.GONE);
            }
        }
        else {
            settingHumidityDryAging.setVisibility(View.GONE);
            settingHumidityCharcuterie.setVisibility(View.GONE);
            TextView label = (TextView) findViewById(R.id.settingHumidityLabel);
            label.setVisibility(View.GONE);
        }
    }

    // get the selected dropdown list value
    public void addListenerOnButton() {
        settingAgingType.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                String item = (String)parentView.getItemAtPosition(position);

                boolean enabled = Steaklocker.userHasCharcuterieEnabled();
                boolean isCharcuterie = item.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE);

                if (!enabled) {
                    if (isCharcuterie) {
                        SettingsActivity.this.showGetCodeEnterCode();
                    }
                }
                else {
                    //Steaklocker.userSetAgingType(item);

                    updateSettingVisibility(item);
                }

            }

            @Override
            public void onNothingSelected(AdapterView<?> parentView) {
                // your code here
            }
        });



        btnSave.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                int pos;
                pos = settingTempUnits.getSelectedItemPosition();
                SharedPrefs.save(SettingsActivity.this, "useFahrenheit", pos);

                pos = settingAlerts.getSelectedItemPosition();
                SharedPrefs.save(SettingsActivity.this, "alertsEnabled", pos);

                String agingType = settingAgingType.getSelectedItem().toString();

                String name = "";
                Float temp = null;
                Float humid = null;

                ParseObject device = Steaklocker.getUserDevice();
                if (device != null) {
                    device.put("agingType", agingType);

                    if (temperatureEnabled) {
                        if (agingType.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE)) {
                            name = settingTemperatureCharcuterie.getSelectedItem().toString();
                            temp = SettingsActivity.this.getKeyByValue(tempOptionsCharcuterie, name);
                        } else {
                            name = settingTemperatureDryAging.getSelectedItem().toString();
                            temp = SettingsActivity.this.getKeyByValue(tempOptionsDryAging, name);
                        }
                        device.put("settingTemperature", Steaklocker.fahrenheitToCelsius(temp));
                    }
                    if (humidityEnabled) {
                        if (agingType.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE)) {
                            name = settingHumidityCharcuterie.getSelectedItem().toString();
                            humid = SettingsActivity.this.getKeyByValue(humidOptionsCharcuterie, name);
                        } else {
                            name = settingHumidityDryAging.getSelectedItem().toString();
                            humid = SettingsActivity.this.getKeyByValue(humidOptionsDryAging, name);
                        }
                        device.put("settingHumidity", humid);
                    }

                    device.saveInBackground();
                }

                Crouton.makeText(SettingsActivity.this, "Settings Saved", Style.INFO).show();
            }

        });
    }


    public void showGetCodeEnterCode() {

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);

        // set title
        alertDialogBuilder.setTitle("Enable Premium Feature");

        // set dialog message
        alertDialogBuilder
                .setMessage(enableFeatureMessage)
                .setCancelable(true)
                .setOnCancelListener(new DialogInterface.OnCancelListener() {
                    @Override
                    public void onCancel(DialogInterface dialog) {
                        SettingsActivity.this.resetAgingType();
                        dialog.cancel();
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        SettingsActivity.this.resetAgingType();
                        dialog.cancel();
                    }
                })
                .setNeutralButton("Get Code", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        SettingsActivity.this.getCodeAction();

                        dialog.cancel();
                        SettingsActivity.this.showEnableCharcuterie();
                    }
                })
                .setPositiveButton("Enter Code", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                        SettingsActivity.this.showEnableCharcuterie();
                    }
                });

        // create alert dialog
        AlertDialog alertDialog = alertDialogBuilder.create();

        // show it
        alertDialog.show();
    }

    public void getCodeAction() {

        final SettingsActivity context = this;
        Steaklocker.loadConfig(new Steaklocker.SteaklockerAsyncInterface() {
            @Override public void onSuccess(ParseObject parseObject) {

                ParseConfig config = ParseConfig.getCurrentConfig();

                String url = config.getString("getFeatureCodeUrl", "http://www.steaklocker.com/");

                if (url.startsWith("mailto")) {
                    final Intent intent = new Intent(Intent.ACTION_SEND);


                    MailTo mt = MailTo.parse(url);
                    intent.putExtra(Intent.EXTRA_EMAIL, new String[] { mt.getTo() });
                    intent.putExtra(Intent.EXTRA_TEXT, mt.getBody());
                    intent.putExtra(Intent.EXTRA_SUBJECT, mt.getSubject());
                    intent.setType("message/rfc822");
                    android.content.pm.PackageManager pm = getPackageManager();
                    boolean handlerExists = intent.resolveActivity(pm) != null;
                    if(handlerExists) {
                        context.startActivity(Intent.createChooser(intent, "Choose an Email client"));
                    }
                }
                else {
                    final Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse(url));
                    context.startActivity(intent);
                }
            }
            @Override public void onError(ParseException e) { }
        });




    }

    public void showEnableCharcuterie() {

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);

        // set title
        alertDialogBuilder.setTitle("Enable Premium Feature");

        // Set up the input
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER_HORIZONTAL);

        final MaterialEditText input = new MaterialEditText(this);
        // Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setHint("Enter code (case sensitive)");
        input.setInputType(InputType.TYPE_CLASS_TEXT );
        layout.setPadding(50, 50, 50, 50);
        layout.addView(input);

        alertDialogBuilder.setView(layout);

        // set dialog message
        alertDialogBuilder
                .setOnCancelListener(new DialogInterface.OnCancelListener() {
                    @Override
                    public void onCancel(DialogInterface dialog) {
                        SettingsActivity.this.resetAgingType();
                        dialog.cancel();
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        SettingsActivity.this.resetAgingType();
                        dialog.cancel();
                    }
                })
                .setPositiveButton("Use Code", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        String code = input.getText().toString();
                        dialog.cancel();
                        SettingsActivity.this.validateCode(code);
                    }
                });

        // create alert dialog
        AlertDialog alertDialog = alertDialogBuilder.create();

        // show it
        alertDialog.show();
    }


    public void validateCode(String code) {
        ParseUser user = ParseUser.getCurrentUser();

        Crouton.makeText(SettingsActivity.this, "Validating Code...", Style.INFO).show();

        HashMap<String, java.lang.Object> params = new HashMap<String, java.lang.Object>();
        params.put("code", code);
        params.put("feature", Steaklocker.TYPE_CHARCUTERIE);
        params.put("userId", user.getObjectId());

        ParseCloud.callFunctionInBackground("useFeatureCode", params, new FunctionCallback<String>() {
            public void done(String result, ParseException e) {
                if (e == null) {
                    Crouton.makeText(SettingsActivity.this, "Premium Feature Enabled", Style.CONFIRM).show();
                    Steaklocker.userEnableCharcuterie();
                    SettingsActivity.this.setAgingType(Steaklocker.TYPE_CHARCUTERIE);
                }
                else {
                    Crouton.makeText(SettingsActivity.this, e.getMessage(), Style.CONFIRM).show();
                    SettingsActivity.this.resetAgingType();
                }
            }
        });
    }
}
