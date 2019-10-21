
import Foundation
import CoreData
public class Location: NSManagedObject, ManagedObjectProtocol {

    // MARK: fetch API
    
    public class func performLocationsLoading(fromData:[Any], in context: NSManagedObjectContext) {
        let existingLocations = Location.findAll(in: context)
        
        var count = 0
        for aNode in fromData {
            print(aNode)
            guard let locationDict = aNode as? [String: Any],
                let _ = locationDict["id"] as? String else {
                    continue
            }

            let location = Location.updateOrMake(fromJSON: locationDict, in: context, allObjects: existingLocations)
            
            if let addressDict = locationDict["address"] as? [String: Any] {
                
                if let address = location.toAddress {
                    address.update(fromJSON: addressDict)
                } else {
                    location.toAddress = Address.make(fromJSON: addressDict, in: context)
                }
                
                if let coordinatesDict = addressDict["coordinates"] as? [String: Any] {
                    if let coordinates = location.toAddress?.toCoordinates {
                        coordinates.update(fromJSON: coordinatesDict)
                    } else {
                        location.toAddress?.toCoordinates = Coordinates.make(fromJSON: coordinatesDict, in: context)
                    }
                }
            }
            
            count += 1
            if count > 5 {
                Location.saveContext(context)
                count = 0
            }
        }
        
        Location.saveContext(context)
    }
}

// MARK: - Transformable
extension Location: Transformable {
    
    static var keyMapping: [String : String]? {
        return ["locationId": "id",
                "locationName": "name"]
    }
    
    //Example of Ignoring a property which we don't want to update when doing an update of a Object
    var ignoreKeys: [String] {
        return ["locationName"]
    }
    
    static var primaryKey: String? {
        return "locationId"
    }
}
