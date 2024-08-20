//
//  Notification.swift
//  IOSTaskManager
//
//  Created by Billie H on 14/08/24.
//

import Foundation
import UserNotifications

class Notification{
    static let notificationCenter = UNUserNotificationCenter.current()
    static func checkForPermission(title: String, interval : Int){
        notificationCenter.getNotificationSettings(completionHandler:{ settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: {didAllow, error in
                    if didAllow{
                        self.dispatchNotification(title: title, interval: interval)
                    }
                })
            case .denied:
                return
            case .authorized:
                self.dispatchNotification(title: title, interval: interval)
            default:
                return
            }
        })
    }
    static func dispatchNotification(title:String, interval:Int){
        let identifier = "identifier"
        let isDaily = true
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let interval = interval
        content.title = title
        content.body = "test"
        content.sound = .default
        
        let calendar = Calendar.current
        let date = Date.now.addingTimeInterval(TimeInterval(interval))
        
        var dateComponent = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        
        dateComponent.hour = calendar.component(.hour, from: date)
        dateComponent.minute = calendar.component(.minute, from: date)
        dateComponent.second = calendar.component(.second, from: date)
        print(dateComponent.hour)
        print(dateComponent.minute)
        print(dateComponent.second)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
        print("Test")
    }
    static func removeNotification(){
        let identifier = "identifier"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
