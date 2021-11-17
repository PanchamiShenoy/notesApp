
import Foundation
import RealmSwift

struct DatabaseManager {
    static let shared = DatabaseManager()
    
    func updateNote(note:NoteItem , realmNote:NoteItemRealm,title:String,content:String)
    {
        NetworkManager.shared.updateNote(note)
        RealmManager.shared.updateNote(title, content,realmNote)
    }
    
    func addNote(note:[String:Any],realmNote:NoteItemRealm)
    {
        NetworkManager.shared.addNote(note: note)
        RealmManager.shared.addNote(note: realmNote)
    }
    
    func deleteNote(deleteNote:NoteItem,note:NoteItemRealm){
        NetworkManager.shared.deleteNote(deleteNote)
        RealmManager.shared.deleteNote(note: note)
    }
    
}
