//
//  FolioReaderChapterList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit
/// Table Of Contents delegate
@objc protocol FolioReaderChapterListDelegate: class {
    /**
     Notifies when the user selected some item on menu.
     */
    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference)

    /**
     Notifies when chapter list did totally dismissed.
     */
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList)
}

class FolioReaderChapterList: UITableViewController {

    weak var delegate: FolioReaderChapterListDelegate?
    fileprivate var tocItems = [FRTocReference]()
    fileprivate var book: FRBook
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    fileprivate var centerViewController: FolioReaderCenter?

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig, book: FRBook, delegate: FolioReaderChapterListDelegate?) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader
        self.delegate = delegate
        self.book = book

        super.init(style: UITableView.Style.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.tableView.register(FolioReaderChapterListCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50

        // Create TOC list
        self.tocItems = self.book.flatTableOfContents
      
        // Jump to the current chapter
        DispatchQueue.main.async {
          
            if
                let currentPageNumber = self.folioReader.readerCenter?.currentPageNumber,
                let reference = self.book.spine.spineReferences[safe: currentPageNumber - 1],
                let index = self.tocItems.firstIndex(where: { $0.resource == reference.resource }) {
              
                  let indexPath = IndexPath(row: index, section: 0)
                  self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath) as! FolioReaderChapterListCell

        cell.setup(withConfiguration: self.readerConfig)
        let tocReference = tocItems[indexPath.row]
        let isSection = tocReference.children.count > 0

        cell.indexLabel?.text = tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add audio duration for Media Ovelay
        if let resource = tocReference.resource {
            if let mediaOverlay = resource.mediaOverlay {
                let duration = self.book.duration(for: "#"+mediaOverlay)

                if let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString() {
                    let text = cell.indexLabel?.text ?? ""
                    cell.indexLabel?.text = text + (duration != nil ? (" - " + durationFormatted) : "")
                }
            }
        }

        // Mark current reading chapter
        if
            let currentPageNumber = self.folioReader.readerCenter?.currentPageNumber,
            let reference = self.book.spine.spineReferences[safe: currentPageNumber - 1],
            (tocReference.resource != nil) {
            let resource = reference.resource
            cell.indexLabel?.textColor = (tocReference.resource == resource ? self.readerConfig.menuTextColorSelected : self.readerConfig.menuTextColor)
        }

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clear
        cell.backgroundColor = UIColor.clear

        let link = self.folioReader.linkPurchase
        if (link!.count > 0) {

            let button=UIButton.init(type: .system)
            button.setTitle("Mua ngay", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor(red: 1, green: 187/255, blue: 0/255, alpha: 1)
                        // button.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
            button.layer.cornerRadius = 10
            // button.frame.size = CGSize(width: 200, height: 50)
            self.view.addSubview(button)
            button.addTarget(self, action: #selector(showRemindPurchase), for: .touchUpInside)
            //set constrains
            button.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 11.0, *) {
                 button.rightAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
                 button.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
                button.widthAnchor.constraint(equalToConstant: 130).isActive = true
            } else {
                 button.rightAnchor.constraint(equalTo: tableView.layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
                 button.bottomAnchor.constraint(equalTo: tableView.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
                button.widthAnchor.constraint(equalToConstant: 130).isActive = true
                 
            }
        }
        return cell
    }
    
    @objc func showRemindPurchase(sender: UIButton!) {
        let link = self.folioReader.linkPurchase
        let alert = UIAlertController(title: "", message: "Đã hết nội dung miễn phí, vui lòng mua sách tại trang web", preferredStyle: .alert)
        
        //Khởi tạo các action (các nút) cho alert
        let alertActionOk = UIAlertAction(title: "Mua ngay", style: .default) { (act) in
            // self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
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

        }
        let alertActionCancel = UIAlertAction(title: "Để sau", style: .cancel) { (act) in
        }
        
        //Thêm các action vào alert
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        
        //Hiển thị alert
        self.present(alert, animated: true, completion: nil)
    }


    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
        
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss { 
            self.delegate?.chapterList(didDismissedChapterList: self)
        }
    }
}
