package com.mk.autosecure.rest_fleet;

import android.os.AsyncTask;
import android.view.View;

import com.google.android.gms.maps.model.LatLng;
import com.google.gson.Gson;
import com.mk.autosecure.BuildConfig;
import com.mk.autosecure.libs.utils.MapTransformUtil;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest_fleet.response.SnapToRoadResponse;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import okhttp3.OkHttpClient;
import okhttp3.Request;

public class SnapToRoadAsyncTask extends AsyncTask<Void, Void, List<LatLng>> {
    private static final String TAG = SnapToRoadAsyncTask.class.getSimpleName();

    private SnapToRoadCallback listener;
    private StringBuilder param;

    public SnapToRoadAsyncTask(SnapToRoadCallback listener, StringBuilder param) {
        this.listener = listener;
        this.param = param;
    }

    @Override
    protected List<LatLng> doInBackground(Void... voids) {

        String[] arrayCheckLength = param.toString().split("\\|");
        Logger.t(TAG).d("String: " + arrayCheckLength.length);
        Logger.t(TAG).d("String: " + arrayCheckLength[0].toString());

        List<LatLng> latLngs = new ArrayList<>();

        if (arrayCheckLength.length > 100) {
            List<List<String>> listOfListPath = ToStringUtils.splitToList(arrayCheckLength, 100);
            for (List<String> listPath : listOfListPath) {
                StringBuilder getPath = new StringBuilder();
                for (String value : listPath) {
                    if (value.contains(listPath.get(listPath.size() - 1))) {
                        getPath.append(value);
                    } else {
                        getPath.append(value).append("|");
                    }
                }
                List<LatLng> result = startCall(getPath);
                if (result != null) {
                    latLngs.addAll(result);
                }
            }
            return latLngs;

        } else {
            List<LatLng> result = startCall(param);
            if (result != null) {
                latLngs.addAll(result);
                return latLngs;
            } else {
                return null;
            }
        }

    }

    @Override
    protected void onPostExecute(List<LatLng> latLngs) {
        super.onPostExecute(latLngs);
        listener.onCallBack(latLngs);
    }

    private List<LatLng> startCall(StringBuilder param) {
        Logger.t(TAG).d("path: " + param.toString());
        String checkPath = param.deleteCharAt(param.length() - 1).toString();
        String api = String.format("https://roads.googleapis.com/v1/snapToRoads?interpolate=true&key=%s&path=%s", BuildConfig.google_maps_key, checkPath);
        List<LatLng> latLngList = new ArrayList<>();
        Logger.t(TAG).d("api: " + api);
        try {
            String res = runSnapToRoad(api);
            Gson gson = new Gson();
            SnapToRoadResponse response = gson.fromJson(res, SnapToRoadResponse.class);
//            Logger.t(TAG).d("snapToRoad: " + res);

            if (response.snappedPoints == null) {
                return null;
            }

            List<SnapToRoadResponse.SnappedPoint> snappedPointList = response.snappedPoints;
            for (SnapToRoadResponse.SnappedPoint snap : snappedPointList) {
                double lat = snap.location.latitude;
                double lng = snap.location.longitude;
                if (lat == 0 || lng == 0) {
                    continue;
                }
                latLngList.add(MapTransformUtil.gps84_To_Gcj02(new LatLng(lat, lng)));
            }
            return latLngList;

        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * request api snaptoRoad
     */
    String runSnapToRoad(String url) throws IOException {
        Request request = new Request.Builder()
                .url(url)
                .build();

        OkHttpClient client = new OkHttpClient();
        try (okhttp3.Response response = client.newCall(request).execute()) {
            return response.body().string();
        }
    }
}
