//
//  PlaceDetailPresenter.swift
//
//  Created by Maeda Kazuya on 2019/01/26.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation
import GooglePlaces

protocol PlaceDetailPresenterInput {
    func fetchPlaceDetail()
    func fetchPlacePhoto()
    func openWeb()
    func openGoogleMap()
    func toggleBookmark()
    func checkBookmarkStatus()
}

protocol PlaceDetailPresenterOutput: AnyObject {
    func showPlaceInfo(place: GMSPlace)
    func showPlacePhoto(photo: UIImage)
    func toggleBookmarkIcon(image: UIImage)
}

final class PlaceDetailPresenter: PlaceDetailPresenterInput {
    private var placeId: String
    private var place: GMSPlace?
    private var model: PlaceDetailModelInput
    private var isBookmarked = false
    private weak var view: PlaceDetailPresenterOutput!

    init(placeId: String, view: PlaceDetailPresenterOutput, model: PlaceDetailModelInput) {
        self.placeId = placeId
        self.view = view
        self.model = model
    }

    func fetchPlaceDetail() {
        model.fetchPlaceDetail(placeId: placeId) { result in
            switch result {
            case .success(let place):
                self.place = place
                self.view.showPlaceInfo(place: place)
            case .failure(let error):
                print("# Error: " + error.localizedDescription)
            }
        }
    }
    
    func fetchPlacePhoto() {
        model.fetchPlacePhoto(placeId: placeId) { result in
            switch result {
            case .success(let photo):
                self.view.showPlacePhoto(photo: photo)
            case .failure(let error):
                print("# Error: " + error.localizedDescription)
            }
        }
    }
    
    func openWeb() {
        if let url = self.place?.website?.absoluteURL {
            UIApplication.shared.open(url)
        }
    }

    func openGoogleMap() {
        if let placeName = place?.name {
            let urlStr = "https://www.google.com/maps/search/?api=1&query=\(placeName)&query_place_id=\(placeId)"

            if let urlEncoded = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlEncoded) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    func toggleBookmark() {
        if let place = place {
            BookmarkManager().updateBookmark(place: place, isBookmarked: isBookmarked)
            self.toggleBookmarkStatus()
        }
    }
    
    func checkBookmarkStatus() {
        if let bookmarks = UserDefaults.standard.array(forKey: Constant.bookmarkDataKey) as? [[String: Any]] {
            for bookmark in bookmarks {
                if (bookmark["placeId"] as? String == self.placeId) {
                    // Already bookmarked
                    self.toggleBookmarkStatus()
                    
                    return
                }
            }
        }
    }
    
    private func toggleBookmarkStatus() {
        if (isBookmarked) {
            if let image = UIImage(named: "star_negative") {
                view.toggleBookmarkIcon(image: image)
            }

            isBookmarked = false
        } else {
            if let image = UIImage(named: "star_positive") {
                view.toggleBookmarkIcon(image: image)
            }

            isBookmarked = true
        }
    }
}
