//
//  SignInViewController.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import UIKit
import MapKit
import CoreLocation

class SignInViewController: UIViewController {
    
    @IBOutlet weak var workingPlace: UITextField!
    @IBOutlet weak var countriesTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    private var apiManager: CountriesAPIManagerProtocol?
    private var countries: [Country] = []
    private let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.isHidden = true
        countriesTableView.isHidden = true
        workingPlace.isHidden = false
        workingPlace.text = ""
        
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCountriesManager()
        setUpTableView()
        setUpTextField()
        setUpMapView()
        requestLocationPermission()
        
        mapView.isHidden = true
        countriesTableView.isHidden = true
    }
    
    private func setUpCountriesManager() {
        apiManager = CountriesAPIManager()
        
        apiManager?.fetchCountries { result in
            switch result {
            case .success(let fetchedCountries):
                self.countries = fetchedCountries
                self.countriesTableView.reloadData()
            case .failure(let error):
                print("Error fetching countries: \(error)")
            }
        }
    }
    
    private func setUpTableView() {
        countriesTableView.dataSource = self
        countriesTableView.delegate = self
        countriesTableView.register(
            UINib(nibName: "CountryTableViewCell", bundle: nil),
            forCellReuseIdentifier: "CountryTableViewCellID")
    }
    
    private func setUpTextField() {
        workingPlace.delegate = self
        workingPlace.inputView = UIView()
    }
    
    private func setUpMapView() {
        mapView.delegate = self
    }
    
    private func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func handleAuthorizationStatus(locationManager: CLLocationManager, status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            if let center = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 500000,
                    longitudinalMeters: 500000
                )
                mapView.setRegion(region, animated: true)
            }
        case .authorized:
            print("authorized")
        default:
            break
        }
    }
    
    private func showCountryOnMap(country: Country) {
        mapView.removeAnnotations(mapView.annotations)
        
        let geocoder = CLGeocoder()
        let fullAddress = "\(country.name.common)"
        
        geocoder.geocodeAddressString(fullAddress) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = country.name.common
            
            self.mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 100000,
                longitudinalMeters: 100000
            )
            self.mapView.setRegion(region, animated: true)
        }
        
        self.mapView.isHidden = false
        self.countriesTableView.isHidden = true
        self.workingPlace.isHidden = true
    }
}
    
    extension SignInViewController: UITextFieldDelegate {
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if textField == workingPlace {
                countriesTableView.isHidden = false
                return false
            }
            return true
        }
    }

    extension SignInViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            countries.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCellID", for: indexPath) as? CountryTableViewCell
            
            let country = countries[indexPath.row]
            cell?.configure(with: country)

            return cell ?? UITableViewCell()
        }
    }
   
    extension SignInViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCountry = countries[indexPath.row]
            showCountryOnMap(country: selectedCountry)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    extension SignInViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "CountryPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = .systemBlue
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }

extension SignInViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(locationManager: manager, status: status)
    }
}
    
