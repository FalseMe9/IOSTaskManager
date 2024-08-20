//
//  Notes.swift
//  PickerViewTest
//
//  Created by Billie H on 03/07/24.
//


import UIKit
import FirebaseDatabase


var isFirst = true

class NotesView : ViewController{
    @IBOutlet weak var tableItem : UITableView!
    @IBOutlet weak var titleField: UITextField!
    var shouldChange = true
    var notes = [String](){
        didSet{
            UserDefaults.standard.setValue(notes, forKeyPath: path+"/Notes")
            if shouldChange{
                if isConfigured{notes.upload(path: path+"/Notes")}
            }
        }
    }
    var folders = [String]() {
        didSet{
            UserDefaults.standard.setValue(folders, forKeyPath: path+"/Folder")
            if shouldChange{
                if isConfigured{folders.upload(path: path+"/Folder")}
            }
        }
    }
    var isFirstNotes = false
    var previousView : NotesView?
    var titleView = ""
    var path = "Notes"
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFirst{
            notesView = self
            self.isFirstNotes = true
            isFirst = false
        }
        tableItem.delegate = self
        tableItem.dataSource = self
        shouldChange = false
        folders = UserDefaults.standard.array(forKey: path+"/Folder") as? [String] ?? [String]()
        notes = UserDefaults.standard.array(forKey: path+"/Notes") as? [String] ?? [String]()
        tableItem.reloadData()
        shouldChange = true
    }
    override func viewDidAppear(_ animated: Bool) {
        syncOnline()

    }
    func syncOnline() {
        var timer = Timer()
        if isConfigured{
            timer.invalidate()
            ref.child(path+"/Folder").observeSingleEvent(of: .value, with: {
                snapshot in self.folders = snapshot.value as? Array<String> ?? [String]()
                self.tableItem.reloadData()
            })
            ref.child(path+"/Notes").observeSingleEvent(of: .value, with: {
                snapshot in self.notes = snapshot.value as? Array<String> ?? [String]()
                self.tableItem.reloadData()
            })
            
        }
        else{
            timer.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { timer in
                self.syncOnline()
            })
        }
    }
    func sendAlert(){
        let alert = UIAlertController(title: "Warning!", message: "File name already used", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let clearAction = UIAlertAction(title:"Clear", style: .destructive, handler: {(action) in
            self.folders = [String]()
            self.notes = [String]()
            self.tableItem.reloadData()
        })
        alert.addAction(clearAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func addNotesB(_ sender: Any) {
        if let titleText = titleField.text, !titleText.isEmpty{
            if notes.contains(titleText) || folders.contains(titleText){
                sendAlert()
            }
            else{
                notes.append(titleText)
                titleField.text = ""
                tableItem.reloadData()
            }
        }
    }
    @IBAction func addFolderB(_ sender: Any) {
        if let titleText = titleField.text, !titleText.isEmpty{
            if notes.contains(titleText) || folders.contains(titleText){
                sendAlert()
            }
            else{
                folders.append(titleText)
                titleField.text = ""
                tableItem.reloadData()
            }
        }
    }
    func downloadAll(_ sender:Any) {
        syncOnline()
    }
}


extension NotesView : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count + folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < folders.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Folders", for: indexPath) as! FolderTableViewCell
            cell.nameL.text = folders[indexPath.row]
            cell.previousView = self
            cell.indexPath = indexPath
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notes", for: indexPath) as! NotesTableViewCell
        cell.nameL.text = notes[indexPath.row-folders.count]
        cell.row = indexPath.row-folders.count
        cell.indexPath = indexPath
        cell.previousView = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.row >= folders.count{
            let newViewController = storyboard.instantiateViewController(withIdentifier: "textViewController") as! TextViewController
            let name = notes[indexPath.row-folders.count]
            newViewController.titleView = name
            newViewController.previousView = self
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        else{
            let newViewController = storyboard.instantiateViewController(withIdentifier: "NotesView") as! NotesView
            let name = folders[indexPath.row]
            newViewController.titleView = name
            newViewController.previousView = self
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}
