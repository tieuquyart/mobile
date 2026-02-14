//
//  UserProfileViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/30/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage

class UserProfileViewController: BaseTableViewController {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    let api = SessionService.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.layer.cornerRadius = avatar.bounds.size.width * 0.5
        avatar.clipsToBounds = true
        refreshUI()
        title = NSLocalizedString("Account", comment: "Account")
    }
    
    func update() {
        WaylensClientS.shared.fetchProfile { [weak self] (result) in
            if result.isSuccess {
                self?.refreshUI()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AccountControlManager.shared.isAuthed {
            refreshUI()
            update()
        } else {
            navigationController?.popViewController(animated: false)
        }
    }
    
    func refreshUI() {
        nameLabel.text = AccountControlManager.shared.keyChainMgr.displayName
        emailLabel.text = AccountControlManager.shared.keyChainMgr.email
        if let urlstr = AccountControlManager.shared.keyChainMgr.largeAvatarUrl ?? AccountControlManager.shared.keyChainMgr.avatarUrl, let url = URL(string: urlstr) {
            avatar.af_setImage(withURL: url, placeholderImage: avatar.image ?? #imageLiteral(resourceName: "user_avatar_placeholder"))
        } else {
            avatar.image = #imageLiteral(resourceName: "user_avatar_placeholder")
        }

        #if FLEET
//        changeAvatarButton.isHidden = true
//        nameCell.accessoryType = .none
//        nameCell.isUserInteractionEnabled = false
        #endif
    }

    @IBAction func onChangeAvatar(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheetOrAlertOnPad)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Take a photo", comment: "Take a photo"), style: .default, handler: { (_) in
                let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                if status == .authorized {
                    self.pickImage(fromCamera: true)
                } else if status == .denied {
                    self.alertForAccess()
                } else if status == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                        if granted {
                            self.pickImage(fromCamera: true)
                        }
                    })
                }
            }))
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Choose a photo", comment: "Choose a photo"), style: .default, handler: { (_) in
            self.pickImage(fromCamera: false)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func pickImage(fromCamera: Bool) {
        let picker = UIImagePickerController()
        picker.sourceType = fromCamera ? .camera : .photoLibrary // photolibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func alertForAccess() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("no_permission_to_access_camera_message", comment: "The app has no permission to access your camera.\nYou can enable it at Privacy Settings"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (_) in
            let url = URL(string:UIApplication.openSettingsURLString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeUsername" {
            (segue.destination as? ChangeUsernameViewController)?.username = AccountControlManager.shared.keyChainMgr.displayName
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let alert = UIAlertController.init(title: NSLocalizedString("Log Out?", comment: "Log Out?"), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Log Out", comment: "Log Out"), style: .default, handler: { (UIAlertAction) in
                self.api.logout(completion: nil)
                AppViewControllerManager.gotoLogin()
            }))
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage,
        let resized = image.resizedImage(CGSize(width: 512, height: 512), interpolationQuality: .high) else {
            return
        }
        HNMessage.show(message: NSLocalizedString("Uploading...", comment: "Uploading..."))
        WaylensClientS.shared.uploadAvatar(resized, progress: { (percent) in
            if percent >= 0 && percent <= 100 {
                HNMessage.showProgress(percent, message: NSLocalizedString("Uploading...", comment: "Uploading..."))
            } else if percent < 0 {
                HNMessage.showError(message: NSLocalizedString("Upload Failed", comment: "Upload Failed"))
            }
        }) { [weak self] (result) in
            if result.isSuccess {
                HNMessage.showSuccess(message: NSLocalizedString("Upload Done", comment: "Upload Done"))
                self?.update()
            } else {
                HNMessage.showError(message: NSLocalizedString("Upload Failed", comment: "Upload Failed"))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
