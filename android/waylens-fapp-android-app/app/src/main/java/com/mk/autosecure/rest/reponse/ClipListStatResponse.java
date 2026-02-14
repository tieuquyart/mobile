package com.mk.autosecure.rest.reponse;

import java.util.Map;

/**
 * Created by DoanVT on 2017/9/1.
 */

public class ClipListStatResponse {

    public Map<String, Integer> clipNums;
    public Map<String, Map<String, Integer>> dateNums;

    @Override
    public String toString() {
        return "ClipListStatResponse{" +
                "clipNums=" + clipNums +
                ", dateNums=" + dateNums +
                '}';
    }
}
