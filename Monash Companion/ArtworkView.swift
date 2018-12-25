//
//  ArtworkView.swift
//  Monash Companion
//
//  Created by Aditi on 30/08/18.
//  Copyright © 2018 Aditi. All rights reserved.
//

import UIKit
import MapKit

class ArtworkView: MKAnnotationView {

    
    //Adapted from https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? FencedAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if let imageName = artwork.imageName {
                if loadImageData(fileName: imageName) == nil {
                    image = UIImage(named: imageName)
                }
                else {
                    image = loadImageData(fileName: imageName)
                }
            } else {
                image = UIImage(named: "Zoo logo")
            }
            image = resizeImage(image: image!, targetSize: CGSize(width: 60, height: 60))
        }
    }
    
    //Adapted from https://moodle.vle.monash.edu/pluginfile.php/7407900/mod_resource/content/4/W05b%20-%20Cameras%20%20Local%20Storage.pdf
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if let fileData = fileManager.contents(atPath: filePath) {
                image = UIImage(data: fileData)
            }
        }
        return image
    }
    
    //Adapted from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
