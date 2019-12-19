
import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var locationId: String?
    @NSManaged public var locationName: String?
    @NSManaged public var toAddress: Address?

}
