//
//  HomeView.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Foundation

import Combine
import SwiftUI

@MainActor
class HomeModel: ObservableObject {
    @Published var historyList: [ChatHistoryModel] = [
        ChatHistoryModel(topic_id: "1", topic_name: "1号房间"),
        ChatHistoryModel(topic_id: "2", topic_name: "2号房间"),
        ChatHistoryModel(topic_id: "3", topic_name: "3号房间"),
    ]

    @Published var isSidebarShowing = false

    @Published var currentTopic: ChatHistoryModel? = ChatHistoryModel(topic_id: "1", topic_name: "1号房间")
}

// 主界面：GPT对话+侧边栏弹窗
struct HomeView: View {
    @StateObject var model = HomeModel()

    var body: some View {
        ZStack(alignment: .leading) { // 侧边栏从左侧滑出，用leading对齐
            // 1. 主对话界面（你的GPT核心界面）
            ChatView(homeModel: model)

            // 2. 半透明遮罩（侧边栏显示时出现，点击可关闭）
            if model.isSidebarShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        model.isSidebarShowing = false // 点击遮罩关闭侧边栏
                    }
            }

            // 3. 侧边栏弹窗（核心）
            HomeSideView(model: model)
                .frame(width: 280) // 侧边栏宽度（可自定义）
                .background(Color.white)
                .cornerRadius(10) // 圆角美化
                .shadow(radius: 5) // 阴影效果
                // 核心动画：滑出/滑入
                .offset(x: model.isSidebarShowing ? 0 : -280) // 隐藏时向左偏移整个宽度
                .animation(.easeInOut(duration: 0.3), value: model.isSidebarShowing) // 平滑动画
                .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView()
}
