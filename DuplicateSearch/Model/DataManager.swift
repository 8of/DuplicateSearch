//
//  DataManager.swift
//  DuplicateSearch
//
//  Created by Andrey Konstantinov on 10/01/2019.
//  Copyright © 2019 Test. All rights reserved.
//

import Cocoa

final class DataManager {

  private let fileSystemManager: FileSystemManager
  private var filesList: [NSData: Duplicate] = [:]
  private let queue =  DispatchQueue(label: "com.company.test.DataManager")

  init(fileSystemManager: FileSystemManager) {
    self.fileSystemManager = fileSystemManager
  }

  convenience init() {
    self.init(fileSystemManager: FileSystemManager())
  }

  func getDuplicateFiles(onChange: @escaping ([String])->(), onSearchStop: @escaping ()-> (), onSearchProgress: @escaping (Progress)->()) {
    let folder = FileManager.default.homeDirectoryForCurrentUser
    // Replace with prev line with next line to test on folder with less content
    // let folder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")

    queue.async {
      [weak self] in
      self?.filesList = [:]
      self?.fileSystemManager.getDuplicateFiles(
        folder: folder,
        onContentFound: {
          [weak self]
          content, url in
          guard let `self` = self else { return }
          let relativePath = self.convertPathToRelativePath(path: url.path, host: folder.path)
          do {
            if (self.filesList.keys.contains(content)) {
              self.filesList[content]?.append(file: relativePath)
              let filesToShow = Array(self.filesList.values.filter({ $0.count > 1 }))
              onChange(self.convertDuplicatesToViewModel(duplicates: filesToShow))
            } else {
              let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
              let dict = attributes as NSDictionary
              self.filesList[content] = Duplicate(size: dict.fileSize(), file: relativePath)
            }
          } catch {}
        },
        onSearchStop: onSearchStop,
        onSearchProgress: onSearchProgress
      )
    }
  }

  func terminateSearch() {
    fileSystemManager.terminateSearch()
  }

  private func convertDuplicatesToViewModel(duplicates: [Duplicate]) -> [String] {
    var answer: [String] = []
    for duplicate in duplicates {
      // Better to make it with localized strings in real project
      let formattedHeader = "\(duplicate.count) files \(duplicate.totalSize):"
      answer.append(formattedHeader)
      answer.append(contentsOf: duplicate.files)
    }
    return answer
  }

  private func convertPathToRelativePath(path: String, host: String) -> String {
    return path.replacingOccurrences(of: host, with: "")
  }

}
