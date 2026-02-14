//
//  RedirectForumViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/11/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import SafariServices

class RedirectForumViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if AccountControlManager.shared.isAuthed {
            WaylensClientS.shared.fetchForumLoginUrl { [weak self] (result) in
                if result.isSuccess, let loginUrl = result.value?["forumLoginUrl"] as? String, let url = URL(string: loginUrl) {
                    self?.loadUrl(url)
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? "Failed to open Forum")
                }
            }
        } else {
            loadUrl(URL(string: "https://forum.waylens.com")!)
        }
    }
    
    func loadUrl(_ url: URL) {
        let vc = SafariViewController(url: url)
        if #available(iOS 11.0, *) {
            vc.dismissButtonStyle = .close
        }
        vc.delegate = self

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }

        present(vc, animated: false, completion: nil)
    }

}

extension RedirectForumViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        navigationController?.popViewController(animated: false)
    }
}
