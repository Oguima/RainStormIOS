//
//  WeekDayRepresentable.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/01/20.
//  Copyright © 2020 Guima Games. All rights reserved.
//

import UIKit

protocol WeekDayRepresentable {
     var day: String { get }
     var date: String { get }
     var temperature: String { get }
     var windSpeed: String { get }
     var image: UIImage? { get }
}




