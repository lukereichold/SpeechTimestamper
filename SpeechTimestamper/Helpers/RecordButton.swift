// Adapted from https://github.com/otusweb/iOS-camera-button

import UIKit

final class RecordButton: UIButton {
    var pathLayer: CAShapeLayer!
    let animationDuration = 0.4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        pathLayer = CAShapeLayer()
        pathLayer.path = currentInnerPath().cgPath
        pathLayer.strokeColor = nil
        pathLayer.fillColor = UIColor.red.cgColor
        layer.addSublayer(pathLayer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //lock the size to match the size of the camera button
        addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.width,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.height,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        
        setTitle("", for: .normal)
//        imageView?.backgroundColor = .clear
//        imageView?.tintColor = .clear
        setImage(nil, for: .normal)
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    override func prepareForInterfaceBuilder() {
        setTitle("", for: .normal)
    }
    
    override var isSelected: Bool {
        didSet {
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration
            morph.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            morph.toValue = currentInnerPath().cgPath
            morph.fillMode = .forwards
            morph.isRemovedOnCompletion = false
            
            pathLayer.add(morph, forKey: "")
        }
    }
    
    @objc func touchUpInside(sender: UIButton) {
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration
        colorChange.toValue = UIColor.red.cgColor
        
        colorChange.fillMode = .forwards
        colorChange.isRemovedOnCompletion = false
        
        colorChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        pathLayer.add(colorChange, forKey: "darkColor")
        
        isSelected.toggle()
    }
    
    @objc func touchDown(sender: UIButton) {
        //when the user touches the button, the inner shape should change transparency
        //create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration
        
        //set the value we want to animate to
        morph.toValue = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        
        //ensure the animation does not get reverted once completed
        morph.fillMode = .forwards
        morph.isRemovedOnCompletion = false
        
        morph.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer.add(morph, forKey:"")
    }
    
    override func draw(_ rect: CGRect) {
        //always draw the outer ring, the inner control is drawn during the animations
        let outerRing = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 60, height: 60))
        outerRing.lineWidth = 6
        UIColor.white.setStroke()
        outerRing.stroke()
    }
    
    func currentInnerPath() -> UIBezierPath {
        let returnPath = isSelected ? innerSquarePath() : innerCirclePath()
        return returnPath
    }
    
    func innerCirclePath() -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 8, y: 8, width: 50, height: 50), cornerRadius: 25)
    }
    
    func innerSquarePath() -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 18, y: 18, width: 30, height: 30), cornerRadius: 4)
    }
}
