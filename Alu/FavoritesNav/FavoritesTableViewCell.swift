import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var orderImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var basketButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
