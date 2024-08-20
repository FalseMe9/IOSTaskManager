//
//  HourlyView2.swift
//  IOSTaskManager
//
//  Created by Billie H on 11/08/24.
//

import UIKit

import AVFoundation

var hourlyView2 : HourlyView2?

class HourlyView2: ViewController {
    @IBOutlet var taskTable:UITableView!
    @IBOutlet var taskTitleTF:UITextField!
    @IBOutlet var taskTitleL:UILabel!
    @IBOutlet var taskTimeL:UILabel!
    @IBOutlet var startAllB:UIButton!
    var isPlaying = false
    var currentCell : HourlyTableCell?
    var isPlayingAll = false {
        didSet{
            if isPlayingAll{
                startAllB.setTitle("Stop",  for: .normal)
            }
            else {
                startAllB.setTitle("Start All",  for: .normal)
            }
        }
    }
    var isToHourly = true
    var isFromHourly = true
    var appDidEnterBackgroundDate : Date? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTable.delegate = self
        taskTable.dataSource = self
        taskTable.dragDelegate = self
        taskTable.reloadData()
        taskTitleTF.delegate = self
        hourlyView2 = self
        taskTitleL.text = hourlyView?.taskTitle
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        taskTable.reloadData()
        hourlyView?.syncButton()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hourlyView?.taskListPV.reloadAllComponents()
    }

    func play(at row:Int){
        guard let cell = get(cellAt: row) else{return}
        cell.playB(self)
    }
    func get(cellAt row:Int) -> HourlyTableCell?{
        guard let cell = hourlyView2?.taskTable.cellForRow(at: IndexPath(row: row, section: 0)) as? HourlyTableCell else{return nil}
        return cell
    }
    // Enter Text
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let r = super.textFieldShouldReturn(textField)
        
        guard var text = taskTitleTF.text else{return r}
        
        if addF(strTask: text){
            taskTitleTF.text = ""
        }

        
        return r
        
    }
    
    
    // Play
    @IBAction func playAllB(_ sender:Any){
        hourlyView?.startAll(self)
    }
    // Misc
    @IBAction func didTapSwitch(_ sender:Any){
        navigationController?.popViewController(animated: true)
//        navigationController?.pushViewController(hourlyView!, animated: true)
    }
    @IBAction func didTapRefresh(_ sender:Any){
        hourlyView?.refresh(self)
        taskTable.reloadData()
    }
}

extension HourlyView2: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hourly.count + 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HourlyTableCell", for: indexPath) as! HourlyTableCell
        if indexPath.row >= hourly.count{
            hourlyView?.getBreakTime()
            cell.task = breaks
            cell.name.text = breaks.displayString()
        }
        else{
            cell.task = hourly[indexPath.row]
            cell.name.text = hourly[indexPath.row].displayString()
        }
        cell.indexPath = indexPath
        cell.previousView = self
        cell.row = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row >= hourly.count || destinationIndexPath.row >= hourly.count{
            taskTable.reloadData()
            return
        }
        let task = hourly[sourceIndexPath.row]
        hourly.remove(at: sourceIndexPath.row)
        hourly.insert(task, at: destinationIndexPath.row)
        taskTable.reloadData()
    }
    
}
