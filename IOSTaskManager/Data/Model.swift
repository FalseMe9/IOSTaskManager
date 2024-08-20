//
//  Model.swift
//  PickerViewTest
//
//  Created by Billie H on 03/07/24.
//

import Foundation

class Task{
    var name = ""
    var time = 0
    var group : Group?
    var index : Int?
    var deadLine : Date?
    init(name: String, minute: Int) {
        self.name = name
        self.time = minute*60
    }
    init(name:String, time:Int){
        self.name = name
        self.time = time
    }
    func minute()->Int{
        return time/60
    }
    func remove(){
        if let group = group, let index = index{
            group.taskList.remove(at: index)
        }
    }
}
extension Array<Task>{
    func toStrings()->[String]{
        var strings : [String] = []
        for task in self{
            let str = task.toString()
            strings.append(str)
        }
        return strings
    }
    func upload(path: String){
        if !isEditing, isConfigured{
            ref.child(path).setValue(self.toStrings())
        }
    }
    func save(path: String){
        UserDefaults.standard.set(self.toStrings(), forKey: path)
    }
    func getTotalTime()->Int{
        var sum = 0
        for task in self{
            sum+=task.time
        }
        return sum
    }
}

class Group{
    var taskList :[Task] = [] {
        didSet{
            save()
            if !isEditing, isConfigured{
                upload()
            }
//            
        }
    }
    let name : String
    let filename : String
    let maxTime : Int
    init(name: String, maxTime:Int = 0) {
        self.name = name
        self.maxTime = maxTime
        filename = name + "TaskFile"
        load()
    }
    func load(){
        if let arr = UserDefaults.standard.value(forKey: filename) as? [String]{
            taskList = arr.toTasks()
        }
    }
    func save(){
        let arr = taskList.toStrings()
        UserDefaults.standard.setValue(arr, forKey:filename)
    }
    func upload(){
        if !isEditing, isConfigured{
            let arr = taskList.toStrings()
            ref.child(filename).setValue(arr)
        }
    }
    
    
    func getTotalTime()->Int{
        var sum = 0
        for task in taskList{
            sum+=task.time
        }
        return sum
    }
    
    func setDefault(){
        UserDefaults.standard.setValue(taskList.toStrings(), forKey: "default"+filename)
    }
    
    func getFromDefault(){
        if let arr =  UserDefaults.standard.value(forKey: "default"+filename) as? [String]{
            taskList = arr.toTasks()
        }
    }
    func getTask(name:String)->Task?{
        if taskList.count < 1{
            return nil
        }
        for i in 0...taskList.count-1{
            let task = taskList[i]
            if name.myHash() == task.name.myHash(){
                task.index = i
                return task
            }
        }
        return nil
    }
    func toString() -> String{
        return name + ":" + String(maxTime)
    }
    
}

extension Array<Group>{
    func getTask(name:String)->Task?{
        for group in self{
            if let task = group.getTask(name: name){
                task.group = group
                return task
            }
        }
        return nil
    }
    func getGroup(name:String)->Group?{
        for group in self{
            if name.myHash() == group.name.myHash(){
                return group
            }
        }
        return nil
    }
    func getFileName(filename:String)->Group?{
        for group in self{
            if filename.myHash() == group.filename.myHash(){
                return group
            }
        }
        return nil
    }
    func save(){
        for group in self{
            group.save()
        }
        saveArray()
    }
    func saveArray(){
        let arr = toStrings()
        UserDefaults.standard.set(arr, forKey: groupListFile)
    }
    mutating func load(){
        loadArray()
        for group in self{
            group.load()
        }
    }
    mutating func loadArray(){
        let str = readFile(filename: groupListFile)
        self = str.toArray().toGroups()
    }
    func upload(){
        if !isEditing, isConfigured{
            for group in self{
                group.upload()
            }
            uploadArray()
        }
    }
    func uploadArray(){
        if !isEditing, isConfigured{
            let arr = toStrings()
            ref.child(groupListFile).setValue(arr)
        }
    }
    func setDefaults(){
        for group in self{
            group.setDefault()
        }
    }
    func getFromDefaults(){
        for group in self{
            group.getFromDefault()
        }
    }
    func count()->Int{
        var num = 0
        for group in self{
            num+=group.taskList.count+1
        }
        return num
    }
    
    func toStrings()->[String]{
        var strings : [String] = []
        for group in self{
            let str = group.toString()
            strings.append(str)
        }
        return strings
    }
}
