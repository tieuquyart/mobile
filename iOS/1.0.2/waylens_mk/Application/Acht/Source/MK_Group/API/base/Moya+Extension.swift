//
//  Moya+Extension.swift
//  test_alamofire
//
//  Created by TranHoangThanh on 12/23/21.
//

import Foundation
import Moya
import WaylensFoundation
//typealias completionBlock =  (MyAPIResult) -> Void
typealias completionBlock =  (WLAPIResult) -> Void


extension MoyaProvider {
//
    @discardableResult
    func request(_ target: Target, completionHandler: completionBlock?) -> Cancellable {
        return request(target) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            if let response = result.value, let target = target as? FleetAPI, target.shouldLogResponse {
                var body: String?
                if let bodyData = response.request?.httpBody {
                    body = String(data:bodyData, encoding: .utf8)
                }

                let responseString = (try? response.mapString()) ?? "nil"

                Log.info("\(target.method) \(response.request?.url?.absoluteString ?? ""), \nbody:\(body ?? "nil"),\nresponse:\(responseString)")
            }

            switch result {
            case .success(let response):
                completionHandler?(strongSelf.handleNetworkResponse(response))
            case .failure(let error):
                Log.verbose((try? result.value?.mapString()) ?? "")
                print("ServerError: - ",error.localizedDescription)
                completionHandler?(.failure(WLError(code: error.errorCode, msg: error.localizedDescription)))
            }
        }
    }

    private func handleNetworkResponse(_ response: Moya.Response) -> WLAPIResult {
       // print("tanh response.statusCode ",response.statusCode)
        switch response.statusCode {
        case 200:
            if let dict = try? response.mapJSON() as? Dictionary<String, Any> {
                return .success(dict)
            } else {
                let apiError = WLAPIError.jsonFormatError
                let error = WLError(code: apiError.rawValue, msg: apiError.message ?? "")
                return .failure(error)
            }
        case 400...599:
            if let dict = try? response.mapJSON() as? Dictionary<String, Any>, let code = dict["code"] as? Int {

                let message: String

                switch code {
                case 3998:
                    message = NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                case 3999:
                    message = NSLocalizedString("Please input correct email address and password", comment: "Please input correct email address and password")
                case 4000:
                    message = NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                case 4001:
                    message = NSLocalizedString("Please check the email address", comment: "Please check the email address")
                case 4002:
                    message = NSLocalizedString("Please input correct password.", comment: "Please input correct password.")
                case 4003:
                    message = NSLocalizedString("We've just sent a verification email, please wait 5 minutes, check your email and try again.", comment: "We've just sent a verification email, please wait 5 minutes, check your email and try again.")
                case 4004:
                    message = NSLocalizedString("Too many verification emails have been sent, please check your email again, including spam or junk folders.", comment: "Too many verification emails have been sent, please check your email again, including spam or junk folders.")
                case 4005:
                    message = NSLocalizedString("The verification code is expires. Please verify again.", comment: "The verification code is expires. Please verify again.")
                case 4006:
                    message = NSLocalizedString("Please input correct verification code.", comment: "Please input correct verification code.")
                case 4007:
                    message = NSLocalizedString("Only fleet owner can do this.", comment: "Only fleet owner can do this.")
                case 4008:
                    message = NSLocalizedString("The email address can not be change.", comment: "The email address can not be change.")
                case 4101:
                    message = NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                case 4102:
                    message = NSLocalizedString("Please check the camera. ", comment: "Please check the camera. ")
                case 4103, 4200, 4202:
                    message = NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                case 4203:
                    message = NSLocalizedString("Camera has been added to a fleet. if it is not your fleet, please contact waylens for support.", comment: "Camera has been added to a fleet. if it is not your fleet, please contact waylens for support.")
                case 4205:
                    message = NSLocalizedString("The plate number already exists.", comment: "The plate number already exists.")
                case 4211:
                    message = NSLocalizedString("The email address has been used.", comment: "The email address has been used.")
                case 4301:
                    message = NSLocalizedString("The vehicle has already been assigned to a driver.", comment: "The vehicle has already been assigned to a driver.")
                case 4302:
                    message = NSLocalizedString("The vehicle has already been bound to a camera.", comment: "The vehicle has already been bound to a camera.")
                case 4303:
                    message = NSLocalizedString("The vehicle is not assigned to the driver.", comment: "The vehicle is not assigned to the driver.")
                case 4304:
                    message = NSLocalizedString("The vehicle is not bound to the camera.", comment: "The vehicle is not bound to the camera.")
                case 4306:
                    message = NSLocalizedString("The vehicle is driving, please operate when the vehicle is parked.", comment: "The vehicle is driving, please operate when the vehicle is parked.")
                case 4307:
                    message = NSLocalizedString("The camera has already been bound to a vehicle.", comment: "The camera has already been bound to a vehicle.")
                case 4308:
                    message = NSLocalizedString("The vehicle has not been assigned to a driver.", comment: "The vehicle has not been assigned to a driver.")
                case 4309:
                    message = NSLocalizedString("The driver has already been assigned a vehicle.", comment: "The driver has already been assigned a vehicle.")
                case 4310, 4311, 4312, 4313:
                    message = NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                case 222 :
                    //value["message"]
                    message = (dict["message"] as? String) ?? NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                default:
                    message = (dict["msg"] as? String) ?? NSLocalizedString("There is something wrong, please try again.", comment: "There is something wrong, please try again.")
                }

                let error = WLError(code: code, msg: message)

                //TODO: Handle token issue in a better way.
                if error.asAPIError?.rawValue == WLAPIError.expiredVerificationToken.rawValue ||
                        error.asAPIError?.rawValue == WLAPIError.incorrectUsernameOrPassword.rawValue {
                    if !AppViewControllerManager.isInSignInContainerViewController {
                        AccountControlManager.shared.keyChainMgr.onLogOut()
                        AppViewControllerManager.gotoLogin()
                    }
                }

                return .failure(error)
            } else {
                let apiError = WLAPIError.jsonFormatError
                let error = WLError(code: apiError.rawValue, msg: apiError.message ?? "")
                return .failure(error)
            }
        default:
            let apiError = WLAPIError.networkError
            let error = WLError(code: apiError.rawValue, msg: apiError.message ?? "")
            return .failure(error)
        }
    }

}
