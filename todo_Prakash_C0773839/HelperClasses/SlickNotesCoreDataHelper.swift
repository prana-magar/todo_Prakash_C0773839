//
//  SlickNotesCoreDataHelper.swift
//  SlickNotes
//
//  Created by user166476 on 6/20/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
import CoreData

class SlickNotesCoreDataHelper
{
    private(set) static var count: Int = 0
    
    static func createNoteInCoreData(
        noteToBeCreated:          SlickNotes,
        intoManagedObjectContext: NSManagedObjectContext) {
        
        // Let’s create an entity and new note record
        let noteEntity = NSEntityDescription.entity(
            forEntityName: "Note",
            in:            intoManagedObjectContext)!
        
        let newNoteToBeCreated = NSManagedObject(
            entity:     noteEntity,
            insertInto: intoManagedObjectContext)

        newNoteToBeCreated.setValue(
            noteToBeCreated.noteId,
            forKey: "noteId")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTitle,
            forKey: "noteTitle")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteText,
            forKey: "noteText")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTimeStamp,
            forKey: "noteTimeStamp")
        
        newNoteToBeCreated.setValue(
        noteToBeCreated.latitude,
        forKey: "latitude")
        
        newNoteToBeCreated.setValue(
        noteToBeCreated.longitude,
        forKey: "longitude")
        
        newNoteToBeCreated.setValue(
        noteToBeCreated.location,
        forKey: "location")
        
        
        
        newNoteToBeCreated.setValue(noteToBeCreated.category, forKey: "parent")
        
        do {
            try intoManagedObjectContext.save()
            count += 1
        } catch let error as NSError {
            // TODO error handling
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func changeNoteInCoreData(
        noteToBeChanged:        SlickNotes,
        inManagedObjectContext: NSManagedObjectContext) {
        
        // read managed object
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteToBeChanged.noteId as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try inManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeChanged = fetchedNotesFromCoreData[0] as! NSManagedObject
            
            // make the changes
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteTitle,
                forKey: "noteTitle")

            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteText,
                forKey: "noteText")

            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteTimeStamp,
                forKey: "noteTimeStamp")
            
            noteManagedObjectToBeChanged.setValue(noteToBeChanged.category, forKey: "parent")

         

            // save
            try inManagedObjectContext.save()

        } catch let error as NSError {
            // TODO error handling
            print("Could not change. \(error), \(error.userInfo)")
        }
    }
    
    static func readNotesFromCoreData(fromManagedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil , sortDescriptors: [NSSortDescriptor]? = nil ) -> [SlickNotes] {

        var returnedNotes = [SlickNotes]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedNotes.append(SlickNotes.init(
                    noteId:        noteManagedObjectRead.value(forKey: "noteId")        as! UUID,
                    noteTitle:     noteManagedObjectRead.value(forKey: "noteTitle")     as! String,
                    noteText:      noteManagedObjectRead.value(forKey: "noteText")      as! String,
                    noteTimeStamp: noteManagedObjectRead.value(forKey: "noteTimeStamp") as! Date,
                    
                    latitude: noteManagedObjectRead.value(forKey: "latitude") as! String,
                    longitude: noteManagedObjectRead.value(forKey: "longitude") as! String,
                    location: noteManagedObjectRead.value(forKey: "location") as! String
                  

                    ))
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
        }
        
        
        return returnedNotes
    }
    
    static func readNotesFromCoreData(fromManagedObjectContext: NSManagedObjectContext ) -> [SlickNotes] {

        var returnedNotes = [SlickNotes]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = nil
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedNotes.append(SlickNotes.init(
                    noteId:        noteManagedObjectRead.value(forKey: "noteId")        as! UUID,
                    noteTitle:     noteManagedObjectRead.value(forKey: "noteTitle")     as! String,
                    noteText:      noteManagedObjectRead.value(forKey: "noteText")      as! String,
                    noteTimeStamp: noteManagedObjectRead.value(forKey: "noteTimeStamp") as! Date,
                    
                    latitude: noteManagedObjectRead.value(forKey: "latitude") as! String,
                    longitude: noteManagedObjectRead.value(forKey: "longitude") as! String,
                    location: noteManagedObjectRead.value(forKey: "location") as! String
                   
                    
                    ))
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
        }
        
        // set note count
        self.count = returnedNotes.count
        
        return returnedNotes
    }
    
    static func readNoteFromCoreData(
        noteIdToBeRead:           UUID,
        fromManagedObjectContext: NSManagedObjectContext) -> SlickNotes? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteIdToBeRead as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        
       
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeRead = fetchedNotesFromCoreData[0] as! NSManagedObject
            
            return SlickNotes.init(
                noteId:        noteManagedObjectToBeRead.value(forKey: "noteId")        as! UUID,
                noteTitle:     noteManagedObjectToBeRead.value(forKey: "noteTitle")     as! String,
                noteText:      noteManagedObjectToBeRead.value(forKey: "noteText")      as! String,
                noteTimeStamp: noteManagedObjectToBeRead.value(forKey: "noteTimeStamp") as! Date,
            latitude: noteManagedObjectToBeRead.value(forKey: "latitude") as! String,
                longitude: noteManagedObjectToBeRead.value(forKey: "longitude") as! String,
            location: noteManagedObjectToBeRead.value(forKey: "location") as! String
           
                )
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    static func deleteNoteFromCoreData(
        noteIdToBeDeleted:        UUID,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdAsCVarArg: CVarArg = noteIdToBeDeleted as CVarArg
        let noteIdPredicate = NSPredicate(format: "noteId == %@", noteIdAsCVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeDeleted = fetchedNotesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(noteManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
                self.count -= 1
            } catch let error as NSError {
                // TODO error handling
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }
}
