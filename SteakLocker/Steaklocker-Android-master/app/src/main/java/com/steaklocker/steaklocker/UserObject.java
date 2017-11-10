package com.steaklocker.steaklocker;
import java.util.Date;
import com.parse.ParseClassName;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;
import java.util.Calendar;
/*
 * An extension of ParseObject that makes
 * it more convenient to access information
 * about a given Meal 
 */

@ParseClassName("UserObject")
public class UserObject extends ParseObject {

    public UserObject() {
        // A default constructor is required.
    }

    public void setUser(ParseUser user) { put("user", user); }
    public void setDevice(ParseObject device) { put("device", device); }
    public void setObject(ParseObject object) { put("object", object); }
    public void setVendor(ParseObject vendor) { put("vendor", vendor); }
    public void setCustomVendor(String vendor) { put("customVendor", vendor); }
    public void setDays(int days) { put("days", days); }
    public void setNickname(String nickname) { put("nickname", nickname); }
    public void setWeight(double weight) { put("weight", weight); }
    public void setCost(double cost) { put("cost", cost); }
    public void setActive(boolean active) {
        put("active", Boolean.valueOf(active));
    }
    public void initFinishedAt() {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DAY_OF_YEAR, this.getDays());
        put("finishedAt", cal.getTime());
    }

    public String getTitle() {
        return getString("title");
    }

    public ParseObject getObject() {
        return getParseObject("object");
    }

    public String getAgingType() {
        Object object = (Object)this.getObject();
        return object.getAgingType();
    }

    public int getDays() {
        return getInt("days");
    }

    public String getNickname() {
        return getString("nickname");
    }


    public String getDisplayName() {
        String value = this.getNickname();
        if (value == null || value.isEmpty()) {
            Object object = (Object)this.getObject();
            if (object != null) {
                value = object.getTitle();
            }
        }
        return value;
    }


    public int getDaysLeft()
    {
        int total = this.getDays();
        int curr = this.getCurrentDay();

        return Math.max(total - curr, 0);
    }
    public int getCurrentDay()
    {
        Date now = new Date();
        Date createdAt = this.getCreatedAt();

        long milli = now.getTime() - createdAt.getTime();

        int days = (int)Math.floor((milli / 1000) / (60*60*24));

        if (days < 1) {
            days = 1;
        }

        return days;
    }


    public String getDaysLeftString() {
        String value;

        int left = this.getDaysLeft();
        if (left == 1) {
            value = "1 day left";
        }
        else {
            value = String.format("%d days left", left);
        }
        return value;
    }
}
