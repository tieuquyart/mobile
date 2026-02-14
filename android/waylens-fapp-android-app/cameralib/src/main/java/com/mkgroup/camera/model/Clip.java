package com.mkgroup.camera.model;

import android.os.Parcel;
import android.text.TextUtils;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.constant.VideoEventType;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.utils.DateTime;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.util.TimeZone;

public class Clip implements Serializable {
    public static final int TYPE_REAL = -1;
    public static final int TYPE_BUFFERED = 0;
    public static final int TYPE_MARKED = 1;

    public static final int TYPE_RACE = (1 << 7);
    public static final int MASK_RACE = 0x7f;

    public static final int TYPE_RACE_CD6T = 0;
    public static final int TYPE_RACE_CD3T = 1;
    public static final int TYPE_RACE_AU6T = 2;
    public static final int TYPE_RACE_AU3T = 4;
    public static final int TYPE_RACE_AU10T = 8;
    public static final int TYPE_RACE_QMILE = 16;

    public static final int TYPE_TEMP = 0x108;

    public static final int TYPE_RACE_AU03 = 0x1001;
    public static final int TYPE_RACE_CD03 = 0x1002;
    public static final int TYPE_RACE_AU06 = 0x1003;
    public static final int TYPE_RACE_CD06 = 0x1004;

    public static final int TYPE_RACE_AU10 = 0x1005;
    public static final int TYPE_RACE_CD10 = 0x1006;

    public static final int TYPE_RACE_AU13 = 0x1007;
    public static final int TYPE_RACE_AU15 = 0x1008;

    public static final int TYPE_RACE_AUEM = 0x1009;
    public static final int TYPE_RACE_CDEM = 0x100A;

    public static final int TYPE_RACE_AUQM = 0x100B;
    public static final int TYPE_RACE_CDQM = 0x100C;

    public static final int TYPE_RACE_AUHM = 0x100D;
    public static final int TYPE_RACE_CDHM = 0x100E;

    public static final int TYPE_RACE_AU1M = 0x100F;
    public static final int TYPE_RACE_CD1M = 0x1010;

    public static final int STREAM_MAIN = 0;
    public static final int STREAM_SUB = 1;
    public static final int STREAM_SUB_N = 2;

    public static final int CLIP_ATTR_LIVE = (1 << 0);    // live clip
    public static final int CLIP_ATTR_AUTO = (1 << 1);    // auto generated clip
    public static final int CLIP_ATTR_MANUALLY = (1 << 2);    // manually generated clip
    public static final int CLIP_ATTR_UPLOADED = (1 << 3);    // clip has been uploaded
    public static final int CLIP_ATTR_LIVE_MARK = (1 << 4);    // created by avf_camera_mark_live_clip()
    public static final int CLIP_ATTR_NO_AUTO_DELETE = (1 << 5);    // do not auto delete the clip is space is low

    public static final String LENS_NORMAL = "normal";
    public static final String LENS_UPSIDEDOWN = "upsidedown";


    // --------------------------------------------------------------
    // CAT_REMOTE:
    // 		type: clipType (buffered 0, marked 1, or plist_id >= 256)
    // 		subType: clipId (0 for plist_id)
    // 		extra: vdbId (for server) or null (for camera)
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // clip id
    // --------------------------------------------------------------
    public static final class ID implements Serializable {

        public int type; // clipType
        public final int subType; // clipID
        public String extra; // unique clip id in this cat/type

        private int hash = -1; // cache hash value

        @Override
        public int hashCode() {
            int result = type;
            result = 31 * result + subType;
            result = 31 * result + (extra != null ? extra.hashCode() : 0);
            result = 31 * result + hash;
            return result;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            ID id = (ID) o;

            if (type != id.type) return false;
            if (subType != id.subType) return false;
            if (hash != id.hash) return false;
            return extra != null ? extra.equals(id.extra) : id.extra == null;
        }

