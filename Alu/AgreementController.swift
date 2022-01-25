import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class AgreementController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
