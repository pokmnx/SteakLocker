package com.steaklocker.steaklocker;

import android.app.Activity;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link MeasurementGraphs.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link MeasurementGraphs#newInstance} factory method to
 * create an instance of this fragment.
 */
public class MeasurementGraphs extends Fragment {

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment MeasurementGraphs.
     */
    // TODO: Rename and change types and number of parameters
    public static MeasurementGraphs newInstance() {
        return new MeasurementGraphs();
    }

    public MeasurementGraphs() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_measurement_graphs, container, false);

        TextView textView =  (TextView)view.findViewById(R.id.graphTitle);
        textView.setText("Temperature");

        textView =  (TextView)view.findViewById(R.id.graphValue);
        textView.setText("");

        ProgressWheel wheel = (ProgressWheel)view.findViewById(R.id.progressWheel);
        wheel.setProgress(0);
        wheel.setBarColor(Steaklocker.getColorHumid());


        String agingType = Steaklocker.getAgingType();
        textView =  (TextView)view.findViewById(R.id.dashboardAgingType);
        textView.setText(agingType.toUpperCase());



        return view;
    }

    public void updateBarColor(int color) {
        ProgressWheel wheel = (ProgressWheel)getView().findViewById(R.id.progressWheel);
        wheel.setBarColor(color);
    }

    public void updateProgress(Double perc) {
        ProgressWheel wheel = (ProgressWheel)getView().findViewById(R.id.progressWheel);
        Double value = (perc / 100.0) * 360.0;
        wheel.setProgress(value.intValue());
    }

    public void updateTitle(String title) {
        TextView textView =  (TextView)getView().findViewById(R.id.graphTitle);
        textView.setText(title);
    }
    public void updateValue(String value) {
        TextView textView =  (TextView)getView().findViewById(R.id.graphValue);
        textView.setText(value);
    }
    public void updateAgingType(String agingType) {
        TextView textView =  (TextView)getView().findViewById(R.id.dashboardAgingType);
        textView.setText(agingType.toUpperCase());
    }

    public void updateBackground() {
        ImageView imageView = (ImageView)getView().findViewById(R.id.dashboardBg);
        imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        int res = Steaklocker.isProUser() ? R.drawable.bg_dashboard_pro : R.drawable.bg_dashboard;
        Drawable d = getResources().getDrawable(res, null);
        imageView.setImageDrawable(d);
    }
}
