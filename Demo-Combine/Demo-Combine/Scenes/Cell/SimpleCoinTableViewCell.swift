//
//  SimpleCoinTableViewCell.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import UIKit

final class SimpleCoinTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var symbolLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(coin: SimpleCoin) {
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        let pngUrl = coin.iconUrl.replacingOccurrences(of: "svg", with: "png")
        if let url = URL(string: pngUrl) {
            iconImageView.setImage(from: url)
        }
    }
}


protocol ReusableView {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
            return String(describing: self)
        }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
