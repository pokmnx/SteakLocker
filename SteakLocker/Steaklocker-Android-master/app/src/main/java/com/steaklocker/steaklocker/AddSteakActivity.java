package com.steaklocker.steaklocker;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.view.inputmethod.InputMethodManager;
import android.util.Log;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Spinner;

import com.rengwuxian.materialedittext.MaterialEditText;
import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import com.parse.*;

import java.lang.*;
import java.util.ArrayList;
import java.util.List;




public class AddSteakActivity extends ActionBarActivity {
    private Spinner meatCuts;
    private List<Object> mObjects;
    private Spinner vendors;
    private List<Vendor> mVendors;
    private Button buttonAdd;
    private MaterialEditText editCustomVendor;


    protected int getFieldInt (MaterialEditText view, int defaultValue) {
        String s = view.getText().toString();
        int v = defaultValue;
        try {
            v = s.isEmpty() ? defaultValue : Integer.parseInt(s);
        }
        catch (Exception e) {
            v = defaultValue;
        }
        return v;
    }
    protected double getFieldDouble (MaterialEditText view, double defaultValue) {
        String s = view.getText().toString();
        double v = defaultValue;
        try {
            v = s.isEmpty() ? defaultValue : Double.parseDouble(s);
        }
        catch (Exception e) {
            v = defaultValue;
        }
        return v;
    }
    private void hideSoftKeyBoard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);

        if(imm.isAcceptingText()) { // verify if the soft keyboard is open
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.form_add_steak);

        setupForm();
    }

    public void setupForm() {
        configMeatCuts();
        configVendors();
        hideSoftKeyBoard();

        updateDays(20);


        buttonAdd = (Button) findViewById(R.id.button_send);
        buttonAdd.setOnClickListener(new OnClickListener()
        {
            public void onClick(View v)
            {
                MaterialEditText view;
                boolean isCustomCut = false;
                boolean isCustomVendor = false;

                ParseObject obj = (ParseObject)meatCuts.getSelectedItem();
                ParseObject vendor = (ParseObject)vendors.getSelectedItem();

                view = (MaterialEditText)findViewById(R.id.nickname);
                String nickname = view.getText().toString();

                view = (MaterialEditText)findViewById(R.id.customVendor);
                String customVendor = view.getText().toString();

                view = (MaterialEditText)findViewById(R.id.days);
                int days = getFieldInt(view, 20);

                view = (MaterialEditText)findViewById(R.id.weight);
                double weight = getFieldDouble(view, 0.0);

                view = (MaterialEditText)findViewById(R.id.cost);
                double cost = getFieldDouble(view, 0.0);


                isCustomCut = obj.getObjectId().equals("custom") ? true : false;
                isCustomVendor = vendor.getObjectId().equals("custom") ? true : false;


                if (obj.getObjectId().equals("none")) {
                    Crouton.makeText(AddSteakActivity.this, "Cut of Meat is Required", Style.ALERT).show();
                    return;
                }
                else if(isCustomCut && nickname.isEmpty()) {
                    Crouton.makeText(AddSteakActivity.this, "Enter a nickname for your custom cut", Style.ALERT).show();
                    return;
                }
                else if (vendor.getObjectId().equals("none")) {
                    Crouton.makeText(AddSteakActivity.this, "Vendor is Required", Style.ALERT).show();
                    return;
                }
                else if (isCustomVendor && customVendor.isEmpty()) {
                    Crouton.makeText(AddSteakActivity.this, "Custom Vendor Name is Required", Style.ALERT).show();
                    return;
                }



                Crouton.makeText(AddSteakActivity.this, "Saving", Style.INFO).show();
                UserObject userObject = new UserObject();
                userObject.setUser(ParseUser.getCurrentUser());
                userObject.setDevice(Steaklocker.getUserDevice());
                if (!isCustomCut) {
                    userObject.setObject(obj);
                }
                if (!isCustomVendor) {
                    userObject.setVendor(vendor);
                }
                else {
                    userObject.setCustomVendor(customVendor);
                }
                userObject.setCustomVendor(customVendor);
                userObject.setDays(days);
                userObject.setNickname(nickname);
                userObject.setWeight(weight);
                userObject.setCost(cost);
                userObject.setActive(true);
                userObject.initFinishedAt();
                userObject.saveInBackground(new SaveCallback() {
                    @Override
                    public void done(ParseException e) {
                        if (e != null) {
                            Crouton.makeText(AddSteakActivity.this, "Error saving", Style.ALERT).show();
                        }
                        else {
                            Crouton.makeText(AddSteakActivity.this, "Saved", Style.CONFIRM).show();
                            startActivity(new Intent(AddSteakActivity.this, ObjectsActivity.class));
                            finish();
                        }
                    }
                });

            }
        });
    }

    public void updateDays(int days) {
        MaterialEditText daysEdit = (MaterialEditText) findViewById(R.id.days);

        daysEdit.setText(Integer.toString(days));
    }

    public Object createFakeObject(String objectId, String title) {
        Object obj = (Object)ParseObject.createWithoutData("Object", objectId);
        obj.setTitle(title);
        return obj;
    }
    public Vendor createFakeVendor(String objectId, String title) {
        Vendor obj = (Vendor)ParseObject.createWithoutData("Vendor", objectId);
        obj.setTitle(title);
        return obj;
    }

    public void configMeatCuts() {
        mObjects = new ArrayList<Object>();

        String agingType = Steaklocker.getAgingType();
        String objectType;
        boolean isCharcuterie = agingType.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE);
        boolean add = false;
        mObjects.add(createFakeObject("none", "- Select Cut of Meat -"));
        mObjects.add(createFakeObject("custom", "Custom Cut"));
        ArrayList<ParseObject> cuts = (ArrayList)Steaklocker.getCuts();
        if (cuts != null) {
            for (int i = 0; i < cuts.size(); i++) {
                add = false;
                Object obj = (Object) cuts.get(i);
                objectType = obj.getAgingType();
                if (isCharcuterie) {
                    add = objectType.equalsIgnoreCase(Steaklocker.TYPE_CHARCUTERIE);
                } else {
                    add = objectType.equalsIgnoreCase(Steaklocker.TYPE_DRY_AGING);
                }

                if (add) {
                    mObjects.add(obj);
                }
            }
        }

        ArrayAdapter spinnerArrayAdapter = new ArrayAdapter(this,
                android.R.layout.simple_spinner_dropdown_item, mObjects);

        meatCuts = (Spinner) findViewById(R.id.objects);
        meatCuts.setAdapter(spinnerArrayAdapter);
        meatCuts.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            public void onItemSelected(AdapterView<?> arg0, View v, int position, long id) {
                Object obj = (Object)meatCuts.getSelectedItem();
                if (!obj.getObjectId().equals("none") && !obj.getObjectId().equals("custom")) {
                    AddSteakActivity.this.updateDays(obj.getDefaultDays());
                }
            }
            public void onNothingSelected(AdapterView<?> arg0) { }
        });
    }
    public void configVendors() {
        mVendors = new ArrayList<Vendor>();
        mVendors.add(createFakeVendor("none", "- Select Vendor -"));
        mVendors.add(createFakeVendor("custom", "Custom Vendor"));
        ArrayList<ParseObject> items = (ArrayList)Steaklocker.getVendors();
        if (items != null) {
            for (int i = 0; i < items.size(); i++) {
                Vendor obj = (Vendor) items.get(i);
                mVendors.add(obj);
            }
        }

        ArrayAdapter spinnerArrayAdapter = new ArrayAdapter(this,
                android.R.layout.simple_spinner_dropdown_item, mVendors);

        editCustomVendor = (MaterialEditText) findViewById(R.id.customVendor);


        vendors = (Spinner) findViewById(R.id.vendors);
        vendors.setAdapter(spinnerArrayAdapter);
        vendors.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            public void onItemSelected(AdapterView<?> arg0, View v, int position, long id) {
                Vendor obj = (Vendor)vendors.getSelectedItem();
                if (obj.getObjectId().equals("custom")) {
                    editCustomVendor.setVisibility(View.VISIBLE);
                }
                else {
                    editCustomVendor.setVisibility(View.GONE);
                }
            }
            public void onNothingSelected(AdapterView<?> arg0) { }
        });
    }


}
