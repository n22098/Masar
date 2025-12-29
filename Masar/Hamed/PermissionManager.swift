import Foundation

class PermissionManager {
    
    static let shared = PermissionManager()
    
    private init() {}
    
    /// Check if current user can access a specific feature
    func canAccess(feature: Permission, user: User) -> Bool {
        guard let provider = user.providerProfile else {
            return false
        }
        
        return provider.permissions.contains(feature)
    }
    
    /// Get all available features for user
    func getAvailableFeatures(for user: User) -> [Permission] {
        guard let provider = user.providerProfile else {
            return []
        }
        
        return provider.permissions
    }
    
    /// Check if user has any provider permissions
    func hasProviderAccess(user: User) -> Bool {
        return user.isProvider
    }
}
