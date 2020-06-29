//
//  MasterViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var managedContext: NSManagedObjectContext!
 
    
    var folderPredicate: NSPredicate?
    var folderSelectedName: String? {
        didSet{
            folderPredicate = NSPredicate(format: "parent.categoryName = %@", folderSelectedName as! CVarArg)
            self.title = folderSelectedName
        }
    }
    
    // buttons
    
    
    var flexible: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var archiveButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    
    var allNotes: [SlickNotes] = []
    var filteredNotes: [SlickNotes] = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        loadNotes()
        
        self.tableView.allowsMultipleSelectionDuringEditing = true 
        // code for searching
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Tasks"
        // 4
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // 5
        definesPresentationContext = true
        
        
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(didPressDelete))
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didPressEdit))
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didPressDone))
        archiveButton = UIBarButtonItem(title: "Mark Completed", style: .plain, target: self, action: #selector(didPressArchive))
        
        
        self.toolbarItems = [editButton,flexible, deleteButton]
        self.navigationController?.toolbar.barTintColor = UIColor.white
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
//        self.view.addGestureRecognizer(tapGesture)
//        
         // Core data initialization
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            // create alert
            let alert = UIAlertController(
                title: "Could note get app delegate",
                message: "Could note get app delegate, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))
            // show alert
            self.present(alert, animated: true)
            return
            
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
         // set context in the storage
        SlickNotesStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        // Do any additional setup after loading the view.

        let sortImage = UIImage(named: "sort")
        let sortButton = UIBarButtonItem(image: sortImage,  style: .plain, target: self, action: "sortTasks:")
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        
        navigationItem.rightBarButtonItems = [addButton,sortButton]
       
    }
    
    
    func loadNotes(sortDescriptors: [NSSortDescriptor]? = nil){
        if folderSelectedName == "All"{
                          folderPredicate = nil
        }
               
        allNotes = SlickNotesStorage.storage.readNotes(withPredicate: folderPredicate, sortDescriptors:sortDescriptors )!
        filteredNotes = allNotes
    }

    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        loadNotes()
        tableView.reloadData()

    }
    
    @objc func didPressDelete() {
        let selectedRows = self.tableView.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= filteredNotes.count {
                    selectionIndex.item -= 1
                }
                tableView(tableView, commit: .delete, forRowAt: selectionIndex)
            }
        }
        didPressDone()
    }
    
    @objc func didPressEdit() {
           
           setEditing(true, animated: true)
         self.toolbarItems = [doneButton,flexible,  archiveButton, flexible,
 deleteButton]

    }
    
    @objc func didPressDone() {
           setEditing(false, animated: true)
        self.toolbarItems = [editButton,flexible, deleteButton]

    }
    
    @objc func didPressArchive() {
        let selectedRows = self.tableView.indexPathsForSelectedRows
        if selectedRows != nil {
            for var selectionIndex in selectedRows! {
                while selectionIndex.item >= filteredNotes.count {
                    selectionIndex.item -= 1
                }
                var object = filteredNotes[selectionIndex.row]
                object.setCategory(category: "Archived")
                SlickNotesStorage.storage.changeNote(noteToBeChanged: object)
            }
        }
        loadNotes()
        self.tableView.reloadData()
    }

    
    
    @objc
       func insertNewObject(_ sender: Any) {
           let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
           let SlickCreateNoteViewController = storyBoard.instantiateViewController(withIdentifier: "SlickCreateNoteViewController") as! SlickCreateNoteViewController
           
           SlickCreateNoteViewController.folderSelectedName = folderSelectedName
           self.navigationController?.pushViewController(SlickCreateNoteViewController, animated: true)
       }
    
    @objc
    func sortTasks(_ sender: Any) {
        let alert = UIAlertController(
            title: "Sort By",
            message: "",
            preferredStyle: .alert)
        
        
        let sortByTitleAction = UIAlertAction(title: "Title", style: .default, handler: {(alert: UIAlertAction!) in
            let sort = NSSortDescriptor(key: #keyPath(Note.noteTitle), ascending: true)
            self.loadNotes(sortDescriptors: [sort] )
            self.tableView.reloadData()
        })
        
        
        let sortByDateAction = UIAlertAction(title: "Due Date", style: .default, handler: {(alert: UIAlertAction!) in
            print("Due Date")
            let sort = NSSortDescriptor(key: #keyPath(Note.noteTimeStamp), ascending: true)
            self.loadNotes(sortDescriptors: [sort] )
            self.tableView.reloadData()

        })
        alert.addAction(sortByTitleAction)
        alert.addAction(sortByDateAction)
        // show alert
        self.present(alert, animated: true)
    }
    
    


    // MARK: - Table View
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SlickNotesStorage.storage.count() == 0 {
            self.tableView.setEmptyMessage("No notes to show")
        } else {
            self.tableView.restore()
        }
        //return places?.count ?? 0
        
        if isFiltering {
          return filteredNotes.count
        }
        return allNotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SlickNotesTableCell

        cell.noteTitleLabel.font =  UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Montserrat-Black")).withSize(23)
        cell.noteTitleLabel.textAlignment = .center
        
        cell.noteTextLabel.font =  UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Montserrat-Black")).withSize(15)
        cell.noteTextLabel.alpha = 0.8

        
        cell.noteDateLabel.font =  UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Montserrat-Black")).withSize(15)
        cell.noteDateLabel.alpha = 0.8
        cell.noteDateLabel.textAlignment = .center

        
        
        let object: SlickNotes
       
        if isFiltering {
            object = filteredNotes[indexPath.row]
        }
        else
        {
            object = allNotes[indexPath.row]
        }
        
        cell.noteTitleLabel!.text = object.noteTitle
        cell.noteTextLabel!.text = object.noteText
        cell.noteDateLabel!.text = SlickNotesDateHelper.convertDate(date: object.noteTimeStamp)
        
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "noteId = %@", object.noteId as! CVarArg)
        var note: Note? = nil
        do {
            let notes = try self.managedContext.fetch(request)
            if notes.count > 0 {
                note = notes[0]
            }
            
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        if note != nil &&  note?.parent?.categoryName == "Archived" {
          
            cell.backgroundColor  =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            cell.noteDateLabel.text =  cell.noteDateLabel.text! + " (Archived)"

        }
        else if isOverdue(taskObject: object){
            cell.backgroundColor  =  UIColor(red: 1, green: 0, blue: 0, alpha: 0.4)
            cell.noteDateLabel.text =  cell.noteDateLabel.text! + " (Overdue)"
            
        }
        else{
            cell.backgroundColor  =  UIColor(red: 0, green: 1, blue: 0, alpha: 0.4)
            cell.noteDateLabel.text =  cell.noteDateLabel.text! + " (Due)"

        }
        
       
        
        return cell
    }
    
    func compareDate(date1:Date, date2:Date) -> Bool {
        let order = NSCalendar.current.compare(date1, to: date2, toGranularity: .day)
        switch order {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }
    
    func isOverdue(taskObject: SlickNotes ) -> Bool{
        
        var currentDate = Date()
        
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        print(timeZoneOffsetDate)
        print(taskObject.noteTimeStamp)
        
        return compareDate(date1: taskObject.noteTimeStamp, date2: timeZoneOffsetDate)
       
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        tableView.setEditing(editing, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object: SlickNotes
        if isFiltering {
            object = filteredNotes[indexPath.row]
        }
        else{
            object = allNotes[indexPath.row]
        }
        
        if !isEditing{
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
             let NoteDetailViewController = storyBoard.instantiateViewController(withIdentifier: "NoteDetailViewController") as! NoteDetailViewController
             NoteDetailViewController.detailItem = object
             NoteDetailViewController.folderSelectedName = folderSelectedName
            self.navigationController?.pushViewController(NoteDetailViewController, animated: true)
        }
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.remove(at: indexPath.row)
            
            var delIndex = 0
            for val in allNotes{
                if val.noteId == filteredNotes[indexPath.row].noteId
                {
                    break
                }
                delIndex = delIndex + 1
            }
            SlickNotesStorage.storage.removeNote(at: delIndex)
            allNotes.remove(at: delIndex)
            filteredNotes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

extension MasterViewController: UISearchResultsUpdating {
      func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
      }
        
    func filterContentForSearchText(_ searchText: String
                                    ) {
      filteredNotes = allNotes.filter { (note: SlickNotes) -> Bool in
        return note.noteTitle.lowercased().contains(searchText.lowercased()) || note.noteText.lowercased().contains(searchText.lowercased()
        )
      }
      
      tableView.reloadData()
    }
}
