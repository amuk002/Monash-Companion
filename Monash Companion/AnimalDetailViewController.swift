//
//  AnimalDetailViewController.swift
//  Monash Companion
//
//  Created by Aditi on 01/09/18.
//  Copyright © 2018 Aditi. All rights reserved.
//  

import UIKit
import MapKit

class AnimalDetailViewController: UIViewController {
    
    var animalImage: String?
    var animalName: String?
    var animalInfo: String?
    var lat: Double?
    var long: Double?
    let regionRadius: CLLocationDistance = 500
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if loadImageData(fileName: animalImage!) == nil {
            imageView.image = UIImage(named: animalImage!)
        }
        else {
            imageView.image = loadImageData(fileName: animalImage!)
        }
        
        nameTextField.text = animalName
        descriptionTextField.text = animalInfo
        
        let initialLocation = CLLocation(latitude: lat!, longitude: long!)
        let newLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        let newPin = MKPointAnnotation()
        newPin.coordinate = newLocation
        mapView.addAnnotation(newPin)
        lat = newPin.coordinate.latitude
        long = newPin.coordinate.longitude
        centerMapOnLocation(location: initialLocation)
        adjustTextViewHeight(textView: descriptionTextField)
    }
    
    //Adapted from https://stackoverflow.com/questions/38714272/how-to-make-uitextview-height-dynamic-according-to-text-length
    func adjustTextViewHeight(textView : UITextView)
    {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
    }
    
    //Adapted from https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
