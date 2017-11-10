package com.steaklocker.steaklocker;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
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
 * {@link ReportGraph.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ReportGraph#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ReportGraph extends Fragment {

    protected TextView textStatus;
    protected TextView textValue;
    protected Button btnSupport;
    private ProgressWheel wheelProgress;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment ReportGraph.
     */
    // TODO: Rename and change types and number of parameters
    public static ReportGraph newInstance() {
        return new ReportGraph();
    }

    public ReportGraph() {
        // Required empty public constructor
        if (true) {

        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_report_graphs, container, false);

        TextView textView =  (TextView)view.findViewById(R.id.reportLockerName);
        textView.setText("Locker 1");

        this.textValue =  (TextView)view.findViewById(R.id.reportGraphValue);
        this.textValue.setText("");

        this.textStatus = (TextView)view.findViewById(R.id.reportStatus);
        this.btnSupport = (Button)view.findViewById(R.id.btnSupport);

        this.btnSupport.setOnClickListener(new View.OnClickListener()
        {
            public void onClick(View v)
            {
                String url = Steaklocker.getConfigString("troubleshootUrl");
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                startActivity(browserIntent);
            }
        });


        this.wheelProgress = (ProgressWheel)view.findViewById(R.id.reportProgressWheel);
        this.wheelProgress.setProgress(0);
        this.wheelProgress.setBarColor(Steaklocker.getColorTemp());

        return view;
    }

    public void updateBarColor(int color)
    {
        this.wheelProgress.setBarColor(color);
    }

    public void updateProgress(Double perc) {
        Double value = (perc / 100.0) * 360.0;
        this.wheelProgress.setProgress(value.intValue());
    }


    public TextView getStatusTextView()
    {
        return this.textStatus;
    }

    public TextView getValueTextView()
    {
        return this.textValue;
    }

    public TextView getButton()
    {
        return this.btnSupport;
    }

    public ProgressWheel getWheelProgress()
    {
        return this.wheelProgress;
    }
}
