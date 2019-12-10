//
//  DateFormatter.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 10/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    //formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.locale = Locale(identifier: "pt_BR") //Tentativa formato Brasil
    return formatter
  }()
}
