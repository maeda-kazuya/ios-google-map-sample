//
//  BookmarkListPresenter.swift
//
//  Created by Maeda Kazuya on 2019/01/27.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation

protocol BookmarkListPresenterInput {
    var numberOfBookmarks: Int { get }
    func place(forRow row: Int) -> Place?
    func didSelectRow(at indexPath: IndexPath)
    func loadBookmark()
}

protocol BookmarkListPresenterOutput: AnyObject {
    func updateList(_ places: [Place])
    func transitionToPlaceDetail(placeId: String)
}

final class BookmarkListPresenter: BookmarkListPresenterInput {
    private var model: BookmarkListModelInput
    private weak var view: BookmarkListPresenterOutput!
    private var bookmarkList: [Place] = []
    
    init(view: BookmarkListPresenterOutput, model: BookmarkListModelInput) {
        self.view = view
        self.model = model
    }

    var numberOfBookmarks: Int {
        return bookmarkList.count
    }
    
    func place(forRow row: Int) -> Place? {
        guard row < bookmarkList.count else { return nil }
        return bookmarkList[row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        if let placeId = bookmarkList[indexPath.row].placeId {
            view.transitionToPlaceDetail(placeId: placeId)
        }
    }

    func loadBookmark() {
        if let bookmarkList = UserDefaults.standard.array(forKey: Constant.bookmarkDataKey) as? [[String: Any]] {
            self.bookmarkList = []
            
            for bookmark in bookmarkList {
                guard let placeId = bookmark["placeId"] as? String, let placeName = bookmark["placeName"] as? String else {
                    continue
                }
                
                let place = Place()
                place.placeId = placeId
                place.name = placeName
                
                self.bookmarkList.append(place)
            }
            
            self.bookmarkList.reverse()
            self.view.updateList(self.bookmarkList)
        }
    }
}
