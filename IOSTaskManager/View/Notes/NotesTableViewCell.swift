//
//  NotesTableViewCell.swift
//  NotesTest
//
//  Created by Billie H on 29/07/24.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    @IBOutlet var nameL:UILabel!
    var previousView : NotesView!
    var indexPath: IndexPath!
    var row : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func closeB(){
        previousView.notes.remove(at: row)
        previousView.tableItem.deleteRows(at: [indexPath], with: .left)
        previousView.tableItem.reloadData()
    }
    @IBAction func imgB(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "textViewController") as! TextViewController
        let name = previousView.notes[row]
        newViewController.titleView = name
        newViewController.previousView = previousView
        newViewController.path = previousView.path+"/"+name
        previousView.navigationController?.pushViewController(newViewController, animated: true)
    }

}
