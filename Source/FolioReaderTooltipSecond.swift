//
//  FolioReaderFontsMenu.swift
//  FolioReaderKit
//
//  Created by Kevin Jantzer on 1/6/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderTooltipSecond: UIViewController, SMSegmentViewDelegate, UIGestureRecognizerDelegate {

    var menuView: UIView!
    var playPauseBtn: UIButton!
    var styleOptionBtns = [UIButton]()
    var viewDidAppear = false

    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.2)

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderTooltipSecond.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        // Menu view
        // menuView = UIView(frame: CGRect(x: 0, y: view.frame.height/2 - 50, width: view.frame.width, height: 150))
        menuView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        menuView.backgroundColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 0.0)
        menuView.autoresizingMask = .flexibleWidth
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowRadius = 6
        menuView.layer.shadowPath = UIBezierPath(rect: menuView.bounds).cgPath
        menuView.layer.rasterizationScale = UIScreen.main.scale
        menuView.layer.shouldRasterize = true
        view.addSubview(menuView)

        let normalColor = UIColor.black
        let selectedColor = self.readerConfig.tintColor
        let size = 55
        let padX = 32
        // @NOTE: could this be improved/simplified with autolayout?
        let gutterX = (Int(view.frame.width) - (size * 3 ) - (padX * 4) ) / 2

        //let btnX = (Int(view.frame.width) - (size * 3)) / 4

        // get icon images
        let play = UIImage(readerImageNamed: "tooltip1")
        let pause = UIImage(readerImageNamed: "pause-icon")
        let prev = UIImage(readerImageNamed: "prev-icon")
        let next = UIImage(readerImageNamed: "tooltip2")


        var imageView = UIImageView(frame: CGRect(x: 80, y: 70, width: 220, height: 140)); // set as you want
        var image = UIImage(readerImageNamed: "tooltip2")
        imageView.image = image;



        // let playSelected = play?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        // let pauseSelected = pause?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)

        // let prevNormal = prev?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        // let nextNormal = next?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        // let prevSelected = prev?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        // let nextSelected = next?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)

        // // prev button
        // let prevBtn = UIButton(frame: CGRect(x: gutterX + padX, y: 0, width: size, height: size))
        // prevBtn.setImage(prevNormal, for: UIControl.State())
        // prevBtn.setImage(prevSelected, for: .selected)
        // prevBtn.addTarget(self, action: #selector(FolioReaderTooltipSecond.prevChapter(_:)), for: .touchUpInside)
        // // menuView.addSubview(prevBtn)



        // next button
        let nextBtn = UIButton(frame: CGRect(x: padX + size, y: 0, width: size, height: size))
        nextBtn.setImage(next, for: UIControl.State())
        nextBtn.setImage(next, for: .selected)
        nextBtn.addTarget(self, action: #selector(FolioReaderTooltipSecond.nextChapter(_:)), for: .touchUpInside)
        menuView.addSubview(imageView)


    }


    override func viewDidAppear(_ animated: Bool) {
        viewDidAppear = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewDidAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Status Bar

    override var prefersStatusBarHidden : Bool {
        return (self.readerConfig.shouldHideNavigationOnTap == true)
    }

    // MARK: - SMSegmentView delegate

    func segmentView(_ segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        guard viewDidAppear else { return }

        if let audioPlayer = self.folioReader.readerAudioPlayer, (segmentView.tag == 2) {
            audioPlayer.setRate(index)
            self.folioReader.currentAudioRate = index
        }
    }

    @objc func prevChapter(_ sender: UIButton!) {
        self.dismiss()

        if (self.readerConfig.shouldHideNavigationOnTap == false) {
            self.folioReader.readerCenter?.showBars()
        }
        // self.folioReader.readerAudioPlayer?.playPrevChapter()
    }

    @objc func nextChapter(_ sender: UIButton!) {
        print("click")
        self.dismiss()

        if (self.readerConfig.shouldHideNavigationOnTap == false) {
            self.folioReader.readerCenter?.showBars()
        }
        // self.folioReader.readerAudioPlayer?.playNextChapter()
    }

    @objc func togglePlay(_ sender: UIButton!) {
        sender.isSelected = sender.isSelected != true
        self.folioReader.readerAudioPlayer?.togglePlay()
        closeView()
    }

    @objc func changeStyle(_ sender: UIButton!) {
        self.folioReader.currentMediaOverlayStyle = MediaOverlayStyle(rawValue: sender.tag)!

        // select the proper style button
        for btn in styleOptionBtns {
            btn.isSelected = btn == sender

            if btn.tag == MediaOverlayStyle.default.rawValue {
                btn.subviews.first?.backgroundColor = (btn.isSelected ? self.readerConfig.tintColor : UIColor(white: 0.5, alpha: 0.7))
            }
        }

        // update the current page style
        if let currentPage = self.folioReader.readerCenter?.currentPage {
            currentPage.webView?.js("setMediaOverlayStyle(\"\(self.folioReader.currentMediaOverlayStyle.className())\")")
        }
    }

    func closeView() {
        self.dismiss()

        if (self.readerConfig.shouldHideNavigationOnTap == false) {
            self.folioReader.readerCenter?.showBars()
        }
    }
    
    // MARK: - Gestures
    
    @objc func tapGesture() {
        closeView()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("232323")
        closeView()
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
}
