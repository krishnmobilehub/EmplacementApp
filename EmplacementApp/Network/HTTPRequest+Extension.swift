
import Foundation

import Alamofire

protocol HTTPRequest: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var request: URLRequest { get }
}

extension HTTPRequest {
    var baseURL: String {
        //We can make this dynamic from build configs when we are doing DEBUG and RELEASE
        return "https://www.google.com/"
    }
    
    var url: URL {
        return URL(string: baseURL + path)!
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var request: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}
