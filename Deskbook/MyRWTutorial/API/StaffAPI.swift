
import Foundation

///  This singleton class allows us to read remote data. Access via `StaffAPI.shared`.
final class StaffAPI {
  /// A type to define our StaffLoaded closure.
  typealias StaffLoadedClosure = (_ staffList: [Staff]?, _ error: String?) -> ()
  
  static let shared = StaffAPI()
  private let httpClient = HTTPClient()
  private let apiHost = "http://localhost:3000/api"
  private let genericError = "There was an issue loading data. Please contact your app support."

  private init() { }
  
  /// Load the staff list (asynch), calling the closure when the request ends with data or in error
  func loadStaffList(staffLoaded: @escaping StaffLoadedClosure) {
    
    // Make our network request
    httpClient.requestFrom(apiHost + "/staff2") { (data, error) in
      // Ensure we have data and no errors
      guard let data = data else {
        // Oops, we have no data, check for error
        if let error = error {
          // We had an error. Check to see what it was
          switch error {
          case .anotherRequestIsRunning:
            // Another request is running, so we'll just not call the closure to let this one die
            return
          case .invalidUrl:
            // The URL was invalid, so let's pass this back up
            staffLoaded(nil, self.genericError + " (Invalid remote address.)")
            break;
          case .connectionError(let errorDescription):
            // Something else
            staffLoaded(nil, self.genericError + " (\(errorDescription))")
            break;
          }
        } else {
          // we had no data and no error. We should never be here
          staffLoaded(nil, self.genericError)
        }
        return
      }
      
      // ASSERT: We have a good response (we have data)
      
      // Decode the JSON, letting Swift 4 do all the heavy lifting!
      let decoder = JSONDecoder()
      do {
        let staffList = try decoder.decode([Staff].self, from: data)
        // Return data through our closure
        staffLoaded(staffList, nil)
      } catch {
        // Error with the remote data
        staffLoaded(nil, self.genericError + " (Invalid remote data.)")
      }
    
    }
  }
}
