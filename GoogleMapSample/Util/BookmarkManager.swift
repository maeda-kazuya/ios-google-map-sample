//
//  BookmarkManager.swift
//
//  Created by Maeda Kazuya on 2019/01/27.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation
import GooglePlaces

class BookmarkManager: NSObject {
    func updateBookmark(place: GMSPlace, isBookmarked: Bool) {
        if (isBookmarked) {
            // Remove from bookmark
            if let bookmarks = UserDefaults.standard.array(forKey: Constant.bookmarkDataKey) as? [[String: Any]] {
                var updatedBookmarks: [[String: Any]] = []
                
                // Copy bookmark list except for removing one
                for bookmark in bookmarks {
                    if (bookmark["placeId"] as? String == place.placeID) {
                        continue
                    } else {
                        updatedBookmarks.append(bookmark)
                    }
                }
                
                UserDefaults.standard.set(updatedBookmarks, forKey: Constant.bookmarkDataKey)
            }
        } else {
            if let bookmarks = UserDefaults.standard.array(forKey: Constant.bookmarkDataKey) {
                UserDefaults.standard.set(bookmarks + [getPlaceDic(place: place)], forKey: Constant.bookmarkDataKey)
            } else {
                UserDefaults.standard.set([getPlaceDic(place: place)], forKey: Constant.bookmarkDataKey)
            }
        }
    }
    
    private func getPlaceDic(place: GMSPlace) -> [String: Any] {
        var placeDic: [String: Any] = [:]
        
        placeDic["placeId"] = place.placeID
        placeDic["placeName"] = place.name
        
        return placeDic
    }
}
