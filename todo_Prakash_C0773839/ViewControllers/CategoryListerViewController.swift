//
//  MasterViewController.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData

class CategoryListerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var objects = [Any]()
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if all category is present if not add it
        
       
        
        
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
        SlickCategoryStorage.storage.setManagedContext(managedObjectContext: managedContext)
        SlickNotesStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        
        var allCategories = SlickCategoryStorage.storage.readCategories(withPredicate: NSPredicate(format: "categoryName = %@", "All"))
               if(allCategories?.count == 0){
                   // app opened first time
                   SlickCategoryStorage.storage.addCategory(categoryToBeAdded: .init(categoryName: "All"))
               }
        
         allCategories = SlickCategoryStorage.storage.readCategories(withPredicate: NSPredicate(format: "categoryName = %@", "Archived"))
        if(allCategories?.count == 0){
            // app opened first time
            SlickCategoryStorage.storage.addCategory(categoryToBeAdded: .init(categoryName: "Archived"))
        }
        // Do any additional setup after loading the view.
       
        
    }
    
  
    
    @IBAction func addCategoryBtnDown(_ sender: Any) {
        
        print("clicked")
       let alertController = UIAlertController(title: "Add New Category", message: "Enter Name", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = ""
        }
     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in
            print("Cancelled")
     })
        
        let addCatAction = UIAlertAction(title: "Add", style: .default, handler: {(alert: UIAlertAction!) in
            let textField = alertController.textFields![0] // Force unwrapping because we know it exists.
            
            
            // code to add new category
            if let inputText = textField.text {
                if inputText == "" {
                    let alertController = UIAlertController(title: "Category Name can't be empty", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {(alert: UIAlertAction!) in
                           print("Cancelled")
                    })
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
    

                }
                
                // check if duplicate
                
                let presentCategory  = SlickCategoryStorage.storage.readCategories(withPredicate: NSPredicate(format: "categoryName = %@", inputText))
                if presentCategory!.count > 0{
                    let alertController = UIAlertController(title: "Category with name \(inputText) already present", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {(alert: UIAlertAction!) in
                           print("Cancelled")
                    })
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                
                
                let category = SlickCategory(categoryName: textField.text!)
                SlickCategoryStorage.storage.addCategory(categoryToBeAdded: category)
                self.tableView.reloadData()
                
            }
            
            
            
            
        })
                      
      alertController.addAction(cancelAction)
      alertController.addAction(addCatAction)

      present(alertController, animated: true, completion: nil)
           
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
//    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }

    @objc
    func insertNewObject(_ sender: Any) {
      //  performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
    }

   

  

    // MARK: - Table View
    


  


}




extension CategoryListerViewController: UITableViewDataSource, UITableViewDelegate{
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //return places?.count ?? 0
        
        
        return SlickCategoryStorage.storage.count()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        
//        cell.layer.borderWidth = 2
        cell.textLabel?.font =  UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Montserrat-Black")).withSize(23)
        
        cell.detailTextLabel?.font =  UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Montserrat-Black")).withSize(17)
        cell.detailTextLabel?.alpha = 0.7

        if let object = SlickCategoryStorage.storage.readCategory(at: indexPath.row) {
            cell.textLabel?.text = object.categoryName
            
            
            // get the count of notes
            var predicate: NSPredicate? = NSPredicate(format: "parent.categoryName = %@", object.categoryName as CVarArg )
            
            if object.categoryName == "All"{
                predicate = nil
            }
            let notes = SlickNotesStorage.storage.readNotes(withPredicate: predicate)
            
            cell.detailTextLabel?.text = "\(notes!.count) Tasks"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = SlickCategoryStorage.storage.readCategory(at: indexPath.row) {
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
           let masterViewController = storyBoard.instantiateViewController(withIdentifier: "noteListerViewController") as! MasterViewController
            masterViewController.folderSelectedName = object.categoryName
           
           self.navigationController?.pushViewController(masterViewController, animated: true)
        }
    }

     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.remove(at: indexPath.row)
            SlickCategoryStorage.storage.removeCategory(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}
