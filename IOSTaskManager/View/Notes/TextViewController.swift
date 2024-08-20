//
//  TextViewController.swift
//  NotesTest
//
//  Created by Billie H on 29/07/24.
//

import UIKit

class TextViewController: UIViewController {
    
    @IBOutlet var notesView : UITextView!
    
    var previousView : NotesView!
    var titleView = ""
    var path = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesView.text = UserDefaults.standard.string(forKey: path)
        myFunctions.loadOnline(path: path, completion: {str in
            self.notesView.text = str
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.standard.setValue(notesView.text, forKey: path)
        notesView.text.upload(path: path)
    }
}
