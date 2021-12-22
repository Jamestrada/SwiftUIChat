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
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
