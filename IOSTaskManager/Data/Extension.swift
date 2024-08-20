//
//  DTypes.swift
//  PickerViewTest
//
//  Created by Billie H on 29/06/24.
//

import Foundation

extension Task{
    func toString() -> String{
        return name + ":" + String(time)
    }
    func displayString()-> String{
        "\(name) (\(minute()))"
    }
}
extension String{
    func trim()->String{
        return self.trimmingCharacters(in: .whitespaces)
    }
    func toTask()->Task?{
        let strTask = self.components(separatedBy: ":")
        if strTask.count != 2{return nil}
        let name = strTask[0].trim()
        guard let time = Int(strTask[1].trim()) else{return nil}
        return Task(name: name, time: time)
    }
    func toTaskByMinute()->Task?{
        let strTask = self.components(separatedBy: ":")
        if strTask.count != 2{return nil}
        let name = strTask[0].trim()
        guard let minute = Int(strTask[1].trim()) else{return nil}
        return Task(name: name, minute: minute)
    }
    func toGroup()->Group?{
        let strGroup = self.components(separatedBy: ":")
        if strGroup.count != 2{return nil}
        let name = strGroup[0].trim()
        guard let maxTime = Int(strGroup[1].trim()) else{return nil}
        return Group(name: name, maxTime: maxTime)
    }
    func toArray(div : String = "\n")->[String]{
        let str = self.components(separatedBy: div)
        var newStr : [String] = []
        for subStr in str{
            newStr.append(subStr.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return str
    }
    func myHash()->Int{
        return self.trimmingCharacters(in: .whitespaces).lowercased().hashValue
    }
    func upload(path : String){
        if !isEditing{
            ref.child(path).setValue(self)
        }
    }
}
extension Array<String>{
    func toTasks()->[Task]{
        var tasks :[Task] = []
        for str in self{
            guard let task = str.toTask() else{continue}
            tasks.append(task)
        }
        return tasks
    }
    func toTasksByMinute()->[Task]{
        var tasks :[Task] = []
        for str in self{
            guard let task = str.toTaskByMinute() else{continue}
            tasks.append(task)
        }
        return tasks
    }
    func toGroups()->[Group]{
        var groups :[Group] = []
        for str in self{
            guard let group = str.toGroup() else{continue}
            groups.append(group)
        }
        return groups
    }
    func toString(div:String = "\n")->String{
        var res = ""
        for str in self{
            if res.isEmpty{
                res+=str
            }
            else{
                res += (div) + str 
            }
        }
        return res
    }
    func toDict()->Dictionary<String, String> {
        var dict : Dictionary<String, String> = [:]
        for str in self{
            var strList = str.components(separatedBy: "\n")
            let key = strList.removeFirst()
            dict[key] = strList.toString()
        }
        return dict
    }
    func toTaskDict()-> Dictionary<String, [Task]>{
        var dict : Dictionary<String, [Task]> = [:]
        for str in self{
            var strList = str.components(separatedBy: "\n")
            let key = strList.removeFirst()
            var tskLst : [Task] = []
            for subStr in strList{
                guard let tsk = subStr.toTask() else{continue}
                tskLst.append(tsk)
            }
            dict[key] = tskLst
        }
        return dict
    }
    func clearEmpty()->[String]{
        var strArray = [String]()
        for str in self{
            if str.trimmingCharacters(in: .whitespaces) != ""{
                strArray.append(str)
            }
        }
        return strArray
    }
    func save(path:String){
        UserDefaults.standard.setValue(self, forKey: path)
    }
    func upload(path : String){
        if !isEditing{
            ref.child(path).setValue(self)
        }
    }
}

extension Dictionary<String, String>{
    func toArray()->Array<String>{
        var arr : [String] = []
        for key in self.keys{
            let str = key + "\n"+(self[key] ?? "")
            arr.append(str)
        }
        return arr
    }
    func saveFile(fileName:String){
        let str = self.toArray().toString(div: "\n**")
        writetoFile(filename: fileName, input: str)
    }
    func upload(filename:String){
        if !isEditing, isConfigured{
            var dict = Dictionary<String,String>()
            for key in self.keys{
                if !key.isEmpty{
                    dict[key] = self[key]
                }
            }
            writeOnline(filename: filename, input: dict)
        }
    }
    mutating func loadFile(fileName:String){
        let str = readFile(filename: fileName)
        self = str.toArray(div: "\n**").toDict()
    }
    mutating func loadOnline(filename:String){
        if let dict = ref.value(forKey: filename) as? Dictionary<String, String>{
            self = dict
        }
    }
}
extension Int{
    func toTime()->String{
        let hour = self/3600
        let minute = (self/60)%60
        let second = self%60
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}
enum DoNow{
    case rest
    case play
    case playAll
}

extension Array{
    func check(row:Int)->Bool{
        if row<0 || row>=self.count{
            return false
        }
        if count == 0{
            return false
        }
        return true
    }
}
