//
//  DayViewController.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 19/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

final class DayViewController: UIViewController {

    //MARK: View Model
    
    var viewModel: DayViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            setupViewModel(with: viewModel)
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    // MARK: - Helper Methods
    
    private func setupView() {
        //Configure View
        view.backgroundColor = .green
    }
    
    private func setupViewModel(with viewModel: DayViewModel) {
        
        print (viewModel)
        /*viewModel.didFetchWeaterData = { [weak self] (data, error) in
            if let _ = error { //Não preciso do erro
                //print("Unable to fetch Weather data (\(error))")
                self?.presentAlert(of: .noWeatherDataAvailable)
            }
            else if let data = data as? DarkSkyResponse {
                print(data)
            } else {
                //Sem dados...
                self?.presentAlert(of: .noWeatherDataAvailable)
            }
        }*/
    }

    

}
