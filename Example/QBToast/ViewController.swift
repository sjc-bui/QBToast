//
//  ViewController.swift
//  QBToast
//
//  Created by sjc-bui on 06/01/2021.
//  Copyright (c) 2021 sjc-bui. All rights reserved.
//

import UIKit
import QBToast

class ViewController: UITableViewController {

  var btn: UIButton?
  let basic: [String] = ["Top", "Center", "Bottom"]
  let states: [String] = ["Success", "Warning", "Error", "Info", "Custom"]
  var sections = [[String]]()

  fileprivate struct ReuseIdentifier {
    static let cell = "cellId"
  }

  override init(style: UITableView.Style) {
    super.init(style: style)
    self.title = "QBToast iOS"
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .groupTableViewBackground
    sections = [basic, states]

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.cell)
    tableView.tableFooterView = UIView()
  }
}

extension ViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Basic"
    }
    return "States"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.cell)
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifier.cell)
    }
    cell?.textLabel?.text = sections[indexPath.section][indexPath.row]
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let style = QBToastStyle(cornerRadius: 8.0)
    if indexPath.section == 0 {
      switch indexPath.row {
        case 0:
          self.navigationController!.view.showToast(message: "This message appear in top", style: style, position: .top, duration: 5.0)
        case 1:
          self.navigationController!.view.showToast(message: "This message appear in center", style: style, position: .center, duration: 5.0)
        case 2:
          self.navigationController!.view.showToast(message: "This message appear in bottom", style: style, duration: 5.0)
        default:
          break
      }
    } else {
      let position = QBToastPosition.allCases.randomElement()!
      switch indexPath.row {
        case 0:
          self.navigationController!.view.showToast(message: "Display successfully", style: style, position: position, state: .success)
        case 1:
          self.navigationController!.view.showToast(message: "A warning occured", style: style, position: position, state: .warning)
        case 2:
          self.navigationController!.view.showToast(message: "Error message", style: style, position: position, state: .error)
        case 3:
          self.navigationController!.view.showToast(message: "Some information", style: style, position: position, state: .info)
        case 4:
          self.navigationController!.view.showToast(message: "Default toast message", style: style, position: position, state: .custom)
        default:
          break
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
