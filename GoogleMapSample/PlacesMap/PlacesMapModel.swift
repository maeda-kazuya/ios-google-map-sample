//
//  PlacesMapModel.swift
//
//  Created by Maeda Kazuya on 2019/01/11.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation
import Alamofire

protocol PlacesMapModelInput {
    func fetchPlace(latitude: Double,
                             longitude: Double,
                             zoom: Float,
                             completion: @escaping (Result<[Place]>) -> ())
}

final class PlacesMapModel: PlacesMapModelInput {
    func fetchPlace(latitude: Double,
                             longitude: Double,
                             zoom: Float,
                             completion: @escaping (Result<[Place]>) -> ()) {
        guard let url = makeUrl(latitude: latitude, longitude: longitude, zoom: zoom) else {
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                let decoder: JSONDecoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let result = try decoder.decode(PlacesResponse.self, from: data)

                    if let placeList: [Place] = result.results {
                        completion(.success(placeList))
                    } else {
                        print("# failed to fetch places..")
                    }
                } catch {
                    print("json convert failed in JSONDecoder", error.localizedDescription)
                }
            }
        }
    }
    
    private func makeUrl(latitude: Double, longitude: Double, zoom: Float) -> String? {
        guard let placesApiKey = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "PlacesApiKey") as? String else {
            return nil
        }

        let keyword = "Restaurant"
        let radius = Int(12000 / zoom)
        
        if let keyword = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return "\(Constant.apiDomain)json?location=\(latitude),\(longitude)&radius=\(radius)&keyword=\(keyword)&key=\(placesApiKey)"
            
            // Add request parameter: type
//            return "\(Constant.apiDomain)json?location=\(latitude),\(longitude)&radius=\(radius)&keyword=\(keyword)&key=\(placesApiKey)&type=restaurant"
        } else {
            return nil
        }
    }
}
