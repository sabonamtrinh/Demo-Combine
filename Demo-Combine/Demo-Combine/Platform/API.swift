//
//  API.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import Foundation
import Combine

class APIService {
    private init() {}
    
    static let shared = APIService()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    private var apiKey: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
          fatalError("Couldn't find file 'Keys.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'Keys.plist'.")
        }
        return value
      }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
        case trace = "TRACE"
        case patch = "PATCH"
    }
    
    
    func request<T: Codable>(url: String, expecting: T.Type) -> AnyPublisher<T, APIError> {
        let urlString = "https://api.coinranking.com/v2/search-suggestions?query=" + url
        
        return URLSession.shared
            .dataTaskPublisher(for: URL(string: urlString)!)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is URLError:
                    return .errorURL
                case is DecodingError:
                    return .errorParsing
                default:
                    return error as? APIError ?? .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}

enum APIError: Error {
   case error(String)
   case errorURL
   case invalidResponse
   case errorParsing
   case unknown
   
   var localizedDescription: String {
     switch self {
     case .error(let string):
       return string
     case .errorURL:
       return "URL String is error."
     case .invalidResponse:
       return "Invalid response"
     case .errorParsing:
       return "Failed parsing response from server"
     case .unknown:
       return "An unknown error occurred"
     }
   }
 }
