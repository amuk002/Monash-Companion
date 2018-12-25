//
//  NewAnimalController.swift
//  Monash Companion
//
//  Created by Aditi on 27/08/18.
//  Copyright © 2018 Aditi. All rights reserved.
//  Adapted from:
//  1. https://moodle.vle.monash.edu/pluginfile.php/7144642/mod_resource/content/3/W05a%20-%20MapKit%20%20Geolocation.pdf
//  2. https://moodle.vle.monash.edu/pluginfile.php/7144626/mod_resource/content/2/W04%20-%20Core%20Data.pdf
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class NewAnimalController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var currentLocation: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 500
    let newPin = MKPointAnnotation()
    
    var lat: Double?
    var long: Double?
    var delegate: NewAnimalDelegate?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currLoc: CLLocationCoordinate2D?
    
    private var appDelegate: AppDelegate?
    private var managedObjectContext: NSManagedObjectContext
    //private var animalList: [Animals] = []
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        
        
        let initialLocation = CLLocation(latitude: currLoc?.latitude ?? -37.877623, longitude: currLoc?.longitude ?? 145.045374)
        let newLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currLoc?.latitude ?? -37.877623, longitude: currLoc?.longitude ?? 145.045374)
        newPin.coordinate = newLocation
        mapView.addAnnotation(newPin)
        lat = newPin.coordinate.latitude
        long = newPin.coordinate.longitude
        centerMapOnLocation(location: initialLocation)
        currentLocation.setImage(#imageLiteral(resourceName: "CurrentLocation"), for: .normal)
        
        mapView.delegate = self
    }
    
    //Adapted from https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnimals() {
        let animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        let first = String((nameTextField.text?.prefix(1))!).capitalized
        let other = String((nameTextField.text?.dropFirst())!)
        animals.name = first + other
        animals.desc = descriptionTextField.text
        let image = addImageView.image
        if image == nil {
            animals.image = "Zoo logo"
        }
        
        else {
             //Adapted from https://moodle.vle.monash.edu/pluginfile.php/7407900/mod_resource/content/4/W05b%20-%20Cameras%20%20Local%20Storage.pdf
            let date = UInt(Date().timeIntervalSince1970)
            var data = Data()
            data = UIImageJPEGRepresentation(image!, 0.8)!
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("\(date)") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
                animals.image = "\(date)"
            }
        }
        
        animals.lat = lat!
        animals.long = long!
        
        do{
            try managedObjectContext.save()
        }
        catch let error{
            print("Could not save Core Data: \(error)")
        }
    }
     //Adapted from https://moodle.vle.monash.edu/pluginfile.php/7407900/mod_resource/content/4/W05b%20-%20Cameras%20%20Local%20Storage.pdf
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
     //Adapted from https://moodle.vle.monash.edu/pluginfile.php/7407900/mod_resource/content/4/W05b%20-%20Cameras%20%20Local%20Storage.pdf
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc: CLLocation = locations.last!
        currLoc = loc.coordinate
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveCurrentLocation(_ sender: Any) {
        if currLoc?.latitude == nil || currLoc?.longitude == nil {
            let alert = UIAlertController(title: "Cannot access current location", message: "Go to settings and allow this app to use your current location.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            mapView.removeAnnotation(newPin)
            let newLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currLoc!.latitude, longitude: currLoc!.longitude)
            let viewNewLocation = CLLocation(latitude: currLoc!.latitude, longitude: currLoc!.longitude)
            newPin.coordinate = newLocation
            mapView.addAnnotation(newPin)
            lat = currLoc?.latitude
            long = currLoc?.longitude
            centerMapOnLocation(location: viewNewLocation)
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            controller.sourceType = UIImagePickerControllerSourceType.camera
        }
        else {
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveAnimalButton(_ sender: Any) {
        if (nameTextField.text?.isEmpty)!
        {
            let alert = UIAlertController(title: "Name Field Empty", message: "Please give some name to this animal.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            let red = UIColor.red
            nameTextField.layer.borderColor = red.cgColor
        }
        else if (descriptionTextField.text?.isEmpty)!
        {
            let alert = UIAlertController(title: "Description Field Empty", message: "Please write something about this animal.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            let red = UIColor.red
            descriptionTextField.layer.borderColor = red.cgColor
        }
        else
        {
            addAnimals()
            delegate?.didSaveAnimal()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //To enable the long press on the location you want to choose
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        //Adapted from https://stackoverflow.com/questions/26228621/how-to-implement-a-draggable-mkpointannotation-using-swift-ios
        let touchedAt = sender.location(in: self.mapView)
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
        mapView.removeAnnotation(newPin)
        newPin.coordinate = touchedAtCoordinate
        mapView.addAnnotation(newPin)
        lat = touchedAtCoordinate.latitude
        long = touchedAtCoordinate.longitude
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
