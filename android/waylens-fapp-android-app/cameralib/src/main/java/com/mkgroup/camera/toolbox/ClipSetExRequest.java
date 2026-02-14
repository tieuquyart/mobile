package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipSet;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.constant.VideoEventType;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

import org.apache.mina.core.buffer.IoBuffer;

import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;


/**
 * Created by doanvt on 2015/8/18.
 */
public class ClipSetExRequest extends VdbRequest<ClipSet> {
    public static final int FLAG_UNKNOWN = -1;
    public static final int FLAG_CLIP_EXTRA = 1;
    //    public static final int FLAG_CLIP_VDB_ID = 1 << 1;
    public static final int FLAG_CLIP_DESC = 1 << 2;
    public static final int FLAG_CLIP_ATTR = 1 << 3;
    //    public static final int FLAG_CLIP_SIZE = 1 << 4;
    public static final int FLAG_CLIP_SCENE_DATA = 1 << 5;
    //    public static final int FLAG_CLIP_RAW_FREQ = 1 << 6;
    public static final int FLAG_CLIP_RAW_FCC = 1 << 7;
    //    public static final int FLAG_CLIP_DATE_OFF = 1 << 8;
    public static final int FLAG_CLIP_VIDEO_TYPE = 1 << 9;
    public static final int FLAG_CLIP_VIDEO_DESCR = 1 << 10;
    static final int METHOD_GET = 0;
    static final int METHOD_SET = 1;
    private final static String TAG = ClipSetExRequest.class.getSimpleName();
    private static final int UUID_LENGTH = 36;
    private final int mClipType;
    private final int mFlag;
    private final int mAttr;

    public ClipSetExRequest(int type, int flag, VdbResponse.Listener<ClipSet> listener,
                            VdbResponse.ErrorListener errorListener) {
        this(METHOD_GET, type, flag, 0, listener, errorListener);
    }

    public ClipSetExRequest(int type, int flag, int attr, VdbResponse.Listener<ClipSet> listener,
                            VdbResponse.ErrorListener errorListener) {
        this(METHOD_GET, type, flag, attr, listener, errorListener);
    }

    private ClipSetExRequest(int method, int type, int flag, int attr, VdbResponse.Listener<ClipSet> listener,
                             VdbResponse.ErrorListener errorListener) {
        super(method, listener, errorListener);
        this.mClipType = type;
        this.mAttr = attr;
        this.mFlag = flag;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        if (mMethod == METHOD_GET) {
            mVdbCommand = VdbCommand.Factory.createCmdGetClipSetInfoEx(mClipType, mFlag);
        }
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<ClipSet> parseVdbResponse(VdbAcknowledge response) {
        switch (mMethod) {
            case METHOD_GET:
                try {
                    return parseGetClipSetResponse(response);
                } catch (Exception e) {
                    //java.lang.IllegalArgumentException: Bad position 48504/569
                    Logger.t(TAG).e("parse clip set failed!" + e.toString());
                }
                break;
            case METHOD_SET:
                break;
        }
        return null;
    }

    private VdbResponse<ClipSet> parseGetClipSetResponse(VdbAcknowledge response) {
        int msgIndex = response.getMsgIndex();
        IoBuffer ioBuffer = IoBuffer.wrap(response.getByteBuffer(), msgIndex, response.getByteBuffer().length - msgIndex);
        ioBuffer.order(ByteOrder.LITTLE_ENDIAN);
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("ackGetClipSetInfo failed: " + retCode);
            return null;
        }

        // vdb_cmd.h vdb_ack_GetClipSetInfoEx_s
        ClipSet clipSet = new ClipSet(ioBuffer.getInt()); // clip_type
        int totalClips = ioBuffer.getInt(); // total_clips
        ioBuffer.getInt(); // total_length_ms
        Clip.ID liveClipId = new Clip.ID(Clip.TYPE_BUFFERED, ioBuffer.getInt(), null); // live_clip_id
        clipSet.setLiveClipId(liveClipId);

        // vdb_cmd.h vdb_clip_info_ex_s
        try {
            for (int i = 0; i < totalClips; i++) {
                Clip clip = readClipInfo(ioBuffer);
                clipSet.addClip(clip);
            }
        } catch (Exception e) {
            Logger.t(TAG).e("readClipInfo exception: " + e.getMessage());
        }
        return VdbResponse.success(clipSet);
    }

