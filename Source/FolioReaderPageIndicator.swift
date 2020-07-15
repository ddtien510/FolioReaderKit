//
//  FolioReaderPageIndicator.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

class FolioReaderPageIndicator: UIView {
    var pagesLabel: UILabel!
    var minutesLabel: UILabel!
    var totalMinutes: Int!
    var totalPages: Int!
    var isShowPopup: Bool = false
    var currentPage: Int = 1 {
        didSet { self.reloadViewWithPage(self.currentPage) }
    }

    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    init(frame: CGRect, readerConfig: FolioReaderConfig, folioReader: FolioReader) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(frame: frame)

        let color = self.folioReader.isNight(self.readerConfig.nightModeBackground, UIColor.white)
        backgroundColor = color
        // layer.shadowColor = color.cgColor
        // layer.shadowOffset = CGSize(width: 0, height: 0)
        // layer.shadowOpacity = 1
        // layer.shadowRadius = 4
        // layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        // layer.rasterizationScale = UIScreen.main.scale
        // layer.shouldRasterize = true

        pagesLabel = UILabel(frame: CGRect.zero)
        pagesLabel.font = UIFont(name: "Avenir-Light", size: 0)!
        pagesLabel.textAlignment = NSTextAlignment.right
        addSubview(pagesLabel)

        minutesLabel = UILabel(frame: CGRect.zero)
        minutesLabel.font = UIFont(name: "Avenir-Light", size: 0)!
        minutesLabel.textAlignment = NSTextAlignment.right
        //        minutesLabel.alpha = 0
        addSubview(minutesLabel)
        // self.showRemindPurchase()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    func reloadView(updateShadow: Bool) {
        minutesLabel.sizeToFit()
        pagesLabel.sizeToFit()

        let fullW = pagesLabel.frame.width + minutesLabel.frame.width
        minutesLabel.frame.origin = CGPoint(x: frame.width/2-fullW/2, y: 2)
        pagesLabel.frame.origin = CGPoint(x: minutesLabel.frame.origin.x+minutesLabel.frame.width, y: 2)
        
        if updateShadow {
            layer.shadowPath = UIBezierPath(rect: bounds).cgPath
            self.reloadColors()
        }
    }

    func reloadColors() {
        let color = self.folioReader.isNight(self.readerConfig.nightModeBackground, UIColor.white)
        backgroundColor = color

        // Animate the shadow color change
        let animation = CABasicAnimation(keyPath: "shadowColor")
        let currentColor = UIColor(cgColor: layer.shadowColor!)
        animation.fromValue = currentColor.cgColor
        animation.toValue = color.cgColor
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.6
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(animation, forKey: "shadowColor")

        minutesLabel.textColor = self.folioReader.isNight(UIColor(white: 1, alpha: 0.3), UIColor(white: 0, alpha: 0.6))
        pagesLabel.textColor = self.folioReader.isNight(UIColor(white: 1, alpha: 0.6), UIColor(white: 0, alpha: 0.9))
    }

    func showRemindPurchase() {
        let link = self.folioReader.linkPurchase
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var alert = UIAlertController(title: "",message:"Bạn có muốn đọc đầy đủ toàn bộ cuốn sách? Xin vui lòng mua ngay tại đây!",
                              preferredStyle: UIAlertController.Style.alert)
            // dispatch_async(dispatch_get_main_queue(), {

            //   self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            // })

            let alertActionOk = UIAlertAction(title: "Mua ngay", style: .default) { (act) in
            if let url = URL(string: link!) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:])
                    } else {
                        UIApplication.shared.openURL(url)
                        // Fallback on earlier versions
                    }
                }
            }
            // window?.rootViewController?.dismiss(animated: false, completion: nil)
            }

            let alertActionCancel = UIAlertAction(title: "Để sau", style: .cancel) { (act) in
        
        }
        
        //Thêm các action vào alert
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        DispatchQueue.main.async {
             window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func reloadViewWithPage(_ page: Int) {
        let chapter = self.folioReader.readerCenter?.getCurrentChapter()
        let href = chapter?.href ?? ""
        let index = self.folioReader.currentMenuIndex
        // print("index", index)


        let pagesRemaining = self.folioReader.needsRTLChange ? totalPages-(totalPages-page+1) : totalPages-page
        // print("pagesRemaining", pagesRemaining)
        if pagesRemaining == 1 {
            pagesLabel.text = " " + self.readerConfig.localizedReaderOnePageLeft
        } else {
            pagesLabel.text = " \(pagesRemaining) " + self.readerConfig.localizedReaderManyPagesLeft
        }

        let minutesRemaining = Int(ceil(CGFloat((pagesRemaining * totalMinutes)/totalPages)))
        // print("minutesRemaining", minutesRemaining)
        
        if minutesRemaining > 1 {
            minutesLabel.text = "\(minutesRemaining) " + self.readerConfig.localizedReaderManyMinutes+" ·"
        } else if minutesRemaining == 1 {
            minutesLabel.text = self.readerConfig.localizedReaderOneMinute+" ·"
            let link = self.folioReader.linkPurchase
            
            if (!self.isShowPopup && link!.count > 0) {
                self.showRemindPurchase()
                self.isShowPopup = true
            }
        } else {
            minutesLabel.text = self.readerConfig.localizedReaderLessThanOneMinute+" ·"
        }
        
        reloadView(updateShadow: false)
    }
}

extension FolioReaderPageIndicator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Set the shadow color to the final value of the animation is done
        if let keyPath = anim.value(forKeyPath: "keyPath") as? String , keyPath == "shadowColor" {
            let color = self.folioReader.isNight(self.readerConfig.nightModeBackground, UIColor.white)
            layer.shadowColor = color.cgColor
        }
    }
}


public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()    
        vc.present(self, animated: true, completion: nil)
    }
}

