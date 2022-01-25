import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var indicator: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
