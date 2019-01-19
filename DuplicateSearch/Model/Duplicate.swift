//
//  Duplicate.swift
//  DuplicateSearch
//
//  Created by Andrey Konstantinov on 10/01/2019.
//  Copyright © 2019 Test. All rights reserved.
//

import Cocoa

final class Duplicate {
  let size: UInt64
  var files: [String] = []
  var count: Int {
    get {
      return files.count
    }
  }

  var totalSize: String {
    get {
      let totalBytesCount: Int64 = Int64(size) * Int64(count)
      return ByteCountFormatter.string(fromByteCount: totalBytesCount, countStyle: .file)
    }
  }

  init(size: UInt64, file: String) {
    self.size = size
    files = [file]
  }

  func append(file: String) {
    files.append(file)
  }
}
