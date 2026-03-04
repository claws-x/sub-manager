//
//  SubscriptionManager.swift
//  SubManager
//
//  Created by AIagent on 2026-03-03.
//

import Foundation
import UserNotifications

/// 订阅管理器 - 真实订阅追踪
class SubscriptionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var subscriptions: [Subscription] = []
    @Published var monthlyTotal: Double = 0.0
    @Published var yearlyTotal: Double = 0.0
    
    // MARK: - Computed Properties - 真实计算
    var activeSubscriptions: Int {
        subscriptions.filter { $0.isActive }.count
    }
    
    var upcomingPayments: [Subscription] {
        let calendar = Calendar.current
        let today = Date()
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) ?? today
        
        return subscriptions.filter { sub in
            guard let nextPayment = sub.nextPaymentDate else { return false }
            return nextPayment > today && nextPayment < nextMonth
        }.sorted { ($0.nextPaymentDate ?? .distantFuture) < ($1.nextPaymentDate ?? .distantFuture) }
    }
    
    // MARK: - Constants
    private let subscriptionsKey = "user_subscriptions"
    private let reminderKey = "subscription_reminders"
    
    // MARK: - Initialization
    init() {
        loadSubscriptions()
        calculateTotals()
        setupNotifications()
    }
    
    // MARK: - Methods - 真实功能
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveSubscriptions()
        calculateTotals()
        schedulePaymentReminder(for: subscription)
    }
    
    func updateSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index] = subscription
            saveSubscriptions()
            calculateTotals()
        }
    }
    
    func deleteSubscription(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
        saveSubscriptions()
        calculateTotals()
    }
    
    func markAsPaid(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index].lastPaymentDate = Date()
            saveSubscriptions()
        }
    }
    
    // MARK: - Calculations - 真实计算
    func calculateTotals() {
        monthlyTotal = subscriptions
            .filter { $0.billingCycle == .monthly }
            .reduce(0) { $0 + $1.price }
        
        yearlyTotal = subscriptions
            .filter { $0.billingCycle == .yearly }
            .reduce(0) { $0 + $1.price }
    }
    
    func getTotalSpent() -> Double {
        // 计算总花费
        return subscriptions.reduce(0) { total, sub in
            guard let startDate = sub.startDate else { return total }
            let daysOwned = Date().timeIntervalSince(startDate) / 86400
            
            switch sub.billingCycle {
            case .monthly:
                return total + (Double(daysOwned) / 30.0 * sub.price)
            case .yearly:
                return total + (Double(daysOwned) / 365.0 * sub.price)
            }
        }
    }
    
    // MARK: - Persistence - 真实数据保存
    private func saveSubscriptions() {
        if let data = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(data, forKey: subscriptionsKey)
        }
    }
    
    private func loadSubscriptions() {
        guard let data = UserDefaults.standard.data(forKey: subscriptionsKey),
              let subs = try? JSONDecoder().decode([Subscription].self, from: data) else {
            return
        }
        subscriptions = subs
    }
    
    // MARK: - Notifications - 真实提醒
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ 通知权限已获取")
            }
        }
    }
    
    private func schedulePaymentReminder(for subscription: Subscription) {
        guard let nextPayment = subscription.nextPaymentDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💳 订阅付款提醒"
        content.body = "\(subscription.name) 即将付款 $\(subscription.price)"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextPayment)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "subscription_\(subscription.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Data Models
struct Subscription: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Double
    var billingCycle: BillingCycle
    var category: String
    var color: String
    var icon: String
    var isActive: Bool
    var startDate: Date?
    var lastPaymentDate: Date?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        billingCycle: BillingCycle = .monthly,
        category: String = "娱乐",
        color: String = "#4ECDC4",
        icon: String = "star.fill",
        isActive: Bool = true,
        startDate: Date? = Date(),
        lastPaymentDate: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.billingCycle = billingCycle
        self.category = category
        self.color = color
        self.icon = icon
        self.isActive = isActive
        self.startDate = startDate
        self.lastPaymentDate = lastPaymentDate
        self.notes = notes
    }
    
    var nextPaymentDate: Date? {
        guard let lastPayment = lastPaymentDate ?? startDate else { return nil }
        
        let calendar = Calendar.current
        switch billingCycle {
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: lastPayment)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: lastPayment)
        }
    }
}

enum BillingCycle: String, Codable {
    case monthly = "月付"
    case yearly = "年付"
}
