package com.steaklocker.steaklocker;

import com.parse.ParseClassName;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;

/*
 * An extension of ParseObject that makes
 * it more convenient to access information
 * about a given Meal 
 */

@ParseClassName("Object")
public class Object extends ParseObject {

    public Object() {
        // A default constructor is required.
    }

    public String getTitle() {
        return getString("title");
    }
    public void setTitle(String title) {
        put("title", title);
    }

    public ParseFile getImage() {
        return getParseFile("image");
    }

    public String toString()
    {
        return getTitle();
    }

    public int getDefaultDays() {
        return getInt("defaultDays");
    }


    public String getAgingType() {
        String agingType = getString("type");
        if (agingType.equalsIgnoreCase(Steaklocker.TYPE_DRY_AGING_MEAT)) {
            agingType = Steaklocker.TYPE_DRY_AGING;
        }
        return agingType;
    }
}
