import Foundation
import UIKit


class Manager {
    
    var share = Manager()
    
    private init() {}
    
    func elert() {
        let alert = UIAlertController(title: "Hello", message: "Test", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        
    }
}
