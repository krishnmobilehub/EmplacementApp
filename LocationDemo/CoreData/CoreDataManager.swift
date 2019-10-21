
import Foundation
import CoreData

class CoreDataManager {
    
    // MARK: - Core Data stack
    static let sharedInstance = CoreDataManager()
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "LocationDemo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("LocationDemo.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        var managedObjectContext: NSManagedObjectContext?
        if #available(iOS 10.0, *){
            
            managedObjectContext = self.persistentContainer.viewContext
        }
        else{
            let coordinator = self.persistentStoreCoordinator
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext?.persistentStoreCoordinator = coordinator
            
        }
        return managedObjectContext!
    }()
    
    // iOS-10
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func getManagedContext () -> NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        }
        else {
            return self.managedObjectContext
        }
    }
    
    // MARK: - Core Data Saving Support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Core Data Fetch Support
    func fetch(entityName: NSString) -> [NSManagedObject] {
        var managedObjects: [NSManagedObject] = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName as String)
        do {
            managedObjects = try getManagedContext().fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return managedObjects
    }
    
    func fetchWithPredicate(entityName: NSString, predicate: NSPredicate) -> [NSManagedObject] {
        var managedObjects: [NSManagedObject] = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName as String)
        fetchRequest.predicate = predicate
        do {
            managedObjects = try getManagedContext().fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return managedObjects
    }
    
    func delete(entityName: NSString) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName as String)
        
        do {
            if let fetchResults = try getManagedContext().fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject] {
                for managedObject in fetchResults  {
                    getManagedContext().delete(managedObject)
                }
                try getManagedContext().save()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
