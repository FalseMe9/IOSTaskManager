//
//  Calendar.swift
//  MacTaskManager
//
//  Created by Billie H on 17/08/24.
//

import Foundation
var calendar = Calendar.current
var today = UserDefaults.standard.value(forKey: "Today") as? Int ?? 0{
    didSet{
        UserDefaults.standard.setValue(today, forKey: "Today")
        refreshDate()}
}
var endHour = UserDefaults.standard.value(forKey: "endHour") as? Int ?? 24{
    didSet{
        UserDefaults.standard.setValue(endHour, forKey: "endHour")
    }
}
var endMinute = UserDefaults.standard.value(forKey: "endMinute") as? Int ?? 0{
    didSet{
        UserDefaults.standard.setValue(endMinute, forKey: "endMinute")
    }
}
func refreshDate(){
    let day = calendar.component(.day, from: Date())
    if today < day{
        today = day
    }
    else if today>day+2{
        today = day+2
    }
}

func endDate()->Date?{
    var component = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
    refreshDate()
    component.day = today
    component.hour = endHour
    component.minute = endMinute
    guard let endDate = calendar.date(from: component) else{return nil}
    return endDate
}
func getDifference()->Int{
    let difference = calendar.dateComponents([.second], from: Date(), to: endDate() ?? Date())
    return difference.second ?? 0
}

