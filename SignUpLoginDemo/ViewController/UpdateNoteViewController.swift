//
//  UpdateNoteViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 28/10/21.
//

import UIKit

class UpdateNoteViewController: UIViewController {

    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var noteFirebase: NoteItem?
    var noteRealm :NoteItemRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.text = noteFirebase?.note
        titleTextField.text = noteFirebase?.title
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        noteFirebase?.title = titleTextField.text!
        noteFirebase?.note = noteTextField.text!
        
        let title = titleTextField.text!
        let note = noteTextField.text!
       // NetworkManager.shared.updateNote(note!)
        //RealmManager.shared.updateNote(title,note,noteRealm!)
        DatabaseManager.shared.updateNote(note: noteFirebase!, realmNote: noteRealm!, title: title, content: note)
        noteTextField.text = ""
        titleTextField.text = ""
    }
    
    @IBAction func onCanecl(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
