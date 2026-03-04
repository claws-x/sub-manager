//
//  ContentView.swift
//  SubManager
//
//  Created by AIagent on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SubscriptionsView()
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("订阅")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("统计")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#4ECDC4"))
    }
}

struct SubscriptionsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("活跃订阅")) {
                    SubscriptionRow(name: "Netflix", price: "$15.99", period: "月", color: "#E50914")
                    SubscriptionRow(name: "Spotify", price: "$9.99", period: "月", color: "#1DB954")
                }
            }
            .navigationTitle("订阅")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct SubscriptionRow: View {
    let name: String
    let price: String
    let period: String
    let color: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                Text("\(price)/\(period)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StatisticsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                StatCard(title: "月度支出", value: "$25.98", color: "#4ECDC4")
                StatCard(title: "年度支出", value: "$311.76", color: "#FF6B6B")
                StatCard(title: "订阅数量", value: "2", color: "#FFE66D")
                
                Spacer()
            }
            .padding()
            .navigationTitle("统计")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
