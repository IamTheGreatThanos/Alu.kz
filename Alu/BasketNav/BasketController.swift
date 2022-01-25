import UIKit
import Foundation
import SwiftyJSON
import Alamofire

class BasketController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var deliveryOnOutlet: UIButton!
    @IBOutlet weak var deliveryOffOutlet: UIButton!
    @IBOutlet weak var returnOnOutlet: UIButton!
    @IBOutlet weak var returnOffOutlet: UIButton!
    
    
    @IBOutlet weak var deliveryAddress: UITextField!
    @IBOutlet weak var returnAddress: UITextField!
    
    @IBOutlet weak var noOrders: UILabel!
    
    var activeTextField: UITextField?
    var deliveryState = true
    var returnState = true
    
    let defaults = UserDefaults.standard
    var orderArray = [JSON]()
    
    var dayStatus = [Int]()
    var totalAmount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noOrders.alpha = 0.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if activeTextField == returnAddress{
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        dayStatus = []
        if self.defaults.bool(forKey: "isSignIn") == true{
            getOrders()
        }
        else{
            let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"AuthorizationController")
                        self.present(viewController, animated: true)
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
                self.heightConstraint.constant = CGFloat(80)
                self.amount.text = "Итого: 0 тг"
                self.noOrders.alpha = 1.0
            }))

            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BTVCell", for: indexPath) as! BasketTableViewCell
        
        cell.name.text = orderArray[indexPath.row]["title"].string
        let urlOfImage = URL(string: orderArray[indexPath.row]["product_image"][0]["image"].stringValue)!
        cell.orderImage.kf.setImage(with: urlOfImage)
        cell.aboutButton.tag = indexPath.row
        cell.aboutButton.addTarget(self, action: #selector(aboutAction(sender:)), for: .touchUpInside)
        cell.days14Button.tag = indexPath.row
        cell.days14Button.addTarget(self, action: #selector(days14Action(sender:)), for: .touchUpInside)
        cell.days30Button.tag = indexPath.row
        cell.days30Button.addTarget(self, action: #selector(days30Action(sender:)), for: .touchUpInside)
        if indexPath.row < dayStatus.count{
            if dayStatus[indexPath.row] == 14{
                cell.days14Button.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
                cell.days30Button.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
                cell.price.text = orderArray[indexPath.row]["price_14"].stringValue + "тг"
            }
            else{
                cell.days14Button.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
                cell.days30Button.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
                cell.price.text = orderArray[indexPath.row]["price_30"].stringValue + "тг"
            }
        }
        if GlobalVariables.favorites.contains(orderArray[indexPath.row]["id"].int!){
            cell.favoriteButton.setBackgroundImage(UIImage(named: "heart1"), for: .normal)
        }
        else{
            cell.favoriteButton.setBackgroundImage(UIImage(named: "heart"), for: .normal)
        }
        if GlobalVariables.basket.contains(orderArray[indexPath.row]["id"].int!){
            cell.basketButton.setBackgroundImage(UIImage(named: "basket1"), for: .normal)
        }
        else{
            cell.basketButton.setBackgroundImage(UIImage(named: "basket"), for: .normal)
        }
        
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
        cell.favoriteButton.tag = orderArray[indexPath.row]["id"].int!
        cell.basketButton.addTarget(self, action: #selector(basketAction(sender:)), for: .touchUpInside)
        cell.basketButton.tag = orderArray[indexPath.row]["id"].int!
        
        return cell
        
    }
    
    
    // MARK: Functions
    
    @objc func favoriteAction(sender: UIButton){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["product" : String(sender.tag)]
        AF.request(GlobalVariables.url + "products/favorites", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if (json!["status"] == "ok") {
                if sender.backgroundImage(for: .normal) == UIImage(named: "heart1"){
                    sender.setBackgroundImage(UIImage(named: "heart"), for: .normal)
                    GlobalVariables.favorites.remove(at: GlobalVariables.favorites.firstIndex(of: sender.tag)!)
                }
                else{
                    sender.setBackgroundImage(UIImage(named: "heart1"), for: .normal)
                    GlobalVariables.favorites.append(sender.tag)
                }
            }
        }
    }
    
    @objc func basketAction(sender: UIButton){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["product" : String(sender.tag)]
        AF.request(GlobalVariables.url + "basket/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if (json!["status"] == "ok") {
                if sender.backgroundImage(for: .normal) == UIImage(named: "basket1"){
                    sender.setBackgroundImage(UIImage(named: "basket"), for: .normal)
                    GlobalVariables.basket.remove(at: GlobalVariables.basket.firstIndex(of: sender.tag)!)
                    self.dayStatus = []
                    self.getOrders()
                }
                else{
                    sender.setBackgroundImage(UIImage(named: "basket1"), for: .normal)
                    GlobalVariables.basket.append(sender.tag)
                }
            }
        }
    }
    
    @objc func aboutAction(sender: UIButton){
        let id = sender.tag
        defaults.set(orderArray[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @objc func days14Action(sender: UIButton){
        dayStatus[sender.tag] = 14
        mainTableView.reloadData()
        var amount = 0
        if deliveryState == true{
            amount += 400
        }
        if returnState == true{
            amount += 400
        }
        
        for i in 0...orderArray.count-1{
            amount += orderArray[i]["price_"+String(dayStatus[i])].int!
        }
        self.amount.text = "Итого: \(amount) тг"
        totalAmount = amount
    }
    
    @objc func days30Action(sender: UIButton){
        dayStatus[sender.tag] = 30
        mainTableView.reloadData()
        var amount = 0
        if deliveryState == true{
            amount += 400
        }
        if returnState == true{
            amount += 400
        }
        for i in 0...orderArray.count-1{
            amount += orderArray[i]["price_"+String(dayStatus[i])].int!
        }
        self.amount.text = "Итого: \(amount) тг"
        totalAmount = amount
    }
    
    func getOrders(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "basket/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { [self] response in
            do{
                if response.data != nil{
                    let json = try? JSON(data: response.data!)
                    if json != nil {
                        self.orderArray = json?.array as! [JSON]
                        if self.orderArray.count != 0{
                            self.heightConstraint.constant = CGFloat(120 * self.orderArray.count)
                            var amount = 0
                            if self.deliveryState == true{
                                amount += 400
                            }
                            if self.returnState == true{
                                amount += 400
                            }
                            for i in json!.arrayValue{
                                amount += i["price_14"].int!
                                self.dayStatus.append(14)
                            }
                            self.amount.text = "Итого: \(amount) тг"
                            self.totalAmount = amount
                        }
                        else{
                            self.heightConstraint.constant = CGFloat(80)
                            self.amount.text = "Итого: 0 тг"
                        }
                        self.mainTableView.reloadData()
                        if self.orderArray.count == 0{
                            self.noOrders.alpha = 1.0
                        }
                        else{
                            self.noOrders.alpha = 0.0
                        }
                    }
                    else{
                        self.heightConstraint.constant = CGFloat(80)
                        self.amount.text = "Итого: 0 тг"
                    }
                }
            }
            catch{
                getOrders()
            }
        }
    }
    
    func sendOrdersFromBasket(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        var bodyDic = [String : Any]()
        if deliveryState == true{
            bodyDic["get_product"] = 1
            bodyDic["get_address"] = deliveryAddress.text!
        }
        else{
            bodyDic["get_product"] = 2
        }
        
        if returnState == true{
            bodyDic["return_product"] = 1
            bodyDic["return_address"] = returnAddress.text!
        }
        else{
            bodyDic["return_product"] = 2
        }
        bodyDic["amount"] = totalAmount
        
        var sendedProducts = [[String : Int]]()
        
        for i in 0...orderArray.count-1{
            var dic = [String : Int]()
            dic["id"] = orderArray[i]["id"].int
            if dayStatus[i] == 14{
                dic["count_day"] = 14
                dic["price"] = orderArray[i]["price_14"].int
            }
            else{
                dic["count_day"] = 30
                dic["price"] = orderArray[i]["price_30"].int
            }
            sendedProducts.append(dic)
        }
        
        bodyDic["products"] = sendedProducts
        
        AF.request(GlobalVariables.url + "basket/rent", method: .post, parameters: bodyDic, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<500).responseJSON { response in
            print(response)
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    GlobalVariables.basket = []
                    self.orderArray = []
                    self.mainTableView.reloadData()
                    self.heightConstraint.constant = CGFloat(120)
                    self.noOrders.alpha = 1.0
                    let alert = UIAlertController(title: "Успешно!", message: "Ваша заявка обрабатывается!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { (alert: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"MessagesController")
                        self.navigationController?.pushViewController(viewController,
                        animated: true)
                    }))
                    self.present(alert, animated: true)
                    self.amount.text = "Итого: 0 тг"
                    self.returnAddress.text = ""
                    self.deliveryAddress.text = ""
                }
                else if(json!["status"] == "already to rent"){
                    GlobalVariables.basket = []
                    self.orderArray = []
                    self.mainTableView.reloadData()
                    self.heightConstraint.constant = CGFloat(120)
                    self.noOrders.alpha = 1.0
                    let alert = UIAlertController(title: "Внимание!", message: "Заказ уже в аренде!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.amount.text = "Итого: 0 тг"
                    self.returnAddress.text = ""
                    self.deliveryAddress.text = ""
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func deliveryOnButton(_ sender: UIButton) {
        if deliveryState == false{
            deliveryOnOutlet.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
            deliveryOffOutlet.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
            deliveryState = true
            self.totalAmount += 400
            self.amount.text = "Итого: \(totalAmount) тг"
        }
    }
    
    @IBAction func deliveryOffButton(_ sender: UIButton) {
        if deliveryState == true{
            deliveryOnOutlet.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
            deliveryOffOutlet.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
            deliveryState = false
            self.totalAmount -= 400
            self.amount.text = "Итого: \(totalAmount) тг"
        }
    }
    
    
    @IBAction func returnOnButton(_ sender: UIButton) {
        if returnState == false{
            returnOnOutlet.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
            returnOffOutlet.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
            returnState = true
            self.totalAmount += 400
            self.amount.text = "Итого: \(totalAmount) тг"
        }
    }
    
    @IBAction func returnOffButton(_ sender: UIButton) {
        if returnState == true{
            returnOnOutlet.setBackgroundImage(UIImage(named: "Checkmark-0"), for: .normal)
            returnOffOutlet.setBackgroundImage(UIImage(named: "Checkmark-1"), for: .normal)
            returnState = false
            self.totalAmount -= 400
            self.amount.text = "Итого: \(totalAmount) тг"
        }
    }
    
    @IBAction func acceptButton(_ sender: UIButton) {
        if orderArray.count != 0{
            if deliveryState == true {
                if deliveryAddress.text!.count > 8{
                    if returnState == true{
                        if returnAddress.text!.count > 8{
                            self.sendOrdersFromBasket()
//                            print(deliveryAddress.text!)
//                            print(returnAddress.text!)
//                            print("Dev State \(deliveryState)")
//                            print("Ret State \(returnState)")
                        }
                        else{
                            let alert = UIAlertController(title: "Внимание!", message: "Введите адрес возврата товара!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        self.sendOrdersFromBasket()
//                        print(deliveryAddress.text!)
//                        print("No return address")
//                        print("Dev State \(deliveryState)")
//                        print("Ret State \(returnState)")
                    }
                }
                else{
                    let alert = UIAlertController(title: "Внимание!", message: "Введите адрес доставки товара!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else{
                if returnState == true{
                    if returnAddress.text!.count > 8{
                        self.sendOrdersFromBasket()
//                        print("No dev address")
//                        print(returnAddress.text!)
//                        print("Dev State \(deliveryState)")
//                        print("Ret State \(returnState)")
                    }
                    else{
                        let alert = UIAlertController(title: "Внимание!", message: "Введите адрес возврата товара!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
                else{
                    self.sendOrdersFromBasket()
//                    print("No dev address")
//                    print("No return address")
//                    print("Dev State \(deliveryState)")
//                    print("Ret State \(returnState)")
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Внимание!", message: "Ваша корзина пуста!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
