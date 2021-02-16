//
//  ViewController.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 11.02.2021.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate {

    @IBOutlet weak var rect: UIView!
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var circleCopy: UIView!
    
    private var gestureBeganPoint: CGPoint?
    private var prevAngle: CGFloat=0
    private let recognizer=UIPanGestureRecognizer()//(target: nil, action: #selector(gesture))
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView=UIImageView()
        imageView.frame=self.circle.bounds
        imageView.image=UIImage(named: "Circle")
        self.circle.addSubview(imageView)
        
        self.recognizer.addTarget(self, action: #selector(self.gesture(_:)))
        //self.recognizer.numberOfTouchesRequired=1
        self.circle.addGestureRecognizer(self.recognizer)

    
        // Do any additional setup after loading the view.
    }


    @objc func gesture(_ gestureRecognizer: UIPanGestureRecognizer){
        let center=CGPoint(x:self.circleCopy.frame.width/2,y:self.circleCopy.frame.height/2)

        if(gestureRecognizer.state == .began){
            
            
        }
        if gestureRecognizer.state == .changed{
            let position=gestureRecognizer.location(in: self.circleCopy)
            
            
            let x = (self.gestureBeganPoint?.x ?? 0) - gestureRecognizer.translation(in: self.circle).x
            let y = (self.gestureBeganPoint?.y ?? 0) - gestureRecognizer.translation(in: self.circle).y
            let xlen=position.x-center.x
            let ylen=position.y-center.y
            let rad = sqrt(xlen*xlen + ylen*ylen)
            
            let angle=acos(xlen/rad)
            print(angle)
            
            let rotate:CGAffineTransform = gestureRecognizer.view!.transform.rotated(by: angle-self.prevAngle)
            self.prevAngle=angle
            gestureRecognizer.view!.transform = rotate
        }
        
        if(gestureRecognizer.state == .ended){

        }
//        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotation.toValue = Double.pi*2
//        rotation.duration = 0.5
//                rotation.repeatCount = 100
//        self.circle.layer.add(rotation, forKey: "rotationAnimation")
    }
    

}


