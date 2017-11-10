package com.steaklocker.steaklocker;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.preference.DialogPreference;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.ListFragment;
import android.text.InputType;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.view.ViewGroup.LayoutParams;
import android.content.Context;
import android.widget.AdapterView;
import android.widget.AdapterView.*;
import com.parse.FindCallback;
import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.rengwuxian.materialedittext.MaterialEditText;

import android.widget.Button;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;



/**
 * A fragment representing a list of Items.

 */
public class ObjectFragment extends ListFragment {

    protected List<ParseObject> mMessages;
    private android.view.ViewGroup.LayoutParams params;
    private ExpandedListView mListView;
    private int old_count = 0;


    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public ObjectFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        setHasOptionsMenu(true);
        View rootView = inflater.inflate(R.layout.fragment_user_objects, container, false);

        Button button = (Button)rootView.findViewById(R.id.buttonNoObjectsAdd);
        if (button != null) {
            button.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                startActivity(new Intent(getActivity(), AddSteakActivity.class));


                }
            });
        }
        return rootView;
    }


    public static ObjectFragment newInstance() {
        ObjectFragment fragment = new ObjectFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onResume() {
        super.onResume();
        reloadItems();
    }
    public void reloadItems() {
        getActivity().setProgressBarIndeterminateVisibility(true);

        final FragmentActivity activity = getActivity();

        // Retrieve messages where current user is a recipient
        ParseQuery<ParseObject> query = ParseQuery.getQuery("UserObject");
        query.include("object");
        query.whereEqualTo("active", true);
        query.whereEqualTo("user", ParseUser.getCurrentUser());
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> messages, ParseException e) {
                if (activity != null) {
                    activity.setProgressBarIndeterminateVisibility(false);
                }

                if (e == null) {
                    mMessages = messages;

                    if (getListView().getAdapter() == null) {
                        ObjectListAdapter adapter = new ObjectListAdapter(
                                getListView().getContext(),
                                mMessages,
                                ObjectFragment.this
                        );
                        adapter.setUserAgingType(Steaklocker.getAgingType());
                        setListAdapter(adapter);
                        //swipeListInit();
                    } else {
                        // Avoid reinstantiating adapter to maintain scroll position
                        ObjectListAdapter adapter = (ObjectListAdapter) getListView().getAdapter();
                        adapter.setUserAgingType(Steaklocker.getAgingType());
                        adapter.refill(mMessages);
                    }
                }
            }
        });
    }



    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        String userAgingType = Steaklocker.getAgingType();

        UserObject userObject = (UserObject)mMessages.get(position);
        Object object = (userObject != null) ? (Object)userObject.getObject() : null;


        if (userObject != null) {
            Steaklocker.setCacheObject(userObject);
        }
        if (object != null) {
            Steaklocker.setCacheObject(object);
        }


        if (object == null || object.getAgingType().equalsIgnoreCase(userAgingType)) {
            Intent intent = new Intent(ObjectFragment.this.getActivity(), SteakActivity.class);
            Bundle b = new Bundle();

            String userObjectId = (userObject == null) ? "" : userObject.getObjectId();
            String objectId = (object == null) ? "" : object.getObjectId();
            b.putString("userObjectId", userObjectId);
            b.putString("objectId", objectId);
            intent.putExtras(b); //Put your id to your next Intent
            startActivity(intent);

        }
        else {
            this.showItemWarning(userObject, position);
        }
    }


    public void showItemWarning(final UserObject userObject, int position) {

        ParseConfig config = ParseConfig.getCurrentConfig();

        Object object = (Object) userObject.getObject();
        String itemAgingType = object.getAgingType();
        String userAgingType = Steaklocker.getAgingType();

        String labelCancel = "Cancel";
        String labelDeleteThis = "Delete Only This Item";
        String labelDeleteAll = "Delete All [item-type] Items";
        labelDeleteAll = labelDeleteAll.replaceAll("\\[item-type\\]", itemAgingType);

        String message = config.getString("invalidAgingTypeWarning");

        message = message.replaceAll("\\[type\\]", userAgingType);
        message = message.replaceAll("\\[item-type\\]", itemAgingType);

        Context ctx = this.getActivity();
        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(ctx);

        // set title
        alertDialogBuilder.setTitle("Invalid Aging Type");


        // Set up the input
        LinearLayout layout = new LinearLayout(this.getActivity());
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER_HORIZONTAL);

        TextView messageView = new TextView(this.getActivity());
        //messageView.setPadding(50,50,50,50);
        messageView.setText(message);
        layout.setPadding(50, 50, 50, 50);
        layout.addView(messageView);

        alertDialogBuilder.setView(layout);

        final int pos = position;

        String[] opts = {labelDeleteAll, labelDeleteThis, labelCancel};
        // set dialog message
        alertDialogBuilder
                //.setMessage(message)
                .setCancelable(true)

                .setItems(opts, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // The 'which' argument contains the index position
                        // of the selected item
                        switch (which) {
                            case 0:
                                ObjectFragment.this.deleteByAgingType(userObject);
                                break;
                            case 1:
                                ObjectFragment.this.deleteSingleObject(userObject, pos);
                                break;
                            case 2:
                                break;
                        }

                    }
                });

        // create alert dialog
        AlertDialog alertDialog = alertDialogBuilder.create();

        // show it
        alertDialog.show();
    }


    void deleteSingleObject(UserObject userObject, int position) {
        userObject.deleteInBackground();
        ObjectFragment.this.mMessages.remove(position);
        ObjectListAdapter adapter = (ObjectListAdapter)getListAdapter();
        adapter.refill();
    }

    void deleteByAgingType(UserObject userObject) {
        UserObject item;
        Object object = (Object) userObject.getObject();
        String itemAgingType = object.getAgingType();

        int i = 0, count = mMessages.size();

        for(; i < count; i++) {
            item = (UserObject)mMessages.get(i);
            if (item.getAgingType().equalsIgnoreCase(itemAgingType)) {
                item.deleteInBackground();
            }


        }

        reloadItems();
    }

}
