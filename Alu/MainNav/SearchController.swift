import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class SearchController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noOrders: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    let defaults = UserDefaults.standard
    
    var orderArray = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.alpha = 0.0
        searchTextField.borderStyle = .none
        searchTextField.setLeftPaddingPoints(35)
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        noOrders.alpha = 0.0
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
        getOrders()
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        cell.name.text = orderArray[indexPath.row]["title"].string
        cell.price.text = orderArray[indexPath.row]["price_14"].stringValue + "тг"
        let urlOfImage = URL(string: orderArray[indexPath.row]["product_image"][0]["image"].stringValue)!
        cell.orderImage.kf.setImage(with: urlOfImage)
        cell.aboutButton.tag = indexPath.row
        cell.aboutButton.addTarget(self, action: #selector(aboutAction(sender:)), for: .touchUpInside)
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
        if orderArray[indexPath.row]["is_rented"].int == 1{
            cell.bgView.backgroundColor = UIColor(red: 0.9882, green: 0.898, blue: 0.7569, alpha: 1.0)
            cell.basketButton.isUserInteractionEnabled = false
        }
        else{
            if orderArray[indexPath.row]["owner"]["id"].stringValue == defaults.string(forKey: "UID")!{
                cell.basketButton.isUserInteractionEnabled = false
            }
            else{
                cell.basketButton.isUserInteractionEnabled = true
            }
            cell.bgView.backgroundColor = UIColor(red: 0.9647, green: 0.9647, blue: 0.9647, alpha: 1.0)
        }
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
        cell.favoriteButton.tag = orderArray[indexPath.row]["id"].int!
        cell.basketButton.addTarget(self, action: #selector(basketAction(sender:)), for: .touchUpInside)
        cell.basketButton.tag = orderArray[indexPath.row]["id"].int!
        
        return cell
    }
    
    @objc func aboutAction(sender: UIButton){
        let id = sender.tag
        defaults.set(orderArray[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @objc func favoriteAction(sender: UIButton){
        if self.defaults.bool(forKey: "isSignIn") == true{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            let parameters = ["product" : String(sender.tag)]
            AF.request(GlobalVariables.url + "products/favorites", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
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
                case .failure(let error):
                    print(error)
                }
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
    
    @objc func basketAction(sender: UIButton){
        if self.defaults.bool(forKey: "isSignIn") == true{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            let parameters = ["product" : String(sender.tag)]
            AF.request(GlobalVariables.url + "basket/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if (json!["status"] == "ok") {
                        if sender.backgroundImage(for: .normal) == UIImage(named: "basket1"){
                            sender.setBackgroundImage(UIImage(named: "basket"), for: .normal)
                            GlobalVariables.basket.remove(at: GlobalVariables.basket.firstIndex(of: sender.tag)!)
                        }
                        else{
                            sender.setBackgroundImage(UIImage(named: "basket1"), for: .normal)
                            GlobalVariables.basket.append(sender.tag)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
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
    
    func getOrders(){
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        let text = searchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = GlobalVariables.url + "products/filter?" + "&search=" + text
        AF.request(url, method: .get, parameters: nil, headers: nil).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if json != nil{
                self.orderArray = json?.array as! [JSON]
                self.mainTableView.reloadData()
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
                if self.orderArray.count == 0{
                    self.noOrders.alpha = 1.0
                }
                else{
                    self.noOrders.alpha = 0.0
                }
            }
            else{
                self.orderArray = []
                self.mainTableView.reloadData()
                self.noOrders.alpha = 0.0
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
