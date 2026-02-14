//
//  HorizonClient.swift
//  Acht
//
//  Created by forkon on 2019/6/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import Alamofire

class HorizonClient: NSObject {

    private enum Config {
        static let baseURL: String = "https://agent.waylens.com"
        static let email: String = "apple@waylens.com"
        static let password: String = "TW@21#Runhe"
    }

    private var token: String? = nil
    private var needsRelogin: Bool {
        if (userID != nil && token != nil && expireTime != nil) && !isTokenExpired {
            return false
        } else {
            return true
        }
    }
    private var expireTime: TimeInterval? = nil
    private var isTokenExpired: Bool {
        if let expireTime = expireTime, Date().timeIntervalSince1970 > expireTime {
            return true
        } else {
            return false
        }
    }

    private var networkingManager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "waylens.com": .disableEvaluation,
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HorizonClient.httpHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )

        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)

                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }

            return (disposition, credential)
        }

        return manager
    }()

    enum Result<Value> {
        case success(Value)
        case failure(Error?)
    }

    var userID: String? = nil

    func loginIfNeeded(_ completion: @escaping (_ userID: String?, _ token: String?, _ expireTime: TimeInterval?) -> ()) {
        if needsRelogin {
            login(with: Config.email, password: Config.password) { [weak self] userID, token, expireTime in
                self?.userID = userID
                self?.token = token
                self?.expireTime = expireTime

                completion(userID, token, expireTime)
            }
        } else {
            completion(userID, token, expireTime)
        }
    }

    func createNewMoment(with clip: HNClip, completion: @escaping ((Result<(PDRUploadMp4Moment, [String : Any])>) -> Void)) {
        loginIfNeeded { [weak self] (userID, token, expireTime) in
            guard let token = token, let videoFilePath = clip.url else {
                completion(.failure(nil))
                return
            }

            let videoFileURL = URL(fileURLWithPath: videoFilePath)
            let description: String = "ID:\(AccountControlManager.shared.keyChainMgr.userID ?? "")\nemail:\(AccountControlManager.shared.keyChainMgr.email ?? "")\ntime:\(clip.startDate.toString(format: .httpHeader))\nDev:iOS/\(deviceIdentifier())"

            var geoInfo: PDRGeoInfo? = nil

            if let longitude = clip.location?.coordinate?.longitude, let latitude = clip.location?.coordinate?.latitude {
                let geoInfoDict: [String : Any] = [
                    "country" : clip.location?.address?.country ?? "",
                    "region" : clip.location?.address?.region ?? "",
                    "city" : clip.location?.address?.city ?? "",
                    "address" : clip.location?.address?.fullAddress ?? "",
                    "longitude" : longitude,
                    "latitude" : latitude
                ]
                geoInfo = PDRGeoInfo(dict: geoInfoDict)
            }

            let newMoment = PDRUploadMp4Moment(title: description, description: "", tags: ["Waylens"])!
            newMoment.geoInfo = geoInfo
            newMoment.setMp4Url(videoFileURL)

            self?.request("\(Config.baseURL)/api/moments", method: .post, parameters: newMoment.dict() as? [String : Any], headers: ["X-Auth-Token" : token]) { response in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let responseValue):
                    if let responseValue = responseValue as? [String : Any], let momentID = responseValue["momentID"] as? Int, let serverInfo = responseValue["uploadServer"] as? [String : Any] {
                        newMoment.momentID = momentID
                        completion(.success((newMoment, serverInfo)))
                    } else {
                        completion(.failure(nil))
                    }
                }
            }
        }
    }

    func fetchVideos(_ cursor: Int = 0, count: Int = 20, completion: @escaping ((Result<([VideoEntry], Bool)>) -> Void)) {
        loginIfNeeded { [weak self] (userID, token, expireTime) in
            guard let userID = userID, let token = token else {
                completion(.failure(nil))
                return
            }

            let parameters: [String : Any] = [
                "cursor" : cursor,
                "count" : count,
                "showSrcMp4" : true
            ]

            self?.request("\(Config.baseURL)/api/v2/users/\(userID)/moments", method: .get, parameters: parameters, headers: ["X-Auth-Token" : token]) { response in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let value):
                    if let resultDict: [String : Any] = value as? [String : Any] {
                        let momentDicts = resultDict["moments"] as! [[String : Any]]
                        let hasMore = (resultDict["hasMore"] as? Bool) ?? false

                        let videos: [VideoEntry] = momentDicts.compactMap({ (momentDict) -> VideoEntry? in
                            if let md = momentDict["moment"] as? [String : Any], let momentJsonData = try? JSONSerialization.data(withJSONObject: md, options: []) {
                                let video = try? JSONDecoder().decode(VideoEntry.self, from: momentJsonData)
                                video?.videoURL = URL(string: momentDict["srcMp4Url"] as! String)
                                return video
                            }
                            return nil
                        })
                        completion(.success((videos, hasMore)))
                    } else {
                        completion(.failure(nil))
                    }
                }
            }
        }
    }

}

private extension HorizonClient {

    static let httpHeaders: HTTPHeaders = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"

        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")

        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                    let osName: String = {
                        #if os(iOS)
                        return "iOS"
                        #elseif os(watchOS)
                        return "watchOS"
                        #elseif os(tvOS)
                        return "tvOS"
                        #elseif os(macOS)
                        return "OS X"
                        #elseif os(Linux)
                        return "Linux"
                        #else
                        return "Unknown"
                        #endif
                    }()

                    return "\(osName) \(versionString)"
                }()

                return "\(executable)/\(appVersion)/\(appBuild);\(deviceModelName());\(osNameVersion);\"\(UIDevice.current.name)\";"
            }

            return "Secure360"
        }()

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
    }()

    func login(with email: String, password: String, completion: @escaping (_ userID: String?, _ token: String?, _ expireTime: TimeInterval?) -> ()) {
        let parameters = ["email" : email, "password" : password]
        request("\(Config.baseURL)/api/users/signin", method: .post, parameters: parameters) { response in
            switch response.result {
            case .failure(_):
                completion(nil, nil, nil)
            case .success(let value):
                if let responseDict = value as? [String : Any],
                    let userID = (responseDict["user"] as? [String : Any])?["userID"] as? String,
                    let token = responseDict["token"] as? String,
                    let expireTime = responseDict["expireTime"] as? TimeInterval {
                    completion(userID, token, expireTime)
                } else {
                    completion(nil, nil, nil)
                }
            }
        }
    }

    @discardableResult
    func request(_ url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completionHandler: @escaping (DataResponse<Any>) -> Void) -> DataRequest {
        let encoding: ParameterEncoding = (method == .post ? JSONEncoding.default : URLEncoding.default)
        return networkingManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            completionHandler(response)
        }
    }

}
