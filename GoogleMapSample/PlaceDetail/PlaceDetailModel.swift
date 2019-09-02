//
//  PlaceDetailModel.swift
//
//  Created by Maeda Kazuya on 2019/01/26.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation
import GooglePlaces

protocol PlaceDetailModelInput {
    func fetchPlaceDetail(placeId: String, completion: @escaping (Result<GMSPlace>) -> ())
    func fetchPlacePhoto(placeId: String, completion: @escaping (Result<UIImage>) -> ())
}

final class PlaceDetailModel: PlaceDetailModelInput {
    func fetchPlaceDetail(placeId: String, completion: @escaping (Result<GMSPlace>) -> ()) {
        GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            
            completion(.success(place))
        })
    }

    func fetchPlacePhoto(placeId: String, completion: @escaping (Result<UIImage>) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, completion: completion)
                }
            }
        }
    }
    
    private func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, completion: @escaping (Result<UIImage>) -> ()) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let photo = photo {
                completion(.success(photo))
            }
        })
    }
}
