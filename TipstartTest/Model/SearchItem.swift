//
//  SearchResult.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 31.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import CoreData

public class SearchItem: NSObject {
    let repoName: String
    let repoUrl: String
    let userImage: String
    let rating: Double
    
    init(with data: NSDictionary) {
        self.repoUrl = data["html_url"] as! String
        self.repoName = data["name"] as! String
        self.userImage = (data["owner"] as! NSDictionary)["avatar_url"] as! String
        self.rating = data["score"] as! Double
    }
}
