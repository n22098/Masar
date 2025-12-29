import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // هذه الدالة هي الأهم. هي المسؤولة عن تهيئة "المشهد" أو النافذة.
        // بما أنك تستخدم Storyboard، فالنظام سيقوم بتهيئة الـ window تلقائياً هنا
        // طالما أنك لم تحذفه من إعدادات Info.plist.
        
        func scene(_ scene: UIScene,
                   willConnectTo session: UISceneSession,
                   options connectionOptions: UIScene.ConnectionOptions) {
            
            guard let _ = (scene as? UIWindowScene) else { return }
            
            func sceneDidDisconnect(_ scene: UIScene) {
                // يتم استدعاؤها عندما يتم تحرير المشهد من الذاكرة.
            }
            
            func sceneDidBecomeActive(_ scene: UIScene) {
                // يتم استدعاؤها عندما ينتقل المشهد إلى حالة النشاط (Active).
                // استخدم هذا لإعادة تشغيل المهام المتوقفة مؤقتاً (أو التي لم تبدأ بعد).
            }
            
            func sceneWillResignActive(_ scene: UIScene) {
                // يتم استدعاؤها عندما ينتقل المشهد من حالة النشاط إلى حالة السكون (مثلاً عند استقبال مكالمة).
            }
            
            func sceneWillEnterForeground(_ scene: UIScene) {
                // يتم استدعاؤها عندما ينتقل المشهد من الخلفية إلى المقدمة.
            }
            
            func sceneDidEnterBackground(_ scene: UIScene) {
                // يتم استدعاؤها عندما ينتقل المشهد إلى الخلفية.
                // استخدم هذا لحفظ البيانات وإطلاق سراح الموارد المشتركة.
            }
        }
    }
}
