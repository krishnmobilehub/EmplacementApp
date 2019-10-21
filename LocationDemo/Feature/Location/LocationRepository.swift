
import Foundation
import CoreData

class LocationRepository {
    
    lazy var persistentContainer: NSPersistentContainer = CoreDataManager.sharedInstance.persistentContainer
    
    func getLocations(groupId:String, successHandler: @escaping (_ locations: [Location]) -> Void,
                      errorHandler: @escaping (_ error: Error) -> Void) {
        
        NetworkManager.makeRequest(CoreHttpRouter.getLocation(groupId: groupId)) { result in
            
            switch result {
            case .success(let response):
                //data loading will happen on the background thread
                
                if let response = response as? [String: Any],
                    let allLocations = response["locations"] as? [Any] {
                    self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                        Location.performLocationsLoading(fromData: allLocations, in: backgroundContext)
                        //on saves, the fetched results controiller will act and invoke its delegate - this class table view
                        
                    })
                    successHandler((allLocations as? [Location]) ?? [])
                } else {
                    successHandler([])
                }

            case .failure(let error):
                print(error.localizedDescription)
                errorHandler(error)
            }
        }
    }
}

