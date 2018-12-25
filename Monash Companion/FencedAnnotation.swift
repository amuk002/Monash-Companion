//
//  FencedAnnotation.swift
//  Monash Companion
//
//  Created by Aditi on 27/08/18.
//  Copyright © 2018 Aditi. All rights reserved.
//  Adapted from https://moodle.vle.monash.edu/pluginfile.php/7144642/mod_resource/content/3/W05a%20-%20MapKit%20%20Geolocation.pdf
//

import UIKit
import MapKit

class FencedAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    
    init(newTitle: String, newSubtitle: String, lat: Double, long: Double, image: String) {
        title = newTitle
        subtitle = newSubtitle
        coordinate = CLLocationCoordinate2D()
        coordinate.latitude = lat
        coordinate.longitude = long
        imageName = image
    }
}
