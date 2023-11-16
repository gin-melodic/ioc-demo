//
//  Core.swift
//  ioc-demo
//
//  Created by melodic-gin on 2023/11/7.
//

import Foundation
import Alamofire

public protocol APICovertable<T> {
    associatedtype T
    func convert() -> T
}

extension String: APICovertable {
    public func convert() -> String {
        return self
    }
}

public protocol APIComponents {
    var serviceName: APIComponents { get }
    var path: String { get }
    var description: String? { get }
    var method: Alamofire.HTTPMethod { get }
    var overrideBaseAPI: String? { get }
    var bypass: Bool? { get }
}

struct APIItem: APIComponents {
    var serviceName: APIComponents
    var path: String
    var description: String?
    var method: Alamofire.HTTPMethod = .get
    var overrideBaseAPI: String?
    var bypass: Bool?
}

extension APIItem: APICovertable {
    func convert() -> APIComponents {
        return self
    }
}

extension ServiceName: APICovertable {
    public func convert() -> String {
        return self.rawValue
    }
}

// Retrieve all configuration files from the configuration file for subsequent use.
struct APICollection {
    static let shared = APICollection()
    
    private var all: [ServiceName: APIItem] = [:]
}

public class NetworkCore {
    public static let shared = NetworkCore()
    var baseURL = ""
    
    private(set) var taskQueue = NSMutableArray()
    
    lazy var sessionManager: Alamofire.Session =  Alamofire.Session(configuration: URLSessionConfiguration.default, startRequestsImmediately: false)
    
    private init() {
        let configManager = ConfigManager.shared
        self.baseURL = configManager.config.baseURL
    }
    
    /**
        Send request.
        Usage exapmle: NetworkCore.shared.request(api: ServiceName.Login, complete: nil)
     */
    @discardableResult
    func request<T, K>(api: T, parameters: K = Alamofire.Empty?.none, headers: HTTPHeaders = HTTPHeaders(), complete: @escaping  (DataResponse<Any, Error>) -> Void) -> DataRequest where T: APICovertable, K: Encodable {
        let apiItem: APIItem = api.convert() as! APIItem
        let url: URLConvertible = self.baseURL + apiItem.path
        // Set http headers, token, ...
        let request = self.sessionManager.request(url, method: apiItem.method, parameters: parameters, headers: headers)
        request.validate().responseData { dataResponse in
            // deal response
        }.resume()
        return request
    }
}

