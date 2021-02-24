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
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleCtrlView: UIView!
    private var banner: GADBannerView!
    private var sectors: [UIView]=[]
    private var sectorsLabels: [UIView]=[]
    private var model: Wheel?
    private var gestureBeganPoint: CGPoint?
    private var prevAngle: CGFloat=0{
        didSet{
            if(abs(abs(self.prevAngle)-abs(oldValue))<CGFloat.pi/2){
                self.angleSpeed=(self.angleSpeed*2 + self.prevAngle-oldValue)/3
            }
            
            self.timeInterval=(self.timeInterval*2 + CGFloat(Date().timeIntervalSince1970-(self.angleUpdateTime ?? Date()).timeIntervalSince1970))/3
            
            self.angleUpdateTime=Date()
            
            let radStep = self.angleStep*CGFloat.pi/180
            if(abs(abs(self.prevAngle)-abs(self.prevAngleSoundPlayed))>radStep){
                self.player?.play()
                self.prevAngleSoundPlayed=self.prevAngle
            }
        }
    }
    private var prevAngleSoundPlayed: CGFloat=0
    private var tmpAngle:CGFloat=0{
        didSet{
            print(self.tmpAngle)
        }
    }
    private var decayAngle: CGFloat=0{
        didSet{
            DispatchQueue.main.async{
                self.tmpAngle += self.decayAngle-self.decayPrevAngle
                let rotate:CGAffineTransform = self.circleView.transform.rotated(by: self.decayAngle-self.decayPrevAngle)
                self.circleView.transform = rotate
                self.decayPrevAngle=self.decayAngle
                
            }
        }
    }
    private var decayPrevAngle: CGFloat=0{
        didSet{
            self.angleUpdateTime=Date()
            
            let radStep = self.angleStep*CGFloat.pi/180
            if(abs(abs(self.decayPrevAngle)-abs(self.prevAngleSoundPlayed))>radStep){
                self.player?.play()
                self.prevAngleSoundPlayed=self.decayPrevAngle
            }
        }
    }
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
        //self.createWheel()
        
        //google admob
        //self.bannerInit()
    }
    
    func bannerInit(){
        print(ASIdentifierManager.shared().advertisingIdentifier )
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID as! String]
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["698cb274896d20be3b5eb497e0d2fd59"]
        self.banner = GADBannerView(adSize: kGADAdSizeBanner)
        self.banner.frame=CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
        //self.banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" //testID
        self.banner.adUnitID = "ca-app-pub-4351509496299304/8674244905"
        self.banner.rootViewController=self
        self.banner.delegate=self
        self.banner.load(GADRequest())
        self.view.addSubview(self.banner)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        self.model?.delegate=self
        self.createWheel()
        //        self.circleView.setNeedsLayout()
    }
    
    func modelUpdate() {
        self.createWheel()
    }
    
    func createWheel(){
        self.circleView.transform=CGAffineTransform.init(rotationAngle: 0)
        self.sectors=[]
        self.sectorsLabels=[]
        let count=self.model?.getCount() ?? 0
        self.angleStep = CGFloat(360)/CGFloat(count) < 360 ? CGFloat(360)/CGFloat(count) : 30
        let radius = self.circleView.frame.width / 2
        var array = [(String,UIColor)]()
        
        for i in 0..<(self.model?.getCount() ?? 0){
            array.append(self.model?.getAt(i) ?? ("", .clear))
        }
        
        for i in 0..<(self.model?.getCount() ?? 0){
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
            self.sectors.append(view)
            self.circleView.addSubview(self.sectors[i])
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
            
//            path.move(to: .init(x: 0, y: 0))
//            path.addLine(to: .init(x: radius, y: 0))
//            path.addLine(to: .init(x: 2*radius, y: 0))
//            path.addLine(to: .init(x: 2*radius, y: radius))
//            path.addLine(to: .init(x: radius, y: radius))
//            path.addArc(withCenter: .init(x: radius, y: radius), radius: radius, startAngle: -CGFloat.pi/2+0.5*step, endAngle: -CGFloat.pi/2 - 0.5*step, clockwise: false)
//            path.addLine(to: .init(x: radius, y: radius))
//            path.addLine(to: .init(x: 0, y: radius))
//            path.addLine(to: .init(x: 0, y: 0))
            
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 2*radius, y: 0))
            path.addLine(to: .init(x: 2*radius, y: 2*radius))
            path.addLine(to: .init(x: 0, y: 2*radius))
            path.addLine(to: .init(x: 0, y: 0))
            path.move(to: .init(x: radius, y: radius))
            path.addArc(withCenter: .init(x: radius, y: radius), radius: radius, startAngle: -CGFloat.pi/2+0.5*step, endAngle: -CGFloat.pi/2 - 0.5*step, clockwise: false)
            path.addLine(to: .init(x: radius, y: radius))
            
            
            textView.textContainer.exclusionPaths=[path]
            //textView.frame=CGRect(x: 0, y: 0, width: self.circleView.bounds.width, height: self.circleView.bounds.height*0.5)
            let angle=CGFloat.pi/2+(self.angleStep*CGFloat(i) + self.angleStep/2)*CGFloat.pi/180
            let rotate:CGAffineTransform = view.transform.rotated(by: angle)
            textView.transform=rotate
            self.sectorsLabels.append(textView)
            self.circleView.addSubview(self.sectorsLabels[i])
        }
        
    }
    
    
    @objc func gesture(_ gestureRecognizer: UIPanGestureRecognizer){
        let center=CGPoint(x:self.circleCtrlView.frame.width/2,y:self.circleCtrlView.frame.height/2)
        
        if(gestureRecognizer.state == .began){
            let position=gestureRecognizer.location(in: self.circleCtrlView)
            let xlen=position.x-center.x
            let ylen=position.y-center.y
            let rad = sqrt(xlen*xlen + ylen*ylen)
            
            var angle:CGFloat = 0
            if (xlen>0 && ylen>0)||(xlen<0&&ylen>0) {
                angle = acos(xlen/rad)
            }
            if (xlen>0 && ylen<0)||(xlen<0&&ylen<0) {
                angle = acos(xlen/rad)
            }
            print("init angle = \(angle)")
            self.prevAngle=angle
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
            self.tmpAngle += -(angle-self.prevAngle)
            let rotate:CGAffineTransform = gestureRecognizer.view!.transform.rotated(by: -(angle-self.prevAngle))
            self.prevAngle=angle
            gestureRecognizer.view!.transform = rotate
        }
        
        if(gestureRecognizer.state == .ended){
            let duration:CGFloat=10+CGFloat.random(in: 0..<5)
            let counter:Int=Int(duration/self.timeInterval)
            DispatchQueue.global().async{
                for i in 1..<counter{
                    DispatchQueue.global().sync{
                        usleep(useconds_t(1000000*self.timeInterval))
                    }
                    let angle = self.angleSpeed  - self.angleSpeed * log(CGFloat(i)) / log(CGFloat(counter))
                    self.decayAngle -= angle
                }
                print("prevAngle = \(self.prevAngle)\ndecayPrevAngle = \(self.decayAngle)")
            }
            
            let scale = CGFloat.random(in: 1..<1.5)
            let ind = Int.random(in: 0..<self.sectors.count)
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
    }
}
