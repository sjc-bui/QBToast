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
  let durations: [TimeInterval] = [1.0, 1.5, 2.0, 3.0, 4.0]
  let basic: [String] = ["Top", "Center", "Bottom"]
  var states: [String] = []
  let mores: [String] = ["Tap to dismiss", "Toast queue"]
  var sections = [[String]]()

  let userDefaults = UserDefaults.standard

  fileprivate struct ReuseIdentifier {
    static let cell       = "cellId"
    static let cellValue1 = "cellVal1"
  }

  fileprivate struct ReuseStr {
    static let position     = "position"
    static let message      = "message"
    static let tapEnabled   = "tapEnabled"
    static let queueEnabled = "queueEnabled"
  }

  override init(style: UITableView.Style) {
    super.init(style: style)
    self.title = "QBToast"
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .groupTableViewBackground
    QBToastManager.shared.tapToDismissEnabled = userDefaults.bool(forKey: ReuseStr.tapEnabled)
    QBToastManager.shared.inQueueEnabled = userDefaults.bool(forKey: ReuseStr.queueEnabled)

    for state in QBToastState.allCases {
      states.append("\(state.rawValue) - `.\(state)` in \(durations[state.rawValue])s")
    }
    sections = [basic, states, mores]

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message",
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(setMessage))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Auto run",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(autoRun))

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.cell)
    tableView.tableFooterView = UIView()
  }

  @objc func autoRun() {
    QBToast(message: "This is a success message.", position: .top, duration: 2.5, state: .success).showToast()
    QBToast(message: "Consider this a warning.", position: .center, duration: 3.0, state: .warning).showToast()
    QBToast(message: "This is an error message.", position: .center, duration: 2.0, state: .error).showToast()
    QBToast(message: "This is a sample message.", position: .bottom, duration: 2.5).showToast()
    QBToast(message: "This is an information message.", position: .bottom, duration: 3.5, state: .info).showToast()
    QBToast(message: "Done...", position: .top, duration: 2.5, state: .success).showToast()
  }

  @objc func setMessage() {
    let alert = UIAlertController(title: "Set toast message", message: nil, preferredStyle: .alert)
    alert.addTextField { textField in
      textField.text = self.userDefaults.string(forKey: ReuseStr.message)
    }
    let okBtn = UIAlertAction(title: "Save", style: .default) { _ in
      let message = alert.textFields![0] as UITextField
      self.userDefaults.set(message.text, forKey: ReuseStr.message)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      self.dismiss(animated: true, completion: nil)
    }
    alert.addAction(okBtn)
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
    if indexPath.section == 2 {
      cell = UITableViewCell(style: .value1, reuseIdentifier: ReuseIdentifier.cellValue1)
      switch indexPath.row {
      case 0:
        cell?.detailTextLabel?.text = userDefaults.bool(forKey: ReuseStr.tapEnabled) ? "Enabled" : "Disabled"
      case 1:
        cell?.detailTextLabel?.text = userDefaults.bool(forKey: ReuseStr.queueEnabled) ? "Enabled" : "Disabled"
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
    let prevIndex = userDefaults.integer(forKey: ReuseStr.position)

    if indexPath.section == 0 {
      if prevIndex != indexPath.row {
        tableView.cellForRow(at: IndexPath(row: prevIndex, section: indexPath.section))?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        userDefaults.set(indexPath.row, forKey: ReuseStr.position)
      }
    } else if indexPath.section == 1 {
      let pos: QBToastPosition = prevIndex == 0 ? .top : prevIndex == 1 ? .center : .bottom
      let message = userDefaults.string(forKey: ReuseStr.message)
      let defaultState: QBToastState = QBToastState(rawValue: indexPath.row)!

      QBToast(message: message, position: pos, duration: durations[indexPath.row],
              state: defaultState).showToast { bol in
        self.status(bol)
      }
    } else if indexPath.section == 2 {
      switch indexPath.row {
      case 0:
        let isEnabled = userDefaults.bool(forKey: ReuseStr.tapEnabled)
        QBToastManager.shared.tapToDismissEnabled = !isEnabled
        userDefaults.set(!isEnabled, forKey: ReuseStr.tapEnabled)
      case 1:
        let isEnabled = userDefaults.bool(forKey: ReuseStr.queueEnabled)
        QBToastManager.shared.inQueueEnabled = !isEnabled
        userDefaults.set(!isEnabled, forKey: ReuseStr.queueEnabled)
      default:
        break
      }
      tableView.reloadRows(at: [IndexPath(item: indexPath.row, section: indexPath.section)], with: .automatic)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  private func status(_ byTap: Bool) {
    print(byTap ? "tapped" : "time out")
  }
}
