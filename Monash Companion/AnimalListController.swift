//
//  AnimalListController.swift
//  Monash Companion
//
//  Created by Aditi on 27/08/18.
//  Copyright © 2018 Aditi. All rights reserved.
//  1. https://moodle.vle.monash.edu/pluginfile.php/7144642/mod_resource/content/3/W05a%20-%20MapKit%20%20Geolocation.pdf
//  2. https://moodle.vle.monash.edu/pluginfile.php/7144626/mod_resource/content/2/W04%20-%20Core%20Data.pdf
//

import UIKit
import MapKit
import CoreData
import UserNotifications

protocol AnimalSelectionDelegate: class {
    func animalSelected(_ newAnimal: FencedAnnotation)
}

protocol NewAnimalDelegate {
    func didSaveAnimal()
}

class AnimalListController: UITableViewController, CLLocationManagerDelegate, UISearchResultsUpdating, NewAnimalDelegate {
    
    var mapViewController: MapViewController?
    var animalDetailViewController: AnimalDetailViewController?
    var locationList = [FencedAnnotation]()
    var filteredLocationList = [FencedAnnotation]()
    
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: AnimalSelectionDelegate?
    
    private var managedObjectContext: NSManagedObjectContext
    var animalList: [Animals] = []
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    func didSaveAnimal() {
        locationList = []
        filteredLocationList = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animals")
        do {
            animalList = try managedObjectContext.fetch(fetchRequest) as! [Animals]
        } catch {
            fatalError("Failed to fetch animals: \(error)")
        }
        for animal in animalList {
            let location: FencedAnnotation = FencedAnnotation(newTitle: animal.name!, newSubtitle: animal.desc!, lat: animal.lat, long: animal.long, image: animal.image!)
            locationList.append(location)
            self.mapViewController?.addAnnotation(annotation: location)
            let geoLocation = CLCircularRegion(center: location.coordinate, radius: 10, identifier: location.title!)
            geoLocation.notifyOnEntry = true
            locationManager.startMonitoring(for: geoLocation)
        }
        switch sortSegment.selectedSegmentIndex {
        case 0:
            filteredLocationList = locationList.sorted { $0.title! < $1.title! }
        case 1:
            filteredLocationList = locationList.sorted { $0.title! > $1.title! }
        default:
            break
        }
        self.tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animals")
        do {
            animalList = try managedObjectContext.fetch(fetchRequest) as! [Animals]
            if animalList.count == 0 {
                addAnimals()
                animalList = try managedObjectContext.fetch(fetchRequest) as! [Animals]
            }
            animalList = try managedObjectContext.fetch(fetchRequest) as! [Animals]
    
            for animal in animalList {
                let location: FencedAnnotation = FencedAnnotation(newTitle: animal.name!, newSubtitle: animal.desc!, lat: animal.lat, long: animal.long, image: animal.image!)
                self.locationList.append(location)
                self.mapViewController?.addAnnotation(annotation: location)
                let geoLocation = CLCircularRegion(center: location.coordinate, radius: 10, identifier: location.title!)
                geoLocation.notifyOnEntry = true
                locationManager.startMonitoring(for: geoLocation)
            }
        }
        catch{
            fatalError("Failed to fetch animals: \(error)")
        }
        filteredLocationList = locationList.sorted { $0.title! < $1.title! }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
            
        })

        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Animals"
        searchController.searchBar.backgroundColor = UIColor.white
        navigationItem.searchController = searchController
        
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    }
    
    func addAnimals() {
        var animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        animals.name = "Koala"
        animals.desc = "Lives on trees and sleeps 22 hours a day."
        animals.lat = -37.876828
        animals.long = 145.045171
        animals.image = "Koala_image"
        
        animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        animals.name = "Kangaroo"
        animals.desc = "Jumps very often and has a pocket to carry it's child"
        animals.lat = -37.874874
        animals.long = 145.048355
        animals.image = "Kangaroo_image"
        
        animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        animals.name = "Panda"
        animals.desc = "A bear with large, distinctive black patches around its eyes, over the ears, and across its round body."
        animals.lat = -37.874610
        animals.long = 145.040162
        animals.image = "Panda_image"
        
        animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        animals.name = "Lion"
        animals.desc = "The lion is a species in the cat family; it is a muscular, deep-chested cat with a short, rounded head, a reduced neck and round ears, and a hairy tuft at the end of its tail."
        animals.lat = -37.881019
        animals.long = 145.040540
        animals.image = "Lion_image"
        
        animals = NSEntityDescription.insertNewObject(forEntityName: "Animals", into: managedObjectContext) as! Animals
        animals.name = "White-headed capuchin"
        animals.desc = "A medium-sized New World monkey of the family Cebidae, subfamily Cebinae."
        animals.lat = -37.882751
        animals.long = 145.044942
        animals.image = "Capuchin_image"
        
        do{
            try managedObjectContext.save()
        }
        catch let error{
            print("Could not save Core Data: \(error)")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text ,searchText.count > 0 {
            filteredLocationList = locationList.filter({(location: FencedAnnotation) -> Bool in
                return (location.title?.contains(searchText))!
            })
        }
        else {
            filteredLocationList = locationList
        }
        tableView.reloadData()
    }
    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        switch sortSegment.selectedSegmentIndex {
        case 0:
            filteredLocationList = filteredLocationList.sorted { $0.title! < $1.title! }
            tableView.reloadData()
        case 1:
            filteredLocationList = filteredLocationList.sorted { $0.title! > $1.title! }
            tableView.reloadData()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "\(region.identifier) Nearby!", message: "You are near the \(region.identifier) cage.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        let content = UNMutableNotificationContent()
        content.title = "\(region.identifier) Nearby!"
        content.subtitle = "You are near the \(region.identifier) cage."
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "timeDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        // Configure the cell...
        //let annotation: FencedAnnotation = self.locationList.object(at: indexPath.row) as! FencedAnnotation
        //let annotation: FencedAnnotation = self.filteredLocationList[indexPath.row]
        
        let annotation: FencedAnnotation = self.filteredLocationList[indexPath.row]
        cell.textLabel!.text = annotation.title
        cell.detailTextLabel!.text = annotation.subtitle
        
        var image: UIImage?
        if loadImageData(fileName: annotation.imageName!) == nil {
            image = UIImage(named: annotation.imageName!)!
        }
        else {
            image = loadImageData(fileName: annotation.imageName!)!
        }
        image = resizeImage(image: image!, targetSize: CGSize(width: 60, height: 60))
        cell.imageView?.image = image
        
        return cell
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mapViewController?.focusOn(annotation: self.filteredLocationList[indexPath.row] as MKAnnotation)
        let selectedAnimal = self.filteredLocationList[indexPath.row]
        delegate?.animalSelected(selectedAnimal)
        if let mapViewController = delegate as? MapViewController,
            let mapNavigationController = mapViewController.navigationController {
            splitViewController?.showDetailViewController(mapNavigationController, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "addAnimal" {
            let controller = segue.destination as! NewAnimalController
            controller.delegate = self
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .delete
        }
        return .none
    }

    // Override to support editing the table view.
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let location: FencedAnnotation = self.filteredLocationList[indexPath.row] as FencedAnnotation
            //self.locationList.remove(location)
            self.mapViewController?.removeAnnotation(annotation: location)
            let geoLocation = CLCircularRegion(center: location.coordinate, radius: 10, identifier: location.title!)
            locationManager.stopMonitoring(for: geoLocation)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animals")
            do {
                animalList = try managedObjectContext.fetch(fetchRequest) as! [Animals]
            } catch {
                fatalError("Failed to fetch animals: \(error)")
            }
            for (index, animal) in animalList.enumerated() {
                if filteredLocationList[indexPath.row].title == animal.name {
                        managedObjectContext.delete(animalList[index])
                }
            }
            do {
                try managedObjectContext.save()
                //tableView.reloadData()
            }
            catch let error {
                print("Could not save Core Data \(error)")
            }
            // remove the deleted item from the `UITableView
            filteredLocationList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        /*
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        */
    }



    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