        public ID(int type, int subType, String extra) {
            this.type = type;
            this.subType = subType;
            this.extra = extra;
        }

        public void setType(int type) {
            this.type = type;
        }

        public void setExtra(String extra) {
            this.extra = extra;
            this.hash = -1;
        }

        @Override
        public String toString() {
            return "ID{" +
                    "type=" + type +
                    ", subType=" + subType +
                    ", extra='" + extra + '\'' +
                    ", hash=" + hash +
                    '}';
        }
    }


    public static final class StreamInfo implements Serializable {

        public int version;

        public byte video_coding;
        public byte video_framerate;
        public int video_width;
        public int video_height;

        public byte audio_coding;
        public byte audio_num_channels;
        public int audio_sampling_freq;

        public final boolean valid() {
            return version != 0;
        }

        @Override
        public String toString() {
            return "StreamInfo{" +
                    "version=" + version +
                    ", video_coding=" + video_coding +
                    ", video_framerate=" + video_framerate +
                    ", video_width=" + video_width +
                    ", video_height=" + video_height +
                    ", audio_coding=" + audio_coding +
                    ", audio_num_channels=" + audio_num_channels +
                    ", audio_sampling_freq=" + audio_sampling_freq +
                    '}';
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            StreamInfo that = (StreamInfo) o;

            if (version != that.version) return false;
            if (video_coding != that.video_coding) return false;
            if (video_framerate != that.video_framerate) return false;
            if (video_width != that.video_width) return false;
            if (video_height != that.video_height) return false;
            if (audio_coding != that.audio_coding) return false;
            if (audio_num_channels != that.audio_num_channels) return false;
            return audio_sampling_freq == that.audio_sampling_freq;
        }

        @Override
        public int hashCode() {
            int result = version;
            result = 31 * result + (int) video_coding;
            result = 31 * result + (int) video_framerate;
            result = 31 * result + (int) video_width;
            result = 31 * result + (int) video_height;
            result = 31 * result + (int) audio_coding;
            result = 31 * result + (int) audio_num_channels;
            result = 31 * result + audio_sampling_freq;
            return result;
        }
    }

    public class EditInfo implements Serializable {
        public ID bufferedCid;
        public ID realCid;
        public long minExtensibleValue;
        public long maxExtensibleValue;
        public long selectedStartValue;
        public long selectedEndValue;
        public long currentPosition;

        public EditInfo() {
            minExtensibleValue = getStartTimeMs();
            maxExtensibleValue = getStartTimeMs() + getDurationMs();
            selectedStartValue = minExtensibleValue;
            selectedEndValue = maxExtensibleValue;
            bufferedCid = cid;
            realCid = cid;
        }

        public int getSelectedLength() {
            return (int) (selectedEndValue - selectedStartValue);
        }

        @Override
        public String toString() {
            return "EditInfo{" +
                    "bufferedCid=" + bufferedCid +
                    ", realCid=" + realCid +
                    ", minExtensibleValue=" + minExtensibleValue +
                    ", maxExtensibleValue=" + maxExtensibleValue +
                    ", selectedStartValue=" + selectedStartValue +
                    ", selectedEndValue=" + selectedEndValue +
                    ", currentPosition=" + currentPosition +
                    '}';
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            EditInfo editInfo = (EditInfo) o;

            if (minExtensibleValue != editInfo.minExtensibleValue) return false;
            if (maxExtensibleValue != editInfo.maxExtensibleValue) return false;
            if (selectedStartValue != editInfo.selectedStartValue) return false;
            if (selectedEndValue != editInfo.selectedEndValue) return false;
            if (currentPosition != editInfo.currentPosition) return false;
            if (bufferedCid != null ? !bufferedCid.equals(editInfo.bufferedCid) : editInfo.bufferedCid != null)
                return false;
            return realCid != null ? realCid.equals(editInfo.realCid) : editInfo.realCid == null;
        }

