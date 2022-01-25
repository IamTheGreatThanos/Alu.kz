import UIKit
import Alamofire
import SwiftyJSON

class AuthorizationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var phoneConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstText: UIImageView!
    @IBOutlet weak var secondText: UIImageView!
    @IBOutlet weak var checkmark_1: UIImageView!
    @IBOutlet weak var checkmark_2: UIImageView!
    @IBOutlet weak var line_1: UIImageView!
    @IBOutlet weak var line_2: UIImageView!
    
    let defaults = UserDefaults.standard
    
    var isChecked_1 = 1
    var isChecked_2 = 1
    
    var isSignIn = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonOnKeyboard()
        line_1.alpha = 0.0
        
        let tapGestureRecognizer_1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped_1(tapGestureRecognizer:)))
        let tapGestureRecognizer_2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped_2(tapGestureRecognizer:)))
        let tapGestureRecognizer_3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped_3(tapGestureRecognizer:)))
        
        firstText.addGestureRecognizer(tapGestureRecognizer_1)
        
        checkmark_1.addGestureRecognizer(tapGestureRecognizer_2)
        
        checkmark_2.addGestureRecognizer(tapGestureRecognizer_3)
    }
    
    @objc func imageTapped_1(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"AgreementController")
        self.present(viewController, animated: true)
    }
    
    @objc func imageTapped_2(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if isChecked_1 == 1{
            isChecked_1 = 0
            checkmark_1.image = UIImage(named: "Checkmark-0")
        }
        else{
            isChecked_1 = 1
            checkmark_1.image = UIImage(named: "Checkmark-1")
        }
    }
    
    @objc func imageTapped_3(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if isChecked_2 == 1{
            isChecked_2 = 0
            checkmark_2.image = UIImage(named: "Checkmark-0")
        }
        else{
            isChecked_2 = 1
            checkmark_2.image = UIImage(named: "Checkmark-1")
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == numberTextField{
            if self.numberTextField.text!.count < 6{
                self.numberTextField.text = "+7 ("
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == numberTextField{
            if numberTextField.text?.count == 3{
                numberTextField.text = "+7 ("
            }
            
            if numberTextField.text?.count == 7{
                numberTextField.text! += ") "
            }
            if numberTextField.text?.count == 8{
                numberTextField.text! = String(numberTextField.text!.prefix(6))
            }
            
            if numberTextField.text?.count == 12{
                numberTextField.text! += "  "
            }
            if numberTextField.text?.count == 13{
                numberTextField.text! = String(numberTextField.text!.prefix(11))
            }
            if numberTextField.text?.count == 16{
                numberTextField.text! += "  "
            }
            if numberTextField.text?.count == 17{
                numberTextField.text! = String(numberTextField.text!.prefix(15))
            }
            if numberTextField.text?.count == 21{
                numberTextField.text! = String(numberTextField.text!.prefix(20))
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
        
        numberTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }

    @IBAction func signInButton(_ sender: UIButton) {
        checkmark_1.alpha = 0.0
        checkmark_2.alpha = 0.0
        firstText.alpha = 0.0
        secondText.alpha = 0.0
        line_2.alpha = 0.0
        line_1.alpha = 1.0
        nameTextField.alpha = 0.0
        nameLabel.alpha = 0.0
        phoneConstraint.constant = 60
        isSignIn = 1
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        checkmark_1.alpha = 1.0
        checkmark_2.alpha = 1.0
        firstText.alpha = 1.0
        secondText.alpha = 1.0
        line_2.alpha = 1.0
        line_1.alpha = 0.0
        nameTextField.alpha = 1.0
        nameLabel.alpha = 1.0
        phoneConstraint.constant = 80
        isSignIn = 0
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        if isSignIn == 1{
            if numberTextField.text!.count == 20 && numberTextField.text!.count > 3{
                let number = numberTextField.text![1..<2] + numberTextField.text![4..<7] + numberTextField.text![9..<12] + numberTextField.text![14..<16] + numberTextField.text![18..<20]
                let parameters = ["phone" : String(number)]
                AF.request(GlobalVariables.url + "users/phone/check", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                    let json = try? JSON(data: response.data!)
                    if (json!["status"] == "ok") {
                        self.defaults.set(String(number), forKey: "PhoneNumber")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"ValidationController")
                        self.present(viewController, animated: true)
                    }
                    else{
                        let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы. Пожалуйста, зарегистрируйтесь!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
            else{
                let alert = UIAlertController(title: "Внимание!", message: "Имя или номер сотового неверного формата.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else{
            if isChecked_1 == 1{
                if numberTextField.text!.count == 20 && numberTextField.text!.count > 3{
                    let number = numberTextField.text![1..<2] + numberTextField.text![4..<7] + numberTextField.text![9..<12] + numberTextField.text![14..<16] + numberTextField.text![18..<20]
                    let parameters = ["phone" : String(number), "name" : nameTextField.text!]
                    AF.request(GlobalVariables.url + "users/phone/otp/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                        let json = try? JSON(data: response.data!)
                        if (json!["status"] == "ok") {
                            self.defaults.set(String(number), forKey: "PhoneNumber")
                            self.defaults.set(self.nameTextField.text!, forKey: "Name")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier :"ValidationController")
                            self.present(viewController, animated: true)
                        }
                    }
                }
                else{
                    let alert = UIAlertController(title: "Внимание!", message: "Имя или номер сотового неверного формата.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else{
                let alert = UIAlertController(title: "Извините", message: "Нужно согласие на обработку данных.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

