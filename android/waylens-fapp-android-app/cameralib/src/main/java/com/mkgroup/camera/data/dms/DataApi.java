package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.toolbox.AddFaceRequest;
import com.mkgroup.camera.toolbox.DoCalibrationRequest;
import com.mkgroup.camera.toolbox.GetListFacesRequest;
import com.mkgroup.camera.toolbox.GetVersionInfoRequest;
import com.mkgroup.camera.toolbox.RemoveFaceRequest;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.model.dms.FaceList;
import com.mkgroup.camera.model.dms.Result;
import com.mkgroup.camera.model.dms.VersionInfo;

import java.util.concurrent.ExecutionException;

import io.reactivex.Observable;

public class DataApi {

    private final static String TAG = DataApi.class.getSimpleName();

    public static Observable<Result> doCalibrationRx(final DmsRequestQueue requestQueue, final int x, final int y, final int z) {
        return Observable.defer(() -> {
            try {
                return Observable.just(doCalibration(requestQueue, x, y, z));
            } catch (ExecutionException | InterruptedException e) {
                return Observable.error(e);
            }
        });
    }

    public static Observable<VersionInfo> getVersionInfoRx(final DmsRequestQueue requestQueue) {
        return Observable.defer(() -> {
            try {
                return Observable.just(getVersionInfo(requestQueue));
            } catch (ExecutionException | InterruptedException e) {
                return Observable.error(e);
            }
        });
    }

    public static Observable<FaceList> getAllFacesRx(DmsRequestQueue requestQueue) {
        return Observable.defer(() -> {
            try {
                return Observable.just(getAllFaces(requestQueue));
            } catch (Exception ex) {
                return Observable.error(ex);
            }
        });
    }

    public static Observable<Result> addFaceWithIdRx(DmsRequestQueue requestQueue, String faceId, String name) {
        return Observable.defer(() -> {
            try {
                return Observable.just(addFaceWithID(requestQueue, faceId, name));
            } catch (Exception ex) {
                return Observable.error(ex);
            }
        });
    }

    public static Observable<Result> removeFaceWithIdRx(DmsRequestQueue requestQueue, String faceId, long flag) {
        return Observable.defer(() -> {
            try {
                return Observable.just(removeFaceWithID(requestQueue, faceId, flag));
            } catch (Exception ex) {
                return Observable.error(ex);
            }
        });
    }

    private static VersionInfo getVersionInfo(final DmsRequestQueue requestQueue) throws ExecutionException, InterruptedException {
        DmsRequestFuture<VersionInfo> future = DmsRequestFuture.newFuture();
        GetVersionInfoRequest request = new GetVersionInfoRequest(0, future, future);
        Logger.t(TAG).d("getVersionInfo: " + requestQueue);
        requestQueue.add(request);
        return future.get();
    }

    private static Result addFaceWithID(DmsRequestQueue requestQueue, String faceID, String name) throws ExecutionException, InterruptedException {
        DmsRequestFuture<Result> future = DmsRequestFuture.newFuture();
        AddFaceRequest request = new AddFaceRequest(faceID, name, future, future);
        requestQueue.add(request);
        return future.get();
    }

    public static FaceList getAllFaces(DmsRequestQueue requestQueue) throws ExecutionException, InterruptedException {
        DmsRequestFuture<FaceList> future = DmsRequestFuture.newFuture();
        GetListFacesRequest request = new GetListFacesRequest(0, future, future);
        requestQueue.add(request);
        return future.get();
    }

    public static Result removeFaceWithID(DmsRequestQueue requestQueue, String faceID, long flag) throws ExecutionException, InterruptedException {
        DmsRequestFuture<Result> future = DmsRequestFuture.newFuture();
        RemoveFaceRequest request = new RemoveFaceRequest(faceID, flag, future, future);
        requestQueue.add(request);
        return future.get();
    }

    private static Result doCalibration(DmsRequestQueue requestQueue, int x, int y, int z) throws ExecutionException, InterruptedException {
        DmsRequestFuture<Result> future = DmsRequestFuture.newFuture();
        DoCalibrationRequest request = new DoCalibrationRequest(x, y, z, future, future);
        requestQueue.add(request);
        return future.get();
    }

}
