//
//  DiscoverFrontCardListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 21/03/26.
//

import SwiftUI

struct DiscoverFrontCardListView: View {
    @State var coffeeShop: [DiscoverCoffeeShopItem] = []
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text("Coffio Popular's")
                .font(.title2)
                .bold()
                .padding(.horizontal, 20.0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12.0) {
                    ForEach(coffeeShop, id: \.id) { coffeeShop in
                        DiscoverFrontCardView(dataModel: coffeeShop)
                    }
                }
                .padding(.horizontal, 20.0)
            }
        }
        .task {
            let fetcher = CoffeeShopFetcher()
            do {
                let response: [DiscoverCoffeeShopItem] = try await fetcher.fetchCoffeeShop()
                coffeeShop = response
                
                print("[Coffe Shop Fetcher]: \(response)")
            }
            catch {
                print("[Coffe Shop Fetcher]: \(error)")
            }
        }
    }
}

#Preview {
    DiscoverFrontCardListView()
}
