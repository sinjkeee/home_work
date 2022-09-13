import UIKit

class FolderCellForCollectionView: UICollectionViewCell {
    
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        imageView.image = UIImage(named: "folder")
    }
    
    func selection(isSelected: Bool) {
        self.layer.borderColor = .init(red: 255/255, green: 10/255, blue: 10/255, alpha: 1)
        self.layer.borderWidth = isSelected ? 2 : 0
    }
}
