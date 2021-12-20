//
//  RecentMessage.swift
//  SwiftUIChat
//
//  Created by James Estrada on 12/19/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let text, fromId, toId, email, profileImageUrl: String
    let timestamp: Date
    
}