        @Override
        public int hashCode() {
            int result = bufferedCid != null ? bufferedCid.hashCode() : 0;
            result = 31 * result + (realCid != null ? realCid.hashCode() : 0);
            result = 31 * result + (int) (minExtensibleValue ^ (minExtensibleValue >>> 32));
            result = 31 * result + (int) (maxExtensibleValue ^ (maxExtensibleValue >>> 32));
            result = 31 * result + (int) (selectedStartValue ^ (selectedStartValue >>> 32));
            result = 31 * result + (int) (selectedEndValue ^ (selectedEndValue >>> 32));
            result = 31 * result + (int) (currentPosition ^ (currentPosition >>> 32));
            return result;
        }
    }

    public static class LapTimerData implements Serializable {
        public double latitude;
        public double longitude;
        public long utcTime;
        public long utcTimeUsec;
        public float euler_heading;
        public int trackId;

        public LapTimerData(double latitude, double longitude, long utcTime, long utcTimeUsec, float euler_heading, int trackId) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.utcTime = utcTime;
            this.utcTimeUsec = utcTimeUsec;
            this.euler_heading = euler_heading;
            this.trackId = trackId;
        }

        @Override
        public String toString() {
            return "LapTimerData{" +
                    "latitude=" + latitude +
                    ", longitude=" + longitude +
                    ", utcTime=" + utcTime +
                    ", utcTimeUsec=" + utcTimeUsec +
                    ", euler_heading=" + euler_heading +
                    ", trackId=" + trackId +
                    '}';
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            LapTimerData that = (LapTimerData) o;

            if (Double.compare(that.latitude, latitude) != 0) return false;
            if (Double.compare(that.longitude, longitude) != 0) return false;
            if (utcTime != that.utcTime) return false;
            if (utcTimeUsec != that.utcTimeUsec) return false;
            if (Float.compare(that.euler_heading, euler_heading) != 0) return false;
            return trackId == that.trackId;
        }

        @Override
        public int hashCode() {
            int result;
            long temp;
            temp = Double.doubleToLongBits(latitude);
            result = (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(longitude);
            result = 31 * result + (int) (temp ^ (temp >>> 32));
            result = 31 * result + (int) (utcTime ^ (utcTime >>> 32));
            result = 31 * result + (int) (utcTimeUsec ^ (utcTimeUsec >>> 32));
            result = 31 * result + (euler_heading != +0.0f ? Float.floatToIntBits(euler_heading) : 0);
            result = 31 * result + trackId;
            return result;
        }
    }

    public ID cid;

    public ID realCid;

    public StreamInfo[] streams;

    public String[] descriptions; // [FRONT_HD("Road"), INCABIN_HD("In-cab"), STREAMING("Panorama"), DMS("Driver")]

    public int index;

    private int mClipDate;

    public int gmtOffset;

    private long mStartTimeMs;

    private int mDurationMs;

    private String mVin;

    private boolean mLensNormal = true;

    private boolean mNeedDewarp = false;

    public long clipSize = -1;

    public int videoType = -1;

    public ArrayList<Long> raceTimingPoints = null;

    public LapTimerData lapTimerData;

    public boolean bDeleting;

    public EditInfo editInfo;

    private int attr = 0;

    public String location;

    public Clip(Clip clip) {
        this(clip.cid.type, clip.cid.subType, clip.cid.extra, clip.streams.length, clip.mClipDate, clip.mStartTimeMs, clip.mDurationMs, clip.streams, clip.descriptions);
    }

    public Clip(int type, int subType, String extra, int numStreams, int clipDate, long statTimeMs, int duration) {
        this.cid = new ID(type, subType, extra);
        streams = new StreamInfo[numStreams];
        for (int i = 0; i < numStreams; i++) {
            streams[i] = new StreamInfo();
        }
        descriptions = new String[numStreams];
        this.mClipDate = clipDate;
        this.mStartTimeMs = statTimeMs;
        this.mDurationMs = duration;
        this.editInfo = new EditInfo();
        if (type == TYPE_BUFFERED) {
            videoType = VideoEventType.TYPE_BUFFERED;
        } else {
            videoType = VideoEventType.TYPE_HIGHLIGHT;
        }
    }

