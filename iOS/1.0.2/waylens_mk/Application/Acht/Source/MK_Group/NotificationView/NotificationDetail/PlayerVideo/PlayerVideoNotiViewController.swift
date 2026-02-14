//
//  PlayerVideoNotiViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 10/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import UIKit
import BMPlayer

class BMCustomPlayer: BMPlayer {
    override func storyBoardCustomControl() -> BMPlayerControlView? {
        return BMPlayerCustomControlView()
    }
}

class PlayerVideoNotiViewController: UIViewController {

    @IBOutlet weak var player: BMCustomPlayer!
    var url : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true {
                return
            }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        

        
        let asset = BMPlayerResource(url: URL(string: url)!,
                                     name: "",
                                     cover: nil,
                                     subtitle: nil)
        player.setVideo(resource: asset)
    }

}
