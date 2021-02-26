//
//  WheelViewController.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import UIKit
import AVFoundation
import GoogleUtilities
import GoogleMobileAds
import AdSupport

class WheelViewController: UIViewController,UIDropInteractionDelegate, WheelDelegate, GADBannerViewDelegate {
    struct Sector{
        var startAngle,stopAngle: CGFloat
        var label: String
        var color: UIColor
        var view: UIView
    }
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleCtrlView: UIView!
    @IBOutlet weak var winnerLabel: UILabel!
    private var banner: GADBannerView!
    
    private var sectors: [Sector]=[]
    private var sectorsLabels: [UIView]=[]
    private var sectorsAngles: [(CGFloat,CGFloat)]=[]
    private var model: Wheel?
    private var gestureBeganPoint: CGPoint?

    private var rotating = false
    private var rotationAngle: CGFloat=0{
        didSet{
            let tmpAngle = self.rotationAngle-self.rotationAnglePrev
            DispatchQueue.main.async{
                let rotate:CGAffineTransform = self.circleView.transform.rotated(by: tmpAngle)
                self.circleView.transform = rotate
                self.rotationAnglePrev=self.rotationAngle
            }
            for i in 0..<self.sectors.count{
                self.sectors[i].startAngle += tmpAngle
                self.sectors[i].stopAngle += tmpAngle
                var start=self.sectors[i].startAngle
                var stop=self.sectors[i].stopAngle
                if (start >= 0){
                    start -= 2 * CGFloat.pi * CGFloat(Int(start / (CGFloat.pi * 2)))
                }
                else{
                    start -= 2 * CGFloat.pi * CGFloat(Int((start - 2 * CGFloat.pi) / (CGFloat.pi * 2)))
                }
                if (stop >= 0){
                    stop -= 2 * CGFloat.pi * CGFloat(Int(stop / (CGFloat.pi * 2)))
                }
                else{
                    stop -= 2 * CGFloat.pi * CGFloat(Int((stop - 2 * CGFloat.pi) / (CGFloat.pi * 2)))
                }
                let angleCompare = 3 * CGFloat.pi / 2
                if(stop<start){
                    stop += 2 * CGFloat.pi
                }
                if(angleCompare>=start && angleCompare<=stop){
                    DispatchQueue.main.async {
                        self.winnerLabel.text=self.sectors[i].label
                    }
                }
            }
        }
    }
    private var rotationAnglePrev: CGFloat=0{
        didSet{
            if(abs(abs(self.rotationAnglePrev)-abs(oldValue))<CGFloat.pi/2){
                self.angleSpeed=(self.angleSpeed*2 + self.rotationAnglePrev-oldValue)/3
            }
            
            self.timeInterval=(self.timeInterval*2 + CGFloat(Date().timeIntervalSince1970-(self.angleUpdateTime ?? Date()).timeIntervalSince1970))/3
            
            self.angleUpdateTime=Date()
            
            let radStep = self.angleStep*CGFloat.pi/180
            if(abs(abs(self.rotationAnglePrev)-abs(self.prevAngleSoundPlayed))>radStep){
                self.player?.play()
                self.prevAngleSoundPlayed=self.rotationAnglePrev
            }
        }
    }
    private var prevAngleSoundPlayed: CGFloat=0
    private var angleUpdateTime: Date?

    private var timeInterval: CGFloat = 0
    private var angleSpeed: CGFloat=0
    private var angleStep: CGFloat=0
    private let recognizer=UIPanGestureRecognizer()
    private var player: AVAudioPlayer?
    
    private let soundURL=URL(fileURLWithPath: Bundle.main.path(forResource: "soundWheel", ofType: "aif")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            self.player = try AVAudioPlayer(contentsOf: self.soundURL)
            self.player?.volume=0.0
            self.player?.play()
            self.player?.volume=1.0
        }
        catch{ }
        if let tmp=(self.parent as? TabBarController){
            self.model = tmp.model
            self.model?.delegate=self
        }
        self.circleView.backgroundColor = .none
        self.recognizer.addTarget(self, action: #selector(self.gesture(_:)))
        self.circleView.addGestureRecognizer(self.recognizer)
        
        self.bannerInit()
    }
    
    func bannerInit(){
        self.banner = GADBannerView(adSize: kGADAdSizeBanner)
        let tabBarHeight=(self.parent as! UITabBarController).tabBar.frame.height
        let bannerHeight:CGFloat = 100
        self.banner.frame=CGRect(x: 0, y: self.view.frame.height-tabBarHeight-bannerHeight, width: self.view.frame.width, height: bannerHeight)
        self.banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" //testID
        self.banner.rootViewController=self
        self.banner.delegate=self
        self.banner.load(GADRequest())
        self.view.addSubview(self.banner)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        self.model?.delegate=self
        self.createWheel()
    }
    
    func modelUpdate() {
        self.createWheel()
    }
    
