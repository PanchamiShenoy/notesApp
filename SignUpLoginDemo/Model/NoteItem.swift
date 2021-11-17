//
//  NoteItem.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 28/10/21.
//

import Foundation
import FirebaseFirestore

struct NoteItem {
    var noteId :String?
    var title: String
    var note: String
    var uid: String
    var date: Date
    var isArchieved :Bool
    var reminderTime : Date?
    
    var dictionary: [String: Any] {
            return [
                "title": title,
                "note": note,
                "uid": uid,
                "isArchieved": isArchieved,
                "timestamp": date,
                "reminderTime": reminderTime
            ]
        }
}

