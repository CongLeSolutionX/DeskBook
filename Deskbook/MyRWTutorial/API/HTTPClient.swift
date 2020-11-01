
import UIKit

/// Define our custom errors
enum HTTPClientError {
  case invalidUrl
  case connectionError(errorDescription: String)
  case anotherRequestIsRunning
}

/**
 An HTTP Client that reads data from remote resources
 - Allows only a single dataTask request at a time
 - Returns the received Data or an HTTPClient.RequestError
 */
class HTTPClient {
  
  // MARK: Instance Objects
  
  let defaultSession = URLSession(configuration: .default)
  var dataTask: URLSessionDataTask?
  let semaphore = DispatchSemaphore(value: 1)
  
  // MARK: Request handling
  /// A closure type for our request method
  typealias RequestCompletedClosure = (_ requestData: Data?, _ error: HTTPClientError?) -> ()
  /**
   Request data from a remote resource.
   - Expects url and a completion closure.
   */
  func requestFrom(_ url: String, requestCompleted: @escaping RequestCompletedClosure) {
    // If we have another dataTask running, we bail on this one
    guard dataTaskNotRunning() else {
      requestCompleted(nil, .anotherRequestIsRunning)
      return
    }
    // ASSERT: Another task is not running
    
    guard let validUrl = URL(string:url) else {
      requestCompleted(Data(), .invalidUrl)
      self.clearDataTask()
      return
    }
    
    // ASSERT: We have a validurl
    
    dataTask = defaultSession.dataTask(with: validUrl) { data, response, error in

      defer {
        self.clearDataTask()
      }

      if let error = error {
        requestCompleted(nil, .connectionError(errorDescription: error.localizedDescription))
      } else if let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200 {
        requestCompleted(data, nil)
      } else {
        // We should never ever be here since data and error should be exclusive
        requestCompleted(nil, .connectionError(errorDescription: "Unknown Error"))
      }
      
    }
    
    dataTask?.resume()
    
  }
  
  // MARK: Synch the checking and clearing of our dataTask (to prevent multiple requests)
  
  /**
   Clear the dataTask, but only if another conflicting operation is not in progress.
   Note, this is BLOCKING.
   */
  fileprivate func clearDataTask() {
    self.semaphore.wait()
    self.dataTask = nil
    self.semaphore.signal()
  }
  
  /**
   Check to see if another dataTask is running/pending, but when another conflicting operation has finished.
   Note, this is BLOCKING.
   */
  fileprivate func dataTaskNotRunning() -> Bool {
    var dataTaskNotRunning: Bool
    self.semaphore.wait()
    dataTaskNotRunning = self.dataTask == nil
    self.semaphore.signal()
    return dataTaskNotRunning
  }
  
}

