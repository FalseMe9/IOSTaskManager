//
//  MyFunctions.swift
//  IOSTaskManager
//
//  Created by Billie H on 15/08/24.
//

import Foundation
import AVFAudio


func loadAll(){
    shortcutDict = UserDefaults.standard.value(forKey: shortcutDictFile) as? [String:String] ?? [String:String]()
    shortcutTitles = UserDefaults.standard.value(forKey: shortcutTitleFile) as? [String] ?? []
    useWarning = UserDefaults.standard.value(forKey: warningKey) as? Bool ?? true
    taskDict = UserDefaults.standard.value(forKey: taskDictFile) as? [String:String] ?? [String:String]()
    breaks = (UserDefaults.standard.value(forKey: breakFile) as? String)?.toTask() ?? Task(name: breakFile, minute: 0)
    groupList = (UserDefaults.standard.value(forKey: groupListFile) as? [String])?.toGroups() ?? []
    for group in groupList{
        group.load()
    }
    hourly = (UserDefaults.standard.value(forKey: hourlyFile) as? [String])?.toTasks() ?? []
    dailyView?.tableView1.reloadData()
    hourlyView?.taskListPV.reloadAllComponents()
    hourlyView2?.taskTable.reloadData()
}
func downloadAll(){
    ref.observeSingleEvent(of: .value, with: {
        snapshot in
        guard let dict = snapshot.value as? [String:Any]
        else{return}
        if let temp = dict[shortcutDictFile] as? [String:String]{
            shortcutDict = temp
        }
        if let temp = dict[shortcutTitleFile] as? [String]{
            shortcutTitles = temp
        }
        if let temp = dict[taskDictFile] as? [String:String]{
            taskDict = temp
        }
        if let temp = dict[breakFile] as? String, let temp = Int(temp){
            breaks = Task(name: "Break", minute: temp)
        }
        
        if let str = dict[groupListFile] as? [String]{
            groupList = str.toGroups()
            for group in groupList{
                if let temp = dict[group.filename] as? [String]{
                    group.taskList = temp.toTasks()
                }
                else{group.taskList = []}
            }
            dailyView?.tableView1.reloadData()
        }
        if let temp = dict[hourlyFile] as? [String]{
            hourly = temp.toTasks()
        }
    })
}

func observeAll(){
    ref.observe(.childChanged, with: {
        (snapshot) in
        isEditing = true
        if snapshot.key.myHash() == shortcutTitleFile.myHash(), let temp = snapshot.value as? [String]{
            shortcutTitles = temp
            shortcutView?.shortcutTable.reloadData()
        }
        if snapshot.key.myHash() == breakFile.myHash() , let breakStr = snapshot.value as? String{
            breaks = breakStr.toTask() ?? Task(name: "Break", minute: 10)
            hourlyView?.taskListPV.reloadComponent(hourly.count)
            hourlyView2?.taskTable.reloadData()
        }
        if snapshot.key.myHash() == groupListFile.myHash(), let temp = snapshot.value as? [String]{
            let groups = temp.toGroups()
            
            var newGroup = [Group]()
            for group in groups {
                if let tempGroup = groupList.getGroup(name: group.name){
                    newGroup.append(tempGroup)
                }
                else{
                    newGroup.append(group)
                }
            }
            groupList = newGroup
            dailyView?.tableView1.reloadData()
        }
        if let group = groupList.getFileName(filename: snapshot.key), let temp = snapshot.value as? [String]{
            group.taskList = temp.toTasks()
            dailyView?.tableView1.reloadData()
        }
        if snapshot.key.myHash() == hourlyFile.myHash(),let temp = snapshot.value as? [String]{
            hourly = temp.toTasks()
            hourlyView?.taskListPV.reloadAllComponents()
            hourlyView2?.taskTable.reloadData()
        }
        isEditing = false
        print(snapshot.key)
    })
    ref.observe(.childRemoved, with: {
        snapshot in
        isEditing = true
        if snapshot.key.myHash() == shortcutTitleFile.myHash(){
            shortcutTitles = []
            shortcutView?.shortcutTable.reloadData()
        }
        if snapshot.key.myHash() == hourlyFile.myHash(){
            hourly = []
            hourlyView?.taskListPV.reloadAllComponents()
            hourlyView2?.taskTable.reloadData()
        }
        if let group = groupList.getFileName(filename: snapshot.key){
            group.taskList = []
            dailyView?.tableView1.reloadData()
        }
        isEditing = false
    })
    ref.observe(.childAdded, with: {
        snapshot in
        isEditing = true
        if snapshot.key.myHash() == shortcutTitleFile.myHash(), let temp = snapshot.value as? [String]{
            shortcutTitles = temp
            shortcutView?.shortcutTable.reloadData()
        }
        if snapshot.key.myHash() == hourlyFile.myHash(), let temp = snapshot.value as? [String]{
            hourly = temp.toTasks()
            hourlyView?.taskListPV.reloadAllComponents()
            hourlyView2?.taskTable.reloadData()
        }
        if let group = groupList.getFileName(filename: snapshot.key), let temp = snapshot.value as? [String]{
            group.taskList = temp.toTasks()
            dailyView?.tableView1.reloadData()
        }
        isEditing = false
    })
    
    ref.child(taskDictFile).observe(.childChanged, with: {snapshot in
        isEditing = true
        if let str = snapshot.value as? String{
            taskDict[snapshot.key] = str
        }
        isEditing = false
    })
    ref.child(shortcutDictFile).observe(.childChanged, with: {
        snapshot in
        isEditing = true
        if let str = snapshot.value as? String{
            shortcutDict[snapshot.key] = str
        }
        isEditing = false
    })
}
// File
func getDefaultFile(filename:String)->URL?{
    guard let file = Bundle.main.url(forResource: filename, withExtension: "txt")
    else{
        
        return nil
    }
    return file
}

func readDefaultFile(filename:String)->String{
    guard let file = getDefaultFile(filename: filename) else{return ""}
    var readString = ""
    do{
        try readString = String(contentsOf: file)
    }
    catch{
        print("Failed at reading String : \(file)")
    }
    return readString
}
// Online

func writeOnline(filename:String, input:String){
    if !isEditing{
        ref.child(filename).setValue(input)
    }
}
func writeOnline(filename:String, input: Dictionary<String, Any>){
    if !isEditing{
        ref.child(filename).setValue(input)
    }
}
// User Default
func readFile(filename:String)->String{
    var readString = UserDefaults.standard.value(forKey: filename) as? String
    if readString == nil{
        readString = readDefaultFile(filename: filename)
    }
    return readString!
}
func writetoFile(filename:String, input:String){
    UserDefaults.standard.setValue(input, forKey: filename)
}
func getURL()->URL{
    let url = URL(fileURLWithPath: "/Users/billieh/Desktop")
    return url
}
var synthesizer = AVSpeechSynthesizer()

func talk(str:String) {
    let utterance = AVSpeechUtterance(string: str)
    synthesizer.speak(utterance)
}

class myFunctions{
    static func loadOnline(path: String, completion: @escaping(_ str:String) -> Void){
        var str = ""
        ref.child(path).observeSingleEvent(of: .value, with: {
            snapshot in
            str = snapshot.value as? String ?? ""
            completion(str)
        })
    }

}
