//
//  FIRUpdate.swift
//  Acht
//
//  Created by Chester Shen on 12/4/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import WaylensFoundation

struct FIRUpdate {
    static func checkUpdate(appId: String, token: String) {
        guard let url = URL(string: "https://api.fir.im/apps/latest/\(appId)?api_token=\(token)") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                Log.error("Fail to check app version on FIR")
                return
            }
            let decoded = try? JSONSerialization.jsonObject(with: data!, options: [])
            guard let result = decoded as? [String: Any] else {
                Log.error("Fail to check app version on FIR")
                return
            }
            guard let info = Bundle.main.infoDictionary,
                let currentBuild = info["CFBundleVersion"] as? String,
                let lastestBuild = result["build"] as? String else { return }
            Log.verbose("Fetched latest version \(result)")
            if currentBuild.compare(lastestBuild) == .orderedAscending {
                Log.info("Newer Update version \(lastestBuild)!")
                let date = Date(timeIntervalSince1970: result["updated_at"] as! Double).toString()
                let notes = result["changelog"] as? String ?? ""
                let downloadUrl = result["update_url"] as! String
                let alert = UIAlertController(
                    title:NSLocalizedString("App Update Available", comment: "App Update Available"),
                    message: String(format: NSLocalizedString("app_update_available_message", comment: "%@(%@)\nUpdated at %@\n\n%@"), result["versionShort"] as! String, lastestBuild, date, notes),
                    preferredStyle:.alert
                )
                let actionUpdate = UIAlertAction(title:NSLocalizedString("Check it out", comment: "Check it out"), style:.destructive, handler: {
                    (_) in
                    UIApplication.shared.open(URL(string: downloadUrl)!, options: [:], completionHandler: nil)
                })
                let actionCancel = UIAlertAction(title:NSLocalizedString("Later", comment: "Later"), style:.cancel, handler:nil)
                alert.addAction(actionUpdate)
                alert.addAction(actionCancel)
                DispatchQueue.main.async {
                    if let vc = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController {
                        vc.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
}
