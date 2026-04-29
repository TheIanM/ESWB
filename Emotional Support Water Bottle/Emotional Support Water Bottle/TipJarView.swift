//
//  TipJarView.swift
//  Emotional Support Water Bottle
//
//  Tip jar UI — support the indie dev!
//  Shows a grid of non-consumable IAP options at different price tiers.
//  The app is fully functional regardless of purchase.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var store = StoreManager.shared
    @State private var purchasedID: String?
    @State private var showingThankYou = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                header
                
                // Tip grid
                tipGrid
                
                // Restore button
                restoreButton
            }
            .padding()
        }
        .background(Color(red: 0.05, green: 0.07, blue: 0.09))
        .task {
            await store.loadProducts()
        }
        .alert("Thank you! 💧", isPresented: $showingThankYou) {
            Button("You're welcome!") {}
        } message: {
            if let id = purchasedID, let product = store.products.first(where: { $0.id == id }) {
                Text(store.thankYouMessage(for: product))
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("💧")
                .font(.system(size: 48))
            
            Text("Support the Dev")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("Every drop counts. Tips help keep this app free and ad-free for everyone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Tip Grid
    
    private var tipGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(store.products, id: \.id) { product in
                tipCard(for: product)
            }
        }
    }
    
    private func tipCard(for product: Product) -> some View {
        let isPurchased = store.purchasedProductIDs.contains(product.id)
        
        return Button {
            Task {
                if let transaction = await store.purchase(product) {
                    purchasedID = transaction.productID
                    showingThankYou = true
                }
            }
        } label: {
            VStack(spacing: 8) {
                Text(store.tierEmoji(for: product))
                    .font(.system(size: 32))
                
                Text(store.tierLabel(for: product))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                if isPurchased {
                    Text("Purchased ✓")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                } else {
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isPurchased ? 0.05 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isPurchased ? Color.cyan.opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .disabled(isPurchased || store.isLoading)
    }
    
    // MARK: - Restore
    
    private var restoreButton: some View {
        Button {
            Task {
                await store.restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

#Preview {
    TipJarView()
        .preferredColorScheme(.dark)
}
