package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;
import android.content.Context;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.rest.error.ErrorEnvelope;
import com.mk.autosecure.rest.reponse.DriverStatusReportResponse;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;
import com.mk.autosecure.rest_fleet.request.VehicleFleetBody;
import com.mk.autosecure.rest_fleet.response.Response;
import com.mk.autosecure.rest_fleet.response.VehicleListResponse;
import android.widget.Toast;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.libs.account.CurrentUser;
import com.mk.autosecure.ui.fragment.DashFleetFragment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.TimeZone;

import io.reactivex.Observable;
import io.reactivex.functions.Consumer;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;
import okhttp3.ResponseBody;

public interface DashFleetViewModel {

    interface Inputs {
        void inputQueryTime(String fromTimeMills, String toTimeMills);

        void inputQueryData(String plateNo, String fromTime, String toTime);

        //        void queryAllDash();
        void queryVehicleList();

        void queryStatusReport();

        boolean writeResponseBodyToDisk(ResponseBody body, String fileName, String plateNo);

        void exportVehicleFleet();
    }

    interface Outputs {
        Observable<Optional<DriverStatusReportResponse>> statusReportResponse();

        Observable<List<VehicleInfoBean>> vehicleList();
//        Observable<List<FleetViewRecord>> dashFleet();
    }

    interface Errors {
        Observable<ErrorEnvelope> apiError();

        Observable<Throwable> networkError();

        Observable<Response> responseErr();
    }

    final class ViewModel extends FragmentViewModel<DashFleetFragment> implements DashFleetViewModel.Inputs, DashFleetViewModel.Outputs, DashFleetViewModel.Errors {

        private static final String TAG = DashFleetViewModel.ViewModel.class.getSimpleName();

        private final CurrentUser currentUser;

        private final TimeZone timeZone;

        private String plateNo;

        private String fromTime;

        private String toTime;

        private String token;
        private Context mContext;

        private final BehaviorSubject<Optional<DriverStatusReportResponse>> statusReportResponse = BehaviorSubject.create();
        private final BehaviorSubject<List<VehicleInfoBean>> vehicleInfoBeanList = BehaviorSubject.create();

//        private final BehaviorSubject<List<FleetViewRecord>> dashFleet = BehaviorSubject.create();

        private final PublishSubject<ErrorEnvelope> apiError = PublishSubject.create();

        private final PublishSubject<Throwable> networkError = PublishSubject.create();

        private final PublishSubject<Response> responseErr = PublishSubject.create();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            timeZone = TimeZone.getDefault();
            token = appComponent.currentUser().getAccessToken();
            mContext = appComponent.appContext();
        }

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public void inputQueryTime(String fromTime, String toTime) {
            this.fromTime = fromTime;
            this.toTime = toTime;
        }

        @Override
        public void inputQueryData(String plateNo, String fromTime, String toTime) {
            this.plateNo = plateNo;
            this.fromTime = fromTime;
            this.toTime = toTime;
        }
        /**
         * lấy thông tin báo cáo
         * */
        @SuppressLint("CheckResult")
        public void queryStatusReport() {
            ApiClient.createApiService().getStatusReport(fromTime, toTime, 10, 1, token)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<DriverStatusReportResponse>() {
                        @Override
                        public void accept(DriverStatusReportResponse response) throws Exception {
                            if (response.isSuccess()) {
                                statusReportResponse.onNext(Optional.ofNullable(response));
                            } else {
                                responseErr.onNext(response);
                                statusReportResponse.onNext(Optional.empty());
                            }
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getStatusReport throwable: " + throwable.getMessage());
                        statusReportResponse.onNext(Optional.empty());
                    });
        }
        /**
         * xuất báo cáo
         * */
        @SuppressLint("CheckResult")
        public void exportVehicleFleet() {
            VehicleFleetBody body = new VehicleFleetBody(toTime + "T23:59:59+07:00", fromTime + "T00:00:00+07:00", plateNo);
            ApiClient.createApiService().vehicleFleet(body, token)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(data -> {
                        if (data.body() != null) {
                            boolean writtenToDisk = writeResponseBodyToDisk(data.body(), FileUtils.vehicleFleetFileName,plateNo);
                            Logger.t(TAG).d("file download was a success? " + writtenToDisk);
                            if (writtenToDisk)
                                Toast.makeText(mContext, "Tải & lưu dữ liệu thành công", Toast.LENGTH_SHORT).show();
                            else

                                Toast.makeText(mContext, "Tải & lưu dữ liệu lỗi", Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(mContext, "Không có dữ liệu", Toast.LENGTH_SHORT).show();
                        }

                    }, throwable -> new ServerErrorHandler(TAG));
        }

        /**
         * lưu file excel
         * */
        public boolean writeResponseBodyToDisk(ResponseBody body, String fileName, String plateNo) {
            try {
                String fileSave = "";
                if (plateNo != null && !plateNo.equals("")){
                    fileSave = plateNo + "-" + fileName;
                }else{
                    fileSave = fileName;
                }

                File cacheFile = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), fileSave);
                if (cacheFile.exists()) {
                    cacheFile.delete();
                }

                InputStream inputStream = null;
                OutputStream outputStream = null;

                try {
                    byte[] fileReader = new byte[4096];

                    long fileSize = body.contentLength();
                    long fileSizeDownloaded = 0;

                    inputStream = body.byteStream();
                    outputStream = new FileOutputStream(cacheFile, false);

                    while (true) {
                        int read = inputStream.read(fileReader);

                        if (read == -1) {
                            break;
                        }

                        outputStream.write(fileReader, 0, read);

                        fileSizeDownloaded += read;

                        Logger.t(TAG).d("file download: " + fileSizeDownloaded + " of " + fileSize);
                    }

                    outputStream.flush();

                    return true;
                } catch (IOException e) {
                    Logger.t(TAG).e("download2 throwable: " + e.getMessage());
                    return false;
                } finally {
                    if (inputStream != null) {
                        inputStream.close();
                    }

                    if (outputStream != null) {
                        outputStream.close();
                    }
                }
            } catch (IOException e) {
                Logger.t(TAG).e("download1 throwable: " + e.getMessage());
                return false;
            }
        }

        /***
         * lấy danh sách xe
         * */
        @SuppressLint("CheckResult")
        public void queryVehicleList() {
            ApiClient.createApiService().getVehicleList(token)
                    .compose(Transformers.switchSchedulers())
                    .compose(bindToLifecycle())
                    .subscribe(new Consumer<VehicleListResponse>() {
                        @Override
                        public void accept(VehicleListResponse response) throws Exception {
                            if (response.isSuccess()) {
                                vehicleInfoBeanList.onNext(response.getData());
                            }
                        }
                    }, throwable -> {
                        Logger.t(TAG).e("getVehicle List throwable: " + throwable.getMessage());
                        vehicleInfoBeanList.onNext(new ArrayList<>());
                    });
        }

        @Override
        public Observable<Optional<DriverStatusReportResponse>> statusReportResponse() {
            return statusReportResponse;
        }

        @Override
        public Observable<List<VehicleInfoBean>> vehicleList() {
            return vehicleInfoBeanList;
        }

        @Override
        public Observable<ErrorEnvelope> apiError() {
            return apiError;
        }

        @Override
        public Observable<Throwable> networkError() {
            return networkError;
        }

        @Override
        public Observable<Response> responseErr() {
            return responseErr;
        }
    }
}
