package com.lwz.facedetectr;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.JsonReader;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

public class NetworkUtils {

    public static final String LOG_TAG = NetworkUtils.class.getSimpleName();

    public static final String S_BASE_URL = "http://34.73.178.43:5000/";
    public static final String S_DOWNLOAD = "download";
    public static final String S_UPLOAD = "up_photo";

    public static String post(String filePath) {
        String result = "";
        try {
            MultipartUtility multipart = new MultipartUtility(S_BASE_URL + S_UPLOAD);
            File f = new File(filePath);
            multipart.addFilePart("photo", f);
            result = multipart.finish();
        } catch (IOException e) {
            e.printStackTrace();
        }

        Log.i(LOG_TAG, result);
        return result;
    }

    public static JsonObject parseResults(String result) {
        JsonParser parser = new JsonParser();
        JsonObject json = parser.parse(result).getAsJsonObject();
        JsonObject msg = json.get("msg").getAsJsonObject();

        return msg;
    }

    public static String getProcessedPhotoPath(String result) {
        JsonParser parser = new JsonParser();
        JsonObject json = parser.parse(result).getAsJsonObject();

        return json.get("msg").getAsString();
    }

    public static Bitmap getImageFromPath(String filePath){
        try {
            URL url = new URL(S_BASE_URL + S_DOWNLOAD + "/" + filePath);
            Log.d(LOG_TAG, "Retrieving " + url.toString());
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoInput(true);
            InputStream input = conn.getInputStream();
            Bitmap mBitmap = BitmapFactory.decodeStream(input);
            return mBitmap;
        } catch (MalformedURLException e) {
            e.printStackTrace();
            return null;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

}
