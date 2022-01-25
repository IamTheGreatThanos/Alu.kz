import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class MainController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    
    let defaults = UserDefaults.standard
    var orderArray = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        searchTextField.borderStyle = .none
        searchTextField.setLeftPaddingPoints(35)
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        searchTextField.isUserInteractionEnabled = false
        GlobalVariables.basket = []
        GlobalVariables.favorites = []
        if self.defaults.bool(forKey: "isSignIn") == true{
            getFavorites()
            getBasket()
        }
        else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        getRecomendation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"SearchController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestingCollectionViewCell", for: indexPath) as! InterestingCollectionViewCell
        
        cell.name.text = orderArray[indexPath.row]["title"].string
        cell.price.text = orderArray[indexPath.row]["price_14"].stringValue + "тг"
        let urlOfImage = URL(string: orderArray[indexPath.row]["product_image"][0]["image"].stringValue)!
        cell.imageView.kf.setImage(with: urlOfImage)
        
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
            cell.bgView.backgroundColor = UIColor.white
        }
        
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
        cell.favoriteButton.tag = orderArray[indexPath.row]["id"].int!
        cell.basketButton.addTarget(self, action: #selector(basketAction(sender:)), for: .touchUpInside)
        cell.basketButton.tag = orderArray[indexPath.row]["id"].int!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = indexPath.row
        defaults.set(orderArray[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func electronicButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
        
        defaults.set("Электроника", forKey: "mainTitle")
        defaults.set("4", forKey: "Category_id")
    }
    @IBAction func forHomeButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
        
        defaults.set("Дом и сад", forKey: "mainTitle")
        defaults.set("3", forKey: "Category_id")
    }
    @IBAction func hobbyButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
        
        defaults.set("Хобби", forKey: "mainTitle")
        defaults.set("1", forKey: "Category_id")
    }
    @IBAction func babylonButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
        
        defaults.set("Babylon", forKey: "mainTitle")
        defaults.set("2", forKey: "Category_id")
    }
    @IBAction func styleButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrdersController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
        
        defaults.set("Мода", forKey: "mainTitle")
        defaults.set("5", forKey: "Category_id")
    }
    
    // MARK: Finctions
    
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
    
    func getFavorites(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        DispatchQueue.global().async {
            AF.request(GlobalVariables.url + "products/favorites", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if json != nil {
                        for i in json!.arrayValue{
                            GlobalVariables.favorites.append(i["id"].int!)
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.getFavorites()
                }
            }
        }
    }
    
    func getBasket(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        DispatchQueue.global().async {
            AF.request(GlobalVariables.url + "basket/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if json != nil {
                        for i in json!.arrayValue{
                            GlobalVariables.basket.append(i["id"].int!)
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.getBasket()
                }
            }
        }
    }
    
    func getRecomendation(){
        DispatchQueue.global().async {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10 // seconds
            configuration.timeoutIntervalForResource = 10
            configuration.requestCachePolicy = .useProtocolCachePolicy
//            let sessionManger = Session(configuration: configuration, startRequestsImmediately: true)
            
            let headers: HTTPHeaders
                headers = ["Connection": "keep-alive"]

            AF.request(GlobalVariables.url + "products/recomendation", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { [self] response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if json != nil {
                        self.orderArray = json?.array as! [JSON]
                        self.mainCollectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.alpha = 0.0
                    }
                case .failure(let error):
                    print(error)
                    self.getRecomendation()
                }
            }
        }
    }
    
}
