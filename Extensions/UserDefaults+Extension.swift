import Foundation

extension UserDefaults {
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let authToken = "authToken"
        static let lastLoginDate = "lastLoginDate"
    }
    
    var isLoggedIn: Bool {
        get { bool(forKey: Keys.isLoggedIn) }
        set { set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    var authToken: String? {
        get { string(forKey: Keys.authToken) }
        set { set(newValue, forKey: Keys.authToken) }
    }
    
    var lastLoginDate: Date? {
        get { object(forKey: Keys.lastLoginDate) as? Date }
        set { set(newValue, forKey: Keys.lastLoginDate) }
    }
    
    func clearAuthData() {
        removeObject(forKey: Keys.isLoggedIn)
        removeObject(forKey: Keys.authToken)
        removeObject(forKey: Keys.lastLoginDate)
    }
} 