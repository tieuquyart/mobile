package com.mk.autosecure.ui.fragment;

import android.Manifest;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.SparseBooleanArray;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.PermissionChecker;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;

import com.mk.autosecure.ui.activity.AlbumActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.db.LocalVideoDaoManager;
import com.mkgroup.camera.db.VideoItem;
import com.mkgroup.camera.db.VideoItemDao;
import com.mkgroup.camera.preference.PreferenceUtils;
import com.mkgroup.camera.utils.FileUtils;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.BaseFragment;
import com.mk.autosecure.libs.qualifiers.RequiresFragmentViewModel;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.ui.adapter.DownloadItemAdapter;
import com.mk.autosecure.viewmodels.fragment.AlbumFragmentViewModel;

import java.io.File;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSIONS_REQUESTCODE;

/**
 * Created by doanvt on 2019/3/20.
 * Email：doanvt-hn@mk.com.vn
 */
@RequiresFragmentViewModel(AlbumFragmentViewModel.ViewModel.class)
public class AlbumFragment extends BaseFragment<AlbumFragmentViewModel.ViewModel> {

    private final static String TAG = AlbumFragment.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.rv_videos)
    RecyclerView rv_videos;

    @BindView(R.id.refresh_album_layout)
    SwipeRefreshLayout refreshLayout;

    @BindView(R.id.tv_videoCount)
    TextView tv_videoCount;

    @BindView(R.id.rl_empty)
    RelativeLayout rl_empty;

    @BindView(R.id.tv_left_menu)
    TextView tvLeftMenu;

    @BindView(R.id.tv_right_menu)
    TextView tvRightMenu;

    @OnClick(R.id.tv_left_menu)
    public void leftMenu() {
        boolean allSelected = mDownloadItemAdapter.getAllChecked();
        if (allSelected) {
            setVideoStatus(false);
        } else {
            setVideoStatus(true);
        }
    }

    @OnClick(R.id.tv_right_menu)
    public void rightMenu() {
//        Logger.t(TAG).e("rightMenu: " + popupWindow.isShowing());
        if (popupWindow == null) {
            return;
        }

        if (popupWindow.isShowing()) {
            tvLeftMenu.setVisibility(View.GONE);
            tvRightMenu.setText(R.string.select);
            mDownloadItemAdapter.setSelectTag(false);
            setVideoStatus(false);
            popupWindow.dismiss();
        } else {
            tvLeftMenu.setVisibility(View.VISIBLE);
            tvLeftMenu.setText(R.string.select_all);
            tvRightMenu.setText(R.string.cancel);

            mDownloadItemAdapter.setSelectTag(true);
            popupWindow.showAtLocation(toolbar, Gravity.BOTTOM, 0, 0);
        }
        llDelete.setEnabled(false);
        mDownloadItemAdapter.refresh();
        refreshLayout.setRefreshing(false);
    }

    private void setVideoStatus(boolean select) {
//        Logger.t(TAG).e("setVideoStatus: " + select);
        tvLeftMenu.setText(select ? R.string.deselect : R.string.select_all);
        llDelete.setEnabled(select);

        mDownloadItemAdapter.setCheckStates(select);

        mDownloadItemAdapter.refresh();
        refreshLayout.setRefreshing(false);
    }

    private View rootView;

    private DownloadItemAdapter mDownloadItemAdapter;

    private boolean isVisibleToUser;

    private boolean isInflate;

    private PopupWindow popupWindow;

    private LinearLayout llDelete;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        rootView = inflater.inflate(R.layout.fragment_album, container, false);
        ButterKnife.bind(this, rootView);
        isInflate = true;

