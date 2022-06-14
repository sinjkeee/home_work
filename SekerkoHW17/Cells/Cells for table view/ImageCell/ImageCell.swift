import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var myImageViewForCell: UIImageView!
    
    func selection(isSelected: Bool) {
        self.layer.borderColor = .init(red: 255/255, green: 10/255, blue: 10/255, alpha: 1)
        self.layer.borderWidth = isSelected ? 2 : 0
    }
}
