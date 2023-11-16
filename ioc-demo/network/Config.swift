//
//  Config.swift
//  ioc-demo
//
//  Created by melodic-gin on 2023/11/7.
//

import Foundation
import Yams

enum ConfigError: Error {
    case NotFound(String)
}

// Use for parse config contents with yaml format.
struct Config: Codable, Equatable {
    enum Method: String, Codable, Equatable {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    var baseURL: String
    
    struct Services: Codable, Equatable {
        var name: String
        var path: String
        var description: String?
        var method: Method?
        var baseAPI: String?
        var bypass: Bool?
    }
}

class ConfigManager {
    static let shared = ConfigManager()
    
    fileprivate let configName = "config.yml"
    
    var config: Config!
    
    init() {
        do {
            self.config = try loadConfig()
        } catch {
            
        }
    }
    
    private func loadConfig() throws -> Config {
        if let path = Bundle.main.path(forResource: configName, ofType: nil) {
            let contents = try String(contentsOfFile: path, encoding: .utf8)
            let config = try YAMLDecoder().decode(Config.self, from: contents)
            return config
        } else {
            throw ConfigError.NotFound("Can not find config file.")
        }
    }
}
