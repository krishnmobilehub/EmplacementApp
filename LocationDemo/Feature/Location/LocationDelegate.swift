
import Foundation
import CoreData

protocol LocationDelegate: NSFetchedResultsControllerDelegate {
    func finishWithError(_ error:  String?)
}
