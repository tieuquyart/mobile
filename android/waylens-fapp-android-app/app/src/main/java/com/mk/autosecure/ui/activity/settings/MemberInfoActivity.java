package com.mk.autosecure.ui.activity.settings;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;
import com.orhanobut.logger.Logger;
import com.trello.rxlifecycle2.components.support.RxAppCompatActivity;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.rx.transformers.transformers.Transformers;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.rest_fleet.ApiClient;
import com.mk.autosecure.rest_fleet.bean.RoleBean;
import com.mk.autosecure.rest_fleet.bean.UsersBean;
import com.mk.autosecure.rest_fleet.request.UserBody;
import com.mk.autosecure.rest_fleet.request.UserRoleBody;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.reactivex.schedulers.Schedulers;

@SuppressLint({"CheckResult", "NonConstantResourceId"})
@Route(path = "/ui/activity/settings/MemberInfoActivity")
public class MemberInfoActivity extends RxAppCompatActivity {

    private final static String TAG = MemberInfoActivity.class.getSimpleName();
    private final static String USERS_BEAN = "users_bean";

    public final static int REQUEST_CODE_EMAIL = 1001;
    public final static int REQUEST_CODE_NAME = 1002;
    public final static int REQUEST_CODE_PHONE = 1003;
    int roleId = 0;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.iv_avatar_fleet)
    ImageView ivAvatarFleet;

    @BindView(R.id.tv_email_fleet)
    TextView tvEmailFleet;

    @BindView(R.id.iv_next_email)
    ImageView ivNextEmail;

    @BindView(R.id.tv_role_fleet)
    TextView tvRoleFleet;

    @BindView(R.id.iv_next_role)
    ImageView ivNextRole;

    @BindView(R.id.ed_username)
    EditText edUserName;

    @BindView(R.id.ed_realName)
    EditText edRealName;

    @BindView(R.id.btn_set_owner)
    Button btnSetOwner;

    @BindView(R.id.btn_remove)
    Button btnRemove;

    @BindView(R.id.btn_save)
    Button btnSave;

    @BindView(R.id.ll_info_role)
    LinearLayout ll_info_role;


    @OnClick(R.id.ll_info_role)
    @SuppressLint("CheckResult")
    public void onRole() {

        ApiClient.createApiService().getRoles(HornApplication.getComponent().currentUser().getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .subscribe(rolesResponse -> {
                    AlertDialog.Builder builder = new AlertDialog.Builder(MemberInfoActivity.this);
                    List<RoleBean> roleBeanList = rolesResponse.getData();
                    final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<>(MemberInfoActivity.this, android.R.layout.select_dialog_singlechoice);

                    for (RoleBean roleBean : roleBeanList){
                        arrayAdapter.add(roleBean.getRoleName());
                    }

                    int checkedItem = 0;
                    String role = tvRoleFleet.getText().toString().trim();
                    for(int i = 0 ; i < roleBeanList.size() ; i++){
                        if(role.compareTo(arrayAdapter.getItem(i)) == 0){
                            checkedItem = i;
                            Logger.t(TAG).d("checkedItem:= "+checkedItem+ "role "+role);
                        }
                    }

                    Logger.t(TAG).d("checkedItem:= "+checkedItem);

                    builder.setSingleChoiceItems(arrayAdapter, checkedItem, (dialog, which) -> {
                        Logger.t(TAG).d("setRole: " + which);
                        tvRoleFleet.setText(arrayAdapter.getItem(which));
                        roleId = which + 1;
                        int[] id = new int[]{roleId};
                        ApiClient.createApiService().updateUserRole(usersBean.getId(),new UserRoleBody(id, usersBean.getId()), HornApplication.getComponent().currentUser().getAccessToken())
                                .compose(Transformers.switchSchedulers())
                                .subscribeOn(Schedulers.io())
                                .subscribe(boolResponse -> {
                                    Logger.t(TAG).e("updateRoles response: " + boolResponse.isSuccess());
                                    dialog.dismiss();
                                }, throwable -> {
                                    Logger.t(TAG).e("updateRoles throwable: " + throwable.getMessage());
                                    NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                                    dialog.dismiss();
                                });
                    });

                    builder.show();
                }, throwable -> {
                    Logger.t(TAG).e("getRoles throwable: " + throwable.getMessage());
                    NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                });
    }

/*    private void refreshProfile() {
        LogInPostBody body = new LogInPostBody("doanvt", "doanvt");
        ApiClient.createApiService().logInFleet(body)
                .subscribeOn(Schedulers.io())
                .subscribe(response -> {
                    Logger.t(TAG).d("getUserInfo: " + response.toString());
                    HornApplication.getComponent().currentUser().refreshProfile(response.body().getUserLogin());
                });
    }*/

    @OnClick(R.id.btn_remove)
    public void onRemove() {
        DialogHelper.showRemovePersonnelDialog(this, this::requestDelete);
    }

    @OnClick(R.id.btn_save)
    public void onSave() {
        if(usersBean != null){
            if (TextUtils.isEmpty(edUserName.getText()) || TextUtils.isEmpty(edRealName.getText())){
                Toast.makeText(this,"Tài khoản / Họ tên rỗng!", 0).show();
            }else {
                ApiClient.createApiService().updateUser(usersBean.getId(),new UserBody(edUserName.getText().toString(),edRealName.getText().toString()), HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(boolResponse -> {
                            if(boolResponse.isSuccess()){
                                finish();
                            }
                        }, throwable -> {
                            Logger.t(TAG).e("updateUser throwable: " + throwable.getMessage());
                            NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                        });

            }
        }else{
            if (TextUtils.isEmpty(edUserName.getText()) || TextUtils.isEmpty(edRealName.getText())){
                Toast.makeText(this,"Tài khoản / Họ tên rỗng!", 0).show();
            }else {
                ApiClient.createApiService().addUser(new UserBody(edUserName.getText().toString(),edRealName.getText().toString()), HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribe(boolResponse -> {
                            Logger.i(TAG,boolResponse);
                            if(boolResponse.isSuccess()){
//                                    getDefaultPwd();
                                finish();
                            }
                        }, throwable -> {
                            Logger.t(TAG).e("addUser throwable: " + throwable.getMessage());
                            NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                        });

            }
        }
    }

    private void getDefaultPwd(){
        ApiClient.createApiService().resetPassWord(usersBean.getId(),HornApplication.getComponent().currentUser().getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .subscribe(stringResponse -> {
                    Logger.t(TAG).e("getDefaultPwd: " + stringResponse.getData());
                    DialogHelper.showPopupDialog(getBaseContext(), "Password default,", stringResponse.getData(), this::finish);

                }, throwable -> {
                    Logger.t(TAG).e("getDefaultPwd throwable: " + throwable.getMessage());
                    NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                });
    }

    private UsersBean usersBean;

    public static void launch(Activity activity, UsersBean bean) {
        Intent intent = new Intent(activity, MemberInfoActivity.class);
        intent.putExtra(USERS_BEAN, bean);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_member_info);
        ButterKnife.bind(this);

        initView();

    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    private void initView() {
        setupToolbar();

        usersBean = (UsersBean) getIntent().getSerializableExtra(USERS_BEAN);
        if (usersBean == null) {
            //add new member
            tvToolbarTitle.setText(R.string.add_new_member);
            ll_info_role.setVisibility(View.GONE);
            btnSave.setVisibility(View.VISIBLE);
            btnSetOwner.setVisibility(View.INVISIBLE);
            btnRemove.setVisibility(View.INVISIBLE);

        } else {
            //show personnel info
            tvToolbarTitle.setText(usersBean.getUserName());
            List<String> role = usersBean.getRoleNames();
            ll_info_role.setVisibility(View.VISIBLE);
            if (role != null && role.size() > 0) {
                tvRoleFleet.setText(role.get(0));
            }
            edUserName.setText(usersBean.getUserName());
            edRealName.setText(usersBean.getRealName());

            inflateMenu();

            btnSave.setVisibility(View.VISIBLE);
            btnRemove.setVisibility(View.VISIBLE);
        }
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
    }

    private void inflateMenu() {
        Logger.t(TAG).d("inflateMenu");
        toolbar.inflateMenu(R.menu.menu_personnel_edit);
        toolbar.setOnMenuItemClickListener(item -> {
            if (item.getItemId() == R.id.resetPass) {
                toolbar.getMenu().clear();
                ApiClient.createApiService().resetPassWord(usersBean.getId(),HornApplication.getComponent().currentUser().getAccessToken())
                        .compose(Transformers.switchSchedulers())
                        .compose(bindToLifecycle())
                        .subscribeOn(Schedulers.io())
                        .subscribe(stringResponse -> {
                            Logger.t(TAG).e("resetPwd: " + stringResponse.getData());
                            DialogHelper.showPopupDialog(getBaseContext(), "Password default,", stringResponse.getData(), this::finish);

                        }, throwable -> {
                            Logger.t(TAG).e("resetPwd throwable: " + throwable.getMessage());
                            NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                        });
            }
            return true;
        });
    }


    private void requestDelete() {
        ApiClient.createApiService().delUser(usersBean.getId(),HornApplication.getComponent().currentUser().getAccessToken())
                .compose(Transformers.switchSchedulers())
                .compose(bindToLifecycle())
                .subscribeOn(Schedulers.io())
                .subscribe(response -> {
                    if(response.isSuccess()){
                        finish();
                    }

                }, throwable -> {
                    Logger.t(TAG).e("deleteUser throwable: " + throwable.getMessage());
                    NetworkErrorHelper.handleCommonError(MemberInfoActivity.this, throwable);
                });
    }
}
