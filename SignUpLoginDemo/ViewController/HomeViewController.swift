//
//  HomeViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 18/10/21.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FirebaseFirestore
import RealmSwift

class HomeViewController: UIViewController {
    
    //MARK :- Properties
    
    var noteRealm : NoteItemRealm?
    var searching = false
    var delegate :MenuDelegate?
    let realmInstance = try! Realm()
    var filteredNotes : [NoteItem] = []
    var notes: [NoteItem] = []
    var notesRealm : [NoteItemRealm] = []
    var flag = true
    var toggleButton = UIBarButtonItem()
    var width: CGFloat = 0
    @IBOutlet weak var NoteCollectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    let x = Auth.auth().currentUser?.uid
    let searchController = UISearchController(searchResultsController: nil)
    var hasMoreNotes = true
    var listView = false
    
    //MARK :- Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "not found")
        navigationItem.searchController = searchController
        if AccessToken.current?.tokenString == nil{
            
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user == nil {
                    let status = NetworkManager.shared.checkSignIn()
                    if(status == false){
                        self.transitionToLogin()
                    }
                }
            }
        }
        
        configureNavigation()
        configureCollectionView()
        configureSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "not found")
        fetchNoteRealm()
        fetchNote()
        configureCollectionView()
        hasMoreNotes = true
    }
    
    //MARK :- Actions
    
    @IBAction func onLogOut(_ sender: Any) {
        
        do {
            NetworkManager.shared.signout()
            NetworkManager.shared.googleSignOut()
            LoginManager.init().logOut()
            transitionToLogin()
        }
    }
    
    @objc func toggleButtonTapped(){
        if !flag {
            flag = !flag
            width = (view.frame.width - 20)
            toggleButton.image = UIImage(systemName: "rectangle.grid.1x2.fill")
            
        }else {
            
            flag = !flag
            width = (view.frame.width - 20) / 2
            toggleButton.image = UIImage(systemName: "rectangle.split.2x1.fill")
            
        }
        NoteCollectionView.reloadData()
    }
    
    @objc func handleMenu() {
        
        delegate?.menuHandler()
        
    }
    
    @objc func addNote() {
        
        let addNoteController = storyboard?.instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
        addNoteController.modalPresentationStyle = .fullScreen
        present(addNoteController,animated: true,completion: nil)
    }
    
    @objc func onDeleteNote(_ sender: UIButton) {
        let deleteNote = notes[sender.tag]
        noteRealm = notesRealm[sender.tag]
        DatabaseManager.shared.deleteNote(deleteNote: deleteNote, note: noteRealm!)
        notes.remove(at: sender.tag)
        notesRealm.remove(at:sender.tag)
        NoteCollectionView.reloadData()
    }
    
    //MARK :- Helper
    
    func configureSearchBar(){
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
    }
    
    func configureCollectionView() {
        
        width = (view.frame.width - 20)
        let layout = UICollectionViewFlowLayout()
        NoteCollectionView.collectionViewLayout = layout
        NoteCollectionView.delegate = self
        NoteCollectionView.dataSource = self
    }
    
    func transitionToLogin() {
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "SigninVC")
        
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
    
    func configureNavigation() {
        self.navigationItem.title = "Home Page"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(handleMenu))
        let toggleButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2.fill"), style: .done, target: self, action: #selector(toggleButtonTapped))
        let addButton = UIBarButtonItem(image :UIImage(systemName: "square.and.pencil") ,style:.plain,target:self,action:#selector(addNote))
        navigationItem.rightBarButtonItems = [addButton,toggleButton]
        
    }
    
    func updateUI(notes: [NoteItem]) {
        self.notes = notes
        if notes.count < 7 {
            self.hasMoreNotes = false
        }
        DispatchQueue.main.async {
            self.NoteCollectionView.reloadData()
        }
    }
    
    func fetchNote() {
        
        NetworkManager.shared.resultType { result in
            switch result {
                
            case .success(let notes):
                self.updateUI(notes: notes)
                self.notes = notes.filter({$0.isArchieved == false})
                
            case .failure(let error):
                self.showAlert(title: "Error while Fetching Notes", message: error.localizedDescription)
            }
        }
        
        NoteCollectionView.reloadData()
    }
    
    func fetchNoteRealm(){
        RealmManager.shared.fetchNotes{ notesArray in
            self.notesRealm = notesArray.filter({$0.isArchieved == false})
        }
    }
    
    @objc func onArchieve(_ sender: UIButton){
        
        var noteModified = notes[sender.tag]
        var noteModifiedRealm = notesRealm[sender.tag]
        noteModified.isArchieved =  true
        let db = Firestore.firestore()
        db.collection("notes").document(noteModified.noteId!).updateData(["isArchieved":true])
        try! realmInstance.write({
            noteModifiedRealm.isArchieved = true
        })
        // NoteCollectionView.reloadData()
        
        
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension HomeViewController :UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = searching ? filteredNotes.count : notes.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : NoteCell?
        if indexPath.row == notes.count - 1 && hasMoreNotes{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as? NoteCell
            cell?.activityIndicator.startAnimating()
            return cell!
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as? NoteCell
        }
        if searching{
            
            cell?.note = filteredNotes[indexPath.row]
            
        }
        else{
            cell?.note = notes[indexPath.row]
        }
        
        cell?.deleteButton.tag = indexPath.row
        cell?.deleteButton.addTarget(self, action: #selector(onDeleteNote), for: .touchUpInside)
        cell?.onArchiev.tag = indexPath.row
        cell?.onArchiev.addTarget(self, action: #selector(onArchieve), for: .touchUpInside)
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

//MARK: UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: width, height : 100 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
}

//MARK: UISearchResultsUpdating,UISearchBarDelegate

extension HomeViewController:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        let count = searchController.searchBar.text?.count
        let searchText = searchController.searchBar.text!
        if !searchText.isEmpty {
            searching = true
            filteredNotes.removeAll()
            filteredNotes = notes.filter({$0.title.prefix(count!).lowercased() == searchText.lowercased()})
        }
        else{
            searching = false
            filteredNotes.removeAll()
            filteredNotes = notes
        }
        NoteCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        filteredNotes.removeAll()
        NoteCollectionView.reloadData()
    }
    
}

//MARK: UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > NoteCollectionView.contentSize.height-scrollView.frame.size.height-100{
            guard hasMoreNotes else { return}
            guard !fetchingMoreNotes else {
                print("\nfetching")
                return
                
            }
            NetworkManager.shared.fetchMoreNotes { notes in
                if notes.count < 7{
                    self.hasMoreNotes = false
                }
                self.notes.append(contentsOf: notes)
                self.NoteCollectionView.reloadData()
            }
            
        }
    }
}
