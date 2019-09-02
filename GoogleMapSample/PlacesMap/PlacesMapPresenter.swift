//
//  PlacesMapPresenter.swift
//
//  Created by Maeda Kazuya on 2019/01/11.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire

protocol PlacesMapPresenterInput {
    func detectCurrentLocation()
    func reload()
}

protocol PlacesMapPresenterOutput: AnyObject {
    func getMapView() -> GMSMapView
    func showPlaceDetail(placeId: String)
    func showErrorMessage()
}

final class PlacesMapPresenter: NSObject, PlacesMapPresenterInput {
    private weak var view: PlacesMapPresenterOutput!
    private var model: PlacesMapModelInput

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    init(view: PlacesMapPresenterOutput, model: PlacesMapModelInput) {
        self.view = view
        self.model = model
    }

    func detectCurrentLocation() {
        mapView = self.view.getMapView()
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
    }
    
    func reload() {
        fetchPlace(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude, zoom: mapView.camera.zoom)
    }
    
    private func fetchPlace(latitude: Double, longitude: Double, zoom: Float) {
        model.fetchPlace(latitude: latitude, longitude: longitude, zoom: zoom) { result in
            switch result {
            case .success(let placeList):
                if (placeList.count == 0) {
                    self.view.showErrorMessage()
                }
                
                for place in placeList {
                    if let latitude = place.geometry?.location?.lat, let longitude = place.geometry?.location?.lng {
                        let marker = Marker()
                        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        marker.title = place.name
                        marker.snippet = "See detail"
                        marker.placeId = place.placeId
                        marker.map = self.mapView
                    }
                }
            case .failure(let error):
                print("# Error: " + error.localizedDescription)
            }
        }
    }
}

extension PlacesMapPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }

            fetchPlace(latitude: latitude, longitude: longitude, zoom: zoomLevel)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension PlacesMapPresenter: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let marker: Marker = marker as? Marker, let placeId = marker.placeId {
            view.showPlaceDetail(placeId: placeId)
        } else {
            print("# No placeId..")
        }
    }
}
