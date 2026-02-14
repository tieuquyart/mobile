//
//  CalloutView.swift
//  Acht
//
//  Created by TranHoangThanh on 10/18/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import MapKit
import LBTATools
import BMPlayer

// let’s have a protocol for the callout to inform view controller that the “pickup” button was tapped

protocol CalloutViewDelegate: AnyObject {
    func calloutTapped(for annotation: MKAnnotation)
}



class CalloutView: UIView {
    weak var annotation: MKAnnotation?
    weak var delegate: CalloutViewDelegate?

    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Chạm vào đây để phát video", for: .normal)
       // button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    let imgView = UIImageView(image: UIImage(named: "play"), contentMode: .center)
    
    
    lazy var categorylabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = (annotation as? PickupLocationAnnotation)?.category
        return label
    }()
    
    
    lazy var eventTypelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = (annotation as? PickupLocationAnnotation)?.eventType
        return label
    }()

//    lazy var label: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.text = (annotation as? PickupLocationAnnotation)?.hours
//        return label
//    }()

    var player: BMPlayer!
    
    var videoView = BMPlayerCustomControlView()
    
   
    let hudContainer = UIView(backgroundColor: .white)
    
    
    init(annotation: MKAnnotation?, delegate: CalloutViewDelegate) {
        self.annotation = annotation
        self.delegate = delegate
        super.init(frame: .zero)
        
        
        
        player = BMPlayer(customControlView: videoView)
        let asset = BMPlayerResource(url: URL(string: (annotation as? PickupLocationAnnotation)?.url ?? "")!,
                                     name: "",
                                     cover: nil,
                                     subtitle: nil)
        
        player.setVideo(resource: asset)
        
        configure()
    }
    
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
       //   addBackgroundButton(to: self)
//        addSubview(button)
//        addSubview(categorylabel)
//        addSubview(eventTypelabel)
//
//        stack(categorylabel,eventTypelabel, button)

//        NSLayoutConstraint.activate([
////            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
////            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
////            button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
////            button.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -10),
////
////            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
////            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
////            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
////        ])
//
//        layer.cornerRadius = 10
//        layer.borderColor = UIColor.blue.cgColor
//        layer.borderWidth = 2
//        backgroundColor = .white
        
        setupSelectedAnnotationHUD()
    }
    
    fileprivate func setupSelectedAnnotationHUD() {
        addSubview(hudContainer)
        hudContainer.layer.cornerRadius = 5
    //    hudContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        hudContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
//        hudContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .allSides(16), size: .init(width: 0, height: 100))

        hudContainer.addSubview(categorylabel)
        hudContainer.addSubview(eventTypelabel)
        hudContainer.addSubview(player)
        
        categorylabel.anchor(top: hudContainer.topAnchor, leading: hudContainer.leadingAnchor, bottom: nil, trailing: hudContainer.trailingAnchor, padding: .init(top: 4, left: 4, bottom: 4, right: 4))
        
        eventTypelabel.anchor(top: categorylabel.bottomAnchor, leading: hudContainer.leadingAnchor, bottom: nil, trailing: hudContainer.trailingAnchor, padding: .init(top: 4, left: 4, bottom: 4, right: 4))
//        imgView.anchor(top: eventTypelabel.bottomAnchor, leading: hudContainer.leadingAnchor, bottom: bottomAnchor, trailing: hudContainer.trailingAnchor, padding: .init(top: 4, left: 4, bottom: 4, right: 4))
//        button.withHeight(40)
//        hudContainer.stack(categorylabel,eventTypelabel, imgView).withMargins(.allSides(4))
        player.anchor(top: eventTypelabel.bottomAnchor, leading: hudContainer.leadingAnchor, bottom: bottomAnchor, trailing: hudContainer.trailingAnchor, padding: .init(top: 4, left: 4, bottom: 4, right: 4),size: .init(width: 0, height: 140))
       

        hudContainer.addTapGesture {
            self.didTapButton()
        }
        
    }

    @objc func didTapButton() {
        if let annotation = annotation {
            delegate?.calloutTapped(for: annotation)
        }
    }

    fileprivate func addBackgroundButton(to view: UIView) {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