    public Clip(int type, int subType, String extra, int numStreams, int clipDate, long statTimeMs, int duration, StreamInfo[] streamInfo, String[] descriptions) {
        this.cid = new ID(type, subType, extra);

        streams = new StreamInfo[numStreams];
        for (int i = 0; i < numStreams; i++) {
            streams[i] = new StreamInfo();
            streams[i].version = streamInfo[i].version;
            streams[i].video_coding = streamInfo[i].video_coding;
            streams[i].video_framerate = streamInfo[i].video_framerate;
            streams[i].video_width = streamInfo[i].video_width;
            streams[i].video_height = streamInfo[i].video_height;
            streams[i].audio_coding = streamInfo[i].audio_coding;
            streams[i].audio_num_channels = streamInfo[i].audio_num_channels;
            streams[i].audio_sampling_freq = streamInfo[i].audio_sampling_freq;
        }

        this.descriptions = new String[numStreams];
        System.arraycopy(descriptions, 0, this.descriptions, 0, numStreams);

        this.mClipDate = clipDate;
        this.mStartTimeMs = statTimeMs;
        this.mDurationMs = duration;
        this.editInfo = new EditInfo();
    }

    public int getDurationMs() {
        return mDurationMs;
    }

    public void setDurationMs(int durationMs) {
        this.mDurationMs = durationMs;
    }

    public int getVideoType() {
        return videoType;
    }

    public void setVideoType(int type) {
        this.videoType = type;
    }

    public long getClipDateWithDST() {
        //return ((long) mClipDate) * 1000 - TimeZone.getDefault().getRawOffset() - TimeZone.getDefault().getDSTSavings();
        return getStandardClipDate();
    }

    public final String getDateTimeString() {
        return DateTime.toString(mClipDate, mStartTimeMs);
    }

    public String getDateString() {
        return DateTime.getDateString(mClipDate, 0);
    }

    public final String getTimeString() {
        return DateTime.getTimeString(mClipDate, 0);
    }

    public final String getWeekDayString() {
        return DateTime.getDayName(mClipDate, 0);
    }

    public StreamInfo getStream(int index) {
        return (index < 0 || index >= streams.length) ? null : streams[index];
    }

    public String getDescription(int index) {
        return (index < 0 || index >= descriptions.length) ? null : descriptions[index];
    }

    public int getDescriptionIndex(VideoStreamType streamType) {
        if (descriptions != null && streamType != null) {
            for (int i = 0; i < descriptions.length; i++) {
                if (!TextUtils.isEmpty(descriptions[i])
                        && descriptions[i].equals(streamType.streamType)) {
                    return i;
                }
            }
        }
        return 0;
    }

    public long getClipDate() {
        return ((long) mClipDate) * 1000 - TimeZone.getDefault().getRawOffset();
    }

    public long getClipDateRaw() {
        return ((long) mClipDate) * 1000;
    }

    public void setStartTime(long startTimeMs) {
        mStartTimeMs = startTimeMs;
        editInfo.selectedStartValue = Math.max(editInfo.selectedStartValue, mStartTimeMs);
    }

    public void setEndTime(long endTime) {
        mDurationMs = (int) (endTime - mStartTimeMs);
        editInfo.selectedEndValue = Math.min(editInfo.selectedEndValue, getEndTimeMs());
    }

    public long getStartTimeMs() {
        return mStartTimeMs;
    }

    public long getGMTAbsTime(long offset) {
        return mClipDate * 1000l + mStartTimeMs + offset - gmtOffset * 1000l;
    }

    public long getEndTimeMs() {
        return mStartTimeMs + mDurationMs;
    }

