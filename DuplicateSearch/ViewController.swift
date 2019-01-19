//
//  ViewController.swift
//  DuplicateSearch
//
//  Created by Andrey Konstantinov on 10/01/2019.
//  Copyright © 2019 Test. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {

  private var isSearchInProgress = false
  private var dataSource: [String] = []
  private let dataManager = DataManager()

  @IBOutlet var progressIndicator: NSProgressIndicator!
  @IBOutlet var searchButton: NSButton!
  @IBOutlet var tableView: NSTableView!

  private func startSearch() {
    isSearchInProgress = true
    searchButton.title = "Stop search"
    progressIndicator.doubleValue = 0
    dataSource = []
    tableView.reloadData()

    dataManager.getDuplicateFiles(
      onChange: {
        [weak self]
        duplicates in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          self.dataSource = duplicates
          self.tableView.reloadData()
        }
      }, onSearchStop: {
        [weak self] in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          if self.isSearchInProgress {
            self.stopSearch()
          }
        }
      },
      onSearchProgress: {
        [weak self]
        progress in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          self.progressIndicator.maxValue = Double(progress.totalUnitCount)
          self.progressIndicator.doubleValue = Double(progress.completedUnitCount)
        }
      }
    )
  }

  private func stopSearch() {
    isSearchInProgress = false
    searchButton.title = "Start search"
    dataManager.terminateSearch()
  }

  // MARK: - Actions

  @IBAction func onButtonClick(_ sender: Any) {
    if (!isSearchInProgress) {
      startSearch()
    } else {
      stopSearch()
    }
  }

}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return dataSource.count
  }

}

// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    let item = dataSource[row]
    return item
  }

}
