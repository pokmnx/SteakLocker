/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.steaklocker.steaklocker;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.view.View;

import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;


import java.lang.*;
import java.util.HashMap;

import com.parse.FunctionCallback;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseObject;

public class ReportsActivity extends SteaklockerActivity  implements ActionBar.TabListener {

    private ViewPager viewPager;
    private ReportsPagerAdapter mAdapter;
    protected boolean hasData = false;
    protected boolean doneSync = false;
    protected float tempAvg;
    protected float humidAvg;

    float tempMin;
    float tempMax;
    float humidMin;
    float humidMax;
    float warnTempMin;
    float warnTempMax;
    float warnHumidMin;
    float warnHumidMax;

    ParseObject device;
    String impeeId;
    String agingType;
    Handler mHandler;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        System.gc();

        setContentView(R.layout.activity_reports);

        viewPager = (ViewPager) findViewById(R.id.pager_reports);
        mAdapter = new ReportsPagerAdapter(getSupportFragmentManager(), this);
        viewPager.setAdapter(mAdapter);


        this.device = Steaklocker.getUserDevice();
        this.impeeId = device.getString("impeeId");
        this.agingType = Steaklocker.getAgingType();
        boolean isCharcuterie = agingType.equals(Steaklocker.TYPE_CHARCUTERIE);

        this.tempMin = 0.0f;
        this.tempMax = 35.0f;
        this.humidMin = 0;
        this.humidMax = 100.0f;

        if (isCharcuterie) {
            this.warnTempMin  = Steaklocker.fahrenheitToCelsius((float)Steaklocker.getConfigFloat("tempCharcuterieMin"));
            this.warnTempMax  = Steaklocker.fahrenheitToCelsius((float)Steaklocker.getConfigFloat("tempCharcuterieMax"));
            this.warnHumidMin  = (float)Steaklocker.getConfigFloat("humidCharcuterieMin");
            this.warnHumidMax  = (float)Steaklocker.getConfigFloat("humidCharcuterieMax");
        }
        else {
            this.warnTempMin  = Steaklocker.fahrenheitToCelsius((float)Steaklocker.getConfigFloat("tempDryAgingMin"));
            this.warnTempMax  = Steaklocker.fahrenheitToCelsius((float)Steaklocker.getConfigFloat("tempDryAgingMax"));
            this.warnHumidMin  = (float)Steaklocker.getConfigFloat("humidDryAgingMin");
            this.warnHumidMax  = (float)Steaklocker.getConfigFloat("humidDryAgingMax");
        }

        ImageView imageView =  (ImageView) findViewById(R.id.reportBg);
        imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        int res = Steaklocker.isProUser() ? R.drawable.bg_dashboard_pro : R.drawable.bg_dashboard;
        Drawable d = getResources().getDrawable(res, null);
        imageView.setImageDrawable(d);

        refreshData();

        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }


    }

    public void refreshData()
    {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                ParseObject device = Steaklocker.getUserDevice();
                String impeeId = device.getString("impeeId");

                HashMap<String, java.lang.Object> params = new HashMap<String, java.lang.Object>();
                params.put("impeeId", impeeId);
                ParseCloud.callFunctionInBackground("getAveragesByImpeeId", params, new FunctionCallback<HashMap>() {
                    public void done(HashMap result, ParseException e) {
                        ReportsActivity.this.doneSync = true;
                        if (e == null) {
                            ReportsActivity.this.hasData = true;
                            String msg;
                            try {
                                Double value = (Double)result.get("temperatureAvg");
                                ReportsActivity.this.tempAvg = value.floatValue();
                                value = (Double)result.get("humidityAvg");
                                ReportsActivity.this.humidAvg = value.floatValue();
                            }
                            catch (Exception ex) {
                                 msg = ex.getMessage();
                            }
                            ReportsActivity.this.updateTemp();
                            ReportsActivity.this.updateHumid();
                        }
                    }
                });
            }
        };

        runOnUiThread(runnable);

    }

    protected void updateTemp()
    {
        TextView textValue = (TextView) this.mAdapter.reportTemp.getValueTextView();
        TextView textStatus = (TextView) this.mAdapter.reportTemp.getStatusTextView();
        Button btnSupport = (Button) this.mAdapter.reportTemp.getButton();

        this.mAdapter.reportTemp.updateBarColor(Steaklocker.getColorTemp());

        if (this.hasData) {
            float value = this.tempAvg;

            Double temp = Steaklocker.getTempPercentage((double)value);
            this.mAdapter.reportTemp.updateProgress(temp);
            textValue.setText(String.format("%.1f°C", value));


            if (value < this.warnTempMin) {
                textStatus.setText("Your average temperature is low and we recommend you visit our support page.");
                textStatus.setVisibility(View.VISIBLE);
                btnSupport.setVisibility(View.VISIBLE);

            }
            else if (value > this.warnTempMax) {
                textStatus.setText("Your average temperature is high and we recommend you visit our support page.");
                textStatus.setVisibility(View.VISIBLE);
                btnSupport.setVisibility(View.VISIBLE);
            }
            else {
                if (!this.doneSync) {
                    textStatus.setText("Loading...");
                }
                else {
                    textStatus.setText("Everything looks good!");
                }
                btnSupport.setVisibility(View.INVISIBLE);
            }
        }
        else {
            if (!this.doneSync) {
                textStatus.setText("Loading...");
            }
            else {
                textStatus.setText("Not Enough Data");
            }
            btnSupport.setVisibility(View.INVISIBLE);
        }
    }

    protected void updateHumid()
    {
        TextView textValue = (TextView) this.mAdapter.reportHumid.getValueTextView();
        TextView textStatus = (TextView) this.mAdapter.reportHumid.getStatusTextView();
        Button btnSupport = (Button) this.mAdapter.reportHumid.getButton();

        this.mAdapter.reportHumid.updateBarColor(Steaklocker.getColorHumid());

        if (this.hasData) {
            float value = this.humidAvg;
            Double temp = Steaklocker.getHumidPercentage((double)value);
            this.mAdapter.reportHumid.updateProgress(temp);
            textValue.setText(String.format("%.1f%%", value));


            if (value < this.warnHumidMin) {
                textStatus.setText("Your average humidity is low and we recommend you visit our support page.");
                textStatus.setVisibility(View.VISIBLE);
                btnSupport.setVisibility(View.VISIBLE);

            }
            else if (value > this.warnHumidMax) {
                textStatus.setText("Your average humidity is high and we recommend you visit our support page.");
                textStatus.setVisibility(View.VISIBLE);
                btnSupport.setVisibility(View.VISIBLE);
            }
            else {
                if (!this.doneSync) {
                    textStatus.setText("Loading...");
                }
                else {
                    textStatus.setText("Everything looks good!");
                }
                btnSupport.setVisibility(View.INVISIBLE);
            }
        }
        else {
            if (!this.doneSync) {
                textStatus.setText("Loading...");
            }
            else {
                textStatus.setText("Not Enough Data");
            }
            btnSupport.setVisibility(View.INVISIBLE);
        }
    }


    @Override
    public void onTabReselected(ActionBar.Tab tab, FragmentTransaction ft) {
    }

    @Override
    public void onTabSelected(ActionBar.Tab tab, FragmentTransaction ft) {
        // on tab selected
        // show respected fragment view
        viewPager.setCurrentItem(tab.getPosition());
    }

    @Override
    public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction ft) {

    }

}