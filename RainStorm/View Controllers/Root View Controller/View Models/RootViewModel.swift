//
//  RootViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 27/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

class RootViewModel {
    
    typealias DidFetchWeatherDataCompletion = (Data?, Error?) -> Void
    var didFetchWeaterData: DidFetchWeatherDataCompletion?
    
    init() {
       fetchWeatherData()
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
    private func fetchWeatherData() {
        /*guard let baseUrl = URL(string: "https://api.darksky.net/forecast/") else {
            return
        }
        
        //Secret Key: https://darksky.net/dev/account
        let authenticatedBaseUrl = baseUrl.appendingPathComponent("d338cfc01c45f8ae583757dba7c77dbc")
        
        //let url = authenticatedBaseUrl.appendingPathComponent("\(37.335114),\(-122.008928)")
        */
        
        // Create URL
        //let weatherRequest = WeatherRequest(baseUrl: authenticatedBaseUrl, latitude: 37.335114, longitude: -122.008928)
        
        //let weatherRequest = WeatherRequest(baseUrl: WeatherService.authenticatedBaseUrl, latitude: Defaults.latitude , longitude: Defaults.longitude)
        
        let weatherRequest = WeatherRequest(baseUrl: WeatherService.authenticatedBaseUrl, location: Defaults.location)
        
        URLSession.shared.dataTask(with: weatherRequest.url) { [weak self] (data, response, error) in
            if let error = error {
                //print("Request Did Fail (\(error))")
                self?.didFetchWeaterData?(nil, error)
            } else if let data = data {
                self?.didFetchWeaterData?(data, nil)
            } else {
                //print("Response: \(response)" )
                self?.didFetchWeaterData?(nil, nil)
            }
        }.resume() //Para enviar de verdade...
    }
}
