//
//  FileSystemManager.swift
//  DuplicateSearch
//
//  Created by Andrey Konstantinov on 10/01/2019.
//  Copyright © 2019 Test. All rights reserved.
//

import Cocoa

final class FileSystemManager {
  
  private let showInvisibles = false
  private var isSearchInProgress = false
  private var progress = Progress()
  
  func getDuplicateFiles(folder: URL, onContentFound: @escaping (NSData, URL)->(), onSearchStop: @escaping ()-> (), onSearchProgress: @escaping (Progress)->()) {
    isSearchInProgress = true
    progress = Progress()
    getContentsOf(folder: folder, onContent: onContentFound, onSearchStop: onSearchStop, onSearchProgress: onSearchProgress, isToplevel: true)
  }

  func terminateSearch() {
    isSearchInProgress = false
    progress.cancel()
  }
  
  private func getContentsOf(folder: URL, onContent: @escaping (NSData, URL)->(), onSearchStop: @escaping ()-> (), onSearchProgress: @escaping (Progress)->(), isToplevel: Bool) {
    if (!isSearchInProgress) {
      onSearchStop()
      return
    }
    let URLsList = URLsFrom(folder: folder)
    let progress = Progress.init(totalUnitCount: Int64(URLsList.count))
    self.progress.addChild(progress, withPendingUnitCount: Int64(URLsList.count))
    self.progress.totalUnitCount = self.progress.totalUnitCount + Int64(URLsList.count)
    for (index, url) in URLsList.enumerated() {
      progress.completedUnitCount = Int64(index + 1)
      onSearchProgress(self.progress)

      var isDirectory = ObjCBool(false)
      if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
        if (isDirectory.boolValue) {
          getContentsOf(folder: url, onContent: onContent, onSearchStop: onSearchStop, onSearchProgress: onSearchProgress, isToplevel: false)
        } else {
          if let contents = NSData.init(contentsOf: url) {
            onContent(contents, url)
          }
        }
      }
    }
    if (isToplevel) {
      onSearchStop()
    }
  }
  
  private func URLsFrom(folder: URL) -> [URL] {
    let fileManager = FileManager.default
    do {
      let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
      let urls = contents
        .filter { return showInvisibles ? true : $0.first != "." }
        .map { return folder.appendingPathComponent($0) }
      return urls
    } catch let error {
      print(error)
      return []
    }
  }

}
