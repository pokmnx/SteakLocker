package com.steaklocker.steaklocker;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;

import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.parse.*;

public class TipTrickFragment extends Fragment {

    public ParseObject tipTrick;
    protected AQuery androidAQuery=null;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment MeasurementGraphs.
     */
    // TODO: Rename and change types and number of parameters
    public static TipTrickFragment newInstance(ParseObject object) {
        TipTrickFragment fragment = new TipTrickFragment();
        fragment.tipTrick = object;
        fragment.androidAQuery = new AQuery(fragment.getActivity());
        return fragment;
    }

    public TipTrickFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_tip_trick, container, false);

        ParseFile imageFile = null;
        String title = "";
        ParseImageView imageView = (ParseImageView)view.findViewById(R.id.tipTrickImage);
        Drawable d = getResources().getDrawable(R.drawable.steak_default);
        imageView.setPlaceholder(d);

        if (tipTrick != null) {
            imageFile = tipTrick.getParseFile("image");
            title = tipTrick.getString("title");
        }
        if (imageFile != null) {
            imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);

            boolean memCache = false;
            boolean fileCache = true;
            androidAQuery.id(imageView).image(imageFile.getUrl(), memCache, fileCache, 200, R.drawable.steak_default);
        }
        else {
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        }

        TextView textTitle = (TextView)view.findViewById(R.id.tipTrickTitle);
        textTitle.setText(title);


        imageView.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                TipTrickFragment.this.openTipTrick();
            }
        });

        return view;
    }


    public void openTipTrick() {
        String url = this.tipTrick.getString("url");
        if (url != null && !url.isEmpty()) {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        }
    }


}
