//
//  ProfileViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 01/11/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import Photos
class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var imagePickerController = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture()
        profileDetails()
        imagePickerController.delegate = self
        checkPermission()
    }
    
    func profilePicture(){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        print(userId)
        let ref = storageRef.child(userId)
        ref.getData(maxSize: 5*1024*1024) { data, error in
            let image = UIImage(data: data!)
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
    }
    
    @IBAction func onPick(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true,completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func profileDetails(){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        var firstname = ""
        var lastname = ""
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { snapshot, error in
            for document in (snapshot?.documents)! {
                print(document.data())
                let data = document.data()
                firstname = data["firstname"] as? String ?? ""
                lastname = data["lastname"] as? String ?? ""
            }
            self.label1.text = firstname
            self.label2.text = lastname
        }
    }
    
    func checkPermission() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({(status:
                                                    PHAuthorizationStatus)->Void in ()
            })
        }
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        }else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status:PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("have access")
        }else{
            print("no access")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            print(url)
            uploadImage(fileURL: url)
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(fileURL:URL){
        let userId = Auth.auth().currentUser?.uid
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let localFile = fileURL
        let photoRef = storageRef.child(userId!)
        let upload = photoRef.putFile(from: localFile,metadata: nil){(metadata,err) in
            guard let metadata = metadata else {
                return
            }
            print("photo uploaded")
            self.profilePicture()
        }
    }
    
}
