//
//  SlickNotes.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SlickNotes {
    private(set) var noteId        : UUID
    private(set) var noteTitle     : String
    private(set) var noteText      : String
    private(set) var noteTimeStamp : Date
    private(set) var latitude : String
    private(set) var longitude : String
    private(set) var location : String
    private(set) var category : Category?
   
    
    func setCategory(category:String){
        
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
        
         let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = predicate
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let categories  = try context.fetch(request)
            if categories.count > 0 {
                 let category = categories[0]
                self.category = category
            }
           
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        
    }
    
    init(noteTitle:String, noteText:String, noteTimeStamp:Date, latitude: String, longitude: String, location:String, category: String = "all") {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
        
         let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = predicate
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let categories  = try context.fetch(request)
            if categories.count > 0 {
                 let category = categories[0]
                self.category = category
            }
           
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
       
    }

    init(noteId: UUID, noteTitle:String, noteText:String, noteTimeStamp:Date, latitude: String, longitude: String, location: String, category: String = "all"
    ) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteTimeStamp = noteTimeStamp
        self.latitude = latitude
       self.longitude = longitude
        self.location = location
        
        let predicate = NSPredicate(format: "categoryName = %@", category as CVarArg)
               
                let request: NSFetchRequest<Category> = Category.fetchRequest()
               request.predicate = predicate
               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               do {
                   let categories  = try context.fetch(request)
                   if categories.count > 0 {
                        let category = categories[0]
                       self.category = category
                   }
                  
               } catch {
                   print("Error loading categories \(error.localizedDescription)")
               }
        
    }
    
    
}
