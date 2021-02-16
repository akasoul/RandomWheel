//
//  TableCell.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    
    private let rectClr=UIColor(cgColor:CGColor.init(genericCMYKCyan: CGFloat.random(in: 0..<1), magenta: 0.4, yellow: CGFloat.random(in: 0..<1), black: 0, alpha: 1 ))
    private let rectCornerRadius: CGFloat=30

    override func awakeFromNib() {
        super.awakeFromNib()
        //self.view.backgroundColor=UIColor.red
        
        
    }

    override func draw(_ rect: CGRect) {
      
        super.draw(rect)
        
        self.backgroundColor=UIColor.clear
//        self.view.backgroundColor=UIColor.clear

//        let maskView=UIView()
//        maskView.frame=self.bounds
//        let layer=CAShapeLayer()
//        layer.frame=self.view.bounds
//        layer.path=UIBezierPath(roundedRect: self.view.frame, cornerRadius: 15).cgPath
//        maskView.layer.addSublayer(layer)
//
        self.view.backgroundColor=self.rectClr
        self.view.layer.cornerRadius=self.rectCornerRadius
        //        self.mask=maskView
}
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
