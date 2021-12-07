//
//  ChatLogView.swift
//  SwiftUIChat
//
//  Created by James Estrada on 12/5/21.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    @State var chatText = ""
    
    var body: some View {
        messagesView
//        ZStack {
//
//            VStack(spacing: 0) {
//                Spacer()
//                chatBottomBar
//                    .background(.white)
//            }
//        }
        .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("messages wil go here")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack{
                Spacer()
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
            TextField("Description", text: $chatText)
            Button {
                
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

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid": "dIykUtorR8Oo2nrO5ejZd4gbJaJ3", "email": "waterfall@gmail.com"]))
        }
    }
}
