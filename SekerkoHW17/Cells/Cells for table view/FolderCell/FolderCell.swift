import UIKit
import SnapKit

class FolderCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet var folderNameLabel: UILabel!
    @IBOutlet var folderImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.folderImage.tintColor = .systemBlue
        
        //MARK: - Make constraints
        folderImage.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        folderNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(folderImage.snp.trailing).offset(8)
        }
    }
    
    //MARK: - Methods
    func configure(folderName: URL) {
        folderNameLabel.text = folderName.lastPathComponent
    }
    
    func selection(isSelected: Bool) {
        self.layer.borderColor = .init(red: 255/255, green: 10/255, blue: 10/255, alpha: 1)
        self.layer.borderWidth = isSelected ? 2 : 0
        self.tintColor = isSelected ? .red : .systemBlue
        self.accessoryType = isSelected ? .checkmark : .none
    }
}
