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
  let mores: [String] = ["Duration", "Tap to dismiss"]
  var sections = [[String]]()

  let userDefaults = UserDefaults.standard

  fileprivate struct ReuseIdentifier {
    static let cell = "cellId"
    static let cellValue1 = "cellVal1"
  }

  fileprivate struct ReuseStr {
    static let position = "position"
    static let message  = "message"
    static let duration = "duration"
    static let tapEnabled = "tapEnabled"
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
    QBToastManager.shared.tapToDismissEnabled = userDefaults.bool(forKey: ReuseStr.tapEnabled)
    sections = [basic, states, mores]

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(setMessage))

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.cell)
    tableView.tableFooterView = UIView()
  }

  @objc func setMessage() {
    let alert = UIAlertController(title: "Set toast message", message: nil, preferredStyle: .alert)
    alert.addTextField { textField in
      textField.text = self.userDefaults.string(forKey: ReuseStr.message)
    }
    let ok = UIAlertAction(title: "Save", style: .default) { _ in
      let message = alert.textFields![0] as UITextField
      self.userDefaults.set(message.text, forKey: ReuseStr.message)
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
    if (indexPath.section == 2) {
      cell = UITableViewCell(style: .value1, reuseIdentifier: ReuseIdentifier.cellValue1)
      switch indexPath.row {
        case 0:
          cell?.detailTextLabel?.text = "\(userDefaults.float(forKey: ReuseStr.duration))"
        case 1:
          cell?.detailTextLabel?.text = userDefaults.bool(forKey: ReuseStr.tapEnabled) ? "Enabled" : "Disabled"
        default:
          break
      }
    }
    cell?.textLabel?.text = sections[indexPath.section][indexPath.row]
    if indexPath.section == 0 && indexPath.row == userDefaults.integer(forKey: ReuseStr.position) {
      cell?.accessoryType = .checkmark
    }
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    let style = QBToastStyle(cornerRadius: 12.0)
    let prevIndex = userDefaults.integer(forKey: ReuseStr.position)

    if indexPath.section == 0 {
      if prevIndex != indexPath.row {
        tableView.cellForRow(at: IndexPath(row: prevIndex, section: indexPath.section))?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        userDefaults.set(indexPath.row, forKey: ReuseStr.position)
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

      let message = userDefaults.string(forKey: ReuseStr.message)
      let duration = userDefaults.float(forKey: ReuseStr.duration)

      switch indexPath.row {
        case 0:
          QBToast(message: message, style: style, position: pos, duration: TimeInterval(duration), state: .success).showToast { bol in
            print(bol)
          }
        case 1:
          QBToast(message: message, style: style, position: pos, duration: TimeInterval(duration), state: .warning).showToast { bol in
            print(bol)
          }
        case 2:
          QBToast(message: message, style: style, position: pos, duration: TimeInterval(duration), state: .error).showToast { bol in
            print(bol)
          }
        case 3:
          QBToast(message: message, style: style, position: pos, duration: TimeInterval(duration), state: .info).showToast { bol in
            print(bol)
          }
        case 4:
          QBToast(message: message, style: style, position: pos, duration: TimeInterval(duration), state: .custom).showToast { bol in
            print(bol)
          }
        default:
          break
      }
    } else if indexPath.section == 2 {
      switch indexPath.row {
        case 0:
          var duration: Float = userDefaults.float(forKey: ReuseStr.duration)
          duration += 0.5
          if duration > 5.0 { duration = 0.5 }
          userDefaults.set(duration, forKey: ReuseStr.duration)
        case 1:
          let isEnabled = userDefaults.bool(forKey: ReuseStr.tapEnabled)
          QBToastManager.shared.tapToDismissEnabled = !isEnabled
          userDefaults.set(!isEnabled, forKey: ReuseStr.tapEnabled)
        default:
          break
      }
      let index = IndexPath(item: indexPath.row, section: indexPath.section)
      tableView.reloadRows(at: [index], with: .automatic)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
