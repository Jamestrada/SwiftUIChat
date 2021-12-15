//
//  FirebaseManager.swift
//  SwiftUIChat
//
//  Created by James Estrada on 11/27/21.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    
    let auth: 
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
}
