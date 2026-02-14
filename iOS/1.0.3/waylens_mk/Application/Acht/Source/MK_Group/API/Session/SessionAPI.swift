//
//  AuthAPI.swift
//  test_alamofire
//
//  Created by TranHoangThanh on 12/17/21.
//

import Foundation

import Moya


protocol  SessionAPI {
    func login(name: String, password: String , completion :  completionBlock?)
    func logout(completion :  completionBlock?)
    func changePassword(newPassword : String ,oldPassword : String , completion: completionBlock?)
    func removeAccount(idAccount: Int, completion: completionBlock?)

}


class  SessionService : SessionAPI  {
    

    static let shared : SessionAPI = SessionService()
    let authProvider = MoyaProvider<SessionHttpRouter>(plugins: [NetworkLoggerPlugin(verbose: true)])
    //let authProvider = MoyaProvider<AuthHttpRouter>()
    
    func login(name: String, password: String , completion : completionBlock?) {
        authProvider.request(.login(name: name, password: password), completionHandler: completion)
    }
    
    func logout(completion: completionBlock?) {
        authProvider.request(.logout, completionHandler: completion)
    }
    
    
    func changePassword(newPassword : String ,oldPassword : String , completion: completionBlock?) {
        authProvider.request(.changePassword(newPassword: newPassword, oldPassword: oldPassword), completionHandler: completion)
    }
    
    func removeAccount(idAccount: Int, completion: completionBlock?){
        authProvider.request(.removeAccount(id: idAccount), completionHandler: completion)
    }
    

}
