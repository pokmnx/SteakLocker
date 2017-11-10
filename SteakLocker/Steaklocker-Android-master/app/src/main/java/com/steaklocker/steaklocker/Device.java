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

@ParseClassName("Device")
public class Device extends ParseObject {

    public Device() {
        // A default constructor is required.
    }

    public void setUser(ParseUser user) {
        put("user", user);
    }
    public void setImpeeId(String impeeId) {
        put("impeeId", impeeId);
    }
    public void setPlanId(String planId) {
        put("planId", planId);
    }
    public void setAgentUrl(String agentUrl) {
        put("agentUrl", agentUrl);
    }

    public ParseFile getImage() {
        return getParseFile("image");
    }

}
