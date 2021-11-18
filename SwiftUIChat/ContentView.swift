//
//  ContentView.swift
//  SwiftUIChat
//
//  Created by James Estrada on 11/16/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var isLoginMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Picker(selection: $isLoginMode, label: Text("Picker here")) {
                    Text("Login")
                        .tag(true)
                    Text("Create Account")
                        .tag(false)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                
                Text("Here is my creation account page")
            }
            .navigationTitle("Create Account")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
