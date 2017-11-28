import UIKit

class InternetStatusView: UIView
{
    var statusLabel : UILabel = UILabel()

    init() {
        super.init(frame:CGRect.zero)
        
        var frame = CGRect.zero
        frame.origin.x = 0.0
        frame.origin.y = 0.0
        frame.size.width = UIScreen.main.bounds.size.width
        frame.size.height = 20.0
        self.frame = frame
        
        self.alpha = 1
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth]
        self.addSubview(blurEffectView)
        
        
        statusLabel = UILabel(frame: CGRect(x: CGFloat(10), y: CGFloat(0), width: CGFloat(frame.size.width - 25), height: CGFloat(frame.size.height)))
        statusLabel.textColor = UIColor.white
        statusLabel.text = ""
        statusLabel.textAlignment = NSTextAlignment.center
        statusLabel.font = UIFont.systemFont(ofSize: 11.0)
        self.addSubview(statusLabel)

    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
        
    func showInternetStatusMessage (status : String)
    {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionFlipFromTop, animations: {() -> Void in
            self.statusLabel.text = status
            var newFrame: CGRect = self.frame
            newFrame.size.height = 20.0
            self.frame = newFrame

            self.alpha = 1
            
            UIApplication.shared.windows[0].windowLevel = UIWindowLevelStatusBar + 1.0

            let windo : UIWindow = UIApplication.shared.windows[0]
            windo.addSubview(self)
        
            
        }, completion: {(_ finished: Bool) -> Void in

            self.removeInternetStatusMessage()
        })
    }
    
    func removeInternetStatusMessage ()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute:
            {
                UIView.animate(withDuration: 0.25, delay: 0, options: .transitionFlipFromTop, animations: {() -> Void in
                    self.frame = self.frame.offsetBy(dx: CGFloat(0), dy: CGFloat(-self.frame.size.height))
                    self.alpha = 0
                }, completion: {(_ didFinish: Bool) -> Void in
                    let newFrame: CGRect = self.frame.offsetBy(dx: CGFloat(0), dy: CGFloat(0))
                    self.frame = newFrame
                    self.alpha = 1
                    self.removeFromSuperview()
                    UIApplication.shared.windows[0].windowLevel = UIWindowLevelNormal
                })
        })
    }
}
