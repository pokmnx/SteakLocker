package com.steaklocker.steaklocker;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.content.Context;
import android.webkit.WebView;

import com.parse.ParseObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by jashlock on 1/31/15.
 */
public class SteakInfoFragment extends Fragment {

    public SteakInfoFragment() {

    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout resource that'll be returned
        View rootView = inflater.inflate(R.layout.fragment_steak_info, container, false);

        // Get the arguments that was supplied when
        // the fragment was instantiated in the
        // CustomPagerAdapter
        init(rootView);

        return rootView;
    }

    public void init(View rootView) {
        Bundle b = getArguments();
        String userObjectId = b.getString("userObjectId");
        String objectId = b.getString("objectId");

        Context context = this.getActivity();

        UserObject userObject = (userObjectId.isEmpty()) ? null : (UserObject)Steaklocker.getCacheObject(userObjectId);
        Object object = (objectId.isEmpty()) ? null : (Object)Steaklocker.getCacheObject(objectId);

        WebView info = (WebView) rootView.findViewById(R.id.steakInfo);

        info.setBackgroundColor(0x00FFFFFF);
        String html;
        String format = "<html><head><style type=\"text/css\">" +
            "html{background:rgba(255,255,255,0);}body{background:rgba(255,255,255,0);padding:20px;} " +
            "*{font-family:'Helvetica Neue',Helvetica,sans-serif;font-weight:200;} "+
            "</style></head><body>%s</body></html>";


        if (object == null) {
            html = String.format(format, "No information available.");
        }
        else {
            html = String.format(format, object.getString("information"));
        }

        info.loadDataWithBaseURL("", html, "text/html", "UTF-8", "");
    }
}

