//
//  ViewController.swift
//  DawnTransition
//
//  Created by snail-z on 08/08/2023.
//  Copyright (c) 2023 snail-z. All rights reserved.
//

import UIKit
import DawnKit

class ViewController: UIViewController {

    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setup()
    }

    func setup() {
        title = "DawnTransition"
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 60, right: 0)
        tableView.separatorStyle = .none
        tableView.removeAutomaticallyAdjustsInsets()
        tableView.register(cellWithClass: ViewControllerCell.self)
        view.addSubview(tableView)

        tableView.dw.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.reloadData()
    }
    
    let dataList = ["Sample1ViewController",
                    "Sample2ViewController",
                    "Sample3ViewController",
                    "Sample4ViewController"]
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ViewControllerCell.self)
        cell.descLabel.text = dataList[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = dataList[indexPath.row]
        
        if value == "Sample1ViewController" {
            let vc = Sample1ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if value == "Sample2ViewController" {
            let vc = Sample2ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if value == "Sample3ViewController" {
            let vc = Sample3ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if value == "Sample4ViewController" {
            let vc = Sample4ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
