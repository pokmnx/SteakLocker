package com.steaklocker.steaklocker;

import android.content.Context;
import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.app.Activity;
import android.graphics.drawable.Drawable;
import java.util.List;
import java.lang.Double;

/**
 * Created by jashlock on 1/19/15.
 */
public class MeasurementListAdapter  extends ArrayAdapter {
    private Context context;

    public MeasurementListAdapter(Context context, List items) {
        super(context, android.R.layout.simple_list_item_1, items);
        this.context = context;
    }

    /** * Holder for the list items. */
    private class ViewHolder {
        TextView titleText;
        ProgressBar progressBar;
        boolean active;
    }

    /**
     * @param position
     * @param convertView
     * @param parent
     * @return
     */
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        MeasurementListItem item = (MeasurementListItem)getItem(position);
        View viewToUse = null;
         // This block exists to inflate the settings list item conditionally based on whether
         // we want to support a grid or list view.
        LayoutInflater mInflater = (LayoutInflater) context .getSystemService(Activity.LAYOUT_INFLATER_SERVICE);

        if (convertView == null) {
            viewToUse = mInflater.inflate(R.layout.measurement_list_item, null);

            holder = new ViewHolder();
            holder.titleText = (TextView)viewToUse.findViewById(R.id.titleTextView);
            holder.progressBar = (ProgressBar)viewToUse.findViewById(R.id.progressBar);
            holder.progressBar.setIndeterminate(false);
            holder.progressBar.setMax(100);
            holder.active = false;
            viewToUse.setTag(holder);
        }
        else {
            viewToUse = convertView;
            holder = (ViewHolder) viewToUse.getTag();
        }

        boolean active = item.getActive();
        String title = item.getTitle();
        Drawable d;

        int progressInactive = R.drawable.progress_measurement_inactive;
        int progressColor = progressInactive;
        int textColorInactive = 0xff666666;
        int textColor = textColorInactive;

        Double minValue = 0.0;
        Double maxValue = 100.0;

        if (title == "Humidity") {
            progressColor = R.drawable.progress_measurement_humid;
            textColor = Steaklocker.getColorHumid();
            minValue = Steaklocker.humidMin;
            maxValue = Steaklocker.humidMax;
        }
        else {
            progressColor = R.drawable.progress_measurement_temp;
            textColor = Steaklocker.getColorTemp();
            minValue = Steaklocker.tempMin;
            maxValue = Steaklocker.tempMax;
        }

        if (active) {
            title += " •";
            viewToUse.setBackgroundColor(0xFFE6E6E6);
            holder.titleText.setTextColor(textColor);
            holder.progressBar.setProgressDrawable(viewToUse.getResources().getDrawable(progressColor));
        }
        else {
            viewToUse.setBackgroundColor(0xFFEFEFEF);
            holder.titleText.setTextColor(textColorInactive);
            holder.progressBar.setProgressDrawable(viewToUse.getResources().getDrawable(progressInactive));
        }

        holder.titleText.setText(title);
        holder.progressBar.setMax(100);
        holder.progressBar.setProgress(item.getValue().intValue());
        holder.active = active;

        return viewToUse;
    }

}
