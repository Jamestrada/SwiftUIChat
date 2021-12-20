//
//  RecentMessage.swift
//  SwiftUIChat
//
//  Created by James Estrada on 12/19/21.
//

import Foundation
import Firebase


struct RecentMessage: Codable, Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, fromId, toId, email, profileImageUrl: String
//    let timestamp: Timestamp
    
//    init(documentId: String, data: [String: Any]) {
//        self.documentId = documentId
//        self.text = data["text"] as? String ?? ""
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
//    }
}
