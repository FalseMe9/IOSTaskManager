//
//  ShortcutView.swift
//  PickerViewTest
//
//  Created by Billie H on 10/07/24.
//

import UIKit


class ShortcutView: ViewController{
    @IBOutlet weak var warningS: UISwitch!
    @IBOutlet var shortcutTable : UITableView!
    @IBOutlet var titleTF : UITextField!
    @IBOutlet var dateL:UILabel!
    @IBOutlet var hourL:UITextField!
    @IBOutlet var minuteL:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        titleTF.delegate = self
        shortcutTable.delegate = self
        shortcutTable.dataSource = self
        shortcutTable.dragDelegate = self
        // Data
        warningS.isOn = useWarning
        shortcutView = self
        shortcutTable.reloadData()
        dateL.text = String(today)
        hourL.placeholder = String(format: "%02d", endHour)
        minuteL.placeholder = String(format: "%02d", endMinute)
        hourL.delegate = self
        minuteL.delegate = self
    }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case titleTF:
            addNotesB()
        case hourL:
            endHour = Int(hourL.text ?? "0") ?? 0
            hourL.text = ""
            hourL.placeholder = String(format: "%02d", endHour)
        case minuteL:
            endMinute = Int(minuteL.text ?? "0") ?? 0
            minuteL.text = ""
            minuteL.placeholder = String(format: "%02d", endMinute)
        default:
            break
        }
        if textField == titleTF{
            addNotesB()
        }
        
        return super.textFieldShouldReturn(textField)
    }
    func addNotesB() {
        if let titleText = titleTF.text, !titleText.isEmpty{
            if shortcutDict[titleText] != nil{
                let alert = UIAlertController(title: "Warning!", message: "File name already used", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                let clearAction = UIAlertAction(title:"Clear", style: .destructive, handler: {(action) in
                    shortcutDict = [String:String]()
                    shortcutTitles = [String]()
                    self.shortcutTable.reloadData()
                })
                alert.addAction(clearAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                shortcutTitles.append(titleText)
                shortcutDict[titleText] = ""
                titleTF.text = ""
            }
        }
    }
    @IBAction func warningS(_ sender: Any) {
        useWarning = warningS.isOn
    }
    
    // Date
    @IBAction func addDate(_ sender:Any){
        today += 1
        dateL.text = String(today)
    }
    @IBAction func minDate(_ sender:Any){
        today -= 1
        dateL.text = String(today)
    }
}

extension ShortcutView:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortcutTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Shortcut", for: indexPath) as! ShortcutCell
        cell.nameL.text = shortcutTitles[indexPath.row]
        cell.row = indexPath.row
        cell.indexPath = indexPath
        cell.previousView = self
        return cell
    }
}

extension ShortcutView: UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let titleText = shortcutTitles[sourceIndexPath.row]
        shortcutTitles.remove(at: sourceIndexPath.row)
        shortcutTitles.insert(titleText, at: destinationIndexPath.row)
        shortcutTable.reloadData()
    }
}
