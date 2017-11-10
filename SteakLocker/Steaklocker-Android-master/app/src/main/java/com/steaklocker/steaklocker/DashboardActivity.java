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

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.view.Gravity;
import android.view.ViewGroup.LayoutParams;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.os.Handler;

import com.parse.GetDataCallback;
import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseUser;
import com.parse.ParseFile;
import com.parse.ParseException;


import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.*;

public class DashboardActivity extends SteaklockerActivity implements OnRefreshListener {
    private int measurementState = 0;

    CoordinatorLayout coordinatorLayout;
    SwipeRefreshLayout swipeLayout;
    Snackbar snackbar;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ParseUser user = ParseUser.getCurrentUser();
        if (user == null) {
            Steaklocker.logout(this, true);
            return;
        }

        System.gc();

        setContentView(R.layout.activity_main_dashboard);

        coordinatorLayout = (CoordinatorLayout) findViewById(R.id.coordinatorLayout);

        View layout= findViewById(R.id.layout);

        initData();


        // However, if we're being restored from a previous state,
        // then we don't need to do anything and should return or else
        // we could end up with overlapping fragments.
        if (savedInstanceState != null) {
            return;
        }

        if (swipeLayout == null) {
            //swipeLayout = (SwipeRefreshLayout) layout.findViewById(R.id.swipe_container);
            swipeLayout = (SwipeRefreshLayout) findViewById(R.id.layout);
            swipeLayout.setOnRefreshListener(this);
            swipeLayout.setColorSchemeColors(Steaklocker.getColorTemp());
        }

