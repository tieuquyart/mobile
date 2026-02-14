package com.mk.autosecure.ui.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.afollestad.materialdialogs.MaterialDialog;
import com.mk.autosecure.R;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.adapter.FaceAdapter;

import android.widget.Toast;

import com.mk.autosecure.ui.view.CustomRecyclerView;
import com.mkgroup.camera.model.fms.SendDataFWEvent;
import com.mkgroup.camera.model.fms.SendDataFWResponse;
import com.mkgroup.camera.utils.RxBus;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.EvCamera;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.data.DmsClient;
import com.mkgroup.camera.data.dms.BasicSocket;
import com.mkgroup.camera.data.dms.DmsRequestQueue;
import com.mkgroup.camera.model.dms.FaceList;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.viewmodels.FaceIdFragmentViewModel;

import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Locale;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;

/**
 * Created by cloud on 2021/2/6.
 */

@SuppressLint("CheckResult")
@RequiresFragmentViewModel(FaceIdFragmentViewModel.ViewModel.class)
public class FaceIdFragment extends BaseFragment<FaceIdFragmentViewModel.ViewModel> implements FaceAdapter.FaceOperationListener {

    private static final String TAG = FaceIdFragment.class.getSimpleName();

    public String cameraSn = "";

    private String faceId = "";

    private Context mContext;

    private EvCamera evCamera;

    private FaceAdapter mFaceAdapter;


    enum TypeFace {REMOVE, ADD}

    TypeFace typeFace;

    private long oldFaceListSize = 0;
    private long faceListSize = 0;
    private ArrayList<FaceList.FaceItem> faceItems = new ArrayList<>();

    private boolean isCheckAdd = false;
    private boolean isAddSuccess = false;

    @BindView(R.id.tv_face_list)
    TextView tvFaceList;

    @BindView(R.id.progressBar)
    ProgressBar progressBar;

    @BindView(R.id.rv_faceId)
    CustomRecyclerView rvFaceId;

    @BindView(R.id.btn_add_faceId)
    Button btnAddFaceId;

    View viewDialogAddFace;

    EditText etCCCD;

    /**
     * button add face - save face data to FMS
     */
    @OnClick(R.id.btn_add_faceId)
    public void addFaceId() {
        if (mContext == null) {
            return;
        }

        new MaterialDialog
                .Builder(mContext)
                .customView(viewDialogAddFace, false)
                .positiveText("Thêm")
                .negativeText("Hủy")
                .negativeColorRes(R.color.colorNaviText)
                .onPositive((dialog, which) -> {
//                    driverName = etFaceName.getText().toString().trim();
                    String numberId = etCCCD.getText().toString().trim();

//                    Logger.t(TAG).d("addFaceId name: " + driverName);
                    if (etCCCD.getText().length() != 12) {
                        Toast.makeText(getActivity(), getString(R.string.invalid_idnumber_format),Toast.LENGTH_SHORT).show();
                        return;
                    }

                    if (TextUtils.isEmpty(numberId)) {
                        Toast.makeText(mContext, R.string.please_enter_numberId, Toast.LENGTH_LONG).show();
                        return;
                    }
                    if (viewModel != null && evCamera != null) {
                        progressBar.setVisibility(View.VISIBLE);
//                        viewModel.showButtonAddFace(View.GONE);
                        typeFace = TypeFace.ADD;
                        viewModel.saveFaceData(evCamera, cameraSn, numberId);
                    }
                }).show();
    }

    /**
     * remove all Face on Camera - deprecated
     */

    @OnClick(R.id.btn_remove_all_faceId)
    public void removeAllFaces() {
        if (mContext == null) {
            return;
        }

        progressBar.setVisibility(View.VISIBLE);
        new MaterialDialog
                .Builder(mContext)
                .title("Bạn có chắc chắn muốn xóa tất cả khuôn mặt?")
                .positiveText("Đồng ý")
                .negativeText("Hủy")
                .negativeColorRes(R.color.colorNaviText)
                .onPositive((dialog, which) ->
                        viewModel.removeAllFaces()
                                .compose(bindToLifecycle())
                                .compose(Transformers.switchSchedulers())
                                .subscribe(result -> {
                                    Logger.t(TAG).i("removeAllFaces: " + result.result);
                                    if (viewModel != null) viewModel.getAllFaces();
                                    Toast.makeText(mContext, getString(R.string.remove_success), Toast.LENGTH_SHORT).show();
                                }, throwable -> {
                                    Logger.t(TAG).e("removeAllFaces throwable: " + throwable.getMessage());
                                    Toast.makeText(mContext, getString(R.string.remove_failure), Toast.LENGTH_SHORT).show();
                                }))
                .show();
    }

