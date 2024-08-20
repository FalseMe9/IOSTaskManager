//
//  FolderTableViewCell.swift
//  NotesTest
//
//  Created by Billie H on 29/07/24.
//

import UIKit

class FolderTableViewCell: UITableViewCell {
    @IBOutlet var nameL:UILabel!
    var previousView: NotesView!
    var indexPath : IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func closeB(_ sender: Any){
        let str = previousView.folders[indexPath.row]
        previousView.folders.remove(at: indexPath.row)
        previousView.tableItem.deleteRows(at: [indexPath], with: .left)
        previousView.tableItem.reloadData()
    }
    @IBAction func imgB(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "NotesView") as! NotesView
        let name = previousView.folders[indexPath.row]
        newViewController.titleView = name
        newViewController.path = previousView.path+"/"+name
        newViewController.previousView = previousView
        previousView.navigationController?.pushViewController(newViewController, animated: true)
    }
}
