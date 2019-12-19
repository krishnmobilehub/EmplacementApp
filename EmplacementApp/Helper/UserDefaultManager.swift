
import Foundation
protocol CoreStorageProtocol {
    func saveItem(_ item: Any?)
    func retrieveItem() ->Any?
    func removeItem()
}

enum StorageItemType {
    case ObjectItem
}

enum StorageItem {
    case LastSyncDate
    
    func getKey() ->String? {
        switch self {
        case .LastSyncDate:
            return "_Last_Sync"
        }
    }
    
    func getType() ->StorageItemType {
        switch self {
        case .LastSyncDate:
            return .ObjectItem
        }
    }
}

extension StorageItem : CoreStorageProtocol {
    func saveItem(_ item: Any?) {
        if let item = item,
            let key = self.getKey() {
            UserDefaults.standard.set(item, forKey: key)
        }
    }
    
    func retrieveItem() ->Any? {
        if let key = self.getKey() {
            let type = self.getType()
            switch type {
            case .ObjectItem:
                return UserDefaults.standard.object(forKey:key)
            }
        }
        return nil
    }
    
    func removeItem() {
        if let key = self.getKey() {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
