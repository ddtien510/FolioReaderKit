//
//  Epub.swift
//  Example
//
//  Created by Kevin Delord on 18/05/2017.
//  Copyright © 2017 FolioReader. All rights reserved.
//

import Foundation
import FolioReaderKit

enum Epub: Int {
    case bookOne = 0
    case bookTwo

    var name: String {
        switch self {
        case .bookOne:      return "doc-sach-nhu-mot-nghe-thuat1595471277" // standard eBook
        // case .bookOne:      return "90-ngay-dau-tien-lam-sep1594605101" // standard eBook
        case .bookTwo:      return "The Adventures Of Sherlock Holmes - Adventure I" // audio-eBook
        }
    }

    var shouldHideNavigationOnTap: Bool {
        switch self {
        case .bookOne:      return true
        case .bookTwo:      return true
        }
    }

    var scrollDirection: FolioReaderScrollDirection {
        switch self {
        case .bookOne:      return .horizontal
        case .bookTwo:      return .horizontal
        }
    }

    var bookPath: String? {
        return Bundle.main.path(forResource: self.name, ofType: "epub")
    }

    var readerIdentifier: String {
        switch self {
        case .bookOne:      return "READER_ONE"
        case .bookTwo:      return "READER_TWO"
        }
    }
}
