//
//  Data.swift
//  PickerViewTest
//
//  Created by Billie H on 30/06/24.
//

import Foundation
import FirebaseDatabase



var dailyView : DailyView?
var hourlyView : HourlyView?
var notesView : NotesView?
var shortcutView : ShortcutView?



var shortcutDict : Dictionary<String, String> = [:]{
    didSet{
        shortcutDict.saveFile(fileName: shortcutDictFile)
        shortcutDict.upload(filename: shortcutDictFile)
    }
}
var shortcutTitles : [String] = [] {
    didSet{
        shortcutTitles.save(path: shortcutTitleFile)
        shortcutTitles.upload(path: shortcutTitleFile)
        shortcutView?.shortcutTable.reloadData()
    }
}
var useWarning = true{
    didSet{
        UserDefaults.standard.setValue(useWarning, forKey: warningKey)
    }
}

var taskDict = Dictionary<String, String>(){
    didSet{
        taskDict.saveFile(fileName: taskDictFile)
        taskDict.upload(filename: taskDictFile)
    }
}
var breaks = Task(name: "Break", minute: 20){
    didSet{
        writetoFile(filename: breakFile, input: breaks.toString())
        writeOnline(filename: breakFile, input:breaks.toString())
    }
}

var groupList = [Group](){
    didSet{
        groupList.saveArray()
        groupList.uploadArray()
    }
}

var hourly = [Task](){
    didSet{
        hourly.save(path: hourlyFile)
        hourly.upload(path: hourlyFile)
        hourlyView?.taskListPV.reloadAllComponents()
        hourlyView2?.taskTable.reloadData()
    }
}

