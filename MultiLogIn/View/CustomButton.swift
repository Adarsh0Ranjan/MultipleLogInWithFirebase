//
//  CustomButton.swift
//  MultiLogIn
//
//  Created by Roro Solutions on 03/02/23.
//

import SwiftUI

struct CustomButton: View {
    var isGoogle: Bool 
    var body: some View {
        HStack{
            Group{
                if isGoogle{
                    Image("Google")
                        .resizable()
                }else{
                    Image("Apple")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 35,height: 35)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign In")
                .font(.callout)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

//struct CustomButton_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomButton()
//    }
//}
