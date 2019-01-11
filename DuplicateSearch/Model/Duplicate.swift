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
      return self.covertSizeToString(size: self.size * UInt64(self.count))
    }
  }

  init(size: UInt64, file: String) {
    self.size = size
    files = [file]
  }

  func append(file: String) {
    files.append(file)
  }

  private func covertSizeToString(size: UInt64) -> String {
    var convertedValue: Double = Double(size)
    var multiplyFactor = 0
    let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
    while convertedValue > 1024 {
      convertedValue /= 1024
      multiplyFactor += 1
    }
    return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
  }
}
