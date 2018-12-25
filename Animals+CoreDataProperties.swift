//
//  Animals+CoreDataProperties.swift
//  Monash Companion
//
//  Created by Aditi on 04/09/18.
//  Copyright © 2018 Aditi. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit


extension Animals: MKAnnotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Animals> {
        return NSFetchRequest<Animals>(entityName: "Animals")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var image: String?
    
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}
