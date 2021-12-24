//
//  ChatLogView.swift
//  SwiftUIChat
//
//  Created by James Estrada on 12/5/21.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = chatUser?.uid else {
            return
        }
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(cm)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
                
//                This fetches all messages every time a message is sent
//                querySnapshot?.documents.forEach({ queryDocumentSnapshot in
//                    let data = queryDocumentSnapshot.data()
//                    let docId = queryDocumentSnapshot.documentID
//                    let chatMessage = ChatMessage(documentId: docId, data: data)
//                    self.chatMessages.append(chatMessage)
//                })
            }
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = chatUser?.uid else {
            return
        }
        
        let document = FirebaseManager.shared.firestore
                        .collection("messages")
                        .document(fromId)
                        .collection(toId)
                        .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save mesage into Firestore: \(error)"
                return
            }
            print("Succesfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
                        .collection("messages")
                        .document(toId)
                        .collection(fromId)
                        .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save mesage into Firestore: \(error)"
                return
            }
            print("Succesfully saved recipient received message")
        }
    }
    
    private func persistRecentMessage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid,
                let toId = self.chatUser?.uid,
                let chatUser = chatUser else {
            return
        }
        
        
        // sender
        let documentSender = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let dataSender = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        documentSender.setData(dataSender) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        // recipient
        let documentRecipient = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(uid)
        
        let dataRecipient = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        documentRecipient.setData(dataRecipient) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    
    @Published  var count = 0
}

struct ChatLogView: View {
    
//    let chatUser: ChatUser?
//
//    init(chatUser: ChatUser?) {
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//    }
    
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                vm.firestoreListener?.remove()
            }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack{
                        Spacer()
                    }
                    .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(
                    Color(.systemBackground)
                    .ignoresSafeArea()
                )
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.blue)
            .cornerRadius(4)

        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView {
//            ChatLogView(chatUser: .init(data: ["uid": "dIykUtorR8Oo2nrO5ejZd4gbJaJ3", "email": "waterfall@gmail.com"]))
//        }
        MainMessagesView()
    }
}
