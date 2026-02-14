//
//  MP4UploaderAdapter.swift
//  Acht
//
//  Created by forkon on 2019/5/5.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation
import Alamofire

class MP4UploaderAdapter {
    enum Result {
        case success
        case failure
    }

    private lazy var mp4Uploader: MP4Uploader = MP4Uploader()
    private lazy var horizonClient = HorizonClient()

    private(set) var isUploading: Bool = false

    func uploadClip(_ clip: HNClip, progressClosure: ((Float) -> Void)?, completionClosure: ((MP4UploaderAdapter.Result) -> Void)?) {
        isUploading = true

        horizonClient.createNewMoment(with: clip) { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(_):
                strongSelf.isUploading = false
                completionClosure?(.failure)
            case .success((let newMoment, let serverInfo)):
                let key = serverInfo["privateKey"] as! String
                let baseUrl = serverInfo["url"] as! String

                strongSelf.mp4Uploader.uploadMP4Moment(newMoment, toBaseUrl: baseUrl, privateKey: key, userId: strongSelf.horizonClient.userID, progress: { (done, error, message, progress) in
                    progressClosure?(progress / 100.0)
                }){ (_, error, message) in
                    strongSelf.isUploading = false
                    if error != nil {
                        completionClosure?(.failure)
                    } else {
                        completionClosure?(.success)
                    }
                }
            }
        }
    }

    func cancel() {
        mp4Uploader.cancel()
    }

}
