import UIKit

class AuthorizationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstText: UIImageView!
    @IBOutlet weak var secondText: UIImageView!
    @IBOutlet weak var checkmark_1: UIImageView!
    @IBOutlet weak var checkmark_2: UIImageView!
    @IBOutlet weak var line_1: UIImageView!
    @IBOutlet weak var line_2: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonOnKeyboard()
        line_1.alpha = 0.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        checkmark_1.isUserInteractionEnabled = true
        checkmark_2.isUserInteractionEnabled = true
        checkmark_1.addGestureRecognizer(tapGestureRecognizer)
        checkmark_2.addGestureRecognizer(tapGestureRecognizer)
        firstText.isUserInteractionEnabled = true
        firstText.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if tappedImage == firstText{
            guard let url = URL(string: "http://mobile-app.eco-products.kz") else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else if tappedImage == checkmark_1{
            print("Second")
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
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        checkmark_1.alpha = 1.0
        checkmark_2.alpha = 1.0
        firstText.alpha = 1.0
        secondText.alpha = 1.0
        line_2.alpha = 1.0
        line_1.alpha = 0.0
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"ValidationController")
        self.present(viewController, animated: true)
    }
}

