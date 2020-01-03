//
//  WeekDayTableViewCell.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/01/20.
//  Copyright © 2020 Guima Games. All rights reserved.
//

import UIKit

class WeekDayTableViewCell: UITableViewCell {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    // MARK: - Properties
    @IBOutlet var dayLabel: UILabel! {
        didSet {
            dayLabel.textColor = UIColor.Rainstorm.baseTextColor
            dayLabel.font = UIFont.Rainstorm.heavyLarge
        }
    }
    
    @IBOutlet var dateLabel: UILabel! {
        didSet {
            dateLabel.textColor = .black
            dateLabel.font = UIFont.Rainstorm.lightRegular
        }
    }
    
    @IBOutlet var windSpeedLabel: UILabel! {
        didSet {
            windSpeedLabel.textColor = .black
            windSpeedLabel.font = UIFont.Rainstorm.lightSmall
        }
    }
    
    @IBOutlet var temperatureLabel: UILabel! {
        didSet {
            temperatureLabel.textColor = .black
            temperatureLabel.font = UIFont.Rainstorm.lightSmall
        }
    }
    
    @IBOutlet var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = UIColor.Rainstorm.baseTintColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    //Para não expor, da pra usar um protocolo...
    func configure(with viewModel: weekDayViewModel) {
        dayLabel.text = viewModel.day
        dateLabel.text = viewModel.date
        iconImageView.image = viewModel.image
        windSpeedLabel.text = viewModel.windSpeed
        temperatureLabel.text = viewModel.temperature
    }
    
    /*func configure(with representable: WeekDayRepresentable) {
        dayLabel.text = representable.day
        dateLabel.text = representable.date
        iconImageView.image = representable.image
        windSpeedLabel.text = representable.windSpeed
        temperatureLabel.text = representable.temperature
    }*/
    
    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/

}
