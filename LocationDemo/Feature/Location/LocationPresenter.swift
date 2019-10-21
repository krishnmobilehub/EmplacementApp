
import Foundation
import CoreData

class LocationPresenter {
    
    let repository: LocationRepository
    weak private var delegate: LocationDelegate?
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Location.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "locationName", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: repository.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = delegate
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")  //TODO: remove before shipping the app
        }
        return controller
    }()
    
    // MARK: - Initialization & Configuration
    init(repository: LocationRepository, delegate: LocationDelegate) {
        self.repository = repository
        self.delegate = delegate
    }
    
    // MARK: - Perform Login
    func getLocationWith(groupId:String) {
        repository.getLocations(groupId: groupId, successHandler: { (locations) in
            if locations.count == 0 {
                self.delegate?.finishWithError("No Data")
            }
        }, errorHandler: { (error) in
            
        })
    }
}
