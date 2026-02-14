package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.graphics.Bitmap;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.renderscript.Allocation;
import androidx.renderscript.Element;
import androidx.renderscript.RenderScript;
import androidx.renderscript.ScriptIntrinsicBlur;

/**
 * Created by doanvt on 2019/1/2.
 * Email：doanvt-hn@mk.com.vn
 */

public class GaussianBlurUtil {

    private RenderScript renderScript;

    public GaussianBlurUtil(@NonNull Context context) {
        this.renderScript = RenderScript.create(context);
    }

    public Bitmap gaussianBlur(@IntRange(from = 1, to = 25) int radius, Bitmap original) {
        //这里如果内存占用过多，可以降低图片尺寸，降低内存占用
        Bitmap bitmap = RGB565toARGB8888(original);

        Allocation input = Allocation.createFromBitmap(renderScript, bitmap);
        Allocation output = Allocation.createTyped(renderScript, input.getType());

        ScriptIntrinsicBlur intrinsicBlur = ScriptIntrinsicBlur.create(renderScript, Element.U8_4(renderScript));

        intrinsicBlur.setRadius(radius);

        intrinsicBlur.setInput(input);
        intrinsicBlur.forEach(output);

        output.copyTo(bitmap);

        input.destroy();
        output.destroy();
        renderScript.destroy();

        return bitmap;
    }

    private Bitmap RGB565toARGB8888(Bitmap original) {
        int numPixels = original.getWidth() * original.getHeight();
        int[] pixels = new int[numPixels];

        original.getPixels(pixels,
                0,
                original.getWidth(),
                0, 0,
                original.getWidth(), original.getHeight());

        Bitmap result = Bitmap.createBitmap(original.getWidth(), original.getHeight(), Bitmap.Config.ARGB_8888);

        result.setPixels(pixels,
                0,
                result.getWidth(),
                0, 0,
                result.getWidth(), result.getHeight());

        return result;
    }
}
