import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class OrderInfoController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var price30: UILabel!
    @IBOutlet weak var price14: UILabel!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var basketButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var ProductInfo = JSON()
    let defaults = UserDefaults.standard
    var ProductImageCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonStr = defaults.string(forKey: "AboutProductInfo")!
        if jsonStr != "" {
            if let json = jsonStr.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    ProductInfo = try JSON(data: json)
                    name.text = ProductInfo["title"].string
                    about.text = ProductInfo["about"].string
                    price30.text = "Цена: \(ProductInfo["price_30"].stringValue)тг (за 30 дней)"
                    price14.text = "Цена: \(ProductInfo["price_14"].stringValue)тг (за 14 дней)"
                    ProductImageCount = ProductInfo["product_image"].count
                    if ProductInfo["is_rented"].int == 1 || ProductInfo["owner"]["id"].stringValue == defaults.string(forKey: "UID")!{
                        basketButton.isUserInteractionEnabled = false
                    }
                }
                catch{
                    print("Error")
                }
            }
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if GlobalVariables.favorites.contains(ProductInfo["id"].int!){
            favoriteButton.setBackgroundImage(UIImage(named: "heart1"), for: .normal)
        }
        else{
            favoriteButton.setBackgroundImage(UIImage(named: "heart"), for: .normal)
        }
        
        if GlobalVariables.basket.contains(ProductInfo["id"].int!){
            basketButton.setBackgroundImage(UIImage(named: "basket1"), for: .normal)
        }
        else{
            basketButton.setBackgroundImage(UIImage(named: "basket"), for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProductImageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCell", for: indexPath) as! InfoCollectionViewCell
        let url = URL(string: ProductInfo["product_image"][indexPath.row]["image"].stringValue)
        cell.orderImage.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = URL(string: ProductInfo["product_image"][indexPath.row]["image"].stringValue)!
        self.addImageViewWithImage(image: url)
    }
    
    @IBAction func basketTapped(_ sender: UIButton) {
        if self.defaults.bool(forKey: "isSignIn") == true{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            let parameters = ["product" : ProductInfo["id"].stringValue]
            AF.request(GlobalVariables.url + "basket/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    if sender.backgroundImage(for: .normal) == UIImage(named: "basket1"){
                        sender.setBackgroundImage(UIImage(named: "basket"), for: .normal)
                        GlobalVariables.basket.remove(at: GlobalVariables.basket.firstIndex(of: self.ProductInfo["id"].int!)!)
                    }
                    else{
                        sender.setBackgroundImage(UIImage(named: "basket1"), for: .normal)
                        GlobalVariables.basket.append(self.ProductInfo["id"].int!)
                    }
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
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        if self.defaults.bool(forKey: "isSignIn") == true{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            let parameters = ["product" : ProductInfo["id"].stringValue]
            AF.request(GlobalVariables.url + "products/favorites", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    if sender.backgroundImage(for: .normal) == UIImage(named: "heart1"){
                        sender.setBackgroundImage(UIImage(named: "heart"), for: .normal)
                        GlobalVariables.favorites.remove(at: GlobalVariables.favorites.firstIndex(of: self.ProductInfo["id"].int!)!)
                    }
                    else{
                        sender.setBackgroundImage(UIImage(named: "heart1"), for: .normal)
                        GlobalVariables.favorites.append(self.ProductInfo["id"].int!)
                    }
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
    
    @objc func removeImage() {
        let window = UIApplication.shared.keyWindow!
        let imageView = (window.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
    }
    
    func addImageViewWithImage(image: URL) {
        let window = UIApplication.shared.keyWindow!
        let imageView = UIImageView(frame: window.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.kf.setImage(with: image)
        imageView.isUserInteractionEnabled = true
        imageView.tag = 100
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(dismissTap)
        
        window.addSubview(imageView)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
