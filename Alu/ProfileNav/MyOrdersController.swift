import UIKit
import Foundation
import SwiftyJSON
import Alamofire

class MyOrdersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myRentedTableView: UITableView!
    @IBOutlet weak var myWaitingTableView: UITableView!
    @IBOutlet weak var myCheckingTableView: UITableView!
    
    @IBOutlet weak var rentedHeight: NSLayoutConstraint!
    @IBOutlet weak var waitingHeight: NSLayoutConstraint!
    @IBOutlet weak var checkingHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var noLabel2: UILabel!
    @IBOutlet weak var noLabel3: UILabel!
    
    let defaults = UserDefaults.standard
    
    var myRentedArr = [JSON]()
    var myWaitingArr = [JSON]()
    var myCheckingArr = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case myRentedTableView:
            numberOfRow = myRentedArr.count
        case myWaitingTableView:
            numberOfRow = myWaitingArr.count
        case myCheckingTableView:
            numberOfRow = myCheckingArr.count
        default:
            print("Something wrong!")
        }
        
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case myRentedTableView:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "MyRentedTableViewCell", for: indexPath) as! MyRentedTableViewCell
            let urlOfImage = URL(string: myRentedArr[indexPath.row]["product_image"][0]["image"].stringValue)!
            cell1.orderImage.kf.setImage(with: urlOfImage)
            cell1.name.text = myRentedArr[indexPath.row]["title"].string
            cell1.aboutButton.tag = indexPath.row
            cell1.aboutButton.addTarget(self, action: #selector(aboutAction1(sender:)), for: .touchUpInside)
            return cell1
        case myWaitingTableView:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "MyWaitingTableViewCell", for: indexPath) as! MyWaitingTableViewCell
            let urlOfImage = URL(string: myWaitingArr[indexPath.row]["product_image"][0]["image"].stringValue)!
            cell2.orderImage.kf.setImage(with: urlOfImage)
            cell2.name.text = myWaitingArr[indexPath.row]["title"].string
            cell2.aboutButton.tag = indexPath.row
            cell2.aboutButton.addTarget(self, action: #selector(aboutAction2(sender:)), for: .touchUpInside)
            return cell2
        case myCheckingTableView:
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "MyCheckingTableViewCell", for: indexPath) as! MyCheckingTableViewCell
            let urlOfImage = URL(string: myCheckingArr[indexPath.row]["product_image"][0]["image"].stringValue)!
            cell3.orderImage.kf.setImage(with: urlOfImage)
            cell3.name.text = myCheckingArr[indexPath.row]["title"].string
            cell3.aboutButton.tag = indexPath.row
            cell3.aboutButton.addTarget(self, action: #selector(aboutAction3(sender:)), for: .touchUpInside)
            return cell3
        default:
            print("Something wrong!")
        }
        
        return cell
    }
    
    func getOrders(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "basket/myRented", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if json != nil {
                for i in json!.arrayValue{
                    if i["is_rented"].bool == true{
                        self.myRentedArr.append(i)
                    }
                    else if i["is_publish"].bool == true{
                        self.myWaitingArr.append(i)
                    }
                    else{
                        self.myCheckingArr.append(i)
                    }
                }
                
                self.myRentedTableView.reloadData()
                self.myWaitingTableView.reloadData()
                self.myCheckingTableView.reloadData()
                
                if self.myRentedArr.count != 0{
                    self.rentedHeight.constant = CGFloat(self.myRentedArr.count * 100)
                    self.noLabel.alpha = 0.0
                }
                else{
                    self.rentedHeight.constant = 80
                    self.noLabel.alpha = 1.0
                }
                
                if self.myWaitingArr.count != 0{
                    self.waitingHeight.constant = CGFloat(self.myWaitingArr.count * 100)
                    self.noLabel2.alpha = 0.0
                }
                else{
                    self.waitingHeight.constant = 80
                    self.noLabel2.alpha = 1.0
                }
                
                if self.myCheckingArr.count != 0{
                    self.checkingHeight.constant = CGFloat(self.myCheckingArr.count * 100)
                    self.noLabel3.alpha = 0.0
                }
                else{
                    self.checkingHeight.constant = 80
                    self.noLabel3.alpha = 1.0
                }
            }
        }
    }
    
    
    @objc func aboutAction1(sender: UIButton){
        let id = sender.tag
        defaults.set(myRentedArr[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    
    @objc func aboutAction2(sender: UIButton){
        let id = sender.tag
        defaults.set(myWaitingArr[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    
    @objc func aboutAction3(sender: UIButton){
        let id = sender.tag
        defaults.set(myCheckingArr[id].rawString(), forKey: "AboutProductInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"OrderInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
