//
//  RootViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 27/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation
import CoreLocation

class RootViewModel: NSObject
{
    
    enum WeatherDataError: Error {
        case notAuthorizedToRequestLocation
        case noWeatherDataAvailable
    }
    
    //typealias DidFetchWeatherDataCompletion = (Data?, Error?) -> Void
    //typealias DidFetchWeatherDataCompletion = (DarkSkyResponse?, Error?) -> Void
    
    //typealias DidFetchWeatherDataCompletion = (DarkSkyResponse?, WeatherDataError?) -> Void
    typealias DidFetchWeatherDataCompletion = (WeatherData?, WeatherDataError?) -> Void
    var didFetchWeaterData: DidFetchWeatherDataCompletion?
    
    private lazy var locationManager: CLLocationManager = {
       let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    
    override init() {
        super.init()
        
        fetchWeatherData(for: Defaults.location)
       fetchLocation()
    }
    
    private func fetchLocation() {
        //Adicionar no info.plist: Privacy - Location Always and When In Use Usage Description (addRow)
        locationManager.requestLocation() //Necessita de permissão do usuário... (Ajustar info.plist...)
    }
    
    //MARK: -
    /*
     
     Response: <NSHTTPURLResponse: 0x600003d38fa0> { URL: https://api.darksky.net/forecast/d338cfc01c45f8ae583757dba7c77dbc/37.335114,-122.008928 } { Status Code: 200, Headers {
         "Cache-Control" =     (
             "max-age=60"
         );
         "Content-Encoding" =     (
             gzip
         );
         "Content-Type" =     (
             "application/json; charset=utf-8"
         );
         Date =     (
             "Wed, 20 Nov 2019 16:45:17 GMT"
         );
         Expires =     (
             "Wed, 20 Nov 2019 16:46:17 +0000"
         );
         Vary =     (
             "Accept-Encoding"
         );
         "x-authentication-time" =     (
             544ms
         );
         "x-forecast-api-calls" =     (
             1
         );
         "x-response-time" =     (
             "91.203ms"
         );
     } }
     
     */
    private func fetchWeatherData(for location: CLLocation) {
        // Create URL for Open-Meteo API
        let weatherRequest = WeatherRequest(baseUrl: WeatherService.baseUrl, location: location)
        
        print("Fetching weather from: \(weatherRequest.url)")
        
        URLSession.shared.dataTask(with: weatherRequest.url) { [weak self] (data, response, error) in
            
            // Log response status
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode)")
            }
            
            // Process on main thread
            DispatchQueue.main.async {
                if let error = error {
                    print("Unable to Fetch Weather Data (\(error))")
                    self?.didFetchWeaterData?(nil, .noWeatherDataAvailable)
                } else if let data = data {
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let openMeteoResponse = try decoder.decode(OpenMeteoResponse.self, from: data)
                        
                        print("---- Open-Meteo Response ---")
                        print("Location: \(openMeteoResponse.latitude), \(openMeteoResponse.longitude)")
                        print("Current Temp: \(openMeteoResponse.currentWeather.temperature)°C")
                        print("Weather: \(openMeteoResponse.currentWeather.summary)")
                        
                        self?.didFetchWeaterData?(openMeteoResponse, nil)
                    } catch {
                        print("Unable to decode JSON Response: \(error)")
                        self?.didFetchWeaterData?(nil, .noWeatherDataAvailable)
                    }
                } else {
                    self?.didFetchWeaterData?(nil, .noWeatherDataAvailable)
                }
            }
        }.resume()
    }
}

extension RootViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else
        {
            if status == .authorizedWhenInUse {
                fetchLocation()
            } else {
                didFetchWeaterData?(nil, .notAuthorizedToRequestLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        fetchWeatherData(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to fetch Location (\(error))")
    }
}
