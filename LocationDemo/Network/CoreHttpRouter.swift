
import Foundation
import Alamofire

enum CoreHttpRouter: HTTPRequest {
    case getLocation(groupId:String)
  
    var method: HTTPMethod {
        switch self {
        case .getLocation: return .get
        }
    }
    
    var path: String {
        switch self {
        case .getLocation(let groupId):
            return "/\(groupId)"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .getLocation:
             return try URLEncoding.queryString.encode(request, with: parameters)
        }
    }
}