//        if (isVisibleToUser || (Constants.isFleet() /*&& !Constants.isDriver()*/)) {
//            requestPermission();
//        }
        initView();
        return rootView;
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        Logger.t(TAG).d("setUserVisibleHint: " + isVisibleToUser);
        super.setUserVisibleHint(isVisibleToUser);
        this.isVisibleToUser = isVisibleToUser;
        if (isInflate && isVisibleToUser) {
            requestPermission();
        }
    }

    private void requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            if (PermissionChecker.checkSelfPermission(getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE}, PERMISSIONS_REQUESTCODE);
            } else {
                initView();
            }
        } else {
            initView();
        }
    }

    private void initView() {
        initPop();
        syncVideoDao();
        setupDownloadFileList();
        refreshLayout.setOnRefreshListener(() -> {
            mDownloadItemAdapter.refresh();
            refreshLayout.setRefreshing(false);
        });

        FileUtils.callMediaScanner(null);
    }

    private void initPop() {
        View view = LayoutInflater.from(getActivity()).inflate(R.layout.layout_album_delete, null);
        llDelete = view.findViewById(R.id.ll_album_delete);
        llDelete.setOnClickListener(v -> showDeleteDialog());

        popupWindow = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.WRAP_CONTENT,
                false);
    }

    private void showDeleteDialog() {
        View view = LayoutInflater.from(getActivity()).inflate(R.layout.layout_delete_confirm, null);

        ((TextView) view.findViewById(R.id.tv_delete_tips)).setText(R.string.album_delete_tips);

        PopupWindow deletePop = new PopupWindow(view,
                CoordinatorLayout.LayoutParams.MATCH_PARENT,
                CoordinatorLayout.LayoutParams.WRAP_CONTENT,
                true);

        view.findViewById(R.id.btn_delete).setOnClickListener(v -> {
            List<VideoItem> downloadedFileList = mDownloadItemAdapter.getDownloadedFileList();
            SparseBooleanArray checkStates = mDownloadItemAdapter.getCheckStates();
            for (int i = 0; i < downloadedFileList.size(); i++) {
                boolean b = checkStates.get(i, false);
                if (b) {
                    VideoItem videoItem = downloadedFileList.get(i);

                    String rawVideoPath = videoItem.getRawVideoPath();
                    if (!TextUtils.isEmpty(rawVideoPath)) {
                        File file = new File(rawVideoPath);
                        if (file.exists()) {
                            boolean delete = file.delete();
                            Logger.t(TAG).e("RawVideo: " + delete);
                            FileUtils.callMediaScanner(file);
                        }
                    }

                    LocalVideoDaoManager.getInstance().delete(videoItem);
                }
            }

            rightMenu();
            deletePop.dismiss();
        });

        view.findViewById(R.id.btn_delete_cancel).setOnClickListener(v -> deletePop.dismiss());

        deletePop.showAtLocation(rootView, Gravity.BOTTOM, 0, 0);
    }

    private void setupDownloadFileList() {
        rv_videos.setLayoutManager(new LinearLayoutManager(getActivity()));
        mDownloadItemAdapter = new DownloadItemAdapter(getActivity(), new DownloadItemAdapter.NumberChangeListener() {
            @Override
            public void onVideoNumberChanged(int count) {
                Logger.t(TAG).e("onVideoNumberChanged: " + count);
                if (!popupWindow.isShowing()) {
                    tv_videoCount.setText(String.format("%s %s", count,
                            count >= 2 ? getString(R.string.videos) : getString(R.string.video)));
                }
                if (count == 0) {
                    tvRightMenu.setVisibility(View.GONE);
                    rl_empty.setVisibility(View.VISIBLE);
                } else {
                    tvRightMenu.setVisibility(View.VISIBLE);
                    rl_empty.setVisibility(View.GONE);
                }
            }

            @Override
            public void onSelectNumberChanged(int count) {
                Logger.t(TAG).e("onSelectNumberChanged: " + count);
                if (count == 0) {
                    llDelete.setEnabled(false);
                    tvLeftMenu.setText(R.string.select_all);
                } else if (count == mDownloadItemAdapter.getItemCount()) {
                    llDelete.setEnabled(true);
                    tvLeftMenu.setText(R.string.deselect);
                } else {
                    llDelete.setEnabled(true);
                    tvLeftMenu.setText(R.string.select_all);
                }
                if (popupWindow.isShowing()) {
                    tv_videoCount.setText(String.format("%s %s %s", getString(R.string.selected), count,
                            count >= 2 ? getString(R.string.videos) : getString(R.string.video)));
                }
            }
        });
        rv_videos.setAdapter(mDownloadItemAdapter);
    }

    private void syncVideoDao() {
        boolean aBoolean = PreferenceUtils.getBoolean(PreferenceUtils.SYNC_VIDEO_DB, true);
        Logger.t(TAG).e("syncVideoDao: " + aBoolean);
        if (aBoolean) {
            //创建表
            VideoItemDao.createTable(HornApplication.getComponent().daoMaster().getDatabase(), true);

            List<File> exportedFileList = FileUtils.getExportedFileList();
            LocalVideoDaoManager daoManager = LocalVideoDaoManager.getInstance();

            for (File file :
                    exportedFileList) {
                VideoItem videoItem = new VideoItem();
                videoItem.setTranscodeVideoPath(file.getAbsolutePath());
                //过滤时间
                String fileName = file.getName();
                int prefix = fileName.indexOf("_");
                int suffix = fileName.indexOf(".");
                String timeSubstring = fileName.substring(prefix + 1, suffix);
                DateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.US);
                try {
                    Date parse = format.parse(timeSubstring);
                    videoItem.setCreateTime(parse.getTime());
                } catch (ParseException e) {
                    Logger.t(TAG).e("ex: " + e.getMessage());
                } finally {
                    daoManager.insert(videoItem);
                }
            }
            PreferenceUtils.putBoolean(PreferenceUtils.SYNC_VIDEO_DB, false);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Logger.t(TAG).d("onRequestPermissionsResult: " + requestCode);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSIONS_REQUESTCODE) {
            if (grantResults.length > 0 &&
                    grantResults[0] == PermissionChecker.PERMISSION_GRANTED &&
                    grantResults[1] == PermissionChecker.PERMISSION_GRANTED) {

                initView();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    boolean showDialog = !shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE) ||
                            !shouldShowRequestPermissionRationale(Manifest.permission.READ_EXTERNAL_STORAGE);
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(getContext(),
                                () -> PermissionUtil.startAppSetting(this),
                                () -> rl_empty.setVisibility(View.VISIBLE)
                        );
                    } else {
                        rl_empty.setVisibility(View.VISIBLE);
                    }
                }
                Toast.makeText(getActivity(), getResources().getString(R.string.storage_must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).d("onActivityResult: " + requestCode);
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED) {
                initView();
            } else {
                rl_empty.setVisibility(View.VISIBLE);
            }
        }
    }
}
