//
//  SecondViewController.swift
//
//  Created by Maeda Kazuya on 2019/01/11.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import UIKit

class BookmarkListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var presenter: BookmarkListPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = BookmarkListPresenter(view: self, model: BookmarkListModel())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.loadBookmark()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let placeDetailViewController = segue.destination as? PlaceDetailViewController, let placeId = sender as? String {
            placeDetailViewController.placeId = placeId
        }
    }
}

extension BookmarkListViewController: BookmarkListPresenterOutput {
    func updateList(_ places: [Place]) {
        self.tableView.reloadData()
    }
    
    func transitionToPlaceDetail(placeId: String) {
        self.performSegue(withIdentifier: "showPlaceDetail", sender: placeId)
    }
}

extension BookmarkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectRow(at: indexPath)
    }
}

extension BookmarkListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = presenter?.numberOfBookmarks {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell?.textLabel?.text = self.presenter?.place(forRow: indexPath.row)?.name
        
        return cell!
    }
}
