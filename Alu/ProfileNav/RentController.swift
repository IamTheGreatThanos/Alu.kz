import UIKit
import Foundation
import SwiftyJSON
import Alamofire

class RentController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var noOrders: UILabel!
    
    let defaults = UserDefaults.standard
    var orderArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noOrders.alpha = 0.0
        getOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RentTableViewCell", for: indexPath) as! RentTableViewCell
        cell.name.text = orderArray[indexPath.row]["title"].string
        let urlOfImage = URL(string: orderArray[indexPath.row]["product_image"][0]["image"].stringValue)!
        cell.orderImage.kf.setImage(with: urlOfImage)
        cell.goToButton.tag = indexPath.row
        cell.goToButton.addTarget(self, action: #selector(aboutAction(sender:)), for: .touchUpInside)
        let days_left = orderArray[indexPath.row]["days_left"].stringValue
        if days_left != "deadline"{
            cell.daysLabel.text = days_left
        }
        else{
            cell.daysLabel.text = "0"
        }
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
    
    func getOrders(){
        orderArray = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "basket/rent", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let json = try? JSON(data: response.data!)
            if json != nil {
                for i in json!.arrayValue{
                    for j in i["product"].arrayValue{
                        self.orderArray.append(j)
                    }
                }
                self.mainTableView.reloadData()
                if self.orderArray.count == 0{
                    self.noOrders.alpha = 1.0
                }
                else{
                    self.noOrders.alpha = 0.0
                }
            }
        }
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
