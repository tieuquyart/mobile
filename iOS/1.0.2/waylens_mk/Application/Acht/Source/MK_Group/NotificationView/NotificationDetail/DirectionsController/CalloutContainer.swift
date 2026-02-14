//
//  CalloutContainer.swift
//  Acht
//
//  Created by TranHoangThanh on 10/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

//class CalloutContainer: UIView {
//
//    @IBOutlet weak var contentView: UIView!
//
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        comonInit()
//
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        comonInit()
//
//    }
//
//    private func comonInit() {
//        Bundle(for: type(of: self)).loadNibNamed("CalloutContainer", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
//    }
//}



import UIKit
import LBTATools

//class CalloutContainer: UIView {
//
//   // let imageView = UIImageView(image: nil, contentMode: .scaleAspectFill)
//   // let nameLabel = UILabel(textAlignment: .center)
//
//
//    var categoryLabel = UILabel(textAlignment: .center)
//    var eventLabel = UILabel(textAlignment: .center)
////    setTitle(label: categoryLabel, title: "Phân loại", info: model.category ?? "")
////    setTitle(label: eventTypeLabel, title: "Hành vi", info: model.eventType ?? "")
//
//    var playButton  = UIButton(image: UIImage(named: "play")!)
//
////    let playButton = UIButton(title: "Play", titleColor: .black, font: .boldSystemFont(ofSize: 18),
////        backgroundColor: .white, target: self, action: #selector(handleVideo))
//
//    @objc func handleVideo() {
//        print("play video")
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        backgroundColor = .white
//
//        translatesAutoresizingMaskIntoConstraints = false
//
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.darkGray.cgColor
//
//        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
//        layer.cornerRadius = 5
//
//        // load the spinner
//        //playButton.backgroundColor = .red
//        addSubview(playButton)
//        playButton.fillSuperview()
////        let spinner = UIActivityIndicatorView(style: .large)
////        spinner.color = .darkGray
////        spinner.startAnimating()
////        addSubview(spinner)
////        spinner.fillSuperview()
//
////        addSubview(imageView)
////        imageView.layer.cornerRadius = 5
////        imageView.fillSuperview()
//
//        // label
//        addSubview(categoryLabel)
//        addSubview(eventLabel)
//
//
//        categoryLabel.text = "Hành vi lái xe"
//        eventLabel.text = "Phanh khá gấp"
//
//
//        stack(categoryLabel,eventLabel,playButton, spacing: 2 , alignment: UIStackView.Alignment.center, distribution: UIStackView.Distribution.fillProportionally).fillSuperview()
//
////        let labelContainer = UIView(backgroundColor: .white)
////        labelContainer.stack(nameLabel)
////        stack(UIView(), labelContainer.withHeight(30))
//
//
//        self.addTapGesture {
//            self.handleVideo()
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


extension UIView {
    
    func addTapGesture(action : @escaping ()->Void ){
        let tap = MyTapGestureRecognizer(target: self , action: #selector(self.handleTapCustom(_:)))
        tap.action = action
        tap.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
    }
    @objc func handleTapCustom(_ sender: MyTapGestureRecognizer) {
        sender.action!()
    }
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var action : (()->Void)? = nil
}



import MapKit


class PickupLocationAnnotation: MKPointAnnotation {
    let category: String
    let eventType : String
    let url : String
    init(category: String , eventType : String , url : String) {
        self.category = category
        self.eventType = eventType
        self.url = url
        super.init()
    }
}



// our annotation view for our pickup annotations

class PickupLocationAnnotationView: MKPinAnnotationView {
    weak var calloutView: UIView?

    override func prepareForDisplay() {
        super.prepareForDisplay()
        canShowCallout = false
    }

    // make sure that hits in callout are recognized as not-deselecting the annotation view

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) { return hitView }

        if let calloutView = calloutView {
            let point = convert(point, to: calloutView)
            return calloutView.hitTest(point, with: event)
        }

        return nil
    }

    // lets move the add callout here, inside the annotation view class,
    // so the annotation view can keep track of its callout

    func addCallout(delegate: CalloutViewDelegate) {
        removeCallout()

        let view = CalloutView(annotation: annotation, delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        calloutView = view

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.bottomAnchor.constraint(equalTo: topAnchor, constant: -10)
        ])
    }

    func removeCallout() {
        calloutView?.removeFromSuperview()
    }
}
