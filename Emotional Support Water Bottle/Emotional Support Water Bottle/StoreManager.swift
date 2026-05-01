//
//  StoreManager.swift
//  Emotional Support Water Bottle
//
//  Handles StoreKit 2 IAP for the tip jar.
//  Multiple non-consumable products at different price tiers.
//  The app is fully functional — tips just support the indie dev.
//

import StoreKit
import Foundation

@Observable
final class StoreManager {
    
    static let shared = StoreManager()
    
    /// All available tip products
    var products: [Product] = []
    
    /// Products the user has already purchased
    var purchasedProductIDs: Set<String> = []
    
    /// Whether the user has tipped (any purchase)
    var hasTipped: Bool { !purchasedProductIDs.isEmpty }
    
    /// Loading state
    var isLoading = true
    
    /// Transaction listener task
    private var transactionListener: Task<Void, Never>?
    
    // Product identifiers — must match StoreKit config / App Store Connect
    static let productIDs = [
        "com.eswb.tip.coffee",
        "com.eswb.tip.boba",
        "com.eswb.tip.lunch",
        "com.eswb.tip.dinner",
        "com.eswb.tip.fancyDinner",
        "com.eswb.tip.generous"
    ]
    
    private init() {
        // Listen for transactions (re-verified on launch, approved purchases, etc.)
        transactionListener = listenForTransactions()
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Load Products
    
    /// Fetch products from StoreKit
    func loadProducts() async {
        isLoading = true
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            products = storeProducts.sorted { $0.price < $1.price }
            #if DEBUG
            print("[StoreManager] Loaded \(products.count) products")
            #endif
        } catch {
            #if DEBUG
            print("[StoreManager] Failed to load products: \(error)")
            #endif
        }
        
        // Check existing purchases
        await updatePurchasedProducts()
        isLoading = false
    }
    
    // MARK: - Purchase
    
    /// Purchase a tip product
    func purchase(_ product: Product) async -> StoreKit.Transaction? {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Deliver the product (update state)
                purchasedProductIDs.insert(transaction.productID)
                
                // Finish the transaction
                await transaction.finish()
                
                #if DEBUG
                print("[StoreManager] Purchased: \(transaction.productID)")
                #endif
                return transaction
                
            case .userCancelled:
                #if DEBUG
                print("[StoreManager] Purchase cancelled")
                #endif
                return nil
                
            case .pending:
                // Transaction requires approval (e.g. Ask to Buy)
                #if DEBUG
                print("[StoreManager] Purchase pending")
                #endif
                return nil
                
            @unknown default:
                return nil
            }
        } catch {
            #if DEBUG
            print("[StoreManager] Purchase failed: \(error)")
            #endif
            return nil
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transactions that complete outside the app (restores, family sharing, etc.)
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self else { return }
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                } catch {
                    #if DEBUG
                    print("[StoreManager] Transaction listener error: \(error)")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Verification
    
    /// Verify a transaction's signature
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Restore
    
    /// Restore previous purchases
    func restorePurchases() async {
        await updatePurchasedProducts()
        #if DEBUG
        print("[StoreManager] Restored purchases: \(purchasedProductIDs)")
        #endif
    }
    
    /// Check all previous transactions
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    // MARK: - Helpers
    
    /// Friendly display name for a price tier
    func tierLabel(for product: Product) -> String {
        switch product.id {
        case "com.eswb.tip.coffee":       return "Buy me a coffee"
        case "com.eswb.tip.boba":          return "Buy me a boba"
        case "com.eswb.tip.lunch":         return "Buy me lunch"
        case "com.eswb.tip.dinner":        return "Buy me dinner"
        case "com.eswb.tip.fancyDinner":   return "Fancy dinner"
        case "com.eswb.tip.generous":      return "You're a legend"
        default:                           return "Tip"
        }
    }
    
    /// Emoji for each tier
    func tierEmoji(for product: Product) -> String {
        switch product.id {
        case "com.eswb.tip.coffee":       return "☕️"
        case "com.eswb.tip.boba":          return "🧋"
        case "com.eswb.tip.lunch":         return "🥪"
        case "com.eswb.tip.dinner":        return "🍽️"
        case "com.eswb.tip.fancyDinner":   return "🥩"
        case "com.eswb.tip.generous":      return "💎"
        default:                           return "💧"
        }
    }
    
    /// Thank you message after purchase
    func thankYouMessage(for product: Product) -> String {
        switch product.id {
        case "com.eswb.tip.coffee":       return "Thanks for the coffee! ☕️"
        case "com.eswb.tip.boba":          return "Boba is my favorite! 🧋"
        case "com.eswb.tip.lunch":         return "Lunch is on you! 🥪"
        case "com.eswb.tip.dinner":        return "Dinner too?! You're the best! 🍽️"
        case "com.eswb.tip.fancyDinner":   return "Fancy! I'm speechless 🥩"
        case "com.eswb.tip.generous":      return "You're a legend. Thank you! 💎"
        default:                           return "Thank you for your support! 💧"
        }
    }
}

// MARK: - Errors

enum StoreError: Error {
    case failedVerification
}