    func createWheel(){
        self.circleView.transform=CGAffineTransform.init(rotationAngle: 0)
        self.sectors=[]
        self.sectorsLabels=[]
        self.sectorsAngles=[]
        let count=self.model?.getCount() ?? 0
        self.angleStep = CGFloat(360)/CGFloat(count) < 360 ? CGFloat(360)/CGFloat(count) : 30
        let radius = self.circleView.frame.width / 2
        var array = [(String,UIColor)]()
        
        for i in 0..<(self.model?.getCount() ?? 0){
            array.append(self.model?.getAt(i) ?? ("", .clear))
        }
        
        for i in 0..<(self.model?.getCount() ?? 0){
            let text: String = array[i].0
            let color: UIColor = array[i].1
            let view=UIView(frame: self.circleView.bounds)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: 0, y: 0), radius: radius, startAngle: 0, endAngle: self.angleStep*CGFloat.pi/180, clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: 0))
            let pathLayer = CAShapeLayer()
            pathLayer.frame=CGRect(origin: CGPoint(x: self.circleView.frame.width/2, y: self.circleView.frame.height/2), size: CGSize(width: self.circleView.frame.width/2, height: self.circleView.frame.height/2))
            pathLayer.path=path.cgPath
            pathLayer.fillColor=color.cgColor
            pathLayer.lineWidth=3
            pathLayer.strokeColor=self.view.backgroundColor?.cgColor
            view.layer.addSublayer(pathLayer)
            let rotate:CGAffineTransform = view.transform.rotated(by: CGFloat(i)*self.angleStep*CGFloat.pi/180)
            view.transform=rotate
            self.circleView.addSubview(view)
            
            let startAngle=CGFloat(i)*self.angleStep*CGFloat.pi/180
            let stopAngle=CGFloat(i+1)*self.angleStep*CGFloat.pi/180
            self.sectors.append(Sector(startAngle: startAngle, stopAngle: stopAngle, label: text, color: color,view: view))

        }
        
        for i in 0..<(self.model?.getCount() ?? 0){
            let text: String = array[i].0
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.circleView.bounds.width, height: self.circleView.bounds.height))
            textView.backgroundColor = .clear
            textView.textAlignment = .center
            textView.textColor = UIColor.white
            textView.text=text
            textView.isEditable=false
            textView.isSelectable=false
            textView.isScrollEnabled=false
            let step:CGFloat = self.angleStep*CGFloat.pi/180
            let path=UIBezierPath()
            
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 2*radius, y: 0))
            path.addLine(to: .init(x: 2*radius, y: 2*radius))
            path.addLine(to: .init(x: 0, y: 2*radius))
            path.addLine(to: .init(x: 0, y: 0))
            path.move(to: .init(x: radius, y: radius))
            path.addArc(withCenter: .init(x: radius, y: radius), radius: radius, startAngle: -CGFloat.pi/2+0.5*step, endAngle: -CGFloat.pi/2 - 0.5*step, clockwise: false)
            path.addLine(to: .init(x: radius, y: radius))
            
            textView.textContainer.exclusionPaths=[path]
            let angle=CGFloat.pi/2+(self.angleStep*CGFloat(i) + self.angleStep/2)*CGFloat.pi/180
            let rotate:CGAffineTransform = view.transform.rotated(by: angle)
            textView.transform=rotate
            self.circleView.addSubview(textView)
        }
    }
    
    
    @objc func gesture(_ gestureRecognizer: UIPanGestureRecognizer){
        if(self.rotating){
            return
        }
        let center=CGPoint(x:self.circleCtrlView.frame.width/2,y:self.circleCtrlView.frame.height/2)
        
        if(gestureRecognizer.state == .began){
            let position=gestureRecognizer.location(in: self.circleCtrlView)
            let xlen=position.x-center.x
            let ylen=position.y-center.y
            let rad = sqrt(xlen*xlen + ylen*ylen)
            
            var angle:CGFloat = 0
            if ylen>=0{
                angle = -acos(xlen/rad) + 2*CGFloat.pi
            }
            else{
                angle = acos(xlen/rad)
            }
            self.rotationAnglePrev = -angle
        }
        
        if gestureRecognizer.state == .changed{
            let position=gestureRecognizer.location(in: self.circleCtrlView)
            let xlen=position.x-center.x
            let ylen=position.y-center.y
            let rad = sqrt(xlen*xlen + ylen*ylen)
            var angle:CGFloat = 0
            if ylen>=0{
                angle = -acos(xlen/rad) + 2*CGFloat.pi
            }
            else{
                angle = acos(xlen/rad)
            }
            self.rotationAngle = -angle
        }
        
        if(gestureRecognizer.state == .ended){
            self.rotating = true
            let duration:CGFloat=10+CGFloat.random(in: 0..<5)
            if(self.timeInterval==0){
                return
            }
            let counter:Int=Int(duration/self.timeInterval)
            if(counter<0){
                return
            }
            let tmpSpeed = self.angleSpeed*2.0
            let tmpInterval = self.timeInterval
            print("Duration = \(duration) angleSpeed = \(self.angleStep)")
            DispatchQueue.global().async{
                for i in 1..<counter{
                    DispatchQueue.global().sync{
                        usleep(useconds_t(1000000*tmpInterval))
                    }
                    let angle = tmpSpeed  - tmpSpeed * log(CGFloat(i)) / log(CGFloat(counter))
                    self.rotationAngle += angle
                }
                self.rotating=false
            }
        }
    }
    
    
}
