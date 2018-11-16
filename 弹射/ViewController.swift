//
//  ViewController.swift
//  弹射
//
//  Created by targeter on 2018/11/14.
//  Copyright © 2018年 targeter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    lazy var springView:SpringView = {
        let springView = SpringView(frame: self.view.bounds)
        springView.backgroundColor = .white
        return springView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(springView)
    }


}

