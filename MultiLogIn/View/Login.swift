//
//  Login.swift
//  MultiLogIn
//
//  Created by Roro Solutions on 02/02/23.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import Firebase


struct Login: View {
    @StateObject var viewModel: LoginViewModel = .init()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15){
                Image(systemName: "triangle")
                    .font(.system(size: 38))
                    .foregroundColor(.indigo)
                
                (Text("Welcome,")
                    .foregroundColor(.black) +
                Text("\nLogin to continue")
                    .foregroundColor(.gray)
                 )
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.top,20)
                .padding(.trailing, 15)
                
                CustomTextField(hint: "+91 7632968907", text: $viewModel.mobileNo)
                    .disabled(viewModel.showOtpField)
                    .opacity(viewModel.showOtpField ? 0.4 : 1)
                    .overlay(alignment: .trailing,content: {
                        // change button apears to edit phone number
                        Button("Change"){
                            withAnimation(.easeInOut){
                                viewModel.showOtpField = false
                                viewModel.otpCode = ""
                                viewModel.CLIENT_COODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        .opacity(viewModel.showOtpField ? 1 : 0)
                        .padding(.trailing, 15)
                    })
                    .padding(.top,50)
                
                CustomTextField(hint: "OTP Code", text: $viewModel.otpCode)
                    .disabled(!viewModel.showOtpField)
                    .opacity(!viewModel.showOtpField ? 0.4 : 1)
                    .padding(.top,30)
                
                Button(action: viewModel.showOtpField ? viewModel.verifyOTPCode: viewModel.getOTPCode) {
                    HStack(spacing: 15) {
                        Text(viewModel.showOtpField ? "verify Code" : "Get Code")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                        
                        Image(systemName: "line.diagonal.arrow")
                            .font(.title3)
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,25)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black.opacity(0.05))
                    }
                }
                .padding(.top,30)
                
                Text("(OR)")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top,30)
                    .padding(.bottom,20)
                    .padding(.leading,-60)
                    .padding(.horizontal)
                
                
                HStack(spacing: 8) {
                    
                    // sign with apple id custom button
                        CustomButton(isGoogle: false)
                    .overlay{
                        
                        // sign in with apple id
                        SignInWithAppleButton { request in
                            
                            // requesting parameter from apple login
                            viewModel.nonce = randomNonceString()
                            request.requestedScopes = [.email,.fullName]
                            request.nonce = sha256(viewModel.nonce)
                            
                        } onCompletion: { result in
                            
                            // getting error or sucecess
                            switch result {
                            case .success(let user):
                                print("success")
                                // do login with firebase
                                guard let credential = user.credential as?
                                        ASAuthorizationAppleIDCredential else {
                                    print("error with fireabse")
                                    return
                                }
                                viewModel.authenticateWithAppleId(credential: credential)
                            case .failure(let err):
                                print(err.localizedDescription)
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 55)
                        .blendMode(.overlay)
                        
                    }
                    .clipped()
/* this part is for google signin which is in  pending for now
 
                    CustomButton(isGoogle: true)
                        .overlay {
                            if (FirebaseApp.app()?.options.clientID) != nil{
                                GoogleSignInButton {
                                    GIDSignIn.sharedInstance.signIn(withPresenting: rootController()) { user, error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }

                                        // logging google user into firebase
                                    }
                                }
                            }
                        }
                        .clipped()
                    
                    GoogleSignInButton{
                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

                        // Create Google Sign In configuration object.
                        let config = GIDConfiguration(clientID: clientID)

                        // Start the sign in flow!
                        GIDSignIn.sharedInstance.signIn(withPresenting: rootController())
                        GIDSignIn.sharedInstance.signIn(withPresenting: rootController()) {  user, error in

                          if let error = error {
                            // ...
                            return
                          }

                          guard
                            let authentication = user.,
                            let idToken = authentication.idToken
                          else {
                            return
                          }

                          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                         accessToken: authentication.accessToken)

                          // ...
                        }
                    }
 */
                }
                .padding(.leading,-60)
                .frame(maxWidth: .infinity)
            }
            .padding(.leading,60)
            .padding(.vertical,15)
        }
        .alert(viewModel.errorMessage,isPresented: $viewModel.showError) {
            //
        }
        // simple sheet to confirm log in
        .sheet(isPresented: viewModel.$log_status){
            UserLoggedIn()
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
