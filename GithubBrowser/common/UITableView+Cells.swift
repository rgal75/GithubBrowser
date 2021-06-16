//
//  UITableView+Cells.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import UIKit

extension UITableView {
    func removeEmptyBottomCells() {
        tableFooterView = UIView()
    }
}
