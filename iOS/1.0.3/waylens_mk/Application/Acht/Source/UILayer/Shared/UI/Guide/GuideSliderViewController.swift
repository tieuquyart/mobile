//
//  GuideSliderViewController.swift
//  Acht
//
//  Created by Chester Shen on 6/14/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideSliderViewController: UIViewController, GuideController {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var pageControl: DashDotPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var pageWidth: CGFloat = 350
    static func createViewController() -> GuideSliderViewController {
        let vc = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: "GuideSliderViewController")
        return vc as! GuideSliderViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var attributed = NSMutableAttributedString(string: NSLocalizedString("Tap the button", comment: "Tap the button"))
        let icon = NSTextAttachment()
        icon.image = #imageLiteral(resourceName: "btn_panorama_n")
        icon.bounds = CGRect(x: 0, y: UIFont(name: "BeVietnamPro-Regular", size: 14)!.descender, width: 19, height: 19)
        attributed.append(NSAttributedString(attachment: icon))
        attributed.append(NSAttributedString(string: NSLocalizedString("to watch the 360° videos in panorama mode. Drag and pinch to choose view angle.", comment: "to watch the 360° videos in panorama mode. Drag and pinch to choose view angle.")))
        addPage(index: 0, vc: GuideWelcomePage.createViewController(title: NSLocalizedString("Explore the videos on camera", comment: "Explore the videos on camera"), attributedDetail: attributed, image: #imageLiteral(resourceName: "image_panorama"), button: nil))
        attributed = NSMutableAttributedString(string: NSLocalizedString("event_videos_labeled_in_different_colors", comment: "Event videos are labeled in different colors according to their type.\n\n"))
        attributed.append(NSAttributedString(string: NSLocalizedString("Motion  ", comment: "Motion  "), attributes: [.foregroundColor : UIColor.lightGray]))
        attributed.append(NSAttributedString(string: NSLocalizedString("people_approaching_car_keying", comment: "people approaching, car keying\n"), attributes: [.foregroundColor : UIColor.black]))
        attributed.append(NSAttributedString(string: NSLocalizedString("Bump  ", comment: "Bump  "), attributes: [.foregroundColor : UIColor.lightGray]))
        attributed.append(NSAttributedString(string: NSLocalizedString("knocking_bumps", comment: "knocking, bumps\n"), attributes: [.foregroundColor : UIColor.black]))
        attributed.append(NSAttributedString(string: NSLocalizedString("Impact  ", comment: "Impact  "), attributes: [.foregroundColor : UIColor.lightGray]))
        attributed.append(NSAttributedString(string: NSLocalizedString("heavy_impact", comment: "heavy impact\n"), attributes: [.foregroundColor : UIColor.black]))
        addPage(index: 1, vc: GuideWelcomePage.createViewController(title: nil, attributedDetail: attributed, image: #imageLiteral(resourceName: "image_events"), button: nil))
        addPage(index: 2, vc: GuideWelcomePage.createViewController(title: nil, detail: NSLocalizedString("Tap the video on the timeline to export and delete.", comment: "Tap the video on the timeline to export and delete."), image: #imageLiteral(resourceName: "image_clip_actions"), button: nil))
        addPage(index: 3, vc: GuideWelcomePage.createViewController(title: nil, detail: NSLocalizedString("Drag handles within a video to specifically select the range for export.", comment: "Drag handles within a video to specifically select the range for export."), image: #imageLiteral(resourceName: "image_trim"), button: nil))
        let vc = GuideWelcomePage.createViewController(title: NSLocalizedString("That's it!", comment: "That's it!"), detail: NSLocalizedString("finish_setting_up_camera_detail", comment: "You've set up your Secure360 and have learned the basics of the app. Enjoy the peace of mind that comes with owning a Secure360!"), image: #imageLiteral(resourceName: "image_camera_overview"), button: NSLocalizedString("Finish", comment: "Finish"))
        addPage(index: 4, vc: vc)
        vc.skipButton.isHidden = true
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if scrollView.bounds.width != pageWidth {
            pageWidth = scrollView.bounds.width
            relayout()
        }
    }
    
    func relayout() {
        var index = 0
        for vc in children {
            vc.view.frame = CGRect(x: CGFloat(index)*pageWidth, y: 0, width: pageWidth, height: scrollView.frame.size.height)
            index += 1
        }
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(index), height: scrollView.frame.size.height)
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func addPage(index: Int, vc: GuideWelcomePage) {
        vc.controller = self
        scrollView.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = true
        vc.view.frame = CGRect(x: CGFloat(index)*pageWidth, y: 0, width: pageWidth, height: scrollView.frame.size.height)
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(index+1), height: scrollView.frame.size.height)
    }
    
    @IBAction func onTapPageControl(_ sender: DashDotPageControl) {
        if let nextPage = sender.nextPage {
            scrollView.setContentOffset(CGPoint(x: pageWidth * CGFloat(nextPage), y: 0), animated: true)
        }
    }
    func onAction() {
        UserSetting.shared.guideState = .end
        dismiss(animated: true, completion: nil)
    }
    
    func onSkip() {
        UserSetting.shared.guideState = .end
        dismiss(animated: true, completion: nil)
    }
}

extension GuideSliderViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / pageWidth + 0.5)
        if currentIndex != pageControl.currentPage {
            pageControl.setCurrentPage(currentIndex, animated: true)
        }
    }
}

