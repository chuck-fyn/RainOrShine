//
//  WeatherManager.swift
//  RainOrShine
//
//  Created by Charles Prutting on 8/4/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        //prepare data from 'cityName' name string to perform weather fetch request
        let cityNameNoSpace = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityNameNoSpace!)&units=imperial&APPID=4bd8c3eee404202c8c766c6a8cc380e5#"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //prepare data from user's current lat and lon to perform weather fetch request
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID=4bd8c3eee404202c8c766c6a8cc380e5#"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String) {
        //perform weather fetch requeat - if succesful then call data parse function
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        //create a JSON decoder and decode data with WeatherData struct. Then pull out weather ID, temperature, and city name and send to WeatherModel struct to format data for display in UI. Ignore the rest of the available decoded data unless we wish to provide more detailedd weather info in the future.
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}
