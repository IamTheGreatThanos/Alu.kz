import UIKit
import Foundation
import SwiftyJSON
import Alamofire

class CreateController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var price2TextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var number1TextField: UITextField!
    @IBOutlet weak var number2TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var activeTextField: UITextField?
    let defaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    var selectedImageView = 1
    var ifImageSelect = 0
    
    var image1 = UIImage(named: "rectangle_gray")!
    var image2 = UIImage(named: "rectangle_gray")!
    var image3 = UIImage(named: "rectangle_gray")!
    var image4 = UIImage(named: "rectangle_gray")!
    var image5 = UIImage(named: "rectangle_gray")!
    var image6 = UIImage(named: "rectangle_gray")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldsDesign()
        number1TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        number2TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        priceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        price2TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imagePicker.delegate = self
        
        alphaView.alpha = 0.0
        activityIndicator.alpha = 0.0
        activityIndicator.stopAnimating()
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if activeTextField == number1TextField || activeTextField == number2TextField || activeTextField == addressTextField{
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldsDesign(){
        nameTextField.borderStyle = .none
        priceTextField.borderStyle = .none
        price2TextField.borderStyle = .none
        addressTextField.borderStyle = .none
        number1TextField.borderStyle = .none
        number2TextField.borderStyle = .none
        cityTextField.borderStyle = .none
        aboutTextField.borderStyle = .none
        
        nameTextField.setLeftPaddingPoints(10)
        priceTextField.setLeftPaddingPoints(10)
        price2TextField.setLeftPaddingPoints(10)
        addressTextField.setLeftPaddingPoints(10)
        number1TextField.setLeftPaddingPoints(10)
        number2TextField.setLeftPaddingPoints(10)
        cityTextField.setLeftPaddingPoints(10)
        aboutTextField.setLeftPaddingPoints(10)
        
        nameTextField.layer.cornerRadius = 15
        priceTextField.layer.cornerRadius = 15
        price2TextField.layer.cornerRadius = 15
        addressTextField.layer.cornerRadius = 15
        number1TextField.layer.cornerRadius = 15
        number2TextField.layer.cornerRadius = 15
        cityTextField.layer.cornerRadius = 15
        aboutTextField.layer.cornerRadius = 15

        nameTextField.clipsToBounds = true
        priceTextField.clipsToBounds = true
        price2TextField.clipsToBounds = true
        addressTextField.clipsToBounds = true
        number1TextField.clipsToBounds = true
        number2TextField.clipsToBounds = true
        cityTextField.clipsToBounds = true
        aboutTextField.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField == number1TextField{
            if self.number1TextField.text!.count < 6{
                self.number1TextField.text = "+7 ("
            }
        }
        if textField == number2TextField{
            if self.number2TextField.text!.count < 6{
                self.number2TextField.text = "+7 ("
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
        
        number1TextField.inputAccessoryView = doneToolbar
        number2TextField.inputAccessoryView = doneToolbar
        priceTextField.inputAccessoryView = doneToolbar
        price2TextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == number1TextField{
            if number1TextField.text?.count == 3{
                number1TextField.text = "+7 ("
            }
            
            if number1TextField.text?.count == 7{
                number1TextField.text! += ") "
            }
            if number1TextField.text?.count == 8{
                number1TextField.text! = String(number1TextField.text!.prefix(6))
            }
            
            if number1TextField.text?.count == 12{
                number1TextField.text! += "  "
            }
            if number1TextField.text?.count == 13{
                number1TextField.text! = String(number1TextField.text!.prefix(11))
            }
            if number1TextField.text?.count == 16{
                number1TextField.text! += "  "
            }
            if number1TextField.text?.count == 17{
                number1TextField.text! = String(number1TextField.text!.prefix(15))
            }
            if number1TextField.text?.count == 21{
                number1TextField.text! = String(number1TextField.text!.prefix(20))
            }
        }
        if textField == number2TextField{
            if number2TextField.text?.count == 3{
                number2TextField.text = "+7 ("
            }
            
            if number2TextField.text?.count == 7{
                number2TextField.text! += ") "
            }
            if number2TextField.text?.count == 8{
                number2TextField.text! = String(number2TextField.text!.prefix(6))
            }
            
            if number2TextField.text?.count == 12{
                number2TextField.text! += "  "
            }
            if number2TextField.text?.count == 13{
                number2TextField.text! = String(number2TextField.text!.prefix(11))
            }
            if number2TextField.text?.count == 16{
                number2TextField.text! += "  "
            }
            if number2TextField.text?.count == 17{
                number2TextField.text! = String(number2TextField.text!.prefix(15))
            }
            if number2TextField.text?.count == 21{
                number2TextField.text! = String(number2TextField.text!.prefix(20))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let resizedImage = pickedImage.resizeWithWidth(width: 600)!
            ifImageSelect = 1
            if selectedImageView == 1{
                self.imageView1.image = resizedImage
                image1 = resizedImage
            }
            else if selectedImageView == 2{
                self.imageView2.image = resizedImage
                image2 = resizedImage
            }
            else if selectedImageView == 3{
                self.imageView3.image = resizedImage
                image3 = resizedImage
            }
            else if selectedImageView == 4{
                self.imageView4.image = resizedImage
                image4 = resizedImage
            }
            else if selectedImageView == 5{
                self.imageView5.image = resizedImage
                image5 = resizedImage
            }
            else if selectedImageView == 6{
                self.imageView6.image = resizedImage
                image6 = resizedImage
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func loadImage1(_ sender: UIButton) {
        selectedImageView = 1
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func loadImage2(_ sender: UIButton) {
        selectedImageView = 2
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func loadImage3(_ sender: UIButton) {
        selectedImageView = 3
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func loadImage4(_ sender: UIButton) {
        selectedImageView = 4
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func loadImage5(_ sender: UIButton) {
        selectedImageView = 5
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func loadImage6(_ sender: UIButton) {
        selectedImageView = 6
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func createButton(_ sender: UIButton) {
        if self.defaults.bool(forKey: "isSignIn") == true{
            if nameTextField.text!.count > 4{
                nameTextField.layer.borderWidth = 0
                if aboutTextField.text!.count > 1{
                    aboutTextField.layer.borderWidth = 0
                    if priceTextField.text!.count > 2{
                        priceTextField.layer.borderWidth = 0
                        if price2TextField.text!.count > 2{
                            price2TextField.layer.borderWidth = 0
                            if addressTextField.text!.count > 1{
                                addressTextField.layer.borderWidth = 0
                                if number1TextField.text!.count == 20{
                                    number1TextField.layer.borderWidth = 0
                                    if number2TextField.text!.count == 20{
                                        number2TextField.layer.borderWidth = 0
                                        if ifImageSelect == 1{
                                            alphaView.alpha = 1.0
                                            activityIndicator.alpha = 1.0
                                            activityIndicator.startAnimating()
                                            
                                            let headers: HTTPHeaders = [
                                                "Authorization": "Token " + defaults.string(forKey: "Token")!,
                                              "Accept": "application/json"
                                            ]
                                            
                                            let phone1 = number1TextField.text![1..<2] + number1TextField.text![4..<7] + number1TextField.text![9..<12] + number1TextField.text![14..<16] + number1TextField.text![18..<20]
                                            let phone2 = number2TextField.text![1..<2] + number2TextField.text![4..<7] + number2TextField.text![9..<12] + number2TextField.text![14..<16] + number2TextField.text![18..<20]
                                            
                                            let phoneArr = [String(phone1), String(phone2)]
                                            var imageArr  = [String]()
                                            if image1 != UIImage(named: "rectangle_gray") && imageView1.image != UIImage(named: "rectangle_gray"){
                                                imageArr.append(image1.jpegData(compressionQuality: 0.75)!.base64EncodedString())
                                            }
                                            if image2 != UIImage(named: "rectangle_gray") && imageView2.image != UIImage(named: "rectangle_gray"){
                                                let jpegData = image2.jpegData(compressionQuality: 0.75)!
                                                imageArr.append(jpegData.base64EncodedString())
                                            }
                                            if image3 != UIImage(named: "rectangle_gray") && imageView3.image != UIImage(named: "rectangle_gray"){
                                                imageArr.append(image3.jpegData(compressionQuality: 0.75)!.base64EncodedString())
                                            }
                                            if image4 != UIImage(named: "rectangle_gray") && imageView4.image != UIImage(named: "rectangle_gray"){
                                                imageArr.append(image4.jpegData(compressionQuality: 0.75)!.base64EncodedString())
                                            }
                                            if image5 != UIImage(named: "rectangle_gray") && imageView5.image != UIImage(named: "rectangle_gray"){
                                                imageArr.append(image5.jpegData(compressionQuality: 0.75)!.base64EncodedString())
                                            }
                                            if image6 != UIImage(named: "rectangle_gray") && imageView6.image != UIImage(named: "rectangle_gray"){
                                                imageArr.append(image6.jpegData(compressionQuality: 0.75)!.base64EncodedString())
                                            }
                                            let parameters = ["title" : nameTextField.text!, "about" : aboutTextField.text!, "price_14" : priceTextField.text!, "price_30" : price2TextField.text!, "phones" : phoneArr, "address" : addressTextField.text!, "product_image" : imageArr] as [String : Any]
                                            AF.request(GlobalVariables.url + "products/create", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
                                                switch response.result {
                                                    case .success(_):
                                                        let json = try? JSON(data: response.data!)
                                                        if (json!["status"] == "ok") {
                                                            let alert = UIAlertController(title: "Поздравляю!", message: "Ваша заявка принята!", preferredStyle: .alert)
                                                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { (alert: UIAlertAction!) in
                                                                self.nameTextField.text = ""
                                                                self.aboutTextField.text = ""
                                                                self.priceTextField.text = ""
                                                                self.price2TextField.text = ""
                                                                self.imageView1.image = UIImage(named: "rectangle_gray")
                                                                self.imageView2.image = UIImage(named: "rectangle_gray")
                                                                self.imageView3.image = UIImage(named: "rectangle_gray")
                                                                self.imageView4.image = UIImage(named: "rectangle_gray")
                                                                self.imageView5.image = UIImage(named: "rectangle_gray")
                                                                self.imageView6.image = UIImage(named: "rectangle_gray")
                                                                self.image1 = UIImage(named: "rectangle_gray")!
                                                                self.image2 = UIImage(named: "rectangle_gray")!
                                                                self.image3 = UIImage(named: "rectangle_gray")!
                                                                self.image4 = UIImage(named: "rectangle_gray")!
                                                                self.image5 = UIImage(named: "rectangle_gray")!
                                                                self.image6 = UIImage(named: "rectangle_gray")!
                                                                self.addressTextField.text = ""
                                                                self.number1TextField.text = ""
                                                                self.number2TextField.text = ""
                                                                self.ifImageSelect = 0
                                                                self.alphaView.alpha = 0.0
                                                                self.activityIndicator.alpha = 0.0
                                                                self.activityIndicator.stopAnimating()
                                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                                let viewController = storyboard.instantiateViewController(withIdentifier :"MyOrdersController")
                                                                self.navigationController?.pushViewController(viewController,
                                                                animated: true)
                                                            }))
                                                            self.present(alert, animated: true)
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                        let alert = UIAlertController(title: "Извините", message: "Ошибка соединения с интернетом… Проверьте соединение или повторите чуть позднее!", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {(alert: UIAlertAction!) in
                                                            self.alphaView.alpha = 0.0
                                                            self.activityIndicator.alpha = 0.0
                                                            self.activityIndicator.stopAnimating()
                                                        }))
                                                        self.present(alert, animated: true)
                                                }
                                            }
                                        }
                                        else{
                                            let alert = UIAlertController(title: "Внимание!", message: "Загрузите фотография товара!", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        }
                                    }
                                    else{
                                        number2TextField.layer.borderWidth = 1
                                        number2TextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                                        let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    }
                                }
                                else{
                                    
                                    number1TextField.layer.borderWidth = 1
                                    number1TextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                                    let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                                    self.present(alert, animated: true)
                                }
                            }
                            else{
                                addressTextField.layer.borderWidth = 1
                                addressTextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                                let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            }
                        }
                        else{
                            price2TextField.layer.borderWidth = 1
                            price2TextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                            let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        priceTextField.layer.borderWidth = 1
                        priceTextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                        let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                else{
                    aboutTextField.layer.borderWidth = 1
                    aboutTextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                    let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else{
                nameTextField.layer.borderWidth = 1
                nameTextField.layer.borderColor = UIColor(red: 0.9373, green: 0, blue: 0, alpha: 1.0).cgColor
                let alert = UIAlertController(title: "Внимание!", message: "Заполните все поля!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else{
            let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"AuthorizationController")
                        self.present(viewController, animated: true)
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
            }))

            present(alert, animated: true, completion: nil)
        }
    }
    
    
}
