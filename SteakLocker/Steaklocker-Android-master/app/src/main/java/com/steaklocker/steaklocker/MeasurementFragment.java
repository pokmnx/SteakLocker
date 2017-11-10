package com.steaklocker.steaklocker;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ListView;
import java.util.*;

/**
 * A fragment representing a list of Items.

 */
public class MeasurementFragment extends ListFragment {
    private List<MeasurementListItem> mItems;
    private MeasurementListAdapter mAdapter;
    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public MeasurementFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mItems = new ArrayList<MeasurementListItem>();
        mItems.add(new MeasurementListItem("Temperature", Steaklocker.tempMin, true));
        mItems.add(new MeasurementListItem("Humidity", Steaklocker.humidMin, false));

        mAdapter = new MeasurementListAdapter(getActivity(), mItems);
        setListAdapter(mAdapter);

        
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // remove the dividers from the ListView of the ListFragment
        getListView().setDivider(null);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        // retrieve theListView item
        //MeasurementListItem item = mItems.get(position);
        MeasurementListItem item;

        int i = 0, count = mItems.size();

        for(; i < count; i++) {
            item = mItems.get(i);
            item.setActive(i == position);
        }

        DashboardActivity dashboard = (DashboardActivity)getActivity();
        dashboard.setMeasurementState(position);

        mAdapter.notifyDataSetChanged();
    }

    public void updateTemp(Double perc){
        mItems.get(0).setValue(perc);
        mAdapter.notifyDataSetChanged();
    }
    public void updateHumid(Double perc){
        mItems.get(1).setValue(perc);
        mAdapter.notifyDataSetChanged();
    }
}
