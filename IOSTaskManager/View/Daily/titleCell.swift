//
//  myCell.swift
//  IOSTaskManager
//
//  Created by Billie H on 22/07/24.
//

import UIKit

class titleCell: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet var titleL : UILabel!
    @IBOutlet var taskField : UITextField!
    var titleS : String!
    var timeS : String!
    var group : Group!
    var index : Int!
    var indexPath: IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        taskField.delegate = self
        reloadTime()
        // Configure the view for the selected state
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didtapPlus(self)
        textField.resignFirstResponder()
        return true
    }
    func reloadTime(){
        guard let group = group else{return}
        timeS = "[\(group.getTotalTime()/60)/\(group.maxTime)]"
        titleL.text = titleS + " " + timeS
    }
    @IBAction func didtapPlus(_ sender:Any){
        if let titleText = taskField.text{
            if let task = titleText.toTaskByMinute(){
                group.taskList.append(task)
                taskField.text = ""
                dailyView!.tableView1.reloadData()
                reloadTime()
            }
        }
    }
    @IBAction func didTapExit(_sender:Any){
        groupList.remove(at: index)
        if let dailyView = dailyView{
            dailyView.tableView1.deleteRows(at: [indexPath], with: .automatic)
            dailyView.tableView1.reloadData()
        }
        
    }
    }
