import UIKit
import SnapKit

class ImageViewController: UIViewController {

    static let key = "ImageViewController"
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.frame = view.bounds
        scrollView.bounces = true
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    var arrayImagesURL: [URL] = []
    var arrayImages: [UIImage] = []
    var image: UIImageView!
    var imageFirst: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        arrayImagesURL = arrayImagesURL.filter({$0 != imageFirst})
        arrayImagesURL.insert(imageFirst, at: 0)
        
        arrayImages = arrayImagesURL.map({
            guard let image = UIImage(contentsOfFile: $0.path) else { return UIImage()}
            return image
        })
                
        addImagesInStackView(arrayImages: arrayImages)
            
            view.addSubview(scrollView)
            scrollView.addSubview(stackView)
            setupViewConstraint()
        
    }
}


extension ImageViewController: UIScrollViewDelegate {
    private func setupViewConstraint() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints({
            $0.top.equalTo(scrollView.snp.top).inset(0)
            $0.right.equalTo(scrollView.snp.right).inset(0)
            $0.left.equalTo(scrollView.snp.left).inset(0)
        })

        for imageView in stackView.arrangedSubviews {
            imageView.snp.makeConstraints({
                $0.width.equalTo(view.frame.width)
                $0.height.equalTo(view.frame.height)
            })
        }
    }
    
    func addImagesInStackView(arrayImages: [UIImage]) {
        for index in arrayImages {
            image = UIImageView()
            image.image = index
            image.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(image)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        stackView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < 0 {
            scrollView.zoomScale = 1
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = scrollView.zoomScale == 1
    }
}
