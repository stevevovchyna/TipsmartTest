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
    
    var portraitTV1 = CGRect()
    var portraitTV2 = CGRect()
    var landscapeTV1 = CGRect()
    var landscapeTV2 = CGRect()
    
    let network = Networking()
    let itemManager = ItemManager()
    let mainTVDataModel = TableViewDataModel(sortedBy: .name)
    let secondTVDataModel = TableViewDataModel(sortedBy: .rating)
    let secondTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        tableView.delegate = mainTVDataModel
        tableView.dataSource = mainTVDataModel
        
        secondTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        secondTableView.delegate = secondTVDataModel
        secondTableView.dataSource = secondTVDataModel
        
        self.view.addSubview(secondTableView)
        
        setTableFrames()
        
        cancelButtonHeight.constant = 0
        cancelButton.isHidden = true
        
        searchBar.text = "piscine42"
        
        let cache = itemManager.getAllItems()
        if cache.count > 0, let array = cache[0].cache {
            do {
                let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(array)
                mainTVDataModel.searchResult = self.processSearchResult(with: data as! NSArray, for: 30)
                secondTVDataModel.searchResult = self.processSearchResult(with: data as! NSArray, for: 30)
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
                        self.mainTVDataModel.searchResult = self.processSearchResult(with: data, for: 30)
                        self.secondTVDataModel.searchResult = self.mainTVDataModel.searchResult
                        self.itemManager.removeAllItems()
                        self.itemManager.save()
                        do {
                            let coreData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                            self.addToDB(items: coreData)
                        } catch (let error) {
                            self.presentAlert(text: error.localizedDescription, in: self)
                        }
                        self.tableView.reloadData()
                        self.secondTableView.reloadData()
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

extension ViewController {
    override func viewSafeAreaInsetsDidChange() {
        setTableFrames()
    }
}

extension ViewController {
    private func setTableFrames() {
        let vframe = view.frame.size
        let searchBarHeight = searchBar.frame.size.height
        let searchButtonHeight = searchButton.frame.size.height
        let topInset = view.safeAreaInsets.top
        portraitTV1 = CGRect(x: 0, y: searchBarHeight + searchButtonHeight + topInset, width: vframe.width, height: vframe.height - searchBarHeight - searchButtonHeight - topInset)
        portraitTV2 = CGRect(x: 0, y: searchBarHeight + searchButtonHeight + topInset, width: vframe.width, height: vframe.height - searchBarHeight - searchButtonHeight - topInset)
        landscapeTV1 = CGRect(x: 0, y: searchBarHeight + searchButtonHeight, width: vframe.width / 2, height: vframe.height - searchBarHeight - searchButtonHeight)
        landscapeTV2 = CGRect(x: vframe.width / 2, y: searchBarHeight + searchButtonHeight, width: vframe.width / 2, height: vframe.height - searchBarHeight - searchButtonHeight)
        let isPortrait = (view.frame.size.height > view.frame.size.width);
        tableView.frame = isPortrait ? portraitTV1 : landscapeTV1
        secondTableView.frame = isPortrait ? portraitTV2 : landscapeTV2
        secondTableView.isHidden = isPortrait
    }
    
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


