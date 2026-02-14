package com.mkgroup.camera.db;

import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Generated;
import org.greenrobot.greendao.annotation.Id;
import org.greenrobot.greendao.annotation.Property;

import java.io.Serializable;

@Entity
public class VideoItem implements Serializable {

    static final long serialVersionUID = 42L;

    public static final String KEY_NEED_DEWARP = "needDewarp";

    @Id(autoincrement = true)
    private Long id;

    @Property(nameInDb = "createTime")
    private long createTime;

    @Property(nameInDb = "type")
    private int type;

    @Property(nameInDb = "location")
    private String location;

    @Property(nameInDb = "duration")
    private long duration;

    @Property(nameInDb = "rawVideoPath")
    private String rawVideoPath;

    @Property(nameInDb = "transcodeVideoPath")
    private String transcodeVideoPath;

    @Property(nameInDb = "lensMode")
    private String lensMode = "normal";

    @Property(nameInDb = "general")
    private String general;

    @Generated(hash = 451513972)
    public VideoItem(Long id, long createTime, int type, String location, long duration,
                     String rawVideoPath, String transcodeVideoPath, String lensMode, String general) {
        this.id = id;
        this.createTime = createTime;
        this.type = type;
        this.location = location;
        this.duration = duration;
        this.rawVideoPath = rawVideoPath;
        this.transcodeVideoPath = transcodeVideoPath;
        this.lensMode = lensMode;
        this.general = general;
    }

    @Generated(hash = 1427854055)
    public VideoItem() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public long getCreateTime() {
        return this.createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getLocation() {
        return this.location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getRawVideoPath() {
        return this.rawVideoPath;
    }

    public void setRawVideoPath(String rawVideoPath) {
        this.rawVideoPath = rawVideoPath;
    }

    public String getTranscodeVideoPath() {
        return this.transcodeVideoPath;
    }

    public void setTranscodeVideoPath(String transcodeVideoPath) {
        this.transcodeVideoPath = transcodeVideoPath;
    }

    public long getDuration() {
        return this.duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getLensMode() {
        return this.lensMode;
    }

    public void setLensMode(String lensMode) {
        this.lensMode = lensMode;
    }

    public String getGeneral() {
        return this.general;
    }

    public void setGeneral(String general) {
        this.general = general;
    }

    @Override
    public String toString() {
        return "VideoItem{" +
                "id=" + id +
                ", createTime=" + createTime +
                ", type=" + type +
                ", location='" + location + '\'' +
                ", duration=" + duration +
                ", rawVideoPath='" + rawVideoPath + '\'' +
                ", transcodeVideoPath='" + transcodeVideoPath + '\'' +
                ", lensMode='" + lensMode + '\'' +
                ", general='" + general + '\'' +
                '}';
    }
}
