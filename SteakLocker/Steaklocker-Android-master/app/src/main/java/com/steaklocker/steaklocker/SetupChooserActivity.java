package com.steaklocker.steaklocker;

import android.content.Intent;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class SetupChooserActivity extends SetupActivity {

    String seriesName;
    String modelName;

    ImageView modelImage;
    TextView seriesNameView;
    TextView modelNameView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup_chooser);

        Display display = getWindowManager().getDefaultDisplay();
        int width = display.getWidth();

        modelImage = (ImageView) findViewById(R.id.model_image);
        seriesNameView = (TextView) findViewById(R.id.series_name);
        modelNameView = (TextView) findViewById(R.id.model_name);

        changeModel("SL150");
        changeSeries("Home Series");

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(width, (int)(width * 0.83));
        modelImage.setLayoutParams(params);
        modelImage.setImageResource(R.drawable.img_small_unit);

        modelImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.equals(modelImage)) {
                    if (seriesNameView.getText().toString().equals("Home Series")) {
                        changeModel("SL520");
                        changeSeries("Professional Series");
                    }
                    else {
                        changeModel("SL150");
                        changeSeries("Home Series");
                    }
                }
            }
        });

        final RelativeLayout series = (RelativeLayout) findViewById(R.id.series);
        final RelativeLayout model = (RelativeLayout) findViewById(R.id.model);

        series.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.equals(series)) {
                    Intent intent = new Intent(SetupChooserActivity.this, ChooserActivity.class);

                    if (seriesName.equals("Home Series")) {
                        intent.putExtra("selectedIndex", 0);
                    }
                    else {
                        intent.putExtra("selectedIndex", 1);
                    }

                    intent.putExtra("isModelChooser", false);
                    startActivityForResult(intent, 1);
                }
            }
        });

        model.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.equals(model)) {
                    Intent intent = new Intent(SetupChooserActivity.this, ChooserActivity.class);
                    intent.putExtra("isModelChooser", true);
                    if (seriesName.equals("Home Series")) {
                        intent.putExtra("isHome", true);
                        if (modelName.equals("SL103")) {
                            intent.putExtra("selectedIndex", 0);
                        }
                        else {
                            intent.putExtra("selectedIndex", 1);
                        }
                    }
                    else {
                        intent.putExtra("isHome", false);
                        intent.putExtra("selectedIndex", 0);
                    }

                    startActivityForResult(intent, 2);
                }
            }
        });

        final Button next = (Button) findViewById(R.id.next);
        next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.equals(next)) {
                    ELA.getSharedInstance().getELADevice().model = modelName;
                    if (seriesName.equals("Home Series") && modelName.equals("SL103")) {
                        Intent intent = new Intent(SetupChooserActivity.this, SetupSelectWifi.class);
                        startActivity(intent);
                    }
                    else {
                        Intent intent = new Intent(SetupChooserActivity.this, SetupWifiStartActivity.class);
                        startActivity(intent);
                    }
                }
            }
        });
    }

    public void changeModel(String modelName) {
        this.modelName = modelName;
        modelNameView.setText(modelName);
    }

    public void changeSeries(String seriesName) {
        this.seriesName = seriesName;
        seriesNameView.setText(seriesName);
        if (seriesName.equals("Home Series")) {
            modelImage.setImageResource(R.drawable.img_small_unit);
            changeModel("SL150");
        }
        else {
            modelImage.setImageResource(R.drawable.img_pro_unit);
            changeModel("SL520");
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (data == null) return;

        if (requestCode == 1) { // Series
            seriesName = data.getStringExtra("Series");
            changeSeries(seriesName);
        }
        else {
            modelName = data.getStringExtra("Model");
            changeModel(modelName);
        }
    }
}
