//
//  LocalPreviewViewModel.swift
//  Acht
//
//  Created by gliu on 8/29/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation
import WaylensFoundation

protocol LocalPreviewViewModelDelegate : AnyObject {
    func updateImage(_ image : UIImage)
    func needPower2Size() -> Bool
}

class LocalPreviewViewModel: NSObject, NSURLConnectionDataDelegate, URLSessionDataDelegate {

    var connection  : NSURLConnection?
    var session: URLSession?
    var task        : URLSessionDataTask?
    var image       = Data()
    var imageSize   : Int = 0
    var previewUrlString: String?

    weak var delegate : LocalPreviewViewModelDelegate? = nil

    override init() {
        super.init()
    }
    
    // MARK: - API
    func startPreview(_ urlstring : String?) {
        stopPreviewIfConnected()
        previewUrlString = urlstring
        if let urlstring = urlstring, let url = URL(string: urlstring) {
            if session == nil {
                session = URLSession(configuration: URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
            }
            task = session?.dataTask(with: url)
            task?.resume()
        }
    }
    
    func stopPreviewIfConnected() {
        task?.cancel()
        image.removeAll()
        imageSize = 0
        task = nil
    }
    
    func shutdown() {
        stopPreviewIfConnected()
        session?.invalidateAndCancel()
        session = nil
    }

    //MARK - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        imageSize = Int(response.expectedContentLength)
        image.removeAll()
        completionHandler(.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if imageSize <= 0 {
            return
        }
        image.append(data)
        if (image.count == imageSize) {
            updateImage()
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            Log.error("local preview session became invalid:\(error.localizedDescription)" )
        }
    }

}

private extension LocalPreviewViewModel {

    func updateImage() {
        guard let uiimage = UIImage(data: image) else {
            image.removeAll()
            return
        }

        #if true
        if uiimage.size.width == 1024 && uiimage.size.height == 1024 {
            delegate?.updateImage(uiimage)
        } else {
            delegate?.updateImage(delegate!.needPower2Size() ? self.imageWithPower2Size(uiimage) : uiimage)
        }
        #else
            delegate?.updateImage(UIImage(named: "h-6.jpg")!)
        #endif
    }

    func imageWithPower2Size(_ image : UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1024, height: 1024))
        if image.size.width == image.size.height {
            image.draw(in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        } else {
            image.draw(in: CGRect(x: -398 + 160, y: 0 + 90, width: 1820 - 320, height: 1024 - 180))
        }
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
