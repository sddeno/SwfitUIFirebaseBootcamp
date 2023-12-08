//
//  SettingsView.swift
//  SwfitUIFirebaseBootcamp
//
//  Created by Shubham Deshmukh on 15/05/23.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil

    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProvider(){
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticationUser()
    }
    // link google account, fb, apple, email methiods will bring from manager and access it in view below
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticationUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // create custom error not his
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    
    func updateEmail() async throws {
        
        let email = "changedEmail@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        
        let password = "hello123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResults = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.authUser = authDataResults
        
    }
    
    func linkEmailAccount() async throws {
       let email = "linkdingAllLogin@gmail.com"
        let password = "bingo123"
        let authDataResults = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        self.authUser = authDataResults
        
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                
                Task{
                    do {
                        try viewModel.logOut()
                        showSignInView = true
                    } catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
            
            Button(role: .destructive) {
                Task{
                    do{
                        try await viewModel.deleteAccount()
                        print("Account deleted")
                        showSignInView = true
                    }catch {
                        print("error deleting account \(error)")
                    }
                }
            } label: {
                Text("Delete Account")
            }

            
            if viewModel.authProviders.contains(.email){
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
            
        }
        .onAppear{
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}


extension SettingsView {
    
    private var emailSection: some View {
        Section {
            
            Button("Reset password") {
                
                Task{
                    do {
                        try await viewModel.resetPassword()
                        print("Reset password :::")
                    }catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
            
            
            Button("Update password") {
                
                Task{
                    do {
                        try await viewModel.updatePassword()
                        print("Update password :::")
                    }catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
            Button("Update email") {
                
                Task{
                    do {
                        try await viewModel.updateEmail()
                        print("Update password :::")
                    }catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
        } header: {
            Text("Email Functions ")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            
            Button("Link Email Account") {
                
                Task{
                    do {
                        try await viewModel.linkEmailAccount()
                        print("Linking email Done")
                    }catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
            
            
            Button("Link Google Account") {
                
                Task{
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("link google account Done ")
                    }catch {
                        print("Error : \(error.localizedDescription)")
                    }
                }
            }
            
        } header: {
            Text("Create account")
        }
    }
}

