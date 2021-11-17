//
//  NetworkManager.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 20/10/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UserNotifications

var fetchingMoreNotes = false
var lastDoc: QueryDocumentSnapshot?

struct NetworkManager {
    static let shared = NetworkManager()
    
    func login(withEmail email:String,password:String,completion:AuthDataResultCallback?){
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signup(withEmail email:String,password:String,completion:AuthDataResultCallback?){
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    func writeDocument(documentName: String, data: [String: Any]) {
        let db = Firestore.firestore()
        db.collection(documentName).addDocument(data: data)
    }
    
    func signout()  {
        
        do {
            try Auth.auth().signOut()
            
            
        }catch{
            
        }
    }
    
    func checkSignIn() ->Bool {
        
        if Auth.auth().currentUser?.uid != nil {
            return true
        }
        else{
            return false
        }
    }
    
    func checkGoogleSignIn()-> Bool {
        var status = false
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                status = false
            }
            else{
                status = true
            }
        }
        return status
    }
    
    func googleSignOut(){
        
        GIDSignIn.sharedInstance.signOut()
    }
    
    func addNote(note:[String:Any]){
        let db = Firestore.firestore()
        db.collection("notes").addDocument(data:note)
    }
    
    func deleteNote(_ deleteNote:NoteItem) {
        let db = Firestore.firestore()
        db.collection("notes").document(deleteNote.noteId!).delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateNote(_ note:NoteItem){
        let db = Firestore.firestore()
        db.collection("notes").document(note.noteId!).updateData(["title": note.title, "note": note.note,"timestamp":Date()])
    }
    
    func resultType(completion: @escaping(Result<[NoteItem], Error>) -> Void) {
        
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("notes").whereField("uid", isEqualTo: uid).order(by: "timestamp").limit(to: 7).getDocuments { snapshot, error in
            var notes: [NoteItem] = []
            
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for doc in snapshot.documents {
                let data = doc.data()
                let noteId = doc.documentID
                let title = data["title"] as? String ?? ""
                let note = data["note"] as? String ?? ""
                let uid = data["uid"] as? String ?? ""
                let date = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let reminderTime = (data["reminderTime"] as? Timestamp)?.dateValue() 
                let archieved = data["isArchieved"] as? Bool ?? false
                
                let newNote = NoteItem(noteId: noteId, title: title, note: note, uid: uid, date: date,isArchieved:archieved,reminderTime:reminderTime)
                notes.append(newNote)
            }
            lastDoc = snapshot.documents.last
            completion(.success(notes))
        }
    }
    
    func fetchMoreNotes(completion: @escaping([NoteItem]) -> Void){
        let db = Firestore.firestore()
        fetchingMoreNotes = true
        var notes : [NoteItem] = []
        guard let lastDocument = lastDoc else { return }
        DispatchQueue.global().asyncAfter(deadline: .now()+5, execute: {
            db.collection("notes").order(by: "timestamp").start(afterDocument: lastDocument).limit(to: 7).getDocuments { snapshot, error in
                if error == nil && snapshot != nil {
                    for document in snapshot!.documents {
                        let data = document.data()
                        let note = NoteItem(noteId: document.documentID, title: data["title"] as! String, note: data["note"] as! String,uid:data["uid"] as! String, date: (data["timestamp"] as! Timestamp).dateValue(),isArchieved:(data["isArchieved"] as! Bool),reminderTime: (data["reminderTime"] as! Timestamp).dateValue()
                        )
                        notes.append(note)
                    }
                    lastDoc = snapshot!.documents.last
                    print("\n\n!!!!!!!!!!!!!!!!!!!!!!!!")
                    print(notes)
                    fetchingMoreNotes = false
                    completion(notes)
                }
            }
        })
    }
    
    func fetchNote(isArchived:Bool,completion :@escaping([NoteItem])->Void) {
        let x = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        var notes :[NoteItem] = []
        db.collection("notes").whereField("uid", isEqualTo: x!).whereField("isArchieved", isEqualTo: isArchived ).getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                for document in snapshot!.documents {
                    let data = document.data()
                    let note = NoteItem(noteId: document.documentID, title: data["title"] as! String, note:data["note"] as! String,uid:data["uid"] as! String, date: (data["timestamp"] as! Timestamp).dateValue(),isArchieved:(data["isArchieved"] != nil), reminderTime : (data["reminderTime"] as! Timestamp).dateValue()
                    )
                    notes.append(note)
                }
                lastDoc = snapshot!.documents.last
                
            }
            print("@@@@@@@@@@@@@@@@@",notes)
            completion(notes)
        }
        
    }
}

