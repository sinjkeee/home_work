import UIKit

//MARK: - Enum
enum TypeItem: Int {
    case folder = 0
    case image
}
//some comment
enum StateType {
    case selection
    case create
}

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var elementSelectionButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: - var/let
    let fileManager = FileManager.default
    var contentOfDirectory: [URL] = []
    var catalogURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imagePicker = UIImagePickerController()
    var dictionary: [TypeItem: [URL]] = [:]
    var titleName = "Catalog Browser"
    var segmentIndex = 0
    var indeces: [IndexPath] = []
    var stateType: StateType = .create
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = segmentIndex
        changeValueSegmentedControll(index: segmentIndex)
        
        imagePicker.delegate = self
        self.title = titleName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        deleteButton.isHidden = true
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FolderCellForCollectionView", bundle: nil), forCellWithReuseIdentifier: "FolderCellForCollectionView")
        collectionView.register(UINib(nibName: "ImageCellForCollectionView", bundle: nil), forCellWithReuseIdentifier: "ImageCellForCollectionView")
        
        getStartingValues()
    }
    
    //MARK: - IBAction
    @IBAction func newAddButtonPressed() {
        chooseActionAlert()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        changeValueSegmentedControll(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        chooseActionAlert()
    }
    
    @IBAction func elementSelectionAction(_ sender: UIButton) {
        switch stateType {
        case .create:
            addButton.isEnabled = false
            deleteButton.isHidden = false
            deleteButton.isEnabled = false
            stateType = .selection
        case .selection:
            deleteButton.isHidden = true
            addButton.isEnabled = true
            indeces.removeAll()
            stateType = .create
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        indeces.forEach { indexPath in
            guard let key = TypeItem(rawValue: indexPath.section),
                  var value = dictionary[key] else { return }
            
            self.deletedItem(atPath: value[indexPath.row].path, atURL: value[indexPath.row])
            value.remove(at: indexPath.row)
        }
        getStartingValues()
        indeces.removeAll()
        tableView.reloadData()
        collectionView.reloadData()
        deleteButton.isHidden = true
        addButton.isEnabled = true
    }
    
    //MARK: - Methods
    func getStartingValues() {
        do {
            contentOfDirectory = try fileManager.contentsOfDirectory(at: catalogURL, includingPropertiesForKeys: nil).filter({$0.lastPathComponent != ".DS_Store"})
        } catch { return }
        
        dictionary[.image] = contentOfDirectory.filter({!$0.hasDirectoryPath})
        dictionary[.folder] = contentOfDirectory.filter({$0.hasDirectoryPath})
    }
    
    func changeValueSegmentedControll(index: Int) {
        segmentIndex = index
        tableView.isHidden = index == 1
        collectionView.isHidden = index == 0
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func chooseActionAlert() {
        let alert = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .alert)
        let imageButton = UIAlertAction(title: "Create a new image", style: .default) { _ in
            self.presentImagePicker()
        }
        let folderButton = UIAlertAction(title: "Create a new folder", style: .default) { _ in
            self.addNewFolder()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(imageButton)
        alert.addAction(folderButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    
    func addNewFolder() {
        let alert = UIAlertController(title: "Create a new folder", message: "Enter folder name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            let newText = text.trimmingCharacters(in: .whitespaces)
            self.createNewFolder(folderName: newText)
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        alert.addTextField(configurationHandler: nil)
        present(alert, animated: true)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Attention", message: "A directory with the same name already exists", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    //Создаем новую папку
    func createNewFolder(folderName: String) {
        guard var value = dictionary[.folder] else { return }
        do {
            let myCatalogURL = catalogURL.appendingPathComponent(folderName)
            print(myCatalogURL)
            try fileManager.createDirectory(at: myCatalogURL, withIntermediateDirectories: false)
            value.append(myCatalogURL)
            dictionary[.folder] = value
        } catch {
            showErrorAlert()
        }
    }
    
    func presentImagePicker() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    //Удаляем файл или папку
    func deletedItem(atPath: String, atURL: URL) {
        if fileManager.fileExists(atPath: atPath) {
            do {
                try fileManager.removeItem(at: atURL)
            } catch {
                print("Error!")
            }
        }
    }
    // Выбор VC для перехода
    func vcSelection(indexPath: IndexPath) {
        guard let key = TypeItem(rawValue: indexPath.section),
              let values = dictionary[key] else { return }
        
        switch key {
        case .image:
            guard let controller = storyboard?.instantiateViewController(withIdentifier: ImageViewController.key) as? ImageViewController else { return }
            controller.imageFirst = values[indexPath.row]
            controller.arrayImagesURL = dictionary[.image]!
            present(controller, animated: true, completion: nil)
        case .folder:
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
            controller.catalogURL = catalogURL.appendingPathComponent(values[indexPath.row].lastPathComponent)
            controller.titleName = values[indexPath.row].lastPathComponent
            controller.segmentIndex = segmentedControl.selectedSegmentIndex
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cellSelectionTableView(indexPath: IndexPath, isSelected: Bool) {
        guard let key = TypeItem(rawValue: indexPath.section) else { return }
        
        switch key {
        case .folder:
            guard let folderCell = tableView.cellForRow(at: indexPath) as? FolderCell else { return }
            folderCell.selection(isSelected: isSelected)
            folderCell.isSelected = isSelected
        default:
            guard let imageCell = tableView.cellForRow(at: indexPath) as? ImageCell else { return }
            imageCell.selection(isSelected: isSelected)
            imageCell.isSelected = isSelected
        }
    }
    
    func cellSelectionCollectionView(indexPath: IndexPath, isSelected: Bool) {
        guard let key = TypeItem(rawValue: indexPath.section) else { return }
        
        switch key {
        case .folder:
            guard let folderCell = collectionView.cellForItem(at: indexPath) as? FolderCellForCollectionView else { return }
            folderCell.selection(isSelected: isSelected)
            folderCell.isSelected = isSelected
        default:
            guard let imageCell = collectionView.cellForItem(at: indexPath) as? ImageCellForCollectionView else { return }
            imageCell.selection(isSelected: isSelected)
            imageCell.isSelected = isSelected
        }
    }
}


//MARK: - Extension Table View
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Кол-во секций
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.keys.count
    }
    
    // Кол-во ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let key = TypeItem(rawValue: section),
              let values = dictionary[key] else { return 0 }
        return values.count
    }
    
    // Внешний вид ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") as? FolderCell else { return UITableViewCell() }
        
        guard let key = TypeItem(rawValue: indexPath.section),
              let values = dictionary[key] else { return UITableViewCell() }
        
        switch key {
        case .folder:
            cell.selection(isSelected: indeces.contains { $0 == indexPath })
            cell.configure(folderName: values[indexPath.row])
            cell.isSelected = true
            return cell
        case .image:
            imageCell.selection(isSelected: indeces.contains { $0 == indexPath })
            imageCell.myImageViewForCell.image = UIImage(contentsOfFile: values[indexPath.row].path)
            imageCell.isSelected = true
            return imageCell
        }
    }
    
    // Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    // Работа с тапом по ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch stateType {
        case .create:
            cellSelectionTableView(indexPath: indexPath, isSelected: false)
            vcSelection(indexPath: indexPath)
        case .selection where indeces.contains(where: { $0 == indexPath }):
            cellSelectionTableView(indexPath: indexPath, isSelected: false)
            guard let item = indeces.firstIndex(of: indexPath) else { return }
            indeces.remove(at: item)
            deleteButton.isEnabled = indeces.count > 0
        case .selection:
            cellSelectionTableView(indexPath: indexPath, isSelected: true)
            indeces.append(indexPath)
            deleteButton.isEnabled = indeces.count > 0
        }
        print("select \(indeces)")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch stateType {
        case .selection:
            if indeces.count > 0 {
                guard let item = indeces.firstIndex(of: indexPath) else { return }
                indeces.remove(at: item)
            }
            deleteButton.isEnabled = indeces.count >= 1
        default: break
        }
        cellSelectionTableView(indexPath: indexPath, isSelected: false)
        print("deselect \(indeces)")
    }
    
    // Удаление элемента таблицы по свайпу
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            guard let key = TypeItem(rawValue: indexPath.section),
                  var value = dictionary[key] else { return }
            
            self.deletedItem(atPath: value[indexPath.row].path, atURL: value[indexPath.row])
            value.remove(at: indexPath.row)
            self.dictionary[key] = value
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }
    
    // Имя секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let key = TypeItem(rawValue: section),
              let values = dictionary[key] else { return "" }
        
        switch key {
        case .folder:
            if values.count >= 1 {
                return "Folders"
            }
            return ""
        case .image:
            if values.count >= 1 {
                return "Images"
            }
            return ""
        }
    }
}