    public static FaceIdFragment newInstance(String cameraSn) {
        Bundle args = new Bundle();
        FaceIdFragment fragment = new FaceIdFragment();
        fragment.cameraSn = cameraSn;
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
        evCamera = (EvCamera) VdtCameraManager.getManager().getCurrentCamera();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View view = inflater.inflate(R.layout.fragment_face_id, container, false);
        ButterKnife.bind(this, view);
        initView();
        initEvent();
        initRequestQueue();
        initObservable();

        viewDialogAddFace = LayoutInflater.from(mContext).inflate(R.layout.dialog_add_faceid, null);

        etCCCD = viewDialogAddFace.findViewById(R.id.et_cccd);

        etCCCD.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
//                String text = s.toString();
//                if (text.length() != 12){
//                    Toast.makeText(getActivity(), getString(R.string.invalid_idnumber_format),Toast.LENGTH_SHORT).show();
//                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        return view;
    }

    /***/
    private void initView() {
        rvFaceId.setLayoutManager(new LinearLayoutManager(mContext));
        rvFaceId.addItemDecoration(new DividerItemDecoration(mContext, DividerItemDecoration.VERTICAL));
        mFaceAdapter = new FaceAdapter();
        mFaceAdapter.setOperationListener(this);
        rvFaceId.setAdapter(mFaceAdapter);
    }

    /**
     * remove face data on FMS when click item
     */
    @Override
    public void onItemRemove(FaceList.FaceItem faceItem) {
        if (faceItem == null || mContext == null) return;
        faceId = faceItem.faceID;
        new MaterialDialog
                .Builder(mContext)
                .title(getString(R.string.warning_remove_faceId, faceItem.name))
                .positiveText(getString(R.string.confirm_btn))
                .negativeText(getString(R.string.cancel))
                .negativeColorRes(R.color.colorNaviText)
                .onPositive((dialog, which) -> {
                    typeFace = TypeFace.REMOVE;
                            progressBar.setVisibility(View.VISIBLE);
                            viewModel.removeFaceData(evCamera, cameraSn, faceId);
                        }
                )
                .show();
    }

    /**
     * Khởi tạo handler nhận event khi add-remove face from FMS and add-remove face to DMS
     */
    private void initEvent() {

        viewModel.showBtnAddFace()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(i -> btnAddFaceId.setVisibility(i));

        RxBus.getDefault().toObservable(SendDataFWEvent.class)
                .compose(bindToLifecycle())
                .takeUntil(Observable.error(new TimeoutException()).delay(30, TimeUnit.SECONDS, true))
                .doFinally(()->{
//                    progressBar.setVisibility(View.GONE);
                })
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(event -> {
                    Logger.t(TAG).i("initListener saveFaceData = " + event.getResponse());
                    SendDataFWResponse response = event.getResponse();
                   if (response.isSuccess() && response.getCode() == 2000){
                       if (typeFace == TypeFace.ADD) {
                           String data = response.getData().toString();
                           JSONObject jsonObject = new JSONObject(data);
                           String driverName = jsonObject.getString("driver_name");
                           if (!TextUtils.isEmpty(driverName)) {
                               addFaceToDMS(driverName);
                           } else {
                               progressBar.setVisibility(View.GONE);
                               Toast.makeText(getContext(), R.string.get_driver_name_err, Toast.LENGTH_SHORT).show();
                           }
                       } else if (typeFace == TypeFace.REMOVE) {
                           removeFaceToDMS();
                       }
                   }else{
                       if (response.getCode() != 2000 && !TextUtils.isEmpty(response.getMsg())) {
                           Toast.makeText(getContext(), showMsgWithCode(response.getCode(), response.getMsg()), Toast.LENGTH_SHORT).show();
                           new Handler().postDelayed(() -> {
                               if (viewModel != null) viewModel.getAllFaces();
                               progressBar.setVisibility(View.GONE);
                           }, 100);
                       }
                   }
                }, throwable -> {
                    progressBar.setVisibility(View.GONE);
                    new ServerErrorHandler(TAG);
                });

    }

