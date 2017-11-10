package com.steaklocker.steaklocker;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseImageView;
import com.parse.ParseFile;
import com.parse.ParseException;
import com.parse.GetDataCallback;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.List;

/*
 * Custom ArrayAdapter for Inbox message list items (as ParseObjects)
 */
public class ObjectListAdapter extends ArrayAdapter<ParseObject>{
    protected Context mContext;
    protected List<ParseObject> mMessages;
    protected String userAgingType;
    protected ObjectFragment mFragment;
    protected AQuery androidAQuery;

    public ObjectListAdapter(Context context, List<ParseObject> messages, ObjectFragment fragment) {
        super(context, R.layout.fragment_user_objects, messages);

        mContext = context;
        mMessages = messages;
        mFragment = fragment;
        androidAQuery = new AQuery(mContext);
    }


    public void setUserAgingType(String agingType) {
        this.userAgingType = agingType;
    }


    /*
     * Convert vanilla view to message-specific layout
     */
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;

        if (convertView == null) {
            convertView = LayoutInflater.from(mContext).inflate(R.layout.object_list_item, null);
            holder = new ViewHolder();
            holder.imageView = (ParseImageView) convertView.findViewById(R.id.image);
            holder.titleLabel = (TextView) convertView.findViewById(R.id.textTitle);
            holder.daysLabel = (TextView) convertView.findViewById(R.id.textDays);
            holder.agingType = (TextView) convertView.findViewById(R.id.itemAgingType);
            holder.ageTypeWarningIcon = (TextView)convertView.findViewById(R.id.ageTypeWarningIcon);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        UserObject userObj = (UserObject)mMessages.get(position);
        Object obj = (Object)userObj.getObject();
        String itemAgingType = (obj != null) ? obj.getAgingType() : Steaklocker.TYPE_DRY_AGING;

        ParseFile imageFile = null;
        try {
            imageFile = obj.getParseFile("image");
        }
        catch (Exception e) {
            imageFile = null;
        }


        Drawable d = mContext.getResources().getDrawable(R.drawable.steak_default);
        holder.imageView.setPlaceholder(d);
        if (imageFile != null) {
            boolean memCache = false;
            boolean fileCache = true;
            androidAQuery.id(holder.imageView).image(imageFile.getUrl(), memCache, fileCache, 200, R.drawable.steak_default);
        }

        holder.titleLabel.setText(userObj.getDisplayName());

        int currDay = userObj.getCurrentDay();
        int totalDays = userObj.getDays();
        String daysStatus = String.format("Day %d of %d", currDay, totalDays);

        holder.daysLabel.setText(daysStatus);
        holder.agingType.setText(itemAgingType);
        holder.badAgingType = (itemAgingType.equalsIgnoreCase(this.userAgingType)) ? false : true;

        if (holder.badAgingType) {
            holder.ageTypeWarningIcon.setVisibility(View.VISIBLE);
        }
        else {
            holder.ageTypeWarningIcon.setVisibility(View.GONE);
        }

        return convertView;
    }

    /*
     * Includes data to be displayed in custom layout
     */
    private static class ViewHolder {
        ParseImageView imageView;
        TextView titleLabel;
        TextView daysLabel;
        TextView agingType;
        TextView ageTypeWarningIcon;
        boolean badAgingType;
    }

    public void refill(List<ParseObject> messages) {
        mMessages.clear();
        mMessages.addAll(messages);
        notifyDataSetChanged();
    }

    public void refill() {
        notifyDataSetChanged();
    }

}