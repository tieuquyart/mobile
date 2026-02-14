package com.mk.autosecure.ui.activity.settings;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import android.widget.Toast;

import com.trello.rxlifecycle2.components.support.RxFragmentActivity;
import com.mk.autosecure.R;

import butterknife.BindView;
import butterknife.ButterKnife;

public class FenceRangeActivity extends RxFragmentActivity {

    private final static String TAG = FenceRangeActivity.class.getSimpleName();

    public final static String FENCE_RANGE = "fence_range";
    public final static int FENCE_RANGE_CODE = 1000;

    public static void launch(Fragment fragment, String range) {
        Intent intent = new Intent(fragment.getContext(), FenceRangeActivity.class);
        intent.putExtra(FENCE_RANGE, range);
        fragment.startActivityForResult(intent, FENCE_RANGE_CODE);
    }

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    @BindView(R.id.tv_toolbarTitle)
    TextView tvToolbarTitle;

    @BindView(R.id.et_fence_range)
    EditText etFenceRange;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fence_range);
        ButterKnife.bind(this);

        setupToolbar();
        initView();
    }

    private void initView() {
        tvToolbarTitle.setText(R.string.range);

        String radius = getIntent().getStringExtra(FENCE_RANGE);
        etFenceRange.setText(radius);
        etFenceRange.setInputType(InputType.TYPE_NUMBER_FLAG_DECIMAL);
    }

    private void setupToolbar() {
        toolbar.setNavigationOnClickListener(v -> finish());
        toolbar.inflateMenu(R.menu.username_save);
        toolbar.setOnMenuItemClickListener(item -> {
            if (item.getItemId() == R.id.save) {
                String trim = etFenceRange.getText().toString().trim();
                double range = Double.parseDouble(trim);
                if (range > 0 && range <= 500) {
                    Intent intent = new Intent();
                    intent.putExtra(FENCE_RANGE, trim);
                    setResult(RESULT_OK, intent);
                    finish();
                } else {
                    Toast.makeText(this, R.string.the_number_entered_exceeds_the_limit, Toast.LENGTH_SHORT).show();
                }
            }
            return false;
        });
    }
}