    static int makeFourCC(char first, char second, char third, char fourth) {
        return (first << 24) + (second << 16) + (third << 8) + fourth;
    }

    static void readStreamInfo(Clip clip, int index, IoBuffer ioBuffer) {
        // avf_std_media.h avf_stream_attr_s
        Clip.StreamInfo info = clip.streams[index];
        info.version = ioBuffer.getInt(); // stream_version video_version audio_version extra_size
        info.video_coding = ioBuffer.get(); // video_coding
        info.video_framerate = ioBuffer.get(); // video_framerate
        info.video_width = ioBuffer.getUnsignedShort(); // video_width
        info.video_height = ioBuffer.getUnsignedShort(); // video_height
        info.audio_coding = ioBuffer.get(); // audio_coding
        info.audio_num_channels = ioBuffer.get(); // audio_num_channels
        info.audio_sampling_freq = ioBuffer.getInt(); // audio_sampling_freq
    }

    static Clip readClipInfo(IoBuffer ioBuffer) {
        // vdb_cmd.h vdb_clip_info_s
        int clipId = ioBuffer.getInt(); // clip_id
        int clipDate = ioBuffer.getInt(); // clip_date
        int duration = ioBuffer.getInt(); // clip_duration_ms
        long startTimeMs = ioBuffer.getLong(); // clip_start_time_ms

        int numStreams = ioBuffer.getUnsignedShort(); // num_streams
        Clip clip = new Clip(0, clipId, null, numStreams, clipDate, startTimeMs, duration);

        int flag = ioBuffer.getUnsignedShort(); // flags
//            Logger.t(TAG).d("Flag: " + flag);

        if (numStreams > 0) {
            readStreamInfo(clip, 0, ioBuffer);
            if (numStreams > 1) {
                readStreamInfo(clip, 1, ioBuffer);
                if (numStreams > 2) {
                    readStreamInfo(clip, 2, ioBuffer);
                    if (numStreams > 3) {
                        readStreamInfo(clip, 3, ioBuffer);
                    }
                }
            }
        }

        int clipType = ioBuffer.getInt(); // clip_type
        if (clipType == 0) {
            clip.setVideoType(0);
        } else {
            clip.setVideoType(6);
        }
        clip.cid.setType(clipType);

        int extraSize = ioBuffer.getInt(); // extra_size
        ioBuffer.mark();
        //int offsetSize = 0;

        if ((flag & FLAG_CLIP_EXTRA) > 0) {
            byte[] bytes = new byte[UUID_LENGTH];
            ioBuffer.get(bytes);
            String guid = new String(bytes);
            clip.cid.setExtra(guid);

            ioBuffer.getInt(); //int ref_clip_date
            clip.gmtOffset = ioBuffer.getInt();
            int realClipId = ioBuffer.getInt(); //int real_clip_id
            clip.realCid = new Clip.ID(Clip.TYPE_BUFFERED, realClipId, guid);
        }

//            if ((flag & FLAG_CLIP_VDB_ID) > 0) {
//                String extraString = "";
//
//                int size = ioBuffer.getInt();
//                if (size <= 0) {
//                    extraString = "";
//                } else {
//                    byte[] bytes = new byte[size];
//                    ioBuffer.get(bytes, 0, size);
//                    extraString = new String(bytes, StandardCharsets.US_ASCII);
//                    if ((size % 4) != 0) {
//                        ioBuffer.skip(4 - (size % 4));
//                    }
//                }
//                clip.cid.setExtra(extraString);
//            }

        if ((flag & FLAG_CLIP_DESC) > 0) {
            do {
                int fcc = ioBuffer.getInt();
                if (fcc == 0)
                    break;
                int dataSize = ioBuffer.getInt();
                int alignSize;
                //Logger.t(TAG).d(fcc + " + " + (('0' << 24) + ('N' << 16) + ('I' << 8) + 'V'));
                if (fcc == (('0' << 24) + ('N' << 16) + ('I' << 8) + 'V')) {
                    //Logger.t(TAG).d("dataSize:" + dataSize);
                    String vin;
                    byte[] bytes = new byte[dataSize];
                    ioBuffer.get(bytes);
                    vin = new String(bytes, StandardCharsets.US_ASCII);
                    clip.setVin(vin);
//                        Logger.t(TAG).d(vin);
                    alignTo4nBytes(ioBuffer);
//                    alignSize = ((dataSize + 3) / 4) * 4;
                    //Logger.t(TAG).d("offset size:" + offsetSize);
//                    ioBuffer.skip(alignSize - dataSize);
                } else if (fcc == (('C' << 24) + ('N' << 16) + ('I' << 8) + 'V')) {
                    //Logger.t(TAG).d("dataSize:" + dataSize);

                    //vin_config_info_s
                    byte version = ioBuffer.get();

                    byte bits = ioBuffer.get();
                    byte mirror_horizontal = ioBuffer.get();
                    byte mirror_vertical = ioBuffer.get();
                    byte hdr_mode = ioBuffer.get();
                    byte enc_mode = ioBuffer.get();
                    byte anti_flicker = ioBuffer.get();
                    byte exposure = ioBuffer.get();

                    byte[] dev_name = new byte[8];
                    ioBuffer.get(dev_name);
                    int source_id = ioBuffer.getInt();
                    int video_mode = ioBuffer.getInt();
                    int fps_q9 = ioBuffer.getInt();

//                        Logger.t(TAG).d("hdr_mode: " + hdr_mode);

                    alignTo4nBytes(ioBuffer);
//                    alignSize = ((dataSize + 3) / 4) * 4;
                    //Logger.t(TAG).d("offset size:" + offsetSize);
//                    ioBuffer.skip(alignSize - dataSize);
                } else if (fcc == (('I' << 24) + ('S' << 16) + ('Y' << 8) + 'S')) {
//                        Logger.t(TAG).d("dataSize:" + dataSize);

                    int sysi_offset = 0;
                    do {
                        int tempFcc = ioBuffer.getInt();
                        if (tempFcc == 0)
                            break;

                        int version = ioBuffer.getUnsignedShort();
                        byte type = ioBuffer.get();
                        byte flags = ioBuffer.get();

                        int item_size = ioBuffer.getInt();

                        int i1 = ('I' << 24) + ('T' << 16) + ('T' << 8) + 'A';

                        byte[] data = new byte[item_size];

                        if (type == 2) {
                            int i32_value = ioBuffer.getInt();
                        } else if (type == 3) {
                            long i64_value = ioBuffer.getLong();
                        } else if (type == 4) {
                            double d_value = ioBuffer.getDouble();
                        } else {
                            ioBuffer.get(data);
                            int position = ioBuffer.position();
                            //align_to_4n_bytes 4n对齐
                            int sub = 4 - position % 4;
                            if (sub != 4) {
                                byte[] padding = new byte[sub];
                                ioBuffer.get(padding);
                            }
                        }

                        if (tempFcc == i1) {
                            String attitude = new String(data, StandardCharsets.US_ASCII).trim();
                            clip.setLensNormal(Clip.LENS_NORMAL.equals(attitude));
//                                Logger.t(TAG).d("attitude: " + attitude);
                        }

                        sysi_offset += item_size + 12;
                        if (sysi_offset + 12 > dataSize) {
                            break;
                        }

                    } while (true);

                    alignTo4nBytes(ioBuffer);
//                    alignSize = ((dataSize + 3) / 4) * 4;
                    //Logger.t(TAG).d("offset size:" + offsetSize);
//                    ioBuffer.skip(alignSize - dataSize);
                } else {
                    ioBuffer.skip(dataSize);
                    alignTo4nBytes(ioBuffer);
//                    alignSize = ((dataSize + 3) / 4) * 4;
                    //Logger.t(TAG).d("offset size:" + offsetSize);
//                    ioBuffer.skip(alignSize - dataSize);
                }
            } while (true);
        }

        boolean attrMatch = true;
        if ((flag & FLAG_CLIP_ATTR) > 0) {
            //Logger.t(TAG).d("flag : " + flag );
            int attr = ioBuffer.getInt();
            if ((attr & 1) != 0) {
                //live recording
                attrMatch = true;
                clip.setLiveAttr(attr);
            }
        }

        if ((flag & FLAG_CLIP_SCENE_DATA) > 0) {
            int dataSize = ioBuffer.getInt();
            int fcc = 0;
            fcc = ioBuffer.getInt();
//                Logger.t(TAG).d((char) (fcc & 0xff) + " " + " " + (char) ((fcc >> 8) & 0xff) + (char) ((fcc >> 16) & 0xff) + " " + (char) ((fcc >> 24) & 0xff));
            if (fcc == makeFourCC('P', 'a', 'r', 'k')) {
                int datasize = ioBuffer.getInt();
                if (datasize >= 4) {
                    int wakeType = ioBuffer.getInt();

                    Video_Event_Type[] values = Video_Event_Type.values();
                    if (wakeType < values.length) {
                        int videoType = values[wakeType].type;
                        clip.setVideoType(videoType);
                    }

                    ioBuffer.skip(4);

                    double date = ioBuffer.getDouble();

                    int level = ioBuffer.get();// VIDEO_EVENT_LEVEL

                    byte[] reserved = new byte[7];
                    ioBuffer.get(reserved);// reserved

                    int remain = datasize - 24;
                    if (remain >= 40) {
                        byte[] chars = new byte[40];
                        ioBuffer.get(chars);
                    }

                    alignTo4nBytes(ioBuffer);

//                        Logger.t(TAG).d("wake type = " + wakeType);
//                        Logger.t(TAG).d("video type = " + videoType);
                }
            } else if (fcc == makeFourCC('E', 'V', 'N', 'T')) {
                int datasize = ioBuffer.getInt();
                if (datasize >= 4) {
                    int type = ioBuffer.getInt(); // VIDEO_EVENT_TYPE

                    Video_Event_Type[] values = Video_Event_Type.values();
                    if (type < values.length) {
                        int videoType = values[type].type;
                        clip.setVideoType(videoType);
                    }

                    ioBuffer.skip(4);

                    double date = ioBuffer.getDouble();

                    int level = ioBuffer.get();// VIDEO_EVENT_LEVEL
                    if (level == VIDEO_EVENT_LEVEL_HARSH) {
                        if (clip.getVideoType() == VideoEventType.TYPE_HARD_ACCEL) {
                            clip.setVideoType(VideoEventType.TYPE_HARSH_ACCEL);
                        } else if (clip.getVideoType() == VideoEventType.TYPE_HARD_BRAKE) {
                            clip.setVideoType(VideoEventType.TYPE_HARSH_BRAKE);
                        } else if (clip.getVideoType() == VideoEventType.TYPE_SHARP_TURN) {
                            clip.setVideoType(VideoEventType.TYPE_HARSH_TURN);
                        }
                    } else if (level == VIDEO_EVENT_LEVEL_SEVERE) {
                        if (clip.getVideoType() == VideoEventType.TYPE_HARD_ACCEL) {
                            clip.setVideoType(VideoEventType.TYPE_SEVERE_ACCEL);
                        } else if (clip.getVideoType() == VideoEventType.TYPE_HARD_BRAKE) {
                            clip.setVideoType(VideoEventType.TYPE_SEVERE_BRAKE);
                        } else if (clip.getVideoType() == VideoEventType.TYPE_SHARP_TURN) {
                            clip.setVideoType(VideoEventType.TYPE_SEVERE_TURN);
                        }
                    }

                    byte[] reserved = new byte[7];
                    ioBuffer.get(reserved);// reserved

                    int remain = datasize - 24;
                    if (remain >= 40) {
                        byte[] chars = new byte[40];
                        ioBuffer.get(chars);
                    }

                    alignTo4nBytes(ioBuffer);
                }
            } else if (fcc == makeFourCC('D', 'M', 'S', 'E')) {
                int datasize = ioBuffer.getInt(); // 新版固件这个值貌似有问题（包括了dataSize的四个字节）
                if (datasize >= 4) {
                    int status = ioBuffer.getInt(); // DMS_STATUS
//                    Logger.t(TAG).d("status: " + status);

                    ioBuffer.skip(4);
                    double date = ioBuffer.getDouble();

                    int level = ioBuffer.get();// VIDEO_EVENT_LEVEL
//                    Logger.t(TAG).d("level: " + level);

                    byte[] reserved = new byte[7];
                    ioBuffer.get(reserved);// reserved

                    int remain = datasize - 24;
                    if (remain >= 40) {
                        byte[] chars = new byte[40];
                        ioBuffer.get(chars);
                    }

                    alignTo4nBytes(ioBuffer);
                }
            }
        }

        if ((flag & FLAG_CLIP_RAW_FCC) > 0) {
            int num_fcc = ioBuffer.getInt();
            if (num_fcc != 1 && num_fcc != 0) {
                Logger.t(TAG).d("num_fcc: " + num_fcc + " " + clipId);
            }
            if (num_fcc != 0) {
                for (int i = 0; i < num_fcc; i++) {
                    int fcc = ioBuffer.getInt();
                    //                Logger.t(TAG).d((char) (fcc & 0xff) + " " + " " + (char) ((fcc >> 8) & 0xff) + (char) ((fcc >> 16) & 0xff) + " " + (char) ((fcc >> 24) & 0xff));
                }
            }
        }

        if ((flag & FLAG_CLIP_VIDEO_TYPE) > 0) {
            for (int k = 0; k < numStreams; k++) {
                ioBuffer.get();
                byte[] bytes = new byte[3];
                ioBuffer.get(bytes);
            }
        }

        if ((flag & FLAG_CLIP_VIDEO_DESCR) > 0) {
            for (int j = 0; j < numStreams; j++) {
                int descr_len = ioBuffer.getInt();
                int pos = ioBuffer.position();
                int markValue = ioBuffer.markValue();

                if (descr_len != 0 && descr_len < (markValue + extraSize - pos)) {
                    byte[] bytes = new byte[descr_len];
                    ioBuffer.get(bytes);
                    String des = new String(bytes);
                    clip.descriptions[j] = des;

                    alignTo4nBytes(ioBuffer);
                }
            }
        }

        ioBuffer.reset();
        ioBuffer.skip(extraSize);

        return clip;
    }

