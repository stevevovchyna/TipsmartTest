//
//  ViewController.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 31.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var searchButtonHeight: NSLayoutConstraint!
    
    let network = Networking()
    let itemManager = ItemManager()
    var searchResult: [SearchItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        cancelButtonHeight.constant = 0
        cancelButton.isHidden = true
        searchBar.text = "piscine42"
        let cache = itemManager.getAllItems()
        if cache.count > 0, let array = cache[0].cache {
            do {
                let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(array)
                searchResult = self.processSearchResult(with: data as! NSArray, for: 30)
            } catch (let error) {
                self.presentAlert(text: error.localizedDescription, in: self)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        guard let query = searchBar.text else { return }
        searchBar.resignFirstResponder()
        if query.count > 0 {
            setSearchButton(asActive: false)
            network.performSearch(of: query) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let err):
                        self.setSearchButton(asActive: true)
                        if err != "cancelled" { self.presentAlert(text: err, in: self) }
                    case .success(let data):
                        self.setSearchButton(asActive: true)
                        self.searchResult = self.processSearchResult(with: data, for: 30)
                        self.itemManager.removeAllItems()
                        self.itemManager.save()
                        do {
                            let coreData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                            self.addToDB(items: coreData)
                        } catch (let error) {
                            self.presentAlert(text: error.localizedDescription, in: self)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        network.cancelSearch()
        self.setSearchButton(asActive: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        let item = searchResult[indexPath.row]
        var text = item.repoName
        text = text.inserting(separator: "\n", every: 15)
        cell.repoName.text = text
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

extension ViewController {
    private func processSearchResult(with array: NSArray, for number: Int) -> [SearchItem] {
        var allResults: [SearchItem] = []
        let upperRange = array.count <= number ? array.count : number
        allResults = array.prefix(upperRange).map { SearchItem(with: $0 as! NSDictionary) }
        return allResults
    }
    
    private func setSearchButton(asActive bool: Bool) {
        cancelButton.isHidden = bool
        searchButton.isHidden = !bool
        if !bool {
            cancelButtonHeight.constant = 30
            searchButtonHeight.constant = 0
        } else {
            cancelButtonHeight.constant = 0
            searchButtonHeight.constant = 30
        }
    }
    
    private func presentAlert(text: String, in view: UIViewController) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
    
    private func addToDB(items: Data) {
        let newItem = self.itemManager.newItem()
        newItem.cache = items
        self.itemManager.save()
    }
}


