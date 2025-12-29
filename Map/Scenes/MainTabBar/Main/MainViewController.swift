//
//  MainViewController.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    @IBOutlet private weak var countryTableView: UITableView!
    @IBOutlet private weak var mapView: MKMapView!
    
    private var apiManager: CountriesAPIManagerProtocol?
    private var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCountriesManager()
        setUpTableView()
        setUpMapView()
        
        mapView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            mapView.isHidden = true
            countryTableView.isHidden = false
            mapView.removeAnnotations(mapView.annotations)
        }
    
    private func setUpCountriesManager() {
            apiManager = CountriesAPIManager()
            
            apiManager?.fetchCountries { result in
                switch result {
                case .success(let fetchedCountries):
                    self.countries = fetchedCountries
                    self.countryTableView.reloadData()
                case .failure(let error):
                    print("Error fetching countries: \(error)")
                }
            }
        }
    
    private func setUpTableView() {
        countryTableView.dataSource = self
        countryTableView.delegate = self
        countryTableView.register(
            UINib(nibName: "CountryTableViewCell", bundle: nil),
            forCellReuseIdentifier: "CountryTableViewCellID")
    }
    
    private func setUpMapView() {
            mapView.delegate = self
        }
    
    private func showCountryOnMap(country: Country) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let capital = country.capital.first else {
            print("No capital found")
            return
        }
        
        let geocoder = CLGeocoder()
        let fullAddress = "\(capital), \(country.name.common)"
        
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
            annotation.subtitle = "Capital: \(capital)"
            
            self.mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 100000,
                longitudinalMeters: 100000
            )
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.isHidden = false
            self.countryTableView.isHidden = true
        }
    }
}



extension MainViewController: UITableViewDataSource {
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

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        showCountryOnMap(country: selectedCountry)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "CountryPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemRed
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
