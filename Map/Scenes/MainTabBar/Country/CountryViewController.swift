//
//  CountryViewController.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import UIKit
import MapKit

class CountryViewController: UIViewController {
    
    @IBOutlet private weak var countryNameTextField: UITextField!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var searchButton: UIButton!
    
    private var apiManager: CountriesAPIManagerProtocol?
    private var currentCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAPIManager()
        setUpMapView()
        setUpTextField()
        
        mapView.isHidden = true
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        searchCountry()
    }
    
    private func setUpAPIManager() {
        apiManager = CountriesAPIManager()
    }
    
    private func setUpMapView() {
        mapView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPress)
    }
    
    private func setUpTextField() {
        countryNameTextField.delegate = self
        countryNameTextField.placeholder = "Enter country name"
    }
    
    private func searchCountry() {
        guard let countryName = countryNameTextField.text,
              !countryName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a country name")
            return
        }
        
        fetchCountryByName(countryName: countryName)
    }
    
    private func fetchCountryByName(countryName: String) {
        apiManager?.fetchCountryByName(name: countryName) { result in
            switch result {
            case .success(let country):
                self.currentCountry = country
                self.displayCountryOnMap(country: country)
            case .failure(let error):
                self.showAlert(title: "Error", message: "Could not find country: \(error.localizedDescription)")
                print("Fetch error: \(error)")
            }
        }
    }
    
    private func displayCountryOnMap(country: Country) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard country.latlng.count >= 2 else {
            showAlert(title: "Error", message: "No coordinates available for this country")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(
            latitude: country.latlng[0],
            longitude: country.latlng[1]
        )
        
        addPinToMap(coordinate: coordinate, country: country)
    }
    
    private func addPinToMap(coordinate: CLLocationCoordinate2D, country: Country) {
        let annotation = DraggableAnnotation()
        annotation.coordinate = coordinate
        annotation.title = country.name.common
        annotation.subtitle = country.capital.first.map { "Capital: \($0)" }
        
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 200000,
            longitudinalMeters: 200000
        )
        mapView.setRegion(region, animated: true)
        
        mapView.isHidden = false
        countryNameTextField.isHidden = true
        searchButton.isHidden = true
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let country = currentCountry else { return }
        
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = DraggableAnnotation()
        annotation.coordinate = coordinate
        annotation.title = country.name.common
        annotation.subtitle = "Custom Location"
        
        mapView.addAnnotation(annotation)
        
        showAlert(title: "Pin Moved", message: "The pin has been moved to a custom location")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CountryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchCountry()
        return true
    }
}

extension CountryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is DraggableAnnotation else { return nil }
        
        let identifier = "DraggablePin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemGreen
            annotationView?.isDraggable = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        guard let annotation = view.annotation as? DraggableAnnotation,
              let country = currentCountry else { return }
        
        if newState == .ending {
            annotation.subtitle = "Custom Location"
            print("Pin dragged to: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
        }
    }
}

class DraggableAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
        self.coordinate = coordinate
        super.init()
    }
}
