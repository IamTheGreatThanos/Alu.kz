import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ava: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    let defaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.defaults.bool(forKey: "isSignIn") == true{
            if defaults.string(forKey: "Name") != nil{
                name.text = defaults.string(forKey: "Name")!
            }
            phone.text = "+" + defaults.string(forKey: "PhoneNumber")!
            imagePicker.delegate = self
            getInfo()
        }
        else{
            let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"AuthorizationController")
                        self.present(viewController, animated: true)
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
                let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                mainTabController.selectedViewController = mainTabController.viewControllers?[0]
                self.present(mainTabController, animated: true, completion: nil)
            }))

            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let resizedImage = pickedImage.resizeWithWidth(width: 480)!
            let compressData = pickedImage.jpegData(compressionQuality: 0.0) //max value is 1.0 and minimum is 0.0
            let compressedImage = UIImage(data: compressData!)!
            ava.image = compressedImage
            dismiss(animated: true, completion: nil)
            
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            
            let imgStr = compressData!.base64EncodedString()
            let parameters = ["avatar" : imgStr]
            AF.request(GlobalVariables.url + "users/avatar", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
            }
        }
    }
    
    // MARK: Get Info
    
    func getInfo(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "users/detail/" + defaults.string(forKey: "UID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json!["avatar"].stringValue != (GlobalVariables.url + "media/default/default.png"){
                    let url = URL(string: json!["avatar"].stringValue)
                    self.ava.kf.setImage(with: url)
                }
                self.name.text = json!["nickname"].string
                self.defaults.set(json!["nickname"].string, forKey: "Name")
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Извините", message: "Ошибка соединения с интернетом… Проверьте соединение или повторите чуть позднее!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func rentButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RentController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    
    @IBAction func myOrders(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"MyOrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    
    @IBAction func messagesButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"MessagesController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func changeAvaTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func goToMessages(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"MessagesController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
}
