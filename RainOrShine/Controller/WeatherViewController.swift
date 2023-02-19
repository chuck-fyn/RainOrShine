//
//  WeatherViewController.swift
//  RainOrShine
//
//  Created by Charles Prutting on 8/4/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegate control of weather manager, text field, and location manager instances
        weatherManager.delegate = self
        searchTextField.delegate = self
        locationManager.delegate = self
        
        //Get permission from user on first launch to use location servcies and then fetch location
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //closes keyboard if user touches screen outside keyboard
        view.endEditing(true)
    }
    
    @IBAction func getCurrentLocationWeather(_ sender: UIButton) {
        //fetch location on button press
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        if searchTextField.isEditing == false {
            //if keyboard is closed - opens keyboard when search button pressed
            searchTextField.becomeFirstResponder()
        } else {
            //If keyboard open, sends end editing signal
            searchTextField.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //sends end editing signal when 'go' button pressed on keyboard
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //If text field is not empty, perform new weather fetch based on entered text, if it is empty, replace placeholder text
        if textField.text != "" {
            if let city = searchTextField.text {
                weatherManager.fetchWeather(cityName: city)
            }
            textField.placeholder = "Search"
            searchTextField.text = ""
        }
    }
}

//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //Updates UI after WeatherManager is done fetching weather data
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    func didFailWithError(error: Error) {
        //prints error WeatherManager received while fetching weather data
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //called when location manager is done updatinfg latest location data. We then pass the latitude and longitude of the users location to the WeatherManager to fethch the weather data
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude:lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //prints error received from location manager after attempting to fetch current location
        print("location manager failed to fetch current location with error: \(error)")
    }
    
}
