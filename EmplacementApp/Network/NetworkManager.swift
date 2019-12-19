
import Foundation
import Alamofire

enum NetworkError: LocalizedError {
    case notFound
    case unauthorized
    case forbidden
    case nonRecoverable
    case errorString(String?)
    case unprocessableEntity(String?)
    case other
    
    var errorDescription: String? {
        //Here we should have our cutsom messages that could be used in the app
        return "Some error occurd here"
    }
}

struct NetworkManager {

    static func makeRequest(_ urlRequest: URLRequestConvertible, showLog: Bool = true, completion: @escaping (Result) -> ()) {
        Alamofire.request(urlRequest)
            .validate()
            .responseJSON { responseObject in
                switch responseObject.result {
                case .success(let value):
                    if (showLog) {
                        debugPrint(value)
                    }
                    completion(.success(value))
                case .failure(let error):
                    if let statusCode = responseObject.response?.statusCode {
                        switch statusCode {
                        case 400:
                            var jsonData: String?
                            if let data = responseObject.data {
                                jsonData = String(data: data, encoding: .utf8)
                            }
                            completion(.failure(NetworkError.errorString(jsonData)))
                        case 401: completion(.failure(NetworkError.unauthorized))
                        case 403: completion(.failure(NetworkError.forbidden))
                        case 404: completion(.failure(NetworkError.notFound))
                        case 422: completion(.failure(NetworkError.unauthorized))
                        var jsonData: String?
                        if let data = responseObject.data {
                            jsonData = String(data: data, encoding: .utf8)
                        }
                        completion(.failure(NetworkError.unprocessableEntity(jsonData)))
                        case 500: completion(.failure(NetworkError.nonRecoverable))
                        default:  completion(.failure(NetworkError.other))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
        }
    }
}

enum Result
{
    case success(Any)
    case failure(Error)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
    
    var value: Any? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

