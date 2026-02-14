//
//  SelectRangeTimeLineDataSource.swift
//  Acht
//
//  Created by Chester Shen on 3/7/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class SelectRangeTimeLineDataSource: CameraTimeLineDataSource {
    override var isLocal: Bool {
        get {
            return true
        }
    }
    var clip: HNClip? {
        didSet {
            if let clip = clip {
                let (groupList, clipList, dateList) = self.organizeData([clip])
                self.groupList = groupList
                self.clipList = clipList
                self.dateList = dateList
            } else {
                self.groupList.removeAll()
                self.clipList.removeAll()
                self.dateList.removeAll()
            }
        }
    }
}

// MARK:- UICollectionView DataSource
extension SelectRangeTimeLineDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return max(clipList.count, 1)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if clipList.count <= section {
            return 0
        }
        return clipList[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraTimeLineCell", for: indexPath) as! CameraTimeLineCell
        if let clip = clipWithIndex(indexPath) {
            cell.clip = clip
            cell.timeLabel.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        default:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! CameraTimeLineThumbnail
            guard let data = (collectionView.collectionViewLayout as! CameraTimeLineLayout).thumbnail(atIndex: indexPath),
                let clip = data.clip
                else { return view }
            view.data = data
            guard let camera = camera, let rawClip = clip.rawClip, let time = data.pts else { return view }
            let request = VDBThumbnailRequest(cameraID: camera.sn, clip: rawClip, pts: time, cache: true, ignorable: false)
            view.imageView.vdb_setThumbnail(request, animated:true)
            data.image = view.imageView.image_future
            return view
        }
    }
}
