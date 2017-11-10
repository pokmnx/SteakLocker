package com.steaklocker.steaklocker;

import android.content.Intent;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;

/**
 * Created by jashlock on 1/31/15.
 */
public class DaysLeftFragment extends Fragment {
    UserObject mUserObject;

    public DaysLeftFragment() {

    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout resource that'll be returned
        View rootView = inflater.inflate(R.layout.fragment_steak_daysleft, container, false);

        // Get the arguments that was supplied when
        // the fragment was instantiated in the
        // CustomPagerAdapter
        Bundle b = getArguments();
        String userObjectId = b.getString("userObjectId");
        String objectId = b.getString("objectId");

        mUserObject = (UserObject)Steaklocker.getCacheObject(userObjectId);

        int days = (mUserObject!=null) ? mUserObject.getDays() : 0;
        int daysLeft = (mUserObject!=null) ? mUserObject.getDaysLeft() : 0;
        int daysPast = days - daysLeft;


        ProgressWheel wheel = (ProgressWheel)rootView.findViewById(R.id.progressWheel);
        Double value = ((double)daysPast / (double)days) * 360.0;
        wheel.setProgress(value.intValue());

        String daysLeftString = (mUserObject != null) ? mUserObject.getDaysLeftString() : "";
        ((TextView) rootView.findViewById(R.id.graphValue)).setText(daysLeftString);

        android.widget.Button btnRemove = (Button)rootView.findViewById(R.id.buttonRemove);

        btnRemove.setVisibility(View.VISIBLE);
        btnRemove.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Crouton.makeText(getActivity(), "Deleting...", Style.INFO).show();
                if (DaysLeftFragment.this.mUserObject != null) {
                    DaysLeftFragment.this.mUserObject.deleteInBackground();
                }
                startActivity(new Intent(getActivity(), DashboardActivity.class));
            }

        });
        rootView.findViewById(R.id.buttonRemove).setVisibility(View.VISIBLE);



        return rootView;
    }
}

