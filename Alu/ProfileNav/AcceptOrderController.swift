import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class AcceptOrderController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stayButtonOutlet: UIButton!
    @IBOutlet weak var goToButtonOutlet: UIButton!
    
    let defaults = UserDefaults.standard
    
    var actionType = 0
    var id = 0
    var selectedTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionType = defaults.integer(forKey: "MessageActionType")
        id = defaults.integer(forKey: "MessageID")
        
        if actionType == 2{
            stayButtonOutlet.alpha = 0.0
        }
        
        if actionType == 4{
            goToButtonOutlet.alpha = 1.0
        }
        else{
            goToButtonOutlet.alpha = 0.0
        }
        
        if actionType == 3{
            stayButtonOutlet.setTitle("Самовывоз в пункт выдачи заказов", for: .normal)
        }
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        selectedTime = dateFormatter.string(from: datePicker.date)
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func acceptButton(_ sender: UIButton) {
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["id" : String(id), "date": selectedTime, "leave": "false"]
        AF.request(GlobalVariables.url + "message/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    let alert = UIAlertController(title: "Успешно!", message: "Мы приняли ваш выбор.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {(alert: UIAlertAction!) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func stayButton(_ sender: UIButton) {
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["id" : String(id), "action": "1"]
        AF.request(GlobalVariables.url + "message/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    let alert = UIAlertController(title: "Успешно!", message: "Мы приняли ваш выбор.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {(alert: UIAlertAction!) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["id" : String(id), "action": "2"]
        AF.request(GlobalVariables.url + "message/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    let alert = UIAlertController(title: "Успешно!", message: "Мы приняли ваш выбор.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {(alert: UIAlertAction!) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
