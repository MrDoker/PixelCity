//
//  DroppablePin.swift
//  PixelCity
//
//  Created by DokeR on 29.08.2018.
//  Copyright © 2018 DokeR. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifer: String
    
    init(coordinate: CLLocationCoordinate2D, identifer: String) {
        self.coordinate = coordinate
        self.identifer = identifer
        super.init()
    }
}
