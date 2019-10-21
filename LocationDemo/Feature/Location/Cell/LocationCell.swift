
import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var locationCoordinates: UILabel!
    
    func configureCell(with location: Location?) {
        locationName.text = location?.locationName
        if let address = location?.toAddress?.address, let state = location?.toAddress?.state, let city = location?.toAddress?.city, let zip = location?.toAddress?.zip {
            locationAddress.text = "\(address), \(state)-\(zip), \(city)"
        }
        if let coordinate = location?.toAddress?.toCoordinates {
            locationCoordinates.text = "\(coordinate.latitude), \(coordinate.longitude)"
        }
    }

}
