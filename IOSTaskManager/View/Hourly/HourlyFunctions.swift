//
//  HourlyFunctions.swift
//  IOSTaskManager
//
//  Created by Billie H on 17/08/24.
//

import Foundation
func addF(strTask:String)->Bool{
    if strTask.isEmpty{
        return false
    }
    let task = strTask.split(separator: " X ")
    if task.count == 2{
        if let num = Int(task[1]){
            print(num)
            var bool = false
            for _ in 0..<num{
                bool = addF(strTask: String(task[0]))
            }
            return bool
        }
    }
    if strTask.first == "#"{
        var temp = strTask
        temp.removeFirst()
       
        if shortcutTitles.contains(temp){
            if let arrTask = shortcutDict[temp]?.toArray(){
                addF(arrTask: arrTask)
                return true
            }
        }
    }
    guard let newTask = strTask.toTaskByMinute() else{return false}
    if newTask.name.myHash() == breaks.name.myHash(){
        return true
    }
    if let group = groupList.getGroup(name: newTask.name){
        while true{
            if group.taskList.isEmpty{
                break;
            }
            let task = group.taskList[0]
            if task.time > newTask.time{
                task.time -= newTask.time
                newTask.name = task.name
                hourly.append(newTask)
                group.upload()
                break;
            }
            else if task.time == newTask.time{
                group.taskList.remove(at: 0)
                hourly.append( task)
                break;
            }
            else{
                group.taskList.remove(at: 0)
                newTask.time -= task.time
                hourly.append( task)
            }
        }
    }
    else if let task = groupList.getTask(name: newTask.name){
        task.time -= newTask.time
        if task.time <= 0{
            task.remove()
        }
        task.group?.upload()
        hourly.append(newTask)
    }
    else{
        hourly.append(newTask)
    }
    dailyView?.tableView1.reloadData()
    return true
}
func addF(arrTask:[String]){
    for substr in arrTask{
        _ = addF(strTask: substr)
    }
}
