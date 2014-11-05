package com.telerik.sendgrid;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;
import com.sendgrid.*;


public class SendGridPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("sendWithWeb")) {
            try {
				      this.send(callbackContext, args.getJSONObject(0));
			      } 
            catch (Exception e) {
				      callbackContext.error(e.getMessage());
			     }
           return true;
        }
        return false;
    }

    private void send(final CallbackContext callbackContext, final JSONObject jsonObject) throws JSONException, IOException {

      int appResId = cordova.getActivity().getResources().getIdentifier("api_user", "string", cordova.getActivity().getPackageName());
      String apiUser = cordova.getActivity().getString(appResId);

      appResId = cordova.getActivity().getResources().getIdentifier("api_key", "string", cordova.getActivity().getPackageName());

      String apiKey = cordova.getActivity().getString(appResId);

      final SendGrid sendgrid = new SendGrid(apiUser, apiKey);
      final SendGrid.Email email = new SendGrid.Email();

      email.addTo(jsonObject.getString("to"));
      email.setFrom(jsonObject.getString("from"));
      email.setSubject(jsonObject.getString("subject"));

      if (jsonObject.has("text"))
        email.setText(jsonObject.getString("text"));

      if (jsonObject.has("html"))
        email.setHtml(jsonObject.getString("html"));

      if (jsonObject.has("imagepath")){
          File file = new File(jsonObject.getString("imagepath"));
          if (file != null){
            email.addAttachment(file.getName(), file);
          }
      }

      cordova.getThreadPool().execute(new Runnable() {
  			@Override
  			public void run() {
  			        try {
  			           SendGrid.Response response = sendgrid.send(email);
  	               callbackContext.success(new JSONObject(response.getMessage()));
  			        }
                catch (Exception e) {
  			        	callbackContext.error(e.getMessage());
  			        }
  			}
		  });
    }
}
