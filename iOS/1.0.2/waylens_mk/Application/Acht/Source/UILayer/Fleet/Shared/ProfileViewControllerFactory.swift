//
//  ProfileViewControllerFactory.swift
//  Fleet
//
//  Created by forkon on 2019/11/13.
//  Copyright © 2019 waylens. All rights reserved.
//

protocol ProfileViewControllerFactory {
    func makeProfileInfoComposingViewController(with infoType: ProfileInfoType) -> UIViewController
}