    static void alignTo4nBytes(IoBuffer ioBuffer) {
        int position = ioBuffer.position();
        //align_to_4n_bytes 4n对齐
        int sub = 4 - position % 4;
        if (sub != 4) {
            byte[] padding = new byte[sub];
            ioBuffer.get(padding);
        }
    }

    enum Video_Event_Type {
        NULL(0),
        Motion(1),         // radar
        Park_light(2),     // high sensitive
        Park_heavy(3),     // low sensitive, serious event

        Drive_light(4),    // high sensitive, only for backwards compatible
        Drive_heavy(5),    // low sensitive, seriout event

        Hard_Accel(7),
        Hard_Brake(8),
        Sharp_Turn(9),

        Harsh_Accel(10),
        Harsh_Brake(11),
        Harsh_Turn(12),

        Severe_Accel(13),
        Severe_Brake(14),
        Severe_Turn(15);

        int type;

        Video_Event_Type(int i) {
            this.type = i;
        }
    }

    enum DMS_STATUS {

        DMS_unknown(0),
        DMS_noDriver(1), // NO_DRIVER
        DMS_normal(2),
        //
        DMS_drowsiness(5), // DROWSINESS
        DMS_phoneCall(6), // USING_PHONE
        DMS_drinking(7),
        DMS_smoking(8), // SMOKING
        //
        DMS_asleep(9), // ASLEEP
        DMS_daydreaming(10), // DAYDREAMING
        DMS_yawn(11), // YAWN
        DMS_distracted(12), // DISTRACTED
        DMS_attentive(13),
        //
        DMS_noSeatBelt(14); // NO_SEATBELT

        int status;

        DMS_STATUS(int status) {
            this.status = status;
        }
    }

//    public static final int VIDEO_EVENT_LEVEL_DEFAULT = 0;

//    public static final int VIDEO_EVENT_LEVEL_HARD = 1;

    private static final int VIDEO_EVENT_LEVEL_HARSH = 2;

    private static final int VIDEO_EVENT_LEVEL_SEVERE = 3;

}