    /**
     * add face to DMS when save FMS success
     */
    private void addFaceToDMS(String driverName) {
        viewModel.addFaceWithId(driverName)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(result -> {
                    Logger.t(TAG).i("addFaceWithId: " + result.result);
                    Toast.makeText(mContext, getString(R.string.send_add_faceid_success), Toast.LENGTH_SHORT).show();
                    if (result.result) {
                        new Handler().postDelayed(() -> {
                            if (viewModel != null && evCamera != null) {
                                progressBar.setVisibility(View.GONE);
                                viewModel.getAllFaces();
                            }
                        }, 3000);
                    }
                }, throwable -> {
                    progressBar.setVisibility(View.GONE);
                    Logger.t(TAG).e("addFaceWithId throwable: " + throwable.getMessage());
                    Toast.makeText(mContext, getString(R.string.send_add_faceid_failure), Toast.LENGTH_SHORT).show();
                });
    }

    /**
     * remove Face to DMS when remove on FMS success
     */
    private void removeFaceToDMS() {
        viewModel.removeFaceWithId(faceId)
                .compose(bindToLifecycle())
                .compose(Transformers.switchSchedulers())
                .subscribe(result -> {
                    Logger.t(TAG).i("removeFaceWithId: " + result.result);
                    if (viewModel != null) viewModel.getAllFaces();
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(mContext, getString(R.string.remove_success), Toast.LENGTH_SHORT).show();
                }, throwable -> {
                    progressBar.setVisibility(View.GONE);
                    Logger.t(TAG).e("removeFaceWithId throwable: " + throwable.getMessage());
                    Toast.makeText(mContext, getString(R.string.remove_failure), Toast.LENGTH_SHORT).show();
                });
    }

    /**
     * define code message response FMS
     */
    private String showMsgWithCode(int code, String msg) {
        if (code == 1000) {
            return getString(R.string.json_format_err);
        } else if (code == 1001) {
            return getString(R.string.json_empty);
        } else if (code == 1002) {
            return getString(R.string.remove_faceId_in_vehicle_err);
        } else if (code == 1010) {
            return getString(R.string.driver_not_found);
        } else if (code == 1100) {
            return getString(R.string.camera_in_vehicle_not_found);
        } else if (code == 1101) {
            return getString(R.string.remove_old_driver_in_vehicle_err);
        } else if (code == 1011) {
            return getString(R.string.camera_driver_not_match);
        } else if (code == 1110) {
            return getString(R.string.add_faceId_to_vehicle_data_err);
        } else if (code == 1111) {
            return getString(R.string.add_faceId_to_driver_data_err);
        } else if (code == 3333) {
            return getString(R.string.fms_response_timeout);
        } else if (!TextUtils.isEmpty(msg)) {
            return msg;
        } else {
            return getString(R.string.unknown_err);
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        if (viewModel != null) {
            viewModel.getAllFaces();
        }
    }

    /**
     * khởi tạo RequestQueue DMS
     */
    private void initRequestQueue() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        Logger.t(TAG).d("currentCamera: " + currentCamera);
        if (currentCamera != null) {
            HandlerThread handlerThread = new HandlerThread("DMS");
            handlerThread.start();
            Handler handler = new Handler(handlerThread.getLooper());
            handler.post(() -> {
                DmsClient client = new DmsClient(currentCamera.getHostString());
                try {
                    client.connect();
                } catch (IOException e) {
                    Logger.t(TAG).e("DmsClient connect timeout");
                }

                Logger.t(TAG).d("isConnected: " + client.isConnected());

                if (client.isConnected()) {
                    BasicSocket socket = new BasicSocket(client);
                    DmsRequestQueue requestQueue = new DmsRequestQueue(socket);
                    requestQueue.start();

                    if (viewModel != null) {
                        viewModel.mDmsRequestQueue = requestQueue;
                        viewModel.getAllFaces();
                    }
                }
            });
        }
    }

    /**
     * handler receiver data getAllFace
     */
    private void initObservable() {
        viewModel.allFaces()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(this::onAllFaces, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        Logger.t(TAG).e("getAllFaces throwable: " + throwable.getMessage());
                    }
                });
    }

    private void onAllFaces(FaceList faceList) {
        Logger.t(TAG).i("getAllFaces: " + faceList);
        if (faceList == null) {
            return;
        }
        viewModel.showButtonAddFace(faceList.num_ids != 0 ? View.GONE : View.VISIBLE);
        tvFaceList.setText(String.format(Locale.getDefault(), "%d FACE(s)", faceList.num_ids));
        if (mFaceAdapter != null) {
            mFaceAdapter.setNewData(faceList.mClipList);
        }
    }
}
