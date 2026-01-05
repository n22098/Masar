import Foundation

class PermissionManager {
    
    static let shared = PermissionManager()
    
    private init() {}
    
    /// Check if current user can access a specific feature
    func canAccess(feature: Permission, user: AppUser) -> Bool {
        guard let provider = user.providerProfile else {
            return false
        }
        
        return provider.permissions.contains(feature)
    }
    
    /// Get all available features for user
    func getAvailableFeatures(for user: AppUser) -> [Permission] {
        guard let provider = user.providerProfile else {
            return []
        }
        
        return provider.permissions
    }
    
    /// Check if user has any provider permissions
    func hasProviderAccess(user: AppUser) -> Bool {
        return user.isProvider
    }
}
