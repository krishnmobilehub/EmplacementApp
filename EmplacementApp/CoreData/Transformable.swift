
import Foundation
import CoreData

protocol Transformable {
    static var keyMapping: [String: String]?    { get }
    var dateFormatter: DateFormatter?           { get }
    
    //USAGE is for updateOrMake function for when we have a unique Primary Key
    static var primaryKey: String?              { get }

    /**Ignore Keys are used if we do not want to update specific properties within an object.
    //USAGE: If you are overriding KeyMapping, please use the key that is your
     property name in your model and not the key from the server
     **/
    var ignoreKeys: [String]                    { get }
}

extension Transformable {
    
    static var keyMapping: [String: String]? {
        return nil
    }
    
    var dateFormatter: DateFormatter? {
        return nil
    }
    
    static var primaryKey: String? {
        return nil
    }
    
    var ignoreKeys: [String] {
        return []
    }
}

extension Transformable where Self: NSManagedObject {
    
    //Update existing Object
    func update(fromJSON JSON: [String: Any], with dateFormatter: DateFormatter? = nil) {
        update(fromJSON: JSON, with: dateFormatter, isUpdating: true)
    }
    
    static func updateOrMake(fromJSON JSON: [String: Any],in context: NSManagedObjectContext, with dateFormatter: DateFormatter? = nil, allObjects: [Self]) -> Self {

        //Check to see if there is Primary Key
        if let primaryKey = Self.primaryKey {
            var key = primaryKey
            //If there is a key mapping, check to see if the PrimaryKey is one of them
            if let keyMapping = Self.keyMapping,
                keyMapping.keys.contains(primaryKey) {
                let mappedKey = keyMapping[primaryKey] ?? ""
                key = mappedKey
            }
            
            if !key.isEmpty, let value = JSON[key] as? String {
                let predicate = NSPredicate(format: "%K == %@",primaryKey, value)
                
                let filtered = allObjects.filter { return predicate.evaluate(with: $0) }
                
                if let existingObject = filtered.first {
                    existingObject.update(fromJSON: JSON, with: dateFormatter, isUpdating: true)
                    return existingObject
                }
            }
        }
        
        //Otherwise Create New Object
        let object = make(fromJSON: JSON, in: context, with: dateFormatter)
        return object
    }

    static func make(fromJSON JSON: [String: Any], in context: NSManagedObjectContext, with dateFormatter: DateFormatter? = nil) -> Self {
        
        let managedObject = Self(context: context)
        managedObject.update(fromJSON: JSON, with: dateFormatter, isUpdating: false)
        return managedObject
    }
}

// MARK: - Private
private extension Transformable where Self: NSManagedObject {
    
    func update(fromJSON JSON: [String: Any], with dateFormatter: DateFormatter? = nil, isUpdating: Bool) -> Void {
        let attributes      =   entity.attributesByName
        let mappings        =   Self.keyMapping ?? [:]
        
        for (key, type) in attributes {
            
            var valueFromJson : Any?
            let temp : Any?
            
            if let actualkey = mappings[key] {
                if isUpdating && ignoreKeys.contains(key) {
                    break
                }
                temp = JSON[actualkey]
            }
            else {
                if isUpdating && ignoreKeys.contains(key) {
                    break
                }
                temp = JSON[key]
            }
            
            
            switch type.attributeType {
            case .stringAttributeType :
                valueFromJson = (temp as? String) ?? (temp as? Int)
                
            case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType :
                if let x = temp as? String {
                    valueFromJson = Int(x)
                }
                else if let x = temp as? Int {
                    valueFromJson = x
                }
                
            case .doubleAttributeType :
                if let x = temp as? String {
                    valueFromJson = Double(x)
                }
                else if let x = temp as? Double {
                    valueFromJson = x
                }
                
            case .floatAttributeType :
                if let x = temp as? String {
                    valueFromJson = Float(x)
                }
                else if let x = temp as? Float {
                    valueFromJson = x
                }
                
            case .booleanAttributeType :
                if let x = temp as? String {
                    if x == "true" || x == "1" {
                        valueFromJson = 1
                    }
                    else {
                        valueFromJson = 0
                    }
                }
                else if let x = temp as? Int {
                    valueFromJson = x
                }
                
            case .dateAttributeType :
                valueFromJson = convertValueForDate(temp, dateFormatter: dateFormatter)
                
            default:
                break
            }
            
            setValue(valueFromJson, forKey: key)
        }
    }
    
    func convertValueForDate(_ value: Any?, dateFormatter: DateFormatter?) -> Any? {
        var valueFromJson : Any?
        
        if let x = value as? String {
            valueFromJson = dateFormatter?.date(from: x)
        }
        else if let x = value as? Double {
            valueFromJson = Date(timeIntervalSince1970: Double(x) / 1000)
        }
        
        return valueFromJson
    }
}
