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
        case .bookOne:      return "dau-mo-tien-bac1609311695" // standard eBook
        // case .bookOne:      return "phong-cach-dau-tu-warrent-buffet1608869842" // standard eBook
        // case .bookOne:      return "chet-vi-chung-khoan-40-1-41-1609831944" // standard eBook
        // case .bookOne:      return "90-ngay-dau-tien-lam-sep1594605101" // standard eBook
        // case .bookOne:      return "ket-thuc-ban-hang-don-quyet-dinh1608539752" // standard eBook
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
