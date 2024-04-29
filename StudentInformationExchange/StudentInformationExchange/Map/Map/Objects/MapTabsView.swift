 

import UIKit

class MapTabsView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor(white: 0, alpha: 0.11).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
}
