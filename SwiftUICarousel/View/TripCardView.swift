//
//  TripCardView.swift
//  Whats On Melbourne
//
//  Created by Handy Hasan on 24/9/2022.
//

import SwiftUI

struct TripCardView: View {
    let destination: String
    let imageName: String
    
    @Binding var isShowDetails: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                AsyncImage(url: URL(string: imageName))
                { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(self.isShowDetails ? 0 : 15)
                        .overlay(
                            Text(self.destination)
                               
                                .fontWeight(.heavy)
                                .padding(10)
                            
                                .padding([.bottom, .leading])
                                .opacity(self.isShowDetails ? 0.0 : 1.0)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
                        )
                } placeholder: {
                    Color.purple.opacity(0.1)
                }
                   
            }
            
        }
    }
}

struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        TripCardView(destination: "London", imageName: "london", isShowDetails: .constant(false))
    }
}
