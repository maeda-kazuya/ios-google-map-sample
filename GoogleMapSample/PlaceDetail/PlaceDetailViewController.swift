//
//  PlaceDetailViewController.swift
//
//  Created by Maeda Kazuya on 2019/01/26.
//  Copyright © 2019 Kazuya Maeda. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceDetailViewController: UIViewController {
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var placeId: String?
    private var presenter: PlaceDetailPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let placeId = placeId else {
            return
        }
        
        presenter = PlaceDetailPresenter(placeId: placeId, view: self, model: PlaceDetailModel())
        presenter?.fetchPlaceDetail()
        presenter?.fetchPlacePhoto()
        presenter?.checkBookmarkStatus()
    }
    
    @IBAction func openWeb(_ sender: Any) {
        presenter?.openWeb()
    }

    @IBAction func openGoogleMap(_ sender: Any) {
        presenter?.openGoogleMap()
    }

    @IBAction func toggleBookmark(_ sender: Any) {
        presenter?.toggleBookmark()
    }
}

extension PlaceDetailViewController: PlaceDetailPresenterOutput {
    func showPlaceInfo(place: GMSPlace) {
        nameLabel.text = place.name
        addressLabel.text = place.formattedAddress?.replacingOccurrences(of: "日本、", with: "")
        urlButton.setTitle(place.website?.absoluteURL.absoluteString, for: UIControl.State.normal)

        if let phoneNumber = place.phoneNumber {
            phoneLabel.text = "TEL : " + phoneNumber.replacingOccurrences(of: "+81 ", with: "0")
        }
    }
    
    func showPlacePhoto(photo: UIImage) {
        placeImageView.image = photo
    }
    
    func toggleBookmarkIcon(image: UIImage) {
        self.bookmarkButton.image = image
    }
}
