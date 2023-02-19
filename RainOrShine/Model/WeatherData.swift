//
//  WeatherManager.swift
//  RainOrShine
//
//  Created by Charles Prutting on 8/8/22.
//

import Foundation

//Data structures used to decode JSON weather data
struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
