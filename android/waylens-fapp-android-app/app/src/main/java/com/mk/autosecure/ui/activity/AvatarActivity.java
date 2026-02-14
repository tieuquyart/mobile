package com.mk.autosecure.ui.activity;

import static com.mk.autosecure.libs.utils.PermissionUtil.REQUEST_APP_SETTING;
import static com.mk.autosecure.ui.activity.LocalLiveActivity.PERMISSIONS_REQUESTCODE;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.PermissionChecker;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import android.widget.Toast;

import com.mk.autosecure.ui.view.ClipImageView;
import com.orhanobut.logger.Logger;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.ImageUtils;
import com.mk.autosecure.libs.utils.PermissionUtil;
import com.mk.autosecure.service.job.UploadAvatarJob;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by DoanVT on 2017/11/3.
 * Email: doanvt-hn@mk.com.vn
 */

public class AvatarActivity extends Activity {
    private final static String TAG = AvatarActivity.class.getSimpleName();
    private final static String PICK_FROM_CAMERA = "pick_from_camera";
    private final static int TAKE_PHOTO = 1;
    private final static int FROM_LOCAL = 2;

    private Uri mAvatarUri;

    private String mImgCachePath;

    private boolean fromCamera;

    private String mCroppedImagePath = null;

    private String mReturnImagePath = null;

    @BindView(R.id.civ_cropper_preview)
    ClipImageView mCivCropperPreview;

    @BindView(R.id.toolbar)
    Toolbar toolbar;

