
import UIKit

class StaffListViewController: UIViewController {
  
  // MARK: Constants
  private enum Constants {
    static let CellIdentifier = "Cell"
  }
  
  // MARK: Properties
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    return refreshControl
  }()
  private var staffList: [Staff]?
  
  // MARK: IB Outlets
  @IBOutlet var tableView: UITableView!
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableViewSetup()
    loadData()
  }
}
// MARK: - Implementation
extension StaffListViewController {
  
  private func loadData() {
    StaffAPI.shared.loadStaffList { (staffList, errorMessage) in
      // First handle errors...
      guard let staffList = staffList else {
        // We did not get a staff list, so show an error
        NSLog("load staff list error: \(errorMessage ?? "Unknown")")
        // End the refreshing (Switch to main for the UI update)
        DispatchQueue.main.async {
          self.refreshControl.endRefreshing()
          // Alert
          AlertHelper.showSimpleAlert(title: "Load Error", message: "Unable to load staff right now. Ensure you have Internet connectivity and try again.", viewController: self)
        }
        return
      }
      
      // ASSERT: We have a staffList...
      
      // Save the staff results to our VC property
      self.staffList = staffList
      // Switch to main for the UI update
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
      }
    }
  }
  
  @objc private func refreshData() {
    self.loadData()
  }
  
  private func tableViewSetup() {
    // Wire this class up as a delegate to the table view
    tableView.dataSource = self
    // Add Refresh Control to Table View
    tableView.refreshControl = refreshControl
  }
  
  // MARK: - Navigation
  
  // Prepare to go to our detail view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Proceed only if we have both a staffList and a selected index row
    if let staffList = staffList, let row = tableView.indexPathForSelectedRow?.row {
      // Point to the right staff member
      let staff = staffList[row]
      // Get a reference to the destination VC (cast as our base if possible since our details views implement it)
      let detailView = segue.destination as? StaffDetailBaseViewController
      // Assign the right staff member
      detailView?.staffMember = staff
    }
  }
}

// MARK: - UITableViewDataSource
extension StaffListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Staff List"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let staffList = staffList else {
      return 0
    }
    return staffList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
    if let staffList = staffList {
      let row = indexPath.row
      let staff = staffList[row]
      cell.textLabel!.text = staff.name
      cell.detailTextLabel!.text = staff.mobile
    }
    return cell
  }
  
}
