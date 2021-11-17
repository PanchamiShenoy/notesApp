//
//  RealmManager.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 29/10/21.
//

import Foundation
import RealmSwift
struct RealmManager {
    static var shared = RealmManager()
    let realmInstance = try! Realm()
    var notesRealm : [NoteItemRealm] = []
    func addNote(note:NoteItemRealm){
        try! realmInstance.write({
            realmInstance.add(note)
        })
    }
    
   mutating func deleteNote(note:NoteItemRealm){
        try! realmInstance.write({
            realmInstance.delete(note)
        })
    }
    
    func updateNote(_ title:String,_ noteContent:String,_ note:NoteItemRealm){
        let realmInstance = try! Realm()
        try! realmInstance.write({
            note.title = title
            note.note = noteContent
        })
        
    }
    
  mutating  func fetchNotes(completion :@escaping([NoteItemRealm])->Void) {
      var notesArray :[NoteItemRealm] = []
        let notes = realmInstance.objects(NoteItemRealm.self)
        for note in notes
        {
            notesRealm.append(note)
            notesArray.append(note)
            
        }
      completion(notesArray)
      print(notes)
      
    }
}
