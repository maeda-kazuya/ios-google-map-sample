//
//  FirstViewController.swift
//
//  Created by Maeda Kazuya on 2019/01/11.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacesMapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    private var presenter: PlacesMapPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PlacesMapPresenter(view: self, model: PlacesMapModel())
        presenter?.detectCurrentLocation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let placeDetailViewController = segue.destination as? PlaceDetailViewController, let placeId = sender as? String {
            placeDetailViewController.placeId = placeId
        } else {
            print("# error..")
        }
    }

    @IBAction func reload(_ sender: Any) {
        presenter?.reload()
    }
    
    private func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) in
            //NOP
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension PlacesMapViewController: PlacesMapPresenterOutput {
    func getMapView() -> GMSMapView {
        return mapView
    }
    
    func showPlaceDetail(placeId: String) {
        performSegue(withIdentifier: "showPlaceDetail", sender: placeId)
    }
    
    func showErrorMessage() {
        showAlert("No places found. Please try again later.", message: "")
    }
}
