//
//  Networking.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 31.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(String)
}

class Networking {
    
    let url = "https://api.github.com/search/repositories?q="
    let sortParam = "&sort="
    let orderParam =  "&order=desc"
    let httpMethod = "get"
    let session = URLSession.shared
    var currentTasks: [URLSessionDataTask] = []
    
    public func performSearch(of userQuery: String, sortedBy sortType: String, done: @escaping (Result<NSArray>) -> ()) {
        let request = formRequest(with: userQuery, sortedBy: sortType)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return done(.failure(error.localizedDescription))
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                return done(.failure("Server error"))
            }
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                let result = json["items"] as? NSArray,
                result.count > 0 else {
                return done(.failure("There was an issue with the returned data"))
            }
            done(.success(result))
        }
        currentTasks.append(task)
        task.resume()
    }
    
    public func cancelSearch() {
        if currentTasks.count > 0 {
            for task in currentTasks {
                task.cancel()
            }
            currentTasks.removeAll()
        }
    }
    
    private func formRequest(with userQuery: String, sortedBy sortOrder: String) -> URLRequest {
        let query = userQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlString = url + query! + sortParam + sortOrder + orderParam
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

}
