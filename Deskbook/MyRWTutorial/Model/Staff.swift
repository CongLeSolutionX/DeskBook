
import Foundation

/**
 Defines our main struct to represent a Staff Member.
 */
struct Staff: Codable {
  let id: Int
  let name: String
  let mobile: String
  let email: String
  let image: String
  let department: String
  let title: String
  let bio: String
  let twitter: String
}

extension Staff: CustomStringConvertible {
  var description: String {
    return "name: \(name)" +
      " email: \(email)"
  }
}

extension Staff {
  /**
   A convenience method to extract the mobile phone's digits only
   */
  func mobileDigits() -> String {
    return mobile.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
  }
}

//typealias StaffData = (title: String, value: Any)
//
//extension Staff {
//  var tableRepresentation: [StaffData] {
//    return [
//      ("Id", id),
//      ("Name", name),
//      ("Email", email),
//      ("Department", department),
//      ("Title", title),
//      ("Bio", bio),
//      ("Twitter", twitter)
//    ]
//  }
//}

