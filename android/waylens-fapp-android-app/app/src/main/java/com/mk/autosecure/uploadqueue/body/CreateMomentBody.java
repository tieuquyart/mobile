package com.mk.autosecure.uploadqueue.body;

import android.text.TextUtils;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.utils.ToStringUtils;
import com.mk.autosecure.uploadqueue.entities.LocalMoment;
import com.mk.autosecure.uploadqueue.utils.SettingHelper;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Created by doanvt on 2016/6/17.
 */
public class CreateMomentBody {
    public String title;

    public String desc;

    public List<String> hashTags;

    public String accessLevel;

    public Map<String, String> overlay;

    public int audioType;

    public String musicSource;

    public List<String> shareProviders = new ArrayList<>();

    public Map<String, String> shareParameters = new HashMap<>();

    public String vehicleMaker = null;

    public String vehicleModel = null;

    public int vehicleYear;

    public String vehicleDesc = null;

    public TimingPointsList timingPoints = null;

    public String momentType = null;

    public boolean withGeoTag;

    public GeoInfo geoInfo;

    public LapInfo lapInfo;

    public CreateMomentBody() {

    }

    public CreateMomentBody(LocalMoment localMoment) {
        this.title = localMoment.title;
        //this.desc = localMoment.description;
        this.accessLevel = localMoment.accessLevel;
        this.overlay = localMoment.gaugeSettings;

        if (!TextUtils.isEmpty(localMoment.momentType) && localMoment.momentType.startsWith("RACING")) {
            momentType = localMoment.momentType;
            timingPoints = new TimingPointsList();
            for (long t : localMoment.mTimingPoints) {
                Logger.d(t);
            }
            if (localMoment.raceType < Clip.TYPE_RACE_AU03) {
                for (int i = 0; i < localMoment.mTimingPoints.size(); i++) {
                    try {
                        Field field = TimingPointsList.class.getDeclaredField("t" + (i + 1));
                        field.set(timingPoints, localMoment.mTimingPoints.get(i) > 0 ? localMoment.mTimingPoints.get(i) : null);
                    } catch (Exception e) {
                        Logger.d(e.getMessage());
                    }
                }
            } else {
                switch (localMoment.raceType) {
                    case Clip.TYPE_RACE_AU03:
                    case Clip.TYPE_RACE_CD03:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t3 = localMoment.mTimingPoints.get(1);
                        timingPoints.t4 = localMoment.mTimingPoints.get(2);
                        break;
                    case Clip.TYPE_RACE_AU06:
                    case Clip.TYPE_RACE_CD06:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t3 = localMoment.mTimingPoints.get(1);
                        timingPoints.t4 = localMoment.mTimingPoints.get(2);
                        timingPoints.t5 = localMoment.mTimingPoints.get(3);
                        timingPoints.t6 = localMoment.mTimingPoints.get(4);
                        break;
                    case Clip.TYPE_RACE_AU10:
                    case Clip.TYPE_RACE_CD10:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t5 = localMoment.mTimingPoints.get(1);
                        timingPoints.t6 = localMoment.mTimingPoints.get(2);
                        timingPoints.t7 = localMoment.mTimingPoints.get(3);
                        timingPoints.t8 = localMoment.mTimingPoints.get(4);
                        break;
                    case Clip.TYPE_RACE_AU13:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t7 = localMoment.mTimingPoints.get(1);
                        timingPoints.t8 = localMoment.mTimingPoints.get(2);
                        timingPoints.t11 = localMoment.mTimingPoints.get(3);
                        timingPoints.t12 = localMoment.mTimingPoints.get(4);
                        break;
                    case Clip.TYPE_RACE_AU15:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t7 = localMoment.mTimingPoints.get(1);
                        timingPoints.t8 = localMoment.mTimingPoints.get(2);
                        timingPoints.t13 = localMoment.mTimingPoints.get(3);
                        timingPoints.t14 = localMoment.mTimingPoints.get(4);
                        break;
                    case Clip.TYPE_RACE_AUEM:
                    case Clip.TYPE_RACE_CDEM:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t5 = localMoment.mTimingPoints.get(1);
                        timingPoints.t6 = localMoment.mTimingPoints.get(2);
                        timingPoints.t7 = localMoment.mTimingPoints.get(3);
                        timingPoints.t8 = localMoment.mTimingPoints.get(4);
                        timingPoints.t15 = localMoment.mTimingPoints.get(5);
                        timingPoints.t16 = localMoment.mTimingPoints.get(6);
                        break;
                    case Clip.TYPE_RACE_AUQM:
                    case Clip.TYPE_RACE_CDQM:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t5 = localMoment.mTimingPoints.get(1);
                        timingPoints.t6 = localMoment.mTimingPoints.get(2);
                        timingPoints.t7 = localMoment.mTimingPoints.get(3);
                        timingPoints.t8 = localMoment.mTimingPoints.get(4);
                        timingPoints.t9 = localMoment.mTimingPoints.get(5);
                        timingPoints.t10 = localMoment.mTimingPoints.get(6);
                        break;
                    case Clip.TYPE_RACE_AUHM:
                    case Clip.TYPE_RACE_CDHM:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t5 = localMoment.mTimingPoints.get(1);
                        timingPoints.t6 = localMoment.mTimingPoints.get(2);
                        timingPoints.t7 = localMoment.mTimingPoints.get(3);
                        timingPoints.t8 = localMoment.mTimingPoints.get(4);
                        timingPoints.t17 = localMoment.mTimingPoints.get(5);
                        timingPoints.t18 = localMoment.mTimingPoints.get(6);
                        break;
                    case Clip.TYPE_RACE_AU1M:
                    case Clip.TYPE_RACE_CD1M:
                        timingPoints.t2 = localMoment.mTimingPoints.get(0);
                        timingPoints.t5 = localMoment.mTimingPoints.get(1);
                        timingPoints.t6 = localMoment.mTimingPoints.get(2);
                        timingPoints.t7 = localMoment.mTimingPoints.get(3);
                        timingPoints.t8 = localMoment.mTimingPoints.get(4);
                        timingPoints.t19 = localMoment.mTimingPoints.get(5);
                        timingPoints.t20 = localMoment.mTimingPoints.get(6);
                        break;
                    default:
                        break;
                }
            }
        } else if (!TextUtils.isEmpty(localMoment.momentType) && localMoment.momentType.equals("LAP_TIMER")) {
            momentType = localMoment.momentType;
            lapInfo = localMoment.lapInfo;
        } else {
            if (localMoment.mSegments.size() > 1) {
                momentType = "NORMAL_MULTI";
            } else {
                momentType = "NORMAL_SINGLE";
            }
        }
        if (localMoment.withCarInfo) {
            vehicleMaker = localMoment.mVehicleMaker;
            vehicleModel = localMoment.mVehicleModel;
            vehicleYear = localMoment.mVehicleYear;
        }
        vehicleDesc = localMoment.mVehicleDesc;

        withGeoTag = localMoment.withGeoTag;
        if (withGeoTag) {
            geoInfo = localMoment.geoInfo;
        }

//      Logger.d("after overlay setting");

        if (localMoment.audioID > 0) {
            this.audioType = 1;
            this.musicSource = String.valueOf(localMoment.audioID);
        }

        if (localMoment.isFbShare) {
//            shareProviders.add(SocialProvider.FACEBOOK);
        }

        if (localMoment.isYoutubeShare) {
//            shareProviders.add(SocialProvider.YOUTUBE);
        }
        shareParameters.put("usePerUnitInTranscoding", SettingHelper.getUnit());
    }

    public class TimingPointsList {
        public Long t1;
        public Long t2;
        public Long t3;
        public Long t4;
        public Long t5;
        public Long t6;
        public Long t7;
        public Long t8;
        public Long t9;
        public Long t10;
        public Long t11;
        public Long t12;
        public Long t13;
        public Long t14;
        public Long t15;
        public Long t16;
        public Long t17;
        public Long t18;
        public Long t19;
        public Long t20;
    }

    @Override
    public String toString() {
        return ToStringUtils.getString(this);
    }

}
