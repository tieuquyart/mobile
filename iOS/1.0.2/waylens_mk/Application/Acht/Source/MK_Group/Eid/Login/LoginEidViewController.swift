import UIKit
import eID_SDK_MKV


//protocol Convertable: Codable {
//
//}
//
//extension Convertable {
//
//    /// implement convert Struct or Class to Dictionary
//    func convertToDict() -> Dictionary<String, Any> {
//
//        var dict: Dictionary<String, Any> = [:]
//
//        do {
//            print("init model")
//
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(self)
//
//            print("struct convert to data")
//
//            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> ?? [:]
//
//        } catch {
//            print(error)
//        }
//
//        return dict
//    }
//}



struct DeviceInfo: Convertable {
    var providerCode: String
    let requestId: String
    let deviceId: String
    let encryptedData: String
    let encryptedRandomData: String
    let time: Int
    let appId: Int
    var signature: String
}
protocol LoginEidViewControllerDelegate : AnyObject {
    func rootFace()
}
class LoginEidViewController: BaseViewController {
    var helper  = ConstantMK.helperMK
    var andCustomerId = ""
    var andProviderId = "0"
    var andBranchId = "1"
    var deviceName = ""
    var deviceId = ""
    var deviceInfoForRegisterDevice = ""
    weak var delegate : LoginEidViewControllerDelegate?
    @IBOutlet weak var customerIdTf: UITextField!
    @IBOutlet weak var providerCodeTf: UITextField!
    @IBOutlet weak var appIdTf: UITextField!
    @IBOutlet weak var  activeButton: UIButton!
    func setBorderView(view : UIButton) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        helper.setUrl(value: "https://dev.mk.com.vn:15562/api/")
        getDeviceInfoForRegisterDevice()
        self.setBorderView(view: activeButton)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initHeader(text: "Đăng ký thiết bị", leftButton: false)
    }
    @IBAction func activeButton(_ sender: Any) {
        self.activate()
    }
    func showAlert (_ errorStr : String) {
        let alert = UIAlertController(title: "", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //b3 present
        present(alert, animated: true, completion: nil)
    }
    func activate() {
        self.showProgress()
        helper.doActivate(andCustomerId: "", andBranchId: "") {
            //print("thanh")
            self.showToast(message: "Kích hoạt thành công", seconds: 1.0, completion: {
                self.hideProgress()
                let vc = FaceVerifiedViewController(nibName: "FaceVerifiedViewController", bundle: nil)
                vc.isLoginEid = true
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.pushViewController(vc, animated: false)
            })
        } andFailureHandler: { (err) in
            
            self.hideProgress()
            self.showAlert(err.localizedDescription)
        } errorHandler: { (err) in
            
            self.hideProgress()
            self.showAlert("\(err.rawValue)")
        }
    }
    func getDeviceInfoForRegisterDevice() {
        self.showProgress()
        helper.getDeviceInfoForRegisterDevice() { res in
            print("res",res)
            do {
                
                guard let data = res.data(using: .utf8) else {return}
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let websiteDescription = try decoder.decode(DeviceInfo.self, from: data)
                self.postRequestRegisterDeviceV2(param: websiteDescription) { (result, error) in
                    if let result = result {
                        if let success = result["success"] as? Bool {
                            if success {
                                self.hideProgress()
                                //                                 self.activate()
                            }
                        }
                    } else if let error = error {
                        self.hideProgress()
                        print("error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showAlert(error.localizedDescription)
                        }
                        return
                    }
                }
            } catch let err {
                self.hideProgress()
                self.showAlert("\(err.localizedDescription)")
            }
        } errorHandlerSDK: { err1 in
            self.hideProgress()
            self.showAlert("\(err1.localizedDescription)")
        } errorHandler: { err1 in
            self.hideProgress()
            self.showAlert("\(err1.rawValue)")
        }
    }
    func postRequestRegisterDeviceV2(param : DeviceInfo , completion: @escaping ([String: Any]?, Error?) -> Void) {
        //declare parameter as a dictionary which contains string as key and value combination.
        let parameters : [String : Any] = param.convertToDict()
        //create the url with NSURL
        // print("parameters",parameters)
        let username = "api"
        let password = "apipassword1"
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        let url = URL(string: "https://dev.mk.com.vn:15664/api/registerDeviceV2")!
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        // let session = URLSession.shared
        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            // pass dictionary to data object and set it as request body
        } catch let error {
            print(error.localizedDescription)
            completion(nil, error)
        }
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        task.resume()
    }
}
extension LoginEidViewController : URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
