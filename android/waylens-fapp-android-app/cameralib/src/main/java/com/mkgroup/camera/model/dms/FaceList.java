package com.mkgroup.camera.model.dms;

import java.util.ArrayList;

public class FaceList {

    public long reserved;

    public long num_ids;

    public ArrayList<FaceItem> mClipList = new ArrayList<>();

    public static class FaceItem {
        public String faceID;
        public String name;
        public long person_id;

        @Override
        public String toString() {
            return "FaceItem{" +
                    "faceID=" + faceID +
                    ", name='" + name + '\'' +
                    ", person_id=" + person_id +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "FaceList{" +
                "reserved=" + reserved +
                ", num_ids=" + num_ids +
                ", mClipList=" + mClipList +
                '}';
    }
}
