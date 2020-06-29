//
//  MapViewController.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    let locationManager = CLLocationManager()
    var latitude: String!
    var longitude: String!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
              
       // request permission
       locationManager.requestWhenInUseAuthorization()
      
       // update map info
       locationManager.startUpdatingLocation()

        let latitude = (self.latitude as NSString).doubleValue
        let longitude = (self.longitude as NSString).doubleValue

       self.setUpMap(location: CLLocation(latitude: latitude, longitude: longitude)  )
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

       // Add the annotation to map view
       mapView.addAnnotation(destinationAnnotation)
    }
    
    
    func setUpMap(location: CLLocation){
           
           // setup the span for map
           let latDelta: CLLocationDegrees = 0.07
           let longDelta: CLLocationDegrees = 0.07
           let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
           
           // set up the location for center
           let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
           
           // set up the region
           let region = MKCoordinateRegion(center: center, span: span)
           
           // add region to map
           mapView.setRegion(region, animated: true)

       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MapViewController: CLLocationManagerDelegate{


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]

    }
}
