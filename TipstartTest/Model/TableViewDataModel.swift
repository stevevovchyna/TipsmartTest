//
//  MainTableViewDataModel.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 01.02.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

enum SortOptions {
    case name
    case rating
}

class TableViewDataModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let sortType: SortOptions
    
    var searchResult: [SearchItem] = [] {
        didSet {
            switch sortType {
            case .name:
                self.searchResult.sort { $0.repoName < $1.repoName }
            case .rating:
                self.searchResult.sort { $0.rating > $1.rating }
            }
        }
    }
    
    init(sortedBy type: SortOptions) {
        sortType = type
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        let item = searchResult[indexPath.row]
        var text = item.repoName
        text = text.inserting(separator: "\n", every: 15)
        cell.repoName.text = text + "  \(item.rating)"
        cell.repoUrl.text = item.repoUrl
        cell.userImage.image = UIImage(named: "loading")
        cell.userImage.downloaded(from: URL(string: item.userImage)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchResult.count > 0, let url = URL(string: searchResult[indexPath.row].repoUrl) {
            tableView.cellForRow(at: indexPath)?.isSelected = false
            UIApplication.shared.open(url)
        }
    }

}
