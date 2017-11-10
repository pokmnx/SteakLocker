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

@ParseClassName("Vendor")
public class Vendor extends ParseObject {

    public Vendor() {
        // A default constructor is required.
    }

    public String getTitle() {
        return getString("title");
    }
    public void setTitle(String title) {
        put("title", title);
    }

    public String toString()
    {
        return getTitle();
    }
}
