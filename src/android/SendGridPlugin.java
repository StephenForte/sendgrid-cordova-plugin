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

import org.apache.http.HttpResponse;
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.util.EntityUtils;
import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

public class SendGridPlugin extends CordovaPlugin {

  private String url =  "https://api.sendgrid.com";
  private String endpoint = "/api/mail.send.json";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("sendWithWeb")) {
            try {
				this.send(callbackContext, args.getJSONObject(0));
			} catch (UnsupportedEncodingException e) {
				callbackContext.error(e.getMessage());
			}
            return true;
        }
        return false;
    }

    private void send(final CallbackContext callbackContext, final JSONObject email) throws JSONException, UnsupportedEncodingException {

        int appResId = cordova.getActivity().getResources().getIdentifier("api_user", "string", cordova.getActivity().getPackageName());
        String apiUser = cordova.getActivity().getString(appResId);

        appResId = cordova.getActivity().getResources().getIdentifier("api_key", "string", cordova.getActivity().getPackageName());

        String apiKey = cordova.getActivity().getString(appResId);

        email.put("api_user", apiUser);
        email.put("api_key", apiKey);

        final HttpClient httpclient = new DefaultHttpClient();
	    final HttpPost httppost = new HttpPost(this.url + this.endpoint);

	    httppost.setEntity(this.buildBody(email));

        cordova.getThreadPool().execute(new Runnable() {
			@Override
			public void run() {
			        try {
			          HttpResponse res = httpclient.execute(httppost);
			          HttpEntity httpEntity = res.getEntity();
			          JSONObject response = new JSONObject(EntityUtils.toString(httpEntity));

			          if (response.has("message")
			        		  && response.getString("message").equalsIgnoreCase("success"))
			        	 callbackContext.success(response);
			          else
			        	 callbackContext.error(response);

			        } catch (Exception e) {
			        	callbackContext.error(e.getMessage());
			        }
			}
		});
    }

    private HttpEntity buildBody(JSONObject email) throws UnsupportedEncodingException, JSONException{

     	List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

     	@SuppressWarnings("unchecked")
 		Iterator<String> iterator = email.keys();

    	while(iterator.hasNext()){
    		String key = iterator.next();
    		nameValuePairs.add(new BasicNameValuePair(key, email.getString(key)));
    	}

    	return new UrlEncodedFormEntity(nameValuePairs);
    }
}
