import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class OrdersController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var firstCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var searchedOrderCount: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var firstCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondCollectionViewHeight: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    
    var Categories = [String]()
    var Categories_id = [Int]()
    var SubCategories = [[String]]()
    var SubCategories_id = [[Int]]()
    
    var storedOffsets = CGPoint()
    
    var category_id = "1"
    var selected_category_id = 1
    var subCategory_count = 1
    var secondHeightConstant = 0
    
    var first_SubCategory_id = 0
    var second_Sub_SubCategory_id = 0
    
    var orderArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondHeightConstant = Int(secondCollectionViewHeight.constant)
        
        mainTitle.text = defaults.string(forKey: "mainTitle")
        
        searchTextField.borderStyle = .none
        searchTextField.setLeftPaddingPoints(35)
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        
        category_id = defaults.string(forKey: "Category_id")!
        
        if category_id == "3"{
            SubCategories.append([])
            SubCategories_id.append([])
            firstCollectionViewHeight.constant = 5
        }
        
        if let path = Bundle.main.path(forResource: "Categories", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [NSDictionary]
                for i in jsonResult{
                    if category_id == "3"{
                        if i["model"] as! String == "categories.subcategory"{
                            if category_id == String((i["fields"] as! NSDictionary)["category"] as! Int){
                                SubCategories[0].append((i["fields"] as! NSDictionary)["name"] as! String)
                                SubCategories_id[0].append(i["pk"] as! Int)
                            }
                        }
                    }
                    else{
                        if i["model"] as! String == "categories.subcategory"{
                            if category_id == String((i["fields"] as! NSDictionary)["category"] as! Int){
                                Categories.append((i["fields"] as! NSDictionary)["name"] as! String)
                                Categories_id.append(i["pk"] as! Int)
                                let current_subcategory_id = i["pk"] as! Int
                                var arr = [String]()
                                var arr_id = [Int]()
                                for i in jsonResult{
                                    if i["model"] as! String == "categories.sub_subcategory"{
                                        if current_subcategory_id == (i["fields"] as! NSDictionary)["subcategory"] as! Int{
                                            arr.append((i["fields"] as! NSDictionary)["name"] as! String)
                                            arr_id.append(i["pk"] as! Int)
                                        }
                                    }
                                }
                                SubCategories.append(arr)
                                SubCategories_id.append(arr_id)
                            }
                        }
                    }
                }
                subCategory_count = SubCategories[0].count
            }
            catch {
                print(error)
            }
        }
        
        if category_id == "3"{
            second_Sub_SubCategory_id = SubCategories_id[0][0]
        }
        else{
            first_SubCategory_id = Categories_id[0]
            second_Sub_SubCategory_id = SubCategories_id[0][0]
        }
        
        // MARK: CALL TO BD
        getOrders()
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
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItem = 1
        switch collectionView {
        case firstCollectionView:
            numberOfItem = Categories.count
        case secondCollectionView:
            numberOfItem = subCategory_count
        default:
            print("Something wrong!")
        }
        
        return numberOfItem
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        switch collectionView {
        case firstCollectionView:
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "firstTypeCollectionViewCell", for: indexPath) as! firstTypeCollectionViewCell
            cell1.typeText.setTitle(Categories[indexPath.row], for: .normal)
            cell1.typeText.addTarget(self, action: #selector(firstColViewAction(sender:)), for: .touchUpInside)
            cell1.typeText.tag = indexPath.row
            if indexPath.row == selected_category_id - 1{
                cell1.indicatorView.alpha = 1.0
                cell1.typeText.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 14)
            }
            else{
                cell1.indicatorView.alpha = 0.0
                cell1.typeText.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 14)
            }
            return cell1
        case secondCollectionView:
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "secondTypeCollectionViewCell", for: indexPath) as! secondTypeCollectionViewCell
            let imageForBG = UIImage(named: "Card"+category_id+"_"+String(selected_category_id)+"_"+String(indexPath.row+1))
            if second_Sub_SubCategory_id == SubCategories_id[selected_category_id-1][indexPath.row]{
                cell2.typeButton.borderWidth = 0
                let shadowSize: CGFloat = 20
                let contactRect = CGRect(x: -shadowSize*0.2, y: 160, width: 160 + shadowSize*0.5, height: shadowSize)
                cell2.typeButton.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
                cell2.typeButton.shadowRadius = 5
                cell2.typeButton.shadowOpacity = 0.4
            }
            else{
                cell2.typeButton.borderWidth = 0
                cell2.typeButton.shadowRadius = 0
                cell2.typeButton.shadowOpacity = 0
            }
            cell2.typeButton.tag = indexPath.row
            cell2.typeButton.setBackgroundImage(imageForBG, for: .normal)
            cell2.typeButton.addTarget(self, action: #selector(secondColViewAction(sender:)), for: .touchUpInside)
            return cell2
        default:
            print("Something wrong!")
        }
        return cell
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath) as! OrdersTableViewCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let id = indexPath.row
       defaults.set(orderArray[id].rawString(), forKey: "AboutProductInfo")
       
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
       self.navigationController?.pushViewController(viewController,
       animated: true)
    }
    
    // MARK: Functions
    
    @objc func firstColViewAction(sender: UIButton){
        searchTextField.text = ""
        selected_category_id = sender.tag + 1
        subCategory_count = SubCategories[selected_category_id-1].count
        firstCollectionView.reloadData()
        secondCollectionView.reloadData()
        UIView.animate(withDuration: 0.5, animations: {
            self.firstCollectionView.alpha = 0.0
        })
        UIView.animate(withDuration: 0.5, animations: {
            self.firstCollectionView.alpha = 1.0
        })
        first_SubCategory_id = Categories_id[selected_category_id-1]
        if category_id == "1" && selected_category_id == 5{
            secondCollectionViewHeight.constant = 5
            
            getOrders()
        }
        else{
            secondCollectionViewHeight.constant = CGFloat(secondHeightConstant)
        }
    }
    
    @objc func secondColViewAction(sender: UIButton){
        searchTextField.text = ""
        let sender_id = sender.tag
        second_Sub_SubCategory_id = SubCategories_id[selected_category_id-1][sender_id]
        getOrders()
        storedOffsets = secondCollectionView.contentOffset
        secondCollectionView.reloadData()
        self.secondCollectionView.scrollToItem(at: IndexPath(row: sender_id, section: 0), at: .top, animated: false)
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
        var url = ""
        if category_id == "1" && selected_category_id == 5{
            url = GlobalVariables.url + "products/filter?" + "category=" + category_id + "&subcategory=" + String(first_SubCategory_id)
        }
        else{
            if category_id == "3"{
                url = GlobalVariables.url + "products/filter?" + "category=" + category_id + "&subcategory=" + String(second_Sub_SubCategory_id)
            }
            else{
                url = GlobalVariables.url + "products/filter?" + "category=" + category_id + "&subcategory=" + String(first_SubCategory_id) + "&subcategory2=" + String(second_Sub_SubCategory_id)
            }
        }
        let text = searchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        url += ("&search=" + text)
        AF.request(url, method: .get, parameters: nil).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if json != nil{
                self.orderArray = json?.array as! [JSON]
                self.searchedOrderCount.text = "Найдено: \(self.orderArray.count) товара"
                self.mainTableView.reloadData()
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
            }
            else{
                self.orderArray = []
                self.searchedOrderCount.text = "Найдено: 0 товара"
                self.mainTableView.reloadData()
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
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
