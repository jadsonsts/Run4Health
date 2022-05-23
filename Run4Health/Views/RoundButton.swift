//
//  RoundButton.swift
//  Run4Health
//
//  Created by Jadson on 23/05/22.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        //MARK: Corner radius
        self.layer.cornerRadius = self.frame.height / 2
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}
