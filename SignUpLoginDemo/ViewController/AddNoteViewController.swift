//
//  AddNoteViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 26/10/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RealmSwift
class AddNoteViewController: UIViewController {
    let uid = Auth.auth().currentUser?.uid
    let realmInstance = try! Realm()
    @IBOutlet weak var noteTitle: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteContent: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
    
    @IBAction func onAdd(_ sender: Any) {
        let noteTitle :String = noteTitle.text!
        let noteContent :String = noteContent.text!
       /* let newNote: [String: Any] = ["title": noteTitle,"note":noteContent,"uid" uid,"timestamp":Date(),"reminderTime" : ,"isArchieved":false]
        */
        let newNote = NoteItem(title: noteTitle, note: noteContent, uid: uid!, date: Date(), isArchieved: false, reminderTime: nil)
        let note1 = NoteItemRealm()
        note1.note = noteContent
        note1.title = noteTitle
        note1.uid = uid!
        note1.date = Date()
        note1.reminderTime = nil
        note1.isArchieved = false
        DatabaseManager.shared.addNote(note: newNote.dictionary, realmNote: note1)
        
        self.noteTitle.text = ""
        self.noteContent.text = ""
        
    }
    
    @IBAction func onReminder(_ sender: Any) {
        
        let noteTitle :String = noteTitle.text!
        let noteContent :String = noteContent.text!
        let newNote: [String: Any] = ["title": noteTitle,"note":noteContent,"uid": uid,"timestamp":Date(),"reminderTime" : datePicker.date,"isArchieved":false]
        let note1 = NoteItemRealm()
        note1.note = noteContent
        note1.title = noteTitle
        note1.uid = uid!
        note1.date = Date()
        note1.reminderTime = datePicker.date
        note1.isArchieved = false
        DatabaseManager.shared.addNote(note: newNote, realmNote: note1)
        
        self.noteTitle.text = ""
        self.noteContent.text = ""
        
        let content = UNMutableNotificationContent()
                content.title = "Note Remainder \(note1.title)"
                content.sound = .default
                content.body = note1.note
                  
                 let targetDate = datePicker.date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                
                let request = UNNotificationRequest(identifier: "id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if error != nil {
                        self.showAlert(title: "Failed", message: "Error")
                    }
        }
        
    }
    func printNotes(){
        
        let notes = realmInstance.objects(NoteItemRealm.self)
        for note in notes
        {
            print(note)
        }
    }
    
    func getDate() ->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return dateFormatter.string(from:Date())
    }
}