    public long getEndTimeMsAbs() {
        return getEndTimeMs() + getClipDateWithDST();
    }

    public long getStartTimeMsAbs() {
        return getStartTimeMs() + getClipDateWithDST();
    }

    public long getOffset() {
        return gmtOffset * 1000L;
    }

    public boolean contains(long timeMs) {
        return timeMs >= mStartTimeMs && timeMs < mStartTimeMs + mDurationMs;
    }

    public boolean isClipFullHd() {
        if (getStream(0).video_width > 1280) {
            return true;
        } else {
            return false;
        }
    }

    public String getVin() {
        return mVin;
    }

    public void setVin(String mVin) {
        this.mVin = mVin;
    }

    public boolean isLensNormal() {
        return mLensNormal;
    }

    public void setLensNormal(boolean mLensNormal) {
        this.mLensNormal = mLensNormal;
    }

    public boolean getNeedDewarp() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        if (currentCamera != null) {
            return currentCamera.getNeedDewarp();
        }
        return mNeedDewarp;
    }

    public void setNeedDewarp(boolean mNeedDewarp) {
        this.mNeedDewarp = mNeedDewarp;
    }

    public boolean isLiveRecording() {
        return (attr & 1) != 0;
    }

    public void setLiveAttr(int attr) {
        this.attr = attr;
    }

    // inherit
    public String getVdbId() {
        return cid.extra;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Clip clip = (Clip) o;
        return index == clip.index &&
                mClipDate == clip.mClipDate &&
                gmtOffset == clip.gmtOffset &&
                mStartTimeMs == clip.mStartTimeMs &&
                mDurationMs == clip.mDurationMs &&
                mLensNormal == clip.mLensNormal &&
                clipSize == clip.clipSize &&
                videoType == clip.videoType &&
                bDeleting == clip.bDeleting &&
                attr == clip.attr &&
                Objects.equals(cid, clip.cid) &&
                Objects.equals(realCid, clip.realCid) &&
                Arrays.equals(streams, clip.streams) &&
                Objects.equals(mVin, clip.mVin) &&
                Objects.equals(raceTimingPoints, clip.raceTimingPoints) &&
                Objects.equals(lapTimerData, clip.lapTimerData) &&
                Objects.equals(editInfo, clip.editInfo) &&
                Objects.equals(location, clip.location);
    }

    @Override
    public int hashCode() {
        int result = Objects.hash(cid, realCid, index, mClipDate, gmtOffset, mStartTimeMs, mDurationMs, mVin, mLensNormal, clipSize, videoType, raceTimingPoints, lapTimerData, bDeleting, editInfo, attr, location);
        result = 31 * result + Arrays.hashCode(streams);
        return result;
    }

    @Override
    public String toString() {
        return "Clip{" +
                "cid=" + cid +
                ", realCid=" + realCid +
                ", streams=" + Arrays.toString(streams) +
                ", index=" + index +
                ", mClipDate=" + mClipDate +
                ", gmtOffset=" + gmtOffset +
                ", mStartTimeMs=" + mStartTimeMs +
                ", mDurationMs=" + mDurationMs +
                ", mVin='" + mVin + '\'' +
                ", mLensNormal=" + mLensNormal +
                ", clipSize=" + clipSize +
                ", videoType=" + videoType +
                ", raceTimingPoints=" + raceTimingPoints +
                ", lapTimerData=" + lapTimerData +
                ", bDeleting=" + bDeleting +
                ", editInfo=" + editInfo +
                ", attr=" + attr +
                ", location='" + location + '\'' +
                '}';
    }

    //录制时间(零时区时间)
    public long getStandardClipDate() {
        return (mClipDate - gmtOffset) * 1000l;
    }

    public int describeContents() {
        return 0;
    }

    public void writeToParcel(Parcel dest, int flags) {
        write(dest, cid);
        write(dest, realCid);
        write(dest, streams);
        write(dest, editInfo);
        dest.writeInt(index);
        dest.writeInt(mClipDate);
        dest.writeInt(gmtOffset);
        dest.writeLong(mStartTimeMs);
        dest.writeInt(mDurationMs);
        dest.writeLong(clipSize);
        if (bDeleting) {
            dest.writeByte((byte) 1);
        } else {
            dest.writeByte((byte) 0);
        }
    }

    void write(Parcel dest, ID id) {
        if (id != null) {
            dest.writeInt(0); // means id is not null
            dest.writeInt(id.type);
            dest.writeInt(id.subType);
            if (id.extra != null) {
                dest.writeInt(0); // extra is not null
                dest.writeString(id.extra);
            } else {
                dest.writeInt(-1); // extra is null
            }
        } else {
            dest.writeInt(-1); //means id is null
        }
    }

    void write(Parcel dest, StreamInfo[] streamInfos) {
        if (streamInfos == null) {
            dest.writeInt(-1);
        } else {
            dest.writeInt(streamInfos.length);
            for (StreamInfo streamInfo : streamInfos) {
                dest.writeInt(streamInfo.version);
                dest.writeByte(streamInfo.video_coding);
                dest.writeByte(streamInfo.video_framerate);
                dest.writeInt(streamInfo.video_width);
                dest.writeInt(streamInfo.video_height);
                dest.writeByte(streamInfo.audio_coding);
                dest.writeByte(streamInfo.audio_num_channels);
                dest.writeInt(streamInfo.audio_sampling_freq);
            }
        }
    }

    private void write(Parcel dest, EditInfo editInfo) {
        if (editInfo == null) {
            dest.writeInt(-1);
        } else {
            dest.writeLong(editInfo.minExtensibleValue);
            dest.writeLong(editInfo.maxExtensibleValue);
            dest.writeLong(editInfo.selectedStartValue);
            dest.writeLong(editInfo.selectedEndValue);
            dest.writeLong(editInfo.currentPosition);
        }
    }

    private Clip(Parcel in) {
        cid = readID(in);
        realCid = readID(in);
        streams = readStreams(in);
        editInfo = readEditInfo(in);
        index = in.readInt();
        mClipDate = in.readInt();
        gmtOffset = in.readInt();
        mStartTimeMs = in.readLong();
        mDurationMs = in.readInt();
        clipSize = in.readLong();
        bDeleting = in.readByte() == 1;
        editInfo = new EditInfo();
    }

    ID readID(Parcel in) {
        if (in.readInt() != 0) {
            return null;
        }
        int type = in.readInt();
        int subType = in.readInt();
        int hasExtra = in.readInt();
        String extra;
        if (hasExtra == 0) {
            extra = in.readString();
        } else {
            extra = null;
        }
        return new ID(type, subType, extra);
    }

    StreamInfo[] readStreams(Parcel in) {
        int length = in.readInt();
        if (length == -1) {
            return null;
        }
        StreamInfo[] infos = new StreamInfo[length];
        for (int i = 0; i < length; i++) {
            StreamInfo streamInfo = new StreamInfo();

            streamInfo.version = in.readInt();
            streamInfo.video_coding = in.readByte();
            streamInfo.video_framerate = in.readByte();
            streamInfo.video_width = (short) in.readInt();
            streamInfo.video_height = (short) in.readInt();
            streamInfo.audio_coding = in.readByte();
            streamInfo.audio_num_channels = in.readByte();
            streamInfo.audio_sampling_freq = in.readInt();
            infos[i] = streamInfo;
        }
        return infos;
    }

    private EditInfo readEditInfo(Parcel in) {
        EditInfo editInfo = new EditInfo();
        editInfo.minExtensibleValue = in.readLong();
        editInfo.maxExtensibleValue = in.readLong();
        editInfo.selectedStartValue = in.readLong();
        editInfo.selectedEndValue = in.readLong();
        editInfo.currentPosition = in.readLong();
        return editInfo;
    }
}
