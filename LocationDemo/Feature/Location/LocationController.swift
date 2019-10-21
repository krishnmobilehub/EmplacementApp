
import UIKit
import CoreData

class LocationController: UIViewController {

    @IBOutlet weak var locationTable: UITableView!
    
    lazy var locationPresenter = LocationPresenter(repository: LocationRepository(), delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchLocationWithId(groupId: "xxxxx") // need to pass group id here
        locationTable.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func scanClicked(_ sender: UIButton) {
        _ = BluetoothManager.sharedInstance.start() 
    }
    
    func fetchLocationWithId(groupId:String) {
        locationPresenter.getLocationWith(groupId: groupId)
    } 
}

extension LocationController: LocationDelegate {
    func finishWithError(_ error: String?) {
        // show error
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.locationTable.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.locationTable.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            self.locationTable.reloadRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.locationTable.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        locationTable.beginUpdates()
    }
}

extension LocationController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationPresenter.fetchedhResultController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationPresenter.fetchedhResultController.sections?[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        let location = locationPresenter.fetchedhResultController.object(at: indexPath) as? Location
        cell.configureCell(with: location)
        return cell
    }
}
