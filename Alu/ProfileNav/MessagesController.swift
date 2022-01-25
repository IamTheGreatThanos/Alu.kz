import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class MessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var noMessages: UILabel!
    
    let defaults = UserDefaults.standard
    
    var messageArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noMessages.alpha = 0.0
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessages()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        cell.selectButton.tag = indexPath.row
        cell.selectButton.addTarget(self, action: #selector(selectAction(sender:)), for: .touchUpInside)
        let arrayOfText = messageArray[indexPath.row]["text"].string!.components(separatedBy: "*")
        cell.message.text! = ""
        var mainText = ""
        for i in arrayOfText{
            mainText += i + "\n"
        }
        let mediumFont = UIFont(name: "Montserrat-Medium", size: 12.0)!
        let boldFont = UIFont(name: "Montserrat-Bold", size: 12.0)!
        let attributedText = NSMutableAttributedString.init(string: mainText)
        for i in messageArray[indexPath.row]["words"].arrayValue{
            if i.string != nil{
                let range = (mainText as NSString).range(of: i.string!)
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue , range: range)
                attributedText.addAttribute(NSAttributedString.Key.font, value: mediumFont, range: range)
            }
        }
        let range1 = (mainText as NSString).range(of: "№")
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue , range: range1)
        attributedText.addAttribute(NSAttributedString.Key.font, value: mediumFont, range: range1)
        let range2 = (mainText as NSString).range(of: "Здравствуйте!")
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: range2)
        let range3 = (mainText as NSString).range(of: "Итого:")
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: range3)
        let range4 = (mainText as NSString).range(of: "Курьерская служба")
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: range4)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue , range: range4)
        let range5 = (mainText as NSString).range(of: "Самовывоз в пункт выдачи")
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: range5)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue , range: range5)
        
        cell.message.attributedText = attributedText
        
        if messageArray[indexPath.row]["action"].int == 1{
            if messageArray[indexPath.row]["is_readed"].bool == true{
                cell.indicator.alpha = 0.0
            }
            else{
                cell.indicator.alpha = 1.0
            }
            cell.selectButton.alpha = 0.0
        }
        else{
            if messageArray[indexPath.row]["is_readed"].bool == true{
                cell.indicator.alpha = 0.0
                cell.selectButton.alpha = 0.0
            }
            else{
                cell.selectButton.alpha = 1.0
                cell.indicator.alpha = 1.0
            }
        }
        return cell
    }
    
    @objc func selectAction(sender: UIButton){
        defaults.set(messageArray[sender.tag]["action"].int, forKey: "MessageActionType")
        defaults.set(messageArray[sender.tag]["id"].int, forKey: "MessageID")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"AcceptOrderController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    func getMessages(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "message/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil {
                    self.messageArray = json?.array as! [JSON]
                    self.mainTableView.reloadData()
                    if self.messageArray.count == 0{
                        self.noMessages.alpha = 1.0
                    }
                    else{
                        self.noMessages.alpha = 0.0
                    }
                }
            case .failure(let error):
                print(error)
                self.getMessages()
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
