package com.mk.autosecure.libs.GPUImage;

import android.graphics.RectF;
import android.opengl.GLES20;
import android.opengl.Matrix;

import com.waylens.vrlib.objects.TwoDirectionsObject;

import java.nio.FloatBuffer;

import jp.co.cyberagent.android.gpuimage.GPUImageFilter;
import jp.co.cyberagent.android.gpuimage.OpenGlUtils;

import static com.waylens.mediatranscoder.engine.surfaces.GlUtil.checkGlError;

/**
 * Created by DoanVT on 2017/11/30.
 * Email: doanvt-hn@mk.com.vn
 */

public class TwoDirectionFilter extends GPUImageFilter {

    private final static String TAG = TwoDirectionFilter.class.getSimpleName();

    private static final String VERTEX_SHADER =
            "uniform mat4 uMVPMatrix;\n" +
                    "uniform mat4 uSTMatrix;\n" +
                    "attribute vec4 aPosition;\n" +
                    "attribute vec4 aTextureCoord;\n" +
                    "varying vec2 vTextureCoord;\n" +
                    "void main() {\n" +
                    "  gl_Position = uMVPMatrix * aPosition;\n" +
                    "  vTextureCoord = (uSTMatrix * aTextureCoord).xy;\n" +
                    "}\n";

    private static final String FRAGMENT_SHADER =
            "#extension GL_OES_EGL_image_external : require\n" +
                    "precision mediump float;\n" +      // highp here doesn't seem to matter
                    "varying vec2 vTextureCoord;\n" +
                    "uniform sampler2D sTexture;\n" +
                    "void main() {\n" +
                    "  gl_FragColor = texture2D(sTexture, vTextureCoord);\n" +
                    "}\n";

    private static final int sPositionDataSize = 3;
    private static final int sTextureCoordinateDataSize = 2;

    private float[] mMVPMatrix = new float[16];
    private float[] mSTMatrix = new float[16];
    private int mProgram;
    private int mTextureID = -12345;
    private int muMVPMatrixHandle;
    private int muSTMatrixHandle;
    private int maPositionHandle;
    private int maTextureHandle;

    private TwoDirectionsObject object3D;

    public TwoDirectionFilter(boolean lensNormal) {
        super(VERTEX_SHADER, FRAGMENT_SHADER);
        //RectF(0, 0, 2.0f, 2.0f) for compensate the VR lib
        object3D = new TwoDirectionsObject(new RectF(0, 0, 2.0f, 1.15f), lensNormal);
        object3D.generateMeshCompensateRotation(object3D);
        Matrix.setIdentityM(mSTMatrix, 0);
    }

    @Override
    public void onInit() {
        mGLProgId = OpenGlUtils.loadProgram(VERTEX_SHADER, FRAGMENT_SHADER);
        mProgram = mGLProgId;
        if (mProgram == 0) {
            throw new RuntimeException("failed creating program");
        }
        maPositionHandle = GLES20.glGetAttribLocation(mProgram, "aPosition");
        checkGlError("glGetAttribLocation aPosition");
        if (maPositionHandle == -1) {
            throw new RuntimeException("Could not get attrib location for aPosition");
        }
        maTextureHandle = GLES20.glGetAttribLocation(mProgram, "aTextureCoord");
        checkGlError("glGetAttribLocation aTextureCoord");
        if (maTextureHandle == -1) {
            throw new RuntimeException("Could not get attrib location for aTextureCoord");
        }
        muMVPMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uMVPMatrix");
        checkGlError("glGetUniformLocation uMVPMatrix");
        if (muMVPMatrixHandle == -1) {
            throw new RuntimeException("Could not get attrib location for uMVPMatrix");
        }
        muSTMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uSTMatrix");
        checkGlError("glGetUniformLocation uSTMatrix");
        if (muSTMatrixHandle == -1) {
            throw new RuntimeException("Could not get attrib location for uSTMatrix");
        }

        mGLUniformTexture = GLES20.glGetUniformLocation(mProgram, "sTexture");
        checkGlError("glGetUniformLocation sTexture");
        if (muSTMatrixHandle == -1) {
            throw new RuntimeException("Could not get uniform location for sTexture");
        }

        checkGlError("glTexParameter");

    }


    public void onOutputSizeChanged(final int width, final int height) {
        mOutputWidth = width;
        mOutputHeight = height;
    }

    @Override
    public void onDraw(final int textureId, final FloatBuffer cubeBuffer,
                       final FloatBuffer texture) {
        GLES20.glUseProgram(mGLProgId);
        runPendingOnDrawTasks();
        if (!isInitialized()) {
            return;
        }

        checkGlError("onDrawFrame start");
        GLES20.glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        GLES20.glClear(GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);
        GLES20.glUseProgram(mProgram);
        checkGlError("glUseProgram");
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
        GLES20.glUniform1i(mGLUniformTexture, 0);

        FloatBuffer vertexBuffer = object3D.getVerticesBuffer(0);
        if (vertexBuffer != null) {
            vertexBuffer.position(0);

            GLES20.glVertexAttribPointer(maPositionHandle, sPositionDataSize, GLES20.GL_FLOAT, false, 0, vertexBuffer);
            checkGlError("glEnableVertexAttribArray maPositionHandle");
            GLES20.glEnableVertexAttribArray(maPositionHandle);
            checkGlError("glEnableVertexAttribArray maPositionHandle");
        }


        FloatBuffer textureBuf = object3D.getTexCoordinateBuffer(0);
        if (textureBuf != null) {

            textureBuf.position(0);
            GLES20.glVertexAttribPointer(maTextureHandle, sTextureCoordinateDataSize, GLES20.GL_FLOAT, false, 0, textureBuf);
            checkGlError("glEnableVertexAttribArray maPositionHandle");
            GLES20.glEnableVertexAttribArray(maTextureHandle);
            checkGlError("glEnableVertexAttribArray maPositionHandle");
        }


        Matrix.setIdentityM(mMVPMatrix, 0);
        GLES20.glUniformMatrix4fv(muMVPMatrixHandle, 1, false, mMVPMatrix, 0);
        GLES20.glUniformMatrix4fv(muSTMatrixHandle, 1, false, mSTMatrix, 0);

        if (object3D.getIndicesBuffer() != null) {
            object3D.getIndicesBuffer().position(0);
            GLES20.glDrawElements(GLES20.GL_TRIANGLES, object3D.getNumIndices(), GLES20.GL_UNSIGNED_SHORT, object3D.getIndicesBuffer());
        } else {
            GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, object3D.getNumIndices());
        }

        checkGlError("glDrawArrays");
        GLES20.glFinish();
//        com.orhanobut.logger.Logger.t(TAG).d("finish");
    }

    protected void onDrawArraysPre() {
    }

    public int getOutputWidth() {
        return mOutputWidth;
    }

    public int getOutputHeight() {
        return mOutputHeight;
    }

    public int getProgram() {
        return mGLProgId;
    }

    public int getAttribPosition() {
        return mGLAttribPosition;
    }

    public int getAttribTextureCoordinate() {
        return mGLAttribTextureCoordinate;
    }

    public int getUniformTexture() {
        return mGLUniformTexture;
    }
}
