<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

/**
 * API CHECK UPDATE - CODE GO (MULTILINGUAL)
 * Version: 1.0.1
 */

$updateInfo = [
    "success" => true,
    "data" => [
        "latest_version" => "1.0.5",
        "min_version" => "1.0.0",
        "url_ios" => "https://apps.apple.com/vn/app/id6763352474",
        "url_android" => "https://play.google.com/store/apps/details?id=com.codego.app",
        
        // Đa ngôn ngữ cho nội dung cập nhật
        "release_notes_vi" => "• Thêm tính năng Chatbot AI hỗ trợ học tập\n• Cải thiện hiệu suất màn hình chính\n• Sửa một số lỗi giao diện trên iOS\n• Cập nhật kho câu hỏi mới nhất 2025",
        "release_notes_en" => "• Added AI Chatbot feature for learning support\n• Improved Home Screen performance\n• Fixed some UI bugs on iOS\n• Updated the latest 2025 question bank",
        "release_notes_ja" => "• 学習サポート用のAIチャットボット機能を追加\n• ホーム画面のパフォーマンスを向上\n• iOSの一部のUIバグを修正\n• 2025年の最新の問題バンクを更新",
        
        "is_force_update" => false
    ]
];

echo json_encode($updateInfo);
?>
