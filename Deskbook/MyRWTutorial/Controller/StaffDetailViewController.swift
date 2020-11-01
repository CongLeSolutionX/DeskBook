
import UIKit
import MessageUI

class StaffDetailViewController: StaffDetailBaseViewController {
  
  // Properties provided by the StaffDetailBaseViewController
  // let staffMember: Staff!
  
  // MARK: IB Outlets
  
  @IBOutlet var nameField: UITextField!
  @IBOutlet var emailField: UITextField!
  @IBOutlet var mobileField: UITextField!
  @IBOutlet var bioText: UITextView!
  
  // MARK: View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSLog("staffMember: \(staffMember.name)")
    updateStaffValues()
    
    // Set delegates for fields where we want to track tap and do something other than edit
    emailField.delegate = self
    mobileField.delegate = self
    
  }
  
  // MARK: Implementation
  
  /**
   Set our fields
   */
  fileprivate func updateStaffValues() {
    // Set our fields. Just in case this was called from the BG, let's force main
    DispatchQueue.main.async {
      self.nameField.text = self.staffMember.name
      self.emailField.text = self.staffMember.email
      self.mobileField.text = self.staffMember.mobile
      self.bioText.text = self.staffMember.bio
    }
  }
  
  /**
   Display a message VC with the staff member email pre-populated
   */
  fileprivate func sendEmail() {
    guard MFMailComposeViewController.canSendMail() else {
      NSLog("Mail services are not available on this device!")
      AlertHelper.showSimpleAlert(title: "Unsupported Feature", message: "This device does not support sending email.", viewController: self)
      return
    }
    
    // TODO: Add logic to verify for valid email
    guard staffMember.email.count > 0 else {
      // we just exit quietly if we don't have an email
      return
    }
    
    // Grab a reference to the email VC and set the delegate
    let composeVC = MFMailComposeViewController()
    composeVC.mailComposeDelegate = self
    
    // Set the email
    composeVC.setToRecipients([staffMember.email])
    
    // Present the email VC
    self.present(composeVC, animated: true, completion: nil)
    
  }
  
  /**
   Handles placing a call
   */
  fileprivate func startCall() {
    // If we end up with a valid tel url, and we can open "tel://", then we place the call.
    if let url = URL(string: "tel://\(staffMember.mobileDigits())"), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    } else {
      NSLog("Unable to call: \(staffMember.mobileDigits())")
      AlertHelper.showSimpleAlert(title: "Unsupported Feature", message: "This device does not support calls.", viewController: self)
    }
  }
  
}

// MARK: UITextFieldDelegate

extension StaffDetailViewController: UITextFieldDelegate {
  
  /**
   Catch when the user has tried to edit our fields, we cancel the edit and do something else!
   */
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == self.emailField {
      // Send an email to the staff member
      sendEmail()
    } else if textField == self.mobileField {
      // Place a call to the staff member
      startCall()
    }
    return false
  }
}

// MARK: MFMailComposeViewControllerDelegate

extension StaffDetailViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    // Dismiss the mail compose view controller.
    controller.dismiss(animated: true, completion: nil)
  }
}