//MARK: - Extension Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Сохранение картинки
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var value = dictionary[.image] else { return }
        if let imageURL = info[.imageURL] as? URL, let editedImage = info[.editedImage] as? UIImage {
            let newImageURL = catalogURL.appendingPathComponent(imageURL.lastPathComponent)
            
            let imageJPGData = editedImage.jpegData(compressionQuality: 1)
            do {
                try imageJPGData?.write(to: newImageURL)
                value.append(newImageURL)
                self.dictionary[.image] = value
                self.tableView.reloadData()
                self.collectionView.reloadData()
            } catch {
                print("Error")
            }
            dismiss(animated: true)
            print("image selected")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true)
    }
}

//MARK: - Extension Collection View
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dictionary.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let key = TypeItem(rawValue: section),
              let values = dictionary[key] else { return 0 }
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellForCollectionView", for: indexPath) as? ImageCellForCollectionView else { return UICollectionViewCell() }
        guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCellForCollectionView", for: indexPath) as? FolderCellForCollectionView else { return UICollectionViewCell() }
        
        guard let key = TypeItem(rawValue: indexPath.section),
              let values = dictionary[key] else { return UICollectionViewCell() }
        
        switch key {
        case .folder:
            folderCell.selection(isSelected: indeces.contains { $0 == indexPath })
            folderCell.folderNameLabel.text = values[indexPath.row].lastPathComponent
            folderCell.isSelected = true
            return folderCell
        default:
            imageCell.selection(isSelected: indeces.contains { $0 == indexPath })
            imageCell.imageView.image = UIImage(contentsOfFile: values[indexPath.row].path)
            imageCell.isSelected = true
            return imageCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch stateType {
        case .create:
            vcSelection(indexPath: indexPath)
            cellSelectionCollectionView(indexPath: indexPath, isSelected: false)
        case .selection where indeces.contains(where: { $0 == indexPath }):
            cellSelectionCollectionView(indexPath: indexPath, isSelected: false)
            guard let item = indeces.firstIndex(of: indexPath) else { return }
            indeces.remove(at: item)
            deleteButton.isEnabled = indeces.count > 0
        case .selection:
            cellSelectionCollectionView(indexPath: indexPath, isSelected: true)
            indeces.append(indexPath)
            deleteButton.isEnabled = indeces.count > 0
        }
        print("select \(indeces)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch stateType {
        case .selection:
            if indeces.count > 0 {
                guard let item = indeces.firstIndex(of: indexPath) else { return }
                indeces.remove(at: item)
            }
            deleteButton.isEnabled = indeces.count >= 1
        default: break
        }
        cellSelectionCollectionView(indexPath: indexPath, isSelected: false)
        print("deselect \(indeces)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
