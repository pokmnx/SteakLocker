package com.steaklocker.steaklocker;

/**
 * Created by jashlock on 1/19/15.
 */
public class MeasurementListItem {
    private String title;
    private Double value;
    private boolean active;

    public MeasurementListItem (String title, Double value) {
        setTitle(title);
        setValue(value);
        setActive(false);
    }
    public MeasurementListItem (String title, Double value, boolean active) {
        setTitle(title);
        setValue(value);
        setActive(active);
    }

    public String getTitle() {
        return this.title;
    }
    public void setTitle(String title) {
        this.title = title;
    }

    public Double getValue() { return this.value; }
    public void setValue(Double value) { this.value = value; }

    public boolean getActive() { return this.active; }
    public void setActive(boolean active) { this.active = active; }
}
