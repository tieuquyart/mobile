package com.mk.autosecure.ui.activity.settings;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.HornApplication;
import com.mk.autosecure.libs.BaseActivity;
import com.mk.autosecure.libs.account.User;
import com.mk.autosecure.libs.qualifiers.RequiresActivityViewModel;
import com.mk.autosecure.libs.utils.NetworkErrorHelper;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ServerErrorHandler;
import android.widget.Toast;

import com.mk.autosecure.viewmodels.setting.UsernameViewModel;
import com.mk.autosecure.R;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnTextChanged;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 */
@RequiresActivityViewModel(UsernameViewModel.ViewModel.class)
public class UsernameActivity extends BaseActivity<UsernameViewModel.ViewModel> {
    private static final String TAG = UsernameActivity.class.getSimpleName();

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.et_username)
    EditText etUsername;

    @OnTextChanged(R.id.et_username)
    void onNameTextChanged(final @NonNull CharSequence name) {
        toolbar.getMenu().findItem(R.id.save).setEnabled(!TextUtils.isEmpty(name));
    }

    public static void launch(Activity activity) {
        Intent intent = new Intent(activity, UsernameActivity.class);
        activity.startActivity(intent);
        //activity.overridePendingTransition(R.anim.slide_in_right, R.anim.stay_still);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_username);
        ButterKnife.bind(this);
        initViews();
    }

    private void initViews() {
        setupToolbar();
        toolbar.getMenu().clear();
        toolbar.inflateMenu(R.menu.username_save);
        toolbar.setOnMenuItemClickListener(new Toolbar.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.save:
                        saveUsername();
                        break;
                    default:
                        break;
                }
                return false;
            }
        });
        etUsername.setOnFocusChangeListener((v, hasFocus) -> {
            if (!hasFocus) {
                InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
            }
        });
        init();
    }

    private void init() {
        AppComponent component = HornApplication.getComponent();
        component.currentUser().observable()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(userOptional -> {
                    User user = userOptional.getIncludeNull();
                    if (user != null) {
                        etUsername.setText(!TextUtils.isEmpty(user.displayName()) ? user.displayName() : user.name());
                        etUsername.setSelection(etUsername.getText().length());
                    }
                }, new ServerErrorHandler(TAG));

        etUsername.setFilters(StringUtils.DisableSpecialCharacters(StringUtils.USER_NAME_MAX_LENGTH));

        viewModel.outputs.changeResult()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(aBoolean -> {
                    if (aBoolean) {
                        finish();
                    } else {
                        Toast.makeText(UsernameActivity.this, R.string.error_network_unknown, Toast.LENGTH_SHORT).show();
                    }
                });

        viewModel.errors.alterError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(error -> Toast.makeText(UsernameActivity.this, error.getErrorMessage(), Toast.LENGTH_LONG).show());

        viewModel.errors.lowlevelError()
                .compose(bindToLifecycle())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(throwable -> NetworkErrorHelper.handleCommonError(UsernameActivity.this, throwable));
    }

    private void saveUsername() {
        String username = etUsername.getText().toString();
        if (TextUtils.isEmpty(username)) {
            Toast.makeText(this, R.string.username_empty, Toast.LENGTH_SHORT).show();
        } else {
            etUsername.clearFocus();
            toolbar.getMenu().findItem(R.id.save).setEnabled(false);
            viewModel.inputs.changeUsername(username);
        }
    }

    public void setupToolbar() {
        TextView tvTitle = findViewById(R.id.tv_toolbarTitle);
        tvTitle.setText(getResources().getString(R.string.username_title));
        toolbar.setNavigationOnClickListener(v -> finish());
    }
}
