//
//  ChatMessage.swift
//  SwiftUIChat
//
//  Created by James Estrada on 12/21/21.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
