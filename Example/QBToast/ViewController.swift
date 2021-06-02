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
  let example: [String] = ["top", "center", "bottom"]

  override init(style: UITableView.Style) {
    super.init(style: style)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .groupTableViewBackground
    self.title = "QBToast iOS"
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.tableFooterView = UIView()
  }
}

extension ViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Basic"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return example.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
    cell?.textLabel?.text = example[indexPath.row]
    return cell!
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let style = QBToastStyle(cornerRadius: 8.0)
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
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
