//
//  ContentView.swift
//  SwiftUIChat
//
//  Created by James Estrada on 11/16/21.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3))
                        }
                    }
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }.padding(12)
                    .background(.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
//            print("Should log into Firebase with existing credentials")
        } else {
            createNewAccount()
//            print("Register a new account inside of Firebase Auth and then store image in Storage somehow...")
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to log in user:", error)
                self.loginStatusMessage = "Failed to log in user: \(error)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            self.didCompleteLoginProcess()
        }
    }
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user:", error)
                self.loginStatusMessage = "Failed to create user: \(error)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
//        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.loginStatusMessage = "Failed to push image to Storage: \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString ?? "")
                
                guard let url = url else {
                    return
                }
                self.storeUserInfo(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInfo(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { error in
                if let error = error {
                    print(error)
                    self.loginStatusMessage = "\(error)"
                    return
                }
                print("Success")
                
                self.didCompleteLoginProcess()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
            
        })
    }
}
