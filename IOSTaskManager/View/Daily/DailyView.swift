//
//  newHourlyController.swift
//  IOSTaskManager
//
//  Created by Billie H on 21/07/24.
//

import UIKit
import UserNotifications
import MobileCoreServices


//[Group(name: "school", maxTime: 480), Group(name: "spiritual", maxTime: 120), Group(name: "social", maxTime: 120), Group(name: "personal", maxTime: 120), Group(name: "daily", maxTime: 120), Group(name: "misc")]



class DailyView: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView1 : UITableView!
    @IBOutlet var titleField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyView = self
        titleField.delegate = self
        tableView1.delegate = self
        tableView1.dataSource = self
        tableView1.dragDelegate = self
        tableView1.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView1.reloadData()
    }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        return super.textFieldShouldReturn(textField)
    }
    func getIndex(row:Int)->(titleIndex : Int, taskindex:Int?){
        var num = row
        for i in 0..<groupList.count{
            let group = groupList[i]
            if num == 0{
                return (i, nil)
            }
            else if num <= group.taskList.count{
                return (i, num-1)
            }
            else {
                num -= (group.taskList.count + 1)
            }
        }
        return (0,nil)
    }
    func add(){
        guard let titleText = titleField.text else{return}
        if !titleText.isEmpty{
            if let group = titleText.toGroup(){
                groupList.append(group)
                print(groupList)
                titleField.text = ""
                tableView1.reloadData()
            }
        }
    }
    @IBAction func didTapSetAsDefault(_ sender:Any){
        groupList.setDefaults()
    }
    @IBAction func didTapLoadDefault(_ sender:Any){
        print("Test")
        groupList.getFromDefaults()
        tableView1.reloadData()
    }
    @IBAction func didTapClear(_ sender:Any){
        for group in groupList{
            group.taskList.removeAll()
        }
        tableView1.reloadData()
    }
}

extension DailyView{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if getIndex(row: indexPath.row).taskindex != nil{
            return 50
        }
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let titleIndex = getIndex(row: row).titleIndex
        let group = groupList[titleIndex]
        if let taskIndex = getIndex(row: row).taskindex{
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! taskCell
            
            let task = group.taskList[taskIndex]
            cell.group = group
            cell.index = taskIndex
            cell.indexPath = indexPath
            cell.task = task
            cell.taskL.text = task.displayString()
            cell.previousView = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! titleCell
            cell.group = group
            cell.index = titleIndex
            cell.indexPath = indexPath
            cell.titleS = group.name.capitalized
            cell.reloadTime()
            return cell
        }

    }
}

extension DailyView: UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return[]
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var row = sourceIndexPath.row
        var titleIndex = getIndex(row: row).titleIndex
        var group = groupList[titleIndex]
        if let taskIndex = getIndex(row: row).taskindex{
            let task = group.taskList[taskIndex]
            group.taskList.remove(at: taskIndex)
            row = destinationIndexPath.row
            titleIndex = getIndex(row: row).titleIndex
            group = groupList[titleIndex]
            if let taskIndex = getIndex(row: row).taskindex{
                group.taskList.insert(task, at: taskIndex)
            }
            else{
                if titleIndex > 0 {
                    group = groupList[titleIndex-1]
                }
                group.taskList.append(task)
                
            }
        }
        else{
            groupList.remove(at: titleIndex)
            row = destinationIndexPath.row
            titleIndex = getIndex(row: row).titleIndex
            groupList.insert(group, at: titleIndex)
        }
        tableView.reloadData()

    }
    
}
struct myReminder{
    let title:String
    let date : Date?
    let identifier : String
}
