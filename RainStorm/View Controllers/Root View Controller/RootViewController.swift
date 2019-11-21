//
//  RootViewController.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 19/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    // Mark: Properties
    
    private let dayViewController: DayViewController = {
        guard let dayViewController = UIStoryboard.main.instantiateViewController(withIdentifier: DayViewController.storyboardIdentifier) as? DayViewController else {
            fatalError("Unable to Instanciate Day View Controller")
        }
        
        dayViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        return dayViewController
    }()
    
    private let weekViewController: WeekViewController = {
        guard let weekViewController = UIStoryboard.main.instantiateViewController(withIdentifier: WeekViewController.storyboardIdentifier) as? WeekViewController else {
            fatalError("Unable to Instanciate Week View Controller")
        }
        
        weekViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        return weekViewController
    }()
    
    // Mark: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupChildViewControllers()
        
        fetchWeatherData()
    }
    
    // Mark: Helpers
    private func setupChildViewControllers(){
        addChild(dayViewController)
        addChild(weekViewController)
        
        view.addSubview(dayViewController.view)
        view.addSubview(weekViewController.view)
        
        dayViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dayViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dayViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dayViewController.view.heightAnchor.constraint(equalToConstant: Layout.DayView.height).isActive = true
        
        weekViewController.view.topAnchor.constraint(equalTo: dayViewController.view.bottomAnchor).isActive = true
        weekViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        weekViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        weekViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        dayViewController.didMove(toParent: self)
        weekViewController.didMove(toParent: self)
    }
    
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
        
        URLSession.shared.dataTask(with: weatherRequest.url) { (data, response, error) in
            if let error = error {
                print("Request Did Fail (\(error))")
            }
            else if let response = response
            {
                print("Response: \(response)" )
            }
        }.resume() //Para enviar de verdade...
    }

}

extension RootViewController {
    
    fileprivate enum Layout {
        enum DayView {
            static let height: CGFloat = 200.0
        }
    }
}

