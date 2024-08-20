//
//  DescriptionViewController.swift
//  IOSTaskManager
//
//  Created by Billie H on 30/07/24.
//

import UIKit

class DescriptionViewController: ViewController {
    
    @IBOutlet var descriptionView : UITextView!
    var previousView : ViewController!
    var titleView = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if previousView is DailyView{
            descriptionView.text = taskDict[titleView]
        }
        else{
            descriptionView.text = shortcutDict[titleView]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if previousView is DailyView{
             taskDict[titleView] = descriptionView.text
        }
        else {
            shortcutDict[titleView] = descriptionView.text
        }
    }
}
