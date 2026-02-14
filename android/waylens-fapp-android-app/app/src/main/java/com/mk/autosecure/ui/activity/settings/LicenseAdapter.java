package com.mk.autosecure.ui.activity.settings;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.mk.autosecure.R;
import com.mkgroup.camera.message.bean.LicenseBean;

import java.util.List;

public class LicenseAdapter extends BaseAdapter {
    private Context context;
    private List<LicenseBean.Algorithm> licenseList;
    private LayoutInflater inflater;

    public LicenseAdapter(Context context, List<LicenseBean.Algorithm> licenseList) {
        this.context = context;
        this.licenseList = licenseList;
        this.inflater = LayoutInflater.from(context);
    }

    @Override
    public int getCount() {
        return licenseList.size();
    }

    @Override
    public Object getItem(int position) {
        return licenseList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;

        if (convertView == null) {
            convertView = inflater.inflate(R.layout.item_license, parent, false);
            holder = new ViewHolder();
            holder.tvLicenseName = convertView.findViewById(R.id.tvLicenseName);
            holder.etLicenseInput = convertView.findViewById(R.id.etLicenseInput);
            holder.tvErrorAlgorithm = convertView.findViewById(R.id.tvErrorAlgorithm);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        // Lấy dữ liệu của item hiện tại
        LicenseBean.Algorithm license = licenseList.get(position);

        // Gán giá trị cho TextView
        holder.tvLicenseName.setText(license.getName());
        holder.tvErrorAlgorithm.setText(license.getErrorAlgorithm());

        // Xử lý màu sắc errorAlgorithm
        if ("OK".equalsIgnoreCase(license.getErrorAlgorithm())) {
            holder.tvErrorAlgorithm.setTextColor(ContextCompat.getColor(context, android.R.color.holo_green_dark));
        } else {
            holder.tvErrorAlgorithm.setTextColor(ContextCompat.getColor(context, android.R.color.holo_red_dark));
        }

        // ⚠️ Tắt TextWatcher trước khi setText để tránh vòng lặp không mong muốn
        if (holder.etLicenseInput.getTag() instanceof TextWatcher) {
            holder.etLicenseInput.removeTextChangedListener((TextWatcher) holder.etLicenseInput.getTag());
        }

        // Set giá trị chính xác cho EditText
        holder.etLicenseInput.setText(license.getValue() != null ? license.getValue() : "");

        // Tạo mới TextWatcher cho mỗi EditText
        TextWatcher textWatcher = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                licenseList.get(position).setValue(s.toString()); // Cập nhật vào danh sách
            }

            @Override
            public void afterTextChanged(Editable editable) {}
        };

        // Gán lại TextWatcher cho EditText và lưu vào tag để tránh leak memory
        holder.etLicenseInput.addTextChangedListener(textWatcher);
        holder.etLicenseInput.setTag(textWatcher);

        return convertView;
    }

    // ViewHolder giúp tối ưu hiệu suất
    private static class ViewHolder {
        TextView tvLicenseName;
        EditText etLicenseInput;
        TextView tvErrorAlgorithm;
    }
}
