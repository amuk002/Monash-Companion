//
//  MapViewController.swift
//  Monash Companion
//
//  Created by Aditi on 27/08/18.
//  Copyright © 2018 Aditi. All rights reserved.
//  Adapted from https://moodle.vle.monash.edu/pluginfile.php/7144642/mod_resource/content/3/W05a%20-%20MapKit%20%20Geolocation.pdf
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    var animalImage: String?
    var animalName: String?
    var animalInfo: String?
    var lat: Double?
    var long: Double?
    
    var animal: FencedAnnotation? {
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        mapView.delegate = self
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Adapted from https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
        let initialLocation = CLLocation(latitude: -37.876828, longitude: 145.045171)
        centerMapOnLocation(location: initialLocation)
        mapView.register(ArtworkView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        self.mapView.addAnnotation(annotation)
    }
    
    func removeAnnotation(annotation: MKAnnotation) {
        self.mapView.removeAnnotation(annotation)
    }
    
    //Adapted from https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func focusOn(annotation: MKAnnotation) {
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.selectAnnotation(annotation, animated: true)
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let animal = view.annotation as! FencedAnnotation
        
        animalImage = animal.imageName!
        animalName = animal.title!
        animalInfo = animal.subtitle!
        lat = animal.coordinate.latitude
        long = animal.coordinate.longitude

        
        
        performSegue(withIdentifier: "animalDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "animalDetails" {
            let animalDetails: AnimalDetailViewController = segue.destination as! AnimalDetailViewController
            animalDetails.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            animalDetails.navigationItem.leftItemsSupplementBackButton = true
            print(animalImage! + " " + animalName! + " " + animalInfo!)
            animalDetails.animalImage = self.animalImage
            animalDetails.animalName = self.animalName
            animalDetails.animalInfo = self.animalInfo
            animalDetails.lat = self.lat
            animalDetails.long = self.long
        }
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

extension MapViewController: AnimalSelectionDelegate {
    func animalSelected(_ newAnimal: FencedAnnotation) {
        animal = newAnimal
    }
}
