import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class WelcomeController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkServer()
    }
    
    func checkServer(){
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        mainTabController.selectedViewController = mainTabController.viewControllers?[0]
        self.present(mainTabController, animated: true, completion: nil)
        if self.defaults.bool(forKey: "isSignIn") == true{

        }
        else{
            self.defaults.set("None", forKey: "UID")
        }
    }
}
