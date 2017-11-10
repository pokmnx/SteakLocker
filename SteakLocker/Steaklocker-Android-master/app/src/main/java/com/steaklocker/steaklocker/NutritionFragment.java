package com.steaklocker.steaklocker;

import android.os.Build;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.content.Context;

import com.parse.ParseObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by jashlock on 1/31/15.
 */
public class NutritionFragment extends Fragment {

    public NutritionFragment() {

    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout resource that'll be returned
        View rootView = inflater.inflate(R.layout.fragment_steak_nutrition, container, false);

        // Get the arguments that was supplied when
        // the fragment was instantiated in the
        // CustomPagerAdapter
        init(rootView);

        return rootView;
    }

    public void init(View rootView) {
        Bundle b = getArguments();
        String userObjectId = b.getString("userObjectId");
        String objectId = b.getString("objectId");

        Context context = this.getActivity();

        UserObject userObject = (userObjectId.isEmpty()) ? null : (UserObject)Steaklocker.getCacheObject(userObjectId);
        Object object = (objectId.isEmpty()) ? null : (Object)Steaklocker.getCacheObject(objectId);

        TableLayout table = (TableLayout) rootView.findViewById(R.id.nutritionTable);

        if (object != null) {
            Map<String, String> items = new HashMap<String, String>();
            items.put("servingSize", "Serving Size");
            items.put("calories", "Calories");
            items.put("caloriesFromFat", "Calories from Fat");
            items.put("totalFat", "Total Fat");
            items.put("saturatedFat", "Saturated Fat");
            items.put("transFat", "Trans Fat");
            items.put("cholesterol", "Cholesterol");
            items.put("sodium", "Sodium");
            items.put("carbohydrates", "Carbohydrates");
            items.put("dietaryFiber", "Dietary Fiber");
            items.put("sugars", "Sugars");
            items.put("protein", "Protein");
            items.put("vitaminA", "Vitamin A");
            items.put("vitaminC", "Vitamin C");
            items.put("calcium", "Calcium");
            items.put("iron", "Iron");

            String[] itemOrder = {
                    "servingSize",
                    "calories",
                    "caloriesFromFat",
                    "totalFat",
                    "saturatedFat",
                    "transFat",
                    "cholesterol",
                    "sodium",
                    "carbohydrates",
                    "dietaryFiber",
                    "sugars",
                    "protein",
                    "vitaminA",
                    "vitaminC",
                    "calcium",
                    "iron"
            };

            int count = 0;
            int color = 0xFFFFFFFF;
            for (String key : itemOrder) {
                String label = items.get(key);
                String value = object.getString(key);

                if (value == null || value.isEmpty()) {
                    continue;
                }

                TableRow row = new TableRow(context);

                color = ((count++ % 2) == 0) ? 0xFFFFFFFF : 0xFFF5F5F5;
                row.setBackgroundColor(color);
                row.setPadding(0, 20, 0, 20);


                TextView tdLabel = new TextView(context);
                tdLabel.setText(label);
                tdLabel.setGravity(Gravity.LEFT);
                tdLabel.setPadding(20, 3, 0, 3);
                tdLabel.setLayoutParams(new TableRow.LayoutParams(0, android.view.ViewGroup.LayoutParams.WRAP_CONTENT, 1));
                row.addView(tdLabel);

                TextView tdValue = new TextView(context);
                tdValue.setText(value);
                tdValue.setGravity(Gravity.RIGHT);
                tdLabel.setPadding(0, 3, 20, 3);

                int currentapiVersion = android.os.Build.VERSION.SDK_INT;
                if (currentapiVersion >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    tdValue.setTextAlignment(View.TEXT_ALIGNMENT_VIEW_END);
                } else {
                    // do something for phones running an SDK before froyo
                }

                tdValue.setLayoutParams(new TableRow.LayoutParams(0, android.view.ViewGroup.LayoutParams.WRAP_CONTENT, 1));
                row.addView(tdValue);
                table.addView(row);
            }
        }
        else {
            TableRow row = new TableRow(context);

            row.setPadding(0, 20, 0, 20);

            TextView tdLabel = new TextView(context);
            tdLabel.setText("Not available for custom items.");
            tdLabel.setGravity(Gravity.CENTER);
            tdLabel.setPadding(20, 10, 0, 10);
            tdLabel.setLayoutParams(new TableRow.LayoutParams(0, android.view.ViewGroup.LayoutParams.WRAP_CONTENT, 1));
            row.addView(tdLabel);
            table.addView(row);
        }

    }
}

