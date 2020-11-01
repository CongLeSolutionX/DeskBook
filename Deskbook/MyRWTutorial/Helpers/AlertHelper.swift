
import UIKit

class AlertHelper {
  
  private init() {
    
  }
  
  static func showSimpleAlert(title: String, message: String, viewController: UIViewController) {
    // create the alert
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // add an action (button)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    // show the alert
    viewController.present(alert, animated: true, completion: nil)
  }
}
