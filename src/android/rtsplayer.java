package br.com.stek.rtsplayer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class rtsplayer extends CordovaPlugin {

    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("coolMethod")) {
            this.coolMethod(args.getString(0), callbackContext);
            return true;
        } else if (action.equals("watchVideo")) {
            this.callbackContext = callbackContext;
            String videoUrl = args.getString(0);
            Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, rtsplayerActivity.class);
            intent.putExtra("VIDEO_URL", videoUrl);
            Log.d("FLP","Adicionaod extra: "+videoUrl);
            cordova.startActivityForResult(this, intent, 0);
            return true;
        }

        return false;

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d("FLP","Result: "+resultCode);

        if (resultCode == Activity.RESULT_CANCELED || resultCode == Activity.RESULT_OK)  {
            Log.d("FLP", "OK");
            callbackContext.success();
        } else {
            Log.d("FLP", "error");
            callbackContext.error("Failed");
        }
    }

    private void coolMethod(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }
}
