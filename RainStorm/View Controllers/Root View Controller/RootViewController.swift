//
//  RootViewController.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 19/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    private enum AlertType {
        case noWeatherDataAvailable
    }
    
    // Mark: Properties
    
    //MARK: Quando a aplicação é aberta, no SceneDelegate, ele instancia...
    var viewModel: RootViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            setupViewModel(with: viewModel)
            
        }
    }
    
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
        
        //fetchWeatherData()
       // print(viewModel ?? "No view Model Inhected")
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
        
        //dayViewController.view.heightAnchor.constraint(equalToConstant: Layout.DayView.height).isActive = true
        
        weekViewController.view.topAnchor.constraint(equalTo: dayViewController.view.bottomAnchor).isActive = true
        weekViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        weekViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        weekViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        dayViewController.didMove(toParent: self)
        weekViewController.didMove(toParent: self)
    }
    
    private func setupViewModel(with viewModel: RootViewModel) {
        viewModel.didFetchWeaterData = { [weak self] (weatherData, error) in
            if let _ = error { //Não preciso do erro
                //print("Unable to fetch Weather data (\(error))")
                self?.presentAlert(of: .noWeatherDataAvailable)
            }
            else if let weatherData = weatherData { //as? DarkSkyResponse {
                print(weatherData)
                
                //MARK: Importante: Neste ponto instancia a view model DayViewModel
                let dayViewModel = DayViewModel(weatherData: weatherData.current)
                
                self?.dayViewController.viewModel = dayViewModel
                
                //MARK: Instancia a viewModel WeekViewModel
                let weekViewModel = WeekViewModel(weatherData: weatherData.forecast)
                self?.weekViewController.viewModel = weekViewModel
                
                
            } else {
                //Sem dados...
                self?.presentAlert(of: .noWeatherDataAvailable)
            }
        }
    }
    
    private func presentAlert(of alertType: AlertType) {
        let title: String
        let message: String
        
        switch alertType {
            case .noWeatherDataAvailable:
                title = "Unable to Fetch Weather Data"
                message = "The application is unable to fetch weather data. Please make sure your devide is connected over Wi-fi or celular."
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
}

/*extension RootViewController {
    
    fileprivate enum Layout {
        enum DayView {
            static let height: CGFloat = 200.0
        }
    }
}*/

