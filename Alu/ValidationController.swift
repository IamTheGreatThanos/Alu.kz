import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class ValidationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var codeTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonOnKeyboard()
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == codeTextField{
            if codeTextField.text!.count < 1{
                codeTextField.text! = "   "
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == codeTextField{
            if codeTextField.text!.count < 3{
                codeTextField.text! = "   "
            }
            if codeTextField.text!.count == 4{
                codeTextField.text! += "       "
            }
            if codeTextField.text!.count == 10{
                codeTextField.text! = String(codeTextField.text!.prefix(4))
            }
            if codeTextField.text!.count == 12{
                codeTextField.text! += "       "
            }
            if codeTextField.text!.count == 18{
                codeTextField.text! = String(codeTextField.text!.prefix(12))
            }
            if codeTextField.text!.count == 20{
                codeTextField.text! += "       "
            }
            if codeTextField.text!.count == 26{
                codeTextField.text! = String(codeTextField.text!.prefix(20))
            }
            if codeTextField.text!.count == 29{
                codeTextField.text = String(codeTextField.text!.prefix(28))
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        codeTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    func sendDeviceToken(){
        if defaults.string(forKey: "DeviceToken") != nil{
            let deviceToken = defaults.string(forKey: "DeviceToken")!
            
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            
            let parameters = ["cmt" : "apn", "reg_id" : deviceToken]
            
            AF.request(GlobalVariables.url + "users/push", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
                print(json)
            }
        }
        
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        if codeTextField.text!.count == 28 {
            let number = defaults.string(forKey: "PhoneNumber")!
            let code = codeTextField.text![3] + codeTextField.text![11] + codeTextField.text![19] + codeTextField.text![27]
            let parameters = ["phone" : String(number), "code" : String(code)]
            AF.request(GlobalVariables.url + "users/register/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    self.defaults.set(json!["key"].string, forKey: "Token")
                    self.defaults.set(String(json!["uid"].int!), forKey: "UID")
                    self.defaults.set(json!["nickname"].string, forKey: "Name")
                    self.defaults.set(true, forKey: "isSignIn")
                    
                    self.sendDeviceToken()
                    
                    let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                    mainTabController.selectedViewController = mainTabController.viewControllers?[0]
                    self.present(mainTabController, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Внимание!", message: "СМС код не совпадает.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Внимание!", message: "СМС код неправильного формата.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