    public static void launch(Activity startActivity, boolean fromCamera) {
        Intent intent = new Intent(startActivity, AvatarActivity.class);
        intent.putExtra(PICK_FROM_CAMERA, fromCamera);
        startActivity.startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        fromCamera = intent.getBooleanExtra(PICK_FROM_CAMERA, false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED
                    || PermissionChecker.checkSelfPermission(this, Manifest.permission.CAMERA) != PermissionChecker.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.CAMERA}, PERMISSIONS_REQUESTCODE);
            } else {
                intentToPick();
            }
        } else {
            intentToPick();
        }
    }

    private void intentToPick() {
        mImgCachePath = ImageUtils.getAvatarUrl(this);
        if (fromCamera) {
            jump2TakePhoto();
        } else {
            jump2Picker();
        }
        init();
    }

    private void jump2TakePhoto() {
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);//临时授权
//        ContentValues values = new ContentValues(2);
//        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
        mAvatarUri = ImageUtils.getPictureUri(this);
        Logger.t(TAG).d(mAvatarUri.getPath());
        intent.putExtra(MediaStore.EXTRA_OUTPUT, mAvatarUri);
        startActivityForResult(intent, TAKE_PHOTO);
    }

    private void jump2Picker() {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        startActivityForResult(intent, FROM_LOCAL);
    }

    protected void init() {
        initViews();
    }

    private void initViews() {
        setContentView(R.layout.activity_avatar_picker);
        ButterKnife.bind(this);
        setupToolbar();
    }

    public void setupToolbar() {
        TextView tv_toolbarTitle = (TextView) findViewById(R.id.tv_toolbarTitle);
        if (tv_toolbarTitle != null) {
            tv_toolbarTitle.setText(getResources().getString(R.string.avatar_title));
        }
        getToolbar().setNavigationIcon(R.drawable.ic_back);
        getToolbar().setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Logger.t(TAG).e("onActivityResult: " + requestCode + "--" + resultCode);
        if (requestCode != REQUEST_APP_SETTING && resultCode == RESULT_CANCELED) {
            finish();
            return;
        }

        if (requestCode == TAKE_PHOTO) {
            Logger.t(TAG).d("Get photo: " + mAvatarUri);
            mReturnImagePath = ImageUtils.uriToFile(this,mAvatarUri).getAbsolutePath();
        } else if (requestCode == FROM_LOCAL) {
            Uri imageUri = data.getData();
            Logger.t(TAG).d("image selected path", imageUri.getPath());

            String[] projection = {MediaStore.Images.Media.DATA};
            Cursor cursor = getContentResolver().query(imageUri, projection, null, null, null);
            if (cursor != null) {
                int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                cursor.moveToFirst();
                mReturnImagePath = cursor.getString(column_index);
            }
        } else if (requestCode == REQUEST_APP_SETTING) {
            if (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED
                    && PermissionChecker.checkSelfPermission(this, Manifest.permission.CAMERA) == PermissionChecker.PERMISSION_GRANTED) {
                intentToPick();
            } else {
                finish();
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        }

        if (!TextUtils.isEmpty(mReturnImagePath)) {
            getToolbar().inflateMenu(R.menu.menu_avatar_confirm);
            getToolbar().setOnMenuItemClickListener(item -> {
                switch (item.getItemId()) {
                    case R.id.confirm:
                        String avatarPath = saveCroppedImage();
                        if (avatarPath != null) {
                            UploadAvatarJob job = new UploadAvatarJob(mCroppedImagePath);
                            HornApplication.getComponent().backgroundThreadPool().execute(job);
                        }
                        finish();
                        break;
                }
                return false;
            });
            new ExtractThumbTask(mReturnImagePath, 1536, 2048).execute();
        }
        super.onActivityResult(requestCode, resultCode, data);
    }


    private String saveCroppedImage() {
        Bitmap croppedImage = mCivCropperPreview.clip();
        if (croppedImage == null) {
            return null;
        }

        long now = System.currentTimeMillis();
        String photoId = String.format(Locale.ENGLISH, "%d.%03d", now / 1000, now % 1000);
        String fileName = photoId + ".jpg";
        mCroppedImagePath = mImgCachePath + "/" + fileName;
        try {
            FileOutputStream out = new FileOutputStream(mCroppedImagePath);
            Logger.t(TAG).d("try to compress file : " + mCroppedImagePath);
            if (croppedImage.compress(Bitmap.CompressFormat.JPEG, 60, out)) {
                out.flush();
            } else {
                ImageUtils.saveBitmap(croppedImage, mCroppedImagePath);
                Logger.t(TAG).d("try to save file : " + mCroppedImagePath);
            }
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        return ImageUtils.saveBitmap(croppedImage, mCroppedImagePath);
    }

    public class ExtractThumbTask extends AsyncTask<Object, Void, String> {
        String srcImgPath = null, dstImgPath = null;
        int reqWidth = 1536, reqHeight = 2048;
        Bitmap bmp = null;

        public ExtractThumbTask(String srcImgPath, int width, int height) {
            this.reqWidth = width;
            this.reqHeight = height;
            this.srcImgPath = srcImgPath;
        }

        protected void onPreExecute() {

        }

        @Override
        protected String doInBackground(Object... params) {
            long now = System.currentTimeMillis();
            String photoId = String.format(Locale.ENGLISH, "%d.%03d", now / 1000, now % 1000);
            String dstFileName = photoId + ".jpg";
            dstImgPath = mImgCachePath + "/" + dstFileName;
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            int orientation = -1;

            try {
                if (TextUtils.isEmpty(srcImgPath)) {
                    return null;
                }
                ExifInterface exif = new ExifInterface(srcImgPath);
                orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1);
                Logger.t(TAG).d("orientation:" + orientation);
            } catch (IOException e) {
                Logger.t(TAG).d(e.getMessage());
            }
            Bitmap bitmap = BitmapFactory.decodeFile(srcImgPath);
            Matrix m = new Matrix();
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    m.postRotate(90);
                    bmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), m, true);
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    m.postRotate(180);
                    bmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), m, true);
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    m.postRotate(270);
                    bmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), m, true);
                    break;
                default:
                    bmp = bitmap;
                    break;
            }
            if (bmp == null) {
                return null;
            }

            /**
             BitmapFactory.decodeFile(srcImgPath, options);
             int w = options.outWidth;
             int h = options.outHeight;**/
            int w = bmp.getWidth();
            int h = bmp.getHeight();
            int newW = w, newH = h;
            float ratio = 1;
            if (w <= h) {
                ratio = Math.max((float) w / reqWidth, (float) h / reqHeight);
            } else {
                ratio = Math.max((float) h / reqWidth, (float) w / reqHeight);
            }

            if (ratio < 1.0f) {
                ratio = 1;
            }
            newW = (int) (w / ratio);
            newH = (int) (h / ratio);

            // Decode bitmap with inSampleSize set
            options.inJustDecodeBounds = false;
            options.inSampleSize = 1;

            //bmp = BitmapFactory.decodeFile(srcImgPath, options);
            if (ratio > 1.0f) {
                bmp = ImageUtils.zoomBitmap(bmp, newW, newH);
            }

            return dstImgPath;
        }

        @Override
        protected void onPostExecute(String thumbFullPath) {
            mCivCropperPreview.setImageBitmap(bmp);
        }
    }

    private Toolbar getToolbar() {
        return toolbar;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_REQUESTCODE) {
            if (grantResults.length > 0 &&
                    grantResults[0] == PermissionChecker.PERMISSION_GRANTED &&
                    grantResults[1] == PermissionChecker.PERMISSION_GRANTED &&
                    grantResults[2] == PermissionChecker.PERMISSION_GRANTED) {

                intentToPick();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                    boolean storage = (PermissionChecker.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED)
                            && (PermissionChecker.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_GRANTED);
                    boolean camera = PermissionChecker.checkSelfPermission(this, Manifest.permission.CAMERA) == PermissionChecker.PERMISSION_GRANTED;

                    Logger.t(TAG).e("storage: " + storage);
                    Logger.t(TAG).e("camera: " + camera);

                    boolean showDialog = (!storage
                            && !shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                            && !shouldShowRequestPermissionRationale(Manifest.permission.READ_EXTERNAL_STORAGE))
                            || (!camera && !shouldShowRequestPermissionRationale(Manifest.permission.CAMERA));
                    Logger.t(TAG).d("showDialog: " + showDialog);
                    if (showDialog) {
                        DialogHelper.showPermissionDialog(this,
                                () -> PermissionUtil.startAppSetting(AvatarActivity.this),
                                this::finish);
                    } else {
                        finish();
                    }
                }
                Toast.makeText(this, getResources().getString(R.string.must_allow), Toast.LENGTH_LONG).show();
            }
        }
    }
}
