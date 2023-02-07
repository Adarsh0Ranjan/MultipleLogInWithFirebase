//
//  LogInViewModel.swift
//  MultiLogIn
//
//  Created by Roro Solutions on 02/02/23.
//

import Foundation
import Firebase
import SwiftUI
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    
    @Published var mobileNo:String = "91"
    @Published var otpCode: String = ""
    
    @Published var CLIENT_COODE: String = ""
    @Published var showOtpField: Bool = false
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    @Published  var nonce = ""
    @AppStorage("log_status") var log_status = false
    
    func  getOTPCode() {
//        UIApplication.shared.closeKeyboard()
        Task {
            do{
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                let code =  try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_COODE =  code
                    // enabling otp filed when its sucesss
                    withAnimation(.easeInOut){
                        showOtpField = true
                    }
                })
            }catch {
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode() {
//        UIApplication.shared.closeKeyboard()
        Task {
            do{
                let credentail =  PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_COODE, verificationCode: otpCode)
                
                try await  Auth.auth().signIn(with: credentail)
                
                // user logged in
                print("Success")
                await MainActor.run(body: {
                    withAnimation(.easeInOut){
                        log_status = true
                    }
                })
            }catch {
                await handleError(error: error)
            }
        }
    }
    
    func authenticateWithAppleId(credential: ASAuthorizationAppleIDCredential) {
        
        // getting token...
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        
        // Token String
        guard let tokenString =  String(data: token, encoding: .utf8) else {
            print("error with token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { [self] (result, err) in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            // User Successfully Loggen Into Firebase...
            print("Logged In Successfully")

            // Directing useer to home page
            withAnimation(.easeInOut){
                log_status = true
            }
        }
    }
    
//    func logGoogleUser(user: GIDGoogleUser) {
//        Task{
//            do{
//                guard let idToken = user.idToken else {return}
//                let accessToken = user.accessToken
//                let credentail = OAuthProvider.credential(withProviderID: idToken, accessToken: accessToken)
//                
//                try await Auth.auth().signIn(with: credentail)
//                
//                print("Sucess Google")
//                await MainActor.run(body: {
//                    withAnimation(.easeInOut){log_status = true}
//                })
//                
//            }catch{
//                await handleError(error: error)
//            }
//        }
//    }
//    
    func handleError(error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
   
}
func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}
// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

    

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
}
