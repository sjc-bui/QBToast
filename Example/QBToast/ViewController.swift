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
  let mores: [String] = ["Font size", "Duration"]
  var sections = [[String]]()

  let durations: [CGFloat] = [0.5, 1, 2, 5]
  let fontSizes: [Int] = [12, 14, 18, 20, 25]

  fileprivate struct ReuseIdentifier {
    static let cell = "cellId"
  }

  fileprivate struct ReuseStr {
    static let position = "position"
    static let message  = "message"
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
    sections = [basic, states, mores]

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(setMessage))

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.cell)
    tableView.tableFooterView = UIView()
  }

  @objc func setMessage() {
    let alert = UIAlertController(title: "Set toast message", message: nil, preferredStyle: .alert)
    alert.addTextField { textField in
      textField.text = UserDefaults.standard.string(forKey: ReuseStr.message)
    }
    let ok = UIAlertAction(title: "Save", style: .default) { _ in
      let message = alert.textFields![0] as UITextField
      UserDefaults.standard.set(message.text, forKey: ReuseStr.message)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      self.dismiss(animated: true, completion: nil)
    }
    alert.addAction(ok)
    alert.addAction(cancel)
    self.present(alert, animated: true, completion: nil)
  }
}

extension ViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Position"
    } else if section == 1 {
      return "States"
    }
    return "More"
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
    if indexPath.section == 0 && indexPath.row == UserDefaults.standard.integer(forKey: ReuseStr.position) {
      cell?.accessoryType = .checkmark
    }
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let style = QBToastStyle(cornerRadius: 10.0)
    let prevIndex = UserDefaults.standard.integer(forKey: ReuseStr.position)

    if indexPath.section == 0 {
      if prevIndex != indexPath.row {
        tableView.cellForRow(at: IndexPath(row: prevIndex, section: indexPath.section))?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        UserDefaults.standard.set(indexPath.row, forKey: ReuseStr.position)
      }
    } else if indexPath.section == 1 {
      var pos: QBToastPosition!
      switch prevIndex {
        case 0:
          pos = .top
        case 1:
          pos = .center
        case 2:
          pos = .bottom
        default:
          break
      }

      let message = UserDefaults.standard.string(forKey: ReuseStr.message)
      switch indexPath.row {
        case 0:
          self.navigationController!.view.showToast(message: message, style: style, position: pos, duration: 1.0, state: .success)
        case 1:
          self.navigationController!.view.showToast(message: message, style: style, position: pos, duration: 1.0, state: .warning)
        case 2:
          self.navigationController!.view.showToast(message: message, style: style, position: pos, duration: 1.0, state: .error)
        case 3:
          self.navigationController!.view.showToast(message: message, style: style, position: pos, duration: 1.0, state: .info)
        case 4:
          self.navigationController!.view.showToast(message: message, style: style, position: pos, duration: 1.0, state: .custom)
        default:
          break
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