        Timer t = new Timer();
        t.scheduleAtFixedRate(new TimerTask() {

              @Override
              public void run() {
                  DashboardActivity.this.refreshData(new Steaklocker.SteaklockerAsyncInterface() {
                      @Override
                      public void onSuccess(ParseObject parseObject) {
                      }

                      @Override
                      public void onError(ParseException e) {
                      }
                  });
              }

          }, 0, 1000 * 180);
    }
    @Override
    public void onRefresh() {

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                DashboardActivity.this.refreshData(new Steaklocker.SteaklockerAsyncInterface() {
                    @Override
                    public void onSuccess(ParseObject parseObject) {
                        swipeLayout.setRefreshing(false);
                    }

                    @Override
                    public void onError(ParseException e) {
                        swipeLayout.setRefreshing(false);
                    }
                });
            }
        }, 1000);
    }

    private void initData() {

        Steaklocker.getUserImpeeId(new Steaklocker.SteaklockerAsyncInterface() {
            @Override
            public void onSuccess(ParseObject parseObject) {
                DashboardActivity.this.initConfig();


                // TODO: Refresh data
                DashboardActivity.this.refreshData(new Steaklocker.SteaklockerAsyncInterface() {
                    @Override
                    public void onSuccess(ParseObject parseObject) {
                    }

                    @Override
                    public void onError(ParseException e) {
                    }
                });

            }

            @Override
            public void onError(ParseException e) {
                Crouton.makeText(DashboardActivity.this, e.getMessage(), Style.ALERT).show();
            }
        });


        Steaklocker.loadMeatCuts(new Steaklocker.SteaklockerAsyncListInterface() {
            @Override
            public void onSuccess(List<ParseObject> objects) {}
            @Override
            public void onError(ParseException e) {}
        });

        Steaklocker.loadVendors(new Steaklocker.SteaklockerAsyncListInterface() {
            @Override
            public void onSuccess(List<ParseObject> objects) {}
            @Override
            public void onError(ParseException e) {}
        });

        ParseUser user = ParseUser.getCurrentUser();
        if (user != null) {
            user.fetchInBackground();
        }
    }

    public void initConfig() {
        final MeasurementGraphs graph = (MeasurementGraphs)this.getSupportFragmentManager().findFragmentById(R.id.graphs);

        Steaklocker.loadConfig(new Steaklocker.SteaklockerAsyncInterface() {
            @Override
            public void onSuccess(ParseObject parseObject) {

                String key = Steaklocker.getAgingType();
                key = key.replaceAll(" ", "_");
                key = "Image_" + key;

                ParseConfig config = ParseConfig.getCurrentConfig();
                String agingType = Steaklocker.getAgingType();

                ParseFile imageFile = null;
                try {
                    imageFile = config.getParseFile(key);
                    if (graph != null) {
                        graph.updateAgingType(agingType);
                        graph.updateBackground();
                    }
                } catch (Exception e) {
                    imageFile = null;
                }


            }

            @Override
            public void onError(ParseException e) {
            }
        });
    }



    public void onPause() {
        super.onPause();
    }
    public void onResume() {
        super.onResume();
    }

    public void setCurrentTemp(Number value) {
        if (value == null) {
            return;
        }
        MeasurementFragment frag = (MeasurementFragment)this.getSupportFragmentManager().findFragmentById(R.id.measurements);
        frag.updateTemp(Steaklocker.getTempPercentage(value.doubleValue()));
        if (this.measurementState == 0) {
            MeasurementGraphs graph = (MeasurementGraphs)this.getSupportFragmentManager().findFragmentById(R.id.graphs);
            String str = String.format("%.1f°C", value.floatValue());
            graph.updateValue(str);
        }
    }
    public void setCurrentHumid (Number value) {
        if (value == null) {
            return;
        }
        MeasurementFragment frag = (MeasurementFragment)this.getSupportFragmentManager().findFragmentById(R.id.measurements);
        frag.updateHumid(Steaklocker.getHumidPercentage(value.doubleValue()));
        if (this.measurementState == 1) {
            MeasurementGraphs graph = (MeasurementGraphs)this.getSupportFragmentManager().findFragmentById(R.id.graphs);
            String str = String.format("%.1f%%", value.floatValue());
            graph.updateValue(str);
        }
    }
    public void updateGraphTemperature() {
        MeasurementGraphs graph = (MeasurementGraphs)this.getSupportFragmentManager().findFragmentById(R.id.graphs);
        ParseObject measurement = Steaklocker.getLatestMeasurement();
        graph.updateTitle("Temperature");
        graph.updateBarColor(Steaklocker.getColorTemp());
        if (measurement != null) {
            int useF = SharedPrefs.getInt(this, "useFahrenheit", 0);

            Number value = measurement.getNumber("temperature");
            if (value != null) {
                String unit = "C";
                float temp = value.floatValue();

                if (useF == 1) {
                    temp = Steaklocker.celsiusToFahrenheit(temp);
                    unit = "F";
                }

                String str = String.format("%.1f° %s", temp, unit);
                graph.updateValue(str);
                graph.updateProgress(Steaklocker.getTempPercentage(value.doubleValue()));
            }
        }
    }
    public void updateGraphHumidity() {
        MeasurementGraphs graph = (MeasurementGraphs)this.getSupportFragmentManager().findFragmentById(R.id.graphs);
        ParseObject measurement = Steaklocker.getLatestMeasurement();
        graph.updateTitle("Humidity");
        graph.updateBarColor(Steaklocker.getColorHumid());
        if (measurement != null) {
            Number value = measurement.getNumber("humidity");
            if (value != null) {
                String str = String.format("%.1f%%", value.floatValue());
                graph.updateValue(str);
                graph.updateProgress(Steaklocker.getHumidPercentage(value.doubleValue()));
            }
        }
    }
    public void updateGraph() {
        if (this.measurementState == 0) {
            this.updateGraphTemperature();
        }
        else if (this.measurementState == 1) {
            this.updateGraphHumidity();
        }
    }

    public void setMeasurementState(int pos) {
        this.measurementState = pos;
        this.updateGraph();

        if (pos == 0) {
            if (Steaklocker.showTempWarning()) {
                DashboardActivity.this.snackbar = Snackbar.make(DashboardActivity.this.coordinatorLayout, "Your temperature is too high.", Snackbar.LENGTH_INDEFINITE);
                DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                DashboardActivity.this.snackbar.show();
            }
            else if (Steaklocker.showConnectionWarning()) {
                DashboardActivity.this.snackbar = Snackbar
                        .make(DashboardActivity.this.coordinatorLayout, "Steak Locker Not Connected", Snackbar.LENGTH_INDEFINITE)
                        .setAction("Get Help", new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.ela-lifestyle.com/help/getting-started"));
                                startActivity(browserIntent);
                            }
                        })
                        .setActionTextColor(Color.WHITE);
                DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                DashboardActivity.this.snackbar.show();
            }
            else {
                if (DashboardActivity.this.snackbar != null) {
                    DashboardActivity.this.snackbar.dismiss();
                }
            }
        }
        else {
            if (Steaklocker.showHumidityWarning()) {
                DashboardActivity.this.snackbar = Snackbar.make(DashboardActivity.this.coordinatorLayout, "Your humidity is too low.", Snackbar.LENGTH_INDEFINITE);
                DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                DashboardActivity.this.snackbar.show();
            }
            else if (Steaklocker.showConnectionWarning()) {
                DashboardActivity.this.snackbar = Snackbar
                        .make(DashboardActivity.this.coordinatorLayout, "Steak Locker Not Connected", Snackbar.LENGTH_INDEFINITE)
                        .setAction("Get Help", new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.ela-lifestyle.com/help/getting-started"));
                                startActivity(browserIntent);
                            }
                        })
                        .setActionTextColor(Color.WHITE);
                DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                DashboardActivity.this.snackbar.show();
            }
            else {
                if (DashboardActivity.this.snackbar != null) {
                    DashboardActivity.this.snackbar.dismiss();
                }
            }
        }

    }

    public void refreshData(final Steaklocker.SteaklockerAsyncInterface callback) {
        ParseObject userDevice = Steaklocker.getUserDevice();
        if (userDevice != null) {
            String impeeId = userDevice.getString("impeeId");
            Steaklocker.loadLatestMeasurement(impeeId, new Steaklocker.SteaklockerAsyncInterface() {
                @Override
                public void onSuccess(ParseObject parseObject) {
                    Number temp = parseObject.getNumber("temperature");
                    Number humid = parseObject.getNumber("humidity");

                    DashboardActivity.this.setCurrentTemp(temp);
                    DashboardActivity.this.setCurrentHumid(humid);

                    DashboardActivity.this.updateGraph();

                    if (DashboardActivity.this.snackbar != null && DashboardActivity.this.snackbar.isShown() == true) {
                        callback.onSuccess(parseObject);
                        return;
                    }

                    if (Steaklocker.showConnectionWarning()) {
                        DashboardActivity.this.snackbar = Snackbar
                                .make(DashboardActivity.this.coordinatorLayout, "Steak Locker Not Connected", Snackbar.LENGTH_INDEFINITE)
                                .setAction("Get Help", new View.OnClickListener() {
                                    @Override
                                    public void onClick(View view) {
                                        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.ela-lifestyle.com/help/getting-started"));
                                        startActivity(browserIntent);
                                    }
                                })
                                .setActionTextColor(Color.WHITE);
                        DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
/*
                        Snackbar.SnackbarLayout layout = (Snackbar.SnackbarLayout) DashboardActivity.this.snackbar.getView();
                        View view = snackbar.getView();
                        CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) view.getLayoutParams();
                        params.gravity = Gravity.FILL_HORIZONTAL | Gravity.BOTTOM;
                        view.setLayoutParams(params);
*/
                        DashboardActivity.this.snackbar.show();
                    }
                    else if (Steaklocker.showTempWarning()) {
                        DashboardActivity.this.snackbar = Snackbar.make(DashboardActivity.this.coordinatorLayout, "Your temperature is too high.", Snackbar.LENGTH_INDEFINITE);
                        DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                        DashboardActivity.this.snackbar.show();
                    }
                    else if (Steaklocker.showHumidityWarning()) {
                        DashboardActivity.this.snackbar = Snackbar.make(DashboardActivity.this.coordinatorLayout, "Your humidity is too low.", Snackbar.LENGTH_INDEFINITE);
                        DashboardActivity.this.snackbar.getView().setBackgroundColor(Color.RED);
                        DashboardActivity.this.snackbar.show();
                    }
                    else {
                        if (DashboardActivity.this.snackbar != null) {
                            DashboardActivity.this.snackbar.dismiss();
                        }
                    }

                    callback.onSuccess(parseObject);
                }

                @Override
                public void onError(ParseException e) {
                    callback.onError(e);
                }
            });

        }
    }


}