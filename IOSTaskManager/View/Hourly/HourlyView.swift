//
//  ViewController.swift
//  Test
//
//  Created by Billie H on 28/06/24.
//

import UIKit
import AVFoundation


class HourlyView: ViewController {
    @IBOutlet var taskListPV: UIPickerView!
    @IBOutlet var taskTitleL : UILabel!
    @IBOutlet var taskTimeL : UILabel!
    @IBOutlet var enterTaskTF : UITextField!
    @IBOutlet var taskDescriptionTV: UITextView!
    @IBOutlet var startB : UIButton!
    @IBOutlet var startAllB : UIButton!
    
    // variable
    var timer = Timer()
    var taskTime = String(breaks.minute()){
        didSet{
            taskTimeL.text = taskTime
            hourlyView2?.taskTimeL?.text = taskTime
        }
    }
    var taskTitle = breaks.name{
        didSet{
            taskTitleL.text = taskTitle
            hourlyView2?.taskTitleL.text = taskTitle
        }
    }
    var taskDescription = taskDict[breaks.name]{
        didSet{
            taskDescriptionTV.text = taskDescription
        }
    }
    var currentTask = breaks{
        willSet{
            taskDict[taskTitle] = taskDescriptionTV.text
        }
        didSet{
            taskTitle = currentTask.name
            taskTime = String(currentTask.minute())
            taskDescription = taskDict[taskTitle] ?? ""
        }
    }
    var row = hourly.count{
        didSet{
            if row < hourly.count{
                currentTask = hourly[row]
            }
            else{currentTask = breaks}
        }
    }

    var doNow : DoNow = .rest {
        didSet{
            syncButton()
        }
    }
    var appDidEnterBackgroundDate : Date? = nil
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourlyView = self
        // Delegate
        taskListPV.delegate = self
        taskListPV.dataSource = self
        enterTaskTF.delegate = self
        
        // Get From File
        setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        taskListPV.reloadAllComponents()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        taskDict[taskTitle] = taskDescriptionTV.text
    }
    
    // Background
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(_ notification: NotificationCenter) {
        if doNow != .rest{
            Notification.checkForPermission(title: currentTask.name,interval: currentTask.time)
        }
        timer.invalidate()
        appDidEnterBackgroundDate = Date()
    }
    
    @objc func applicationWillEnterForeground(_ notification: NotificationCenter) {
        Notification.removeNotification()
        guard let previousDate = appDidEnterBackgroundDate else { return }
        // chose function
        var selector = #selector(startf)
        switch (doNow){
        case .rest:
            return
        case .play:
            selector = #selector(startf)
        case .playAll:
            selector = #selector(startAllf)
        }
        // Date Difference
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.second], from: previousDate, to: Date())
        let timerSeconds = difference.second!
        let task = currentTask
        task.time -= timerSeconds
        if task.time < 0 {task.time  = 0}
        // Start Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: selector, userInfo: nil, repeats: true)
    }
    
    // Start
    @IBAction func start(_ sender:Any){
        if(doNow == .rest){
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startf), userInfo: nil, repeats: true)
            doNow = .play
        }
        else {
            timer.invalidate()
            doNow = .rest
            talk(str: "Paused")
            hourly.upload(path: hourlyFile)
            hourlyView2?.taskTable.reloadData()
        }
    }
    @objc func startf(){
        let second = currentTask.time
        taskTime = second.toTime()
        currentTask.time -= 1
        if(second<=0){finish(self)}
    }
    @IBAction func finish(_ sender:Any){
        if hourly.count <= row{
            if(doNow == .play){
                timer.invalidate()
                doNow = .rest
                talk(str: "Finished")
            }
            return
        }
        if(doNow == .rest){
            if row < 0 {row = 0}
            breaks.time += currentTask.time
            remove(row: row)
        }
        if(doNow == .play){
            timer.invalidate()
            doNow = .rest
            talk(str: "Finished")
            breaks.time += currentTask.time
            currentTask.time = 0
            remove(row: row)
            hourlyView2?.taskTable.reloadData()
        }
        if(doNow == .playAll){
            startAll()
        }
    }
    
    @IBAction func clear(_ sender:Any){
        if(doNow != .rest){return}
        timer.invalidate()
        breaks.time = 0
        if hourly.count == 0{
            taskTitle = "No Task!"
            taskTime = "0"
            return
        }
        if hourly.count == 1{
            row = 0
        }
        
    }
    @IBAction func startAll(_ sender:Any){
        if(doNow == .play){
            return
        }
        if(doNow == .rest){
            doNow = .playAll
            timer.invalidate()
            row = 0
            talk(str: currentTask.name)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startAllf), userInfo: nil, repeats: true)
            return
        }
        if(doNow == .playAll){
            doNow = .rest
            timer.invalidate()
            breaks.time += currentTask.time
            currentTask.time = 0
            remove(row: row)
            row = 0
            talk(str: "Finish")
            return
        }
    }
    func startAll(){
        if(hourly.count == 0){
            doNow = .rest
            timer.invalidate()
            seconds = 0
            talk(str: "Finish")
            return
        }
        timer.invalidate()
        seconds = currentTask.time
        remove(row: row)
        row = 0
        currentTask.time+=seconds
        talk(str: currentTask.name)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startAllf), userInfo: nil, repeats: true)
    }
    @objc func startAllf(){
        let task = currentTask
        taskTime = task.time.toTime()
        task.time-=1
        if task.time < 0{
            startAll()
        }
        
    }
    
    // Enter Task
    @IBAction func add(_ sender: Any) {
        guard var strTask = enterTaskTF.text
        else{
            return
        }
        if addF(strTask: strTask){
            enterTaskTF.text = ""
        }
    }
    // Misc
    
    @IBAction func refresh(_ sender: Any){
        getBreakTime()
    }
    func getBreakTime(){
        let timeRemaining = getDifference()
        let totalTime = { ()->Int in
            var num = 0
            for group in groupList{
                num += group.getTotalTime()
            }
            return num
        }
        breaks.time = timeRemaining
        breaks.time -= hourly.getTotalTime()
        if breaks.time >= totalTime(){
            breaks.time -= totalTime()
        }else{breaks.time = 0}
    }
    func remove(row:Int){
        if row < hourly.count{
            hourly.remove(at: row)
        }
    }
    // Button
    func syncButton(){
        var startT = "", startAllT = ""
        let cell = hourlyView2?.get(cellAt: row)
        switch doNow{
        case .rest:
            startT = "Start"
            startAllT = "Start All"
            cell?.isPlaying = false
        case .play:
            startT = "Pause"
            startAllT = ""
            cell?.isPlaying = true
        case .playAll:
            startT = "Pause"
            startAllT = "Stop All"
            cell?.isPlaying = true
        }
        startB.setTitle(startT, for: .normal)
        startAllB.setTitle(startAllT, for: .normal)
        hourlyView2?.startAllB.setTitle(startAllT, for: .normal)
    }
}



extension HourlyView{
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        add(self)
        return super.textFieldShouldReturn(textField)

    } 
}

extension HourlyView: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hourly.count+1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == hourly.count{
            getBreakTime()
            return "Break"
        }
        else{
            return hourly[row].name
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(doNow == .rest){
            self.row = row
        }
    }
}
