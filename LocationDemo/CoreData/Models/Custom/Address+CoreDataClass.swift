
import Foundation
import CoreData


public class Address: NSManagedObject {

}

// MARK: - Transformable
extension Address: Transformable {
    
    //Example of Ignoring a property which we don't want to update when doing an update of a Object
    var ignoreKeys: [String] {
        return ["address"]
    }
}
