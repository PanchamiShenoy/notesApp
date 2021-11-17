//
//  ArchieveViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 08/11/21.
//

import UIKit
import RealmSwift
import FirebaseFirestore

class ArchieveViewController: UIViewController {
    var width: CGFloat = 0
    var noteRealm : NoteItemRealm?
    var notesRealm : [NoteItemRealm] = []
    let realmInstance = try! Realm()
    @IBOutlet weak var ArchieveCollectionView: UICollectionView!
    var notes: [NoteItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchNote()
        fetchNoteRealm()
        configureCollectionView()
        self.ArchieveCollectionView.reloadData()
    }
    
    func configureCollectionView() {
        
        width = (view.frame.width - 20)
        let layout = UICollectionViewFlowLayout()
        ArchieveCollectionView.collectionViewLayout = layout
        ArchieveCollectionView.delegate = self
        ArchieveCollectionView.dataSource = self
    }
    func fetchNote() {
        
        NetworkManager.shared.fetchNote(isArchived: true, completion: { notesArray in
            self.notes = notesArray
            self.ArchieveCollectionView.reloadData()
        })
        
        
    }
    func fetchNoteRealm(){
        RealmManager.shared.fetchNotes{ notesArray in
            self.notesRealm = notesArray.filter({$0.isArchieved == true})
            self.ArchieveCollectionView.reloadData()
        }
        // self.notesRealm = notesArray.filter({$0.reminderTime == nil})
        //print("\n\n@@@@@@@@@@@@@@@@@@@",self.notesRealm)
        //self.ArchieveCollectionView.reloadData()
    }
    @objc func onDeleteNote(_ sender: UIButton) {
        let deleteNote = notes[sender.tag]
        noteRealm = notesRealm[sender.tag]
        DatabaseManager.shared.deleteNote(deleteNote: deleteNote, note: noteRealm!)
        notes.remove(at: sender.tag)
        notesRealm.remove(at:sender.tag)
        ArchieveCollectionView.reloadData()
    }
    @objc func onArchievNote(_ sender: UIButton) {
        var noteModified = notes[sender.tag]
        var noteModifiedRealm = notesRealm[sender.tag]
        noteModified.isArchieved =  false
        let db = Firestore.firestore()
        db.collection("notes").document(noteModified.noteId!).updateData(["isArchieved":false])
        try! realmInstance.write({
            noteModifiedRealm.isArchieved = false
        })
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
    
}
extension ArchieveViewController :UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ArchieveCell?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aCell", for: indexPath) as? ArchieveCell
        cell?.label1.text = notes[indexPath.row].title
        cell?.label2.text = notes[indexPath.row].note
        cell?.onDelete.tag = indexPath.row
        cell?.onDelete.addTarget(self, action: #selector(onDeleteNote), for: .touchUpInside)
        cell?.onArchieve.tag = indexPath.row
        cell?.onArchieve.addTarget(self, action: #selector(onArchievNote), for: .touchUpInside)
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let UpdateNoteViewController = storyboard!.instantiateViewController(withIdentifier: "UpdateNoteViewController") as! UpdateNoteViewController
        UpdateNoteViewController.noteFirebase = notes[indexPath.row]
        let title = notes[indexPath.row].title
        let content = notes[indexPath.row].note
        let predict = NSPredicate.init(format: "%K == %@", "title",title)
        let predict2 = NSPredicate.init(format: "%K == %@", "note",content)
        let query = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [predict,predict2])
        let noteReal = realmInstance.objects(NoteItemRealm.self).filter(query)
        UpdateNoteViewController.noteRealm = noteReal.first
        UpdateNoteViewController.modalPresentationStyle = .fullScreen
        present(UpdateNoteViewController, animated: true, completion: nil)
    }
}


extension ArchieveViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: width, height : 100 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
}
