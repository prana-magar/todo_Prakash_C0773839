//
//  Extension+UIImageView.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-27.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit

extension UIImageView{
    
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .init(width: 4, height: 4)
        self.layer.shadowRadius = 6
    }
}
