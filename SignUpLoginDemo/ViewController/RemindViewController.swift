//
//  RemindViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 09/11/21.
//


import UIKit
import RealmSwift
import FirebaseFirestore

class RemindViewController: UIViewController {
    var width: CGFloat = 0
    var noteRealm : NoteItemRealm?
    @IBOutlet weak var reminderCollectionView: UICollectionView!
    var notesRealm : [NoteItemRealm] = []
    let realmInstance = try! Realm()
    var notes: [NoteItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchNote()
        fetchNoteRealm()
        configureCollectionView()
        self.reminderCollectionView.reloadData()
    }
    
    func configureCollectionView() {
        
        width = (view.frame.width - 20)
        let layout = UICollectionViewFlowLayout()
        reminderCollectionView.collectionViewLayout = layout
        reminderCollectionView.delegate = self
        reminderCollectionView.dataSource = self
    }
    func fetchNote() {
        
        NetworkManager.shared.resultType { result in
            switch result {
                
            case .success(let notes):
                self.notes = notes.filter({$0.reminderTime != nil})
                print("\n\n@@@@@@@@@@@@@@@@@",self.notes)
                
                
            case .failure(let error):
                self.showAlert(title: "Error while Fetching Notes", message: error.localizedDescription)
            }
        }
        
    }
    func fetchNoteRealm(){
        RealmManager.shared.fetchNotes{ notesArray in
            self.notesRealm = notesArray.filter({$0.reminderTime != nil})
            print("\n\n@@@@@@@@@@@@@@@@@",self.notesRealm)
        }
    }
    @objc func onDeleteNote(_ sender: UIButton) {
        let deleteNote = notes[sender.tag]
        noteRealm = notesRealm[sender.tag]
        DatabaseManager.shared.deleteNote(deleteNote:deleteNote, note: noteRealm!)
        notes.remove(at: sender.tag)
        notesRealm.remove(at:sender.tag)
        reminderCollectionView.reloadData()
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
    
}
extension RemindViewController :UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notesRealm.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ReminderCollectionViewCell?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "remindCell", for: indexPath) as? ReminderCollectionViewCell
        let note = notesRealm[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY hh:mm a"
        let reminderDate = note.reminderTime
        
        cell?.label1.text = notesRealm[indexPath.row].title
        cell?.label2.text = notesRealm[indexPath.row].note
        cell?.label3.text = dateFormatter.string(from: reminderDate ?? Date())
        
        cell?.onDelete.tag = indexPath.row
        cell?.onDelete.addTarget(self, action: #selector(onDeleteNote), for: .touchUpInside)
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


extension RemindViewController: UICollectionViewDelegateFlowLayout {
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: width, height : 100 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
}

