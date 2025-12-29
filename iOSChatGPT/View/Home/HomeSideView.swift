//
//  HomeSideView.swift
//  iOSChatGPT
//
//  Created by 郝学智 on 2025/12/26.
//

import Foundation
import SwiftUI

struct HomeSideView: View {
    @ObservedObject var model = HomeModel()

    var body: some View {
        VStack {
            // 侧边栏标题
            Text("对话历史")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))

            // 对话历史列表
            List(model.historyList) { room in // 因ChatRoomModel遵循Identifiable，可省略id参数
                Text(room.topic_name) // 正确展示房间名称
                    .font(.subheadline)
                    .onTapGesture {
                        // 点击列表项，关闭侧边栏
                        model.isSidebarShowing = false
                        // 可选：添加“填充到输入框”的逻辑（示例）
                        // 假设父视图有输入框绑定的属性，可通过闭包传递
                        // if let parentView = self.parent {
                        //     parentView.inputText = "进入\(room.room_name)"
                        // }
                    }
            }
            .listStyle(.plain)

            Spacer()
        }
    }
}
