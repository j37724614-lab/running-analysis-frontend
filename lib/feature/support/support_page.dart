import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '支援服務與說明 / Support & Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 121, 169, 234),
        elevation: 2,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? size.width * 0.15 : 16.0,
            vertical: 24.0,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Header
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        size: 48,
                        color: Color.fromARGB(255, 121, 169, 234),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '跳遠分析 支援中心',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Long Jump Analysis AI Support Center',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Divider(height: 40, thickness: 1),
                    ],
                  ),
                ),

                // Chinese Support Content
                _buildSectionTitle('一、 產品簡介 (App Description)'),
                _buildBodyText(
                  '「跳遠分析」是一個利用 AI 進行跳遠助跑、起跳與落地姿態分析的專業系統。'
                  '透過多個行動裝置沿跑道串聯接力錄影，自動拼接並分析選手的全程跑步速度與關節骨架動態。',
                ),

                _buildSectionTitle('二、 基本使用步驟 (Basic Usage)'),
                _buildUsageStep(
                  stepNumber: '1',
                  title: '裝置設定與錄製 (Upload/Record)',
                  description:
                      '將多台錄影手機（從機）依序擺放在跑道旁，並在主控端手機（主機）進行無線連線。'
                      '在畫面設定空間基準點（錨點）以利對齊，接著按下主機的「開始錄影」，各裝置即會同步以 60fps 開始錄製並自動上傳。',
                ),
                _buildUsageStep(
                  stepNumber: '2',
                  title: '雲端 AI 運算分析 (Analyze)',
                  description:
                      '影片上傳後，後端伺服器會自動將接力錄製的多段影片拼接在一起，並透過 AI 模型追蹤跑者的 2D/3D 骨架座標，計算出速度、步長及關節夾角。',
                ),
                _buildUsageStep(
                  stepNumber: '3',
                  title: '查看報告與回放 (Results)',
                  description: '分析完成後，可在「回放」頁面播放帶有骨骼標記的拼接影片，並同步對照各路段的速度、加速度、左右膝/髖/肘關節角度變化的互動圖表。',
                ),

                _buildSectionTitle('三、 常見問題 (FAQ)'),
                _buildFAQ(
                  question: 'Q: 需要多少台設備才能進行分析？',
                  answer: 'A: 系統支援單相機分析，但為了完整紀錄 100 公尺的跑步軌跡，推薦沿跑道依序擺放 2 到 5 台設備進行接力串聯錄影。',
                ),
                _buildFAQ(
                  question: 'Q: 什麼是「錨點」？為什麼需要設定？',
                  answer:
                      'A: 錨點是相機畫面的空間參照點（例如跑道線標誌）。設定錨點可幫助 AI 計算不同相機間的相對位置，從而將多段影片無縫拼接為一致的空間座標系統。',
                ),
                _buildFAQ(
                  question: 'Q: 運算分析通常需要多久？',
                  answer: 'A: 依據錄製長度及鏡頭數量，AI 運算通常會在 1 至 3 分鐘內完成，您可以在歷史清單中即時查看處理進度。',
                ),

                _buildSectionTitle('四、 聯絡我們 (Contact Us)'),
                _buildBodyText('如果您在使用過程中有任何疑問、遇到技術問題，或是對功能有任何建議，歡迎隨時透過下方電子信箱與我們聯絡：'),
                const SizedBox(height: 8),
                _buildContactInfo('catscats92a27@gmail.com'),

                _buildSectionTitle('五、 資料刪除申請 (Data Deletion Requests)'),
                _buildBodyText(
                  '我們非常尊重您的隱私權。如果您希望完全刪除您上傳的錄影檔案以及系統運算出的所有分析數據，'
                  '請來信至上方信箱，並提供您的「選手名稱 (Runner Name)」或「分析Session ID」，我們將在核對身分後，於 3 個工作天內將伺服器上的相關影片與數據完全清除，且無法復原。',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(thickness: 1),
                ),

                // English Support Content
                _buildSectionTitle('1. Product Description'),
                _buildBodyText(
                  'Long Jump Analysis AI is an advanced long-jump biomechanics app. '
                  'It chains multiple smartphones along a track to capture, stitch, and analyze a sprinter\'s full-run posture, speed, and joint movements.',
                ),

                _buildSectionTitle('2. How it Works'),
                _buildUsageStep(
                  stepNumber: '1',
                  title: 'Setup & Record',
                  description:
                      'Position smartphones along the track and link them via the app. '
                      'Mark coordinate anchors on the screen, then hit "Start Recording" on the master phone. Devices will record in sync and auto-upload the video.',
                ),
                _buildUsageStep(
                  stepNumber: '2',
                  title: 'AI Processing',
                  description:
                      'Our backend server automatically stitches the videos and runs AI models to trace the runner\'s skeleton and compute kinematic metrics.',
                ),
                _buildUsageStep(
                  stepNumber: '3',
                  title: 'View Analytics',
                  description:
                      'Open the "Playback" page to watch the stitched video overlayed with skeletal joint angles, and inspect interactive charts for velocity, step length, and posture symmetry.',
                ),

                _buildSectionTitle('3. Frequently Asked Questions (FAQ)'),
                _buildFAQ(
                  question: 'Q: How many smartphones do I need?',
                  answer:
                      'A: The app supports single-camera analysis, but to capture a complete 100m sprint, we recommend lining up 2 to 4 devices sequentially.',
                ),
                _buildFAQ(
                  question: 'Q: What are "Anchor Points" and why are they needed?',
                  answer:
                      'A: Anchors are visual reference points on the track. They allow the backend to align coordinate systems of different cameras to stitch footage seamlessly.',
                ),
                _buildFAQ(
                  question: 'Q: How long does AI analysis take?',
                  answer:
                      'A: Depending on the number of clips and duration, it typically takes 1 to 3 minutes. The processing status is displayed in the list.',
                ),

                _buildSectionTitle('4. Contact Support'),
                _buildBodyText(
                  'For support, bugs, or feature requests, feel free to reach out to us at:',
                ),
                const SizedBox(height: 8),
                _buildContactInfo('catscats92a27@gmail.com'),

                _buildSectionTitle('5. Data Deletion Requests'),
                _buildBodyText(
                  'If you wish to delete your uploaded videos and processed analytics from our servers permanently, '
                  'please email us with your Runner Name or Session ID. We will delete all associated data within 3 business days.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 80, 143, 232),
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    final parts = text.split('**');
    if (parts.length < 3) {
      return Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6));
    }

    final List<TextSpan> spans = [];
    for (var i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
        children: spans,
      ),
    );
  }

  Widget _buildUsageStep({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 121, 169, 234),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(answer, style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.email, size: 18, color: Color.fromARGB(255, 80, 143, 232)),
          const SizedBox(width: 8),
          SelectableText(
            email,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 143, 232),
            ),
          ),
        ],
      ),
    );
  }
}
