import Foundation
import UIKit
import KeychainSwift

extension UIViewController {
    enum AuthKeys: String {
        case login = "login"
        case password = "password"
    }
    
    func showAlertIfPasswordIsSet(blur: UIVisualEffectView) {
        let alertController = UIAlertController(title: "Access denied", message: "Your password?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
            guard let textPassword = alertController.textFields?.first?.text else { return }
            let keychain = KeychainSwift()
            guard let realPassword = keychain.get(AuthKeys.password.rawValue) else { return }
            if textPassword != realPassword {
                self.showErrorPasswordAlert(message: "Wrong password!", passwordIsSet: true, blur: blur)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    blur.alpha = 0
                } completion: { _ in
                    blur.removeFromSuperview()
                }
            }
        }
        alertController.addAction(okButton)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        present(alertController, animated: true)
    }
    
    func showAlertIfPasswordIsNOTSet(blur: UIVisualEffectView) {
        let alertController = UIAlertController(title: "Security", message: "Do you want to set up a password?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            UIView.animate(withDuration: 0.3, delay: 0) {
                blur.alpha = 0
            } completion: { _ in
                blur.removeFromSuperview()
            }
        }
        let okButton = UIAlertAction(title: "Set password", style: .cancel) { _ in
            guard alertController.textFields?.first?.text != "" else { return self.showErrorPasswordAlert(message: "Enter some password text!", passwordIsSet: false, blur: blur) }
            guard let passwordText = alertController.textFields?.first?.text else { return }
            let keychain = KeychainSwift()
            keychain.set(passwordText, forKey: AuthKeys.password.rawValue)
            UIView.animate(withDuration: 0.3, delay: 0) {
                blur.alpha = 0
            } completion: { _ in
                blur.removeFromSuperview()
            }
        }
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        present(alertController, animated: true)
    }
    
    func showErrorPasswordAlert(message: String, passwordIsSet: Bool, blur: UIVisualEffectView) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
            passwordIsSet ? self.showAlertIfPasswordIsSet(blur: blur) : self.showAlertIfPasswordIsNOTSet(blur: blur)
        }
        alert.addAction(okButton)
        present(alert, animated: true)
    }

    func choiceAlertAction(blurView: UIVisualEffectView) {
        let keychain = KeychainSwift()
        keychain.get(AuthKeys.password.rawValue) != nil ? showAlertIfPasswordIsSet(blur: blurView) : showAlertIfPasswordIsNOTSet(blur: blurView)
    }
    
    func createAndShowBlurEffect() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        blurView.alpha = 0
        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        UIView.animate(withDuration: 0.3, delay: 0) {
            blurView.alpha = 1
        }
        return blurView
    }
    
    func hideBlurView() {
        for view in self.view.subviews where view is UIVisualEffectView {
            view.removeFromSuperview()
        }
    }
}
