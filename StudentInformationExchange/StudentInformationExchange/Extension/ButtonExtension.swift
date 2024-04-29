//
//  ButtonExtension.swift
//  Online Diagnosis
//
//

import UIKit

class ButtonLayerSetup: UIButton{
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}

extension UIButton {
    private struct AssociatedKeys {
        static var tapClosure = "tapClosure"
    }

    typealias ButtonTapClosure = () -> Void

    private var tapClosure: ButtonTapClosure? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tapClosure) as? ButtonTapClosure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tapClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func onTap(_ closure: @escaping ButtonTapClosure) {
        self.tapClosure = closure
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        tapClosure?()
    }
}
