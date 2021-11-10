//
//  UISearchBar+.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import Foundation
import UIKit
import Combine

extension UISearchBar {
  var publisher: AnyPublisher<String?, Never> {
    NotificationCenter.default
      .publisher(for: UITextField.textDidChangeNotification, object: self)
      .compactMap { $0.object as? UISearchBar? }
      .map { $0?.text }
      .eraseToAnyPublisher()
  }
}
