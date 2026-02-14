//
//  FlowGuide.swift
//  Fleet
//
//  Created by forkon on 2020/8/19.
//  Copyright © 2020 waylens. All rights reserved.
//

public protocol FlowGuide: AnyObject {
    func start()
    func nextStep(with params: [AnyHashable : Any]?)
    func nextStep()
}

public protocol FlowGuideStep {

}

public protocol FlowGuidePresenter: AnyObject {
    associatedtype GuideType: FlowGuide
    associatedtype StepType: FlowGuideStep
    var flowGuide: GuideType? { set get }
    func present(_ step: StepType, with params: [AnyHashable : Any]?)
    func makeViewController(for step: StepType, with params: [AnyHashable : Any]?) -> UIViewController
    func dismiss()
}

extension UIViewController {

    fileprivate struct AssociatedKeys {
        static var flowGuide: UInt8 = 8
    }

    public var flowGuide: FlowGuide? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.flowGuide, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.flowGuide) as? FlowGuide
        }
    }

}
