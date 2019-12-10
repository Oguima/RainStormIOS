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
    
    //MARK: -
    @IBOutlet var dateLabel: UILabel! {
        didSet {
            dateLabel.textColor = UIColor.Rainstorm.baseTextColor //UIColor.base //Styles.swift //UIColor(red: 0.31, green: 0.72, blue: 0.83, alpha: 1.0)
            dateLabel.font = UIFont.Rainstorm.heavyLarge //UIFont.systemFont(ofSize: 20.0, weight: .heavy)
        }
    }
    @IBOutlet var timeLabel: UILabel!
    /*{
        didSet {
            timeLabel.textColor = .black
            timeLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        }
    }*/
    
    @IBOutlet var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = UIColor.Rainstorm.baseTintColor //Styles.swift
            
        }
    }
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
        /*{
        didSet {
            windSpeedLabel.textColor = .black
            windSpeedLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        }
    }*/
    
    @IBOutlet var descriptionLabel: UILabel!
    /*{
        didSet{
            descriptionLabel.textColor = .black
            descriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        }
    }*/
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.startAnimating()
            activityIndicatorView.hidesWhenStopped = true
        }
    }
    
    //? wow, o que é isso ?!?, após associar um outlet normal, ele aceita arrastar o item e ele entra como um array de elementos :O :O
    @IBOutlet var regularLabels: [UILabel]! {
        didSet {
            for label in regularLabels {
                label.textColor = .black
                label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
            }
        }
    }
    
    @IBOutlet var smallLabels: [UILabel]! {
        didSet {
            for label in smallLabels {
                label.textColor = .black
                label.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
            }
        }
    }
    
    //MARK: Para esconder itens :O :O
    @IBOutlet var weatherDataViews: [UIView]! {
        didSet {
            for view in weatherDataViews {
                view.isHidden = true
            }
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
        view.backgroundColor = UIColor.Rainstorm.lightBackgroundColor //.green
    }
    
    private func setupViewModel(with viewModel: DayViewModel) {
        
        //print (viewModel)
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
        
        //MARK: Verificar que esta atualizando os itens em Background... !!!
        //Ao carregar o dado, deve-se colocar na main thread... (Gera um runtime exception (Aviso)
        //!Implementing the Day View Model - 03:56 , tratamento de imagem, e afins
        
        activityIndicatorView.stopAnimating()
        
        dateLabel.text = viewModel.date
        timeLabel.text = viewModel.time
        windSpeedLabel.text = viewModel.windSpeed
        temperatureLabel.text = viewModel.temperature
        descriptionLabel.text = viewModel.summary
        
        iconImageView.image = viewModel.image
        
        //Exibe elementos...
        for view in weatherDataViews {
            view.isHidden = false
        }
    }

    

}
