package com.mkgroup.camera.utils;

import com.mkgroup.camera.model.Clip;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import io.reactivex.subjects.BehaviorSubject;

/**
 * Created by DoanVT on 2017/12/27.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipsManager {

    private final static String TAG = ClipsManager.class.getSimpleName();

    private final CopyOnWriteArrayList<Clip> clipList;

    private BehaviorSubject<List<Clip>> clipListObservable = BehaviorSubject.createDefault(new CopyOnWriteArrayList<>());

    public ClipsManager() {
        clipList = new CopyOnWriteArrayList<>();
    }

    public BehaviorSubject<List<Clip>> clipList() {
        return clipListObservable;
    }

    public List<Clip> getClipList() {
        return clipList;
    }

    public Clip getAccurateClip(Clip oldClip) {
        synchronized (clipList) {
            for (int i = 0; i < clipList.size(); i++) {
                Clip clip = clipList.get(i);
                if (clip == null || clip.cid == null) {
                    continue;
                }

                if (clip.cid.type == oldClip.cid.type && clip.cid.subType == oldClip.cid.subType) {
                    return clip;
                }
            }
        }
        return oldClip;
    }

    public void refreshClipList(List<Clip> newClipList) {
        clipList.clear();
        clipList.addAll(newClipList);
        clipListObservable.onNext(clipList);
    }

    public boolean addClip(Clip newClip) {
        boolean isAdded = clipList.add(newClip);
        clipListObservable.onNext(clipList);
        return isAdded;
    }

    public void updateClip(Clip newClip, boolean replaceClip) {
        synchronized (clipList) {
            for (int i = 0; i < clipList.size(); i++) {
                Clip clip = clipList.get(i);
                if (clip == null || clip.cid == null) {
                    continue;
                }

                if (clip.cid.type == newClip.cid.type
                        && clip.cid.subType == newClip.cid.subType) {
                    if (replaceClip) {
                        clipList.set(i, newClip);
                    } else if (clip.isLiveRecording()) {
                        clip.setDurationMs(newClip.getDurationMs());
                        clipList.set(i, clip);
                    }
                    break;
                }
            }
        }
    }

    public boolean deleteClip(Clip deletedClip) {
        boolean result = false;

        synchronized (clipList) {
            for (int i = 0; i < clipList.size(); i++) {
                if (clipList.get(i).cid.equals(deletedClip.cid)) {
                    clipList.remove(i);
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    public List<Clip> queryClip(List<Integer> videoType) {
        List<Clip> tempList = new ArrayList<>();

        synchronized (clipList) {
            int length = videoType.size();
            for (int i = 0; i < length; i++) {
                for (Clip clip : clipList) {
                    if (clip.videoType == videoType.get(i)) {
                        tempList.add(clip);
                    }
                }
            }
        }
        return tempList;
    }

}
