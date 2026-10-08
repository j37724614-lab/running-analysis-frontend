import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '隱私權政策 / Privacy Policy',
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
                // Title Section
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 48,
                        color: Color.fromARGB(255, 121, 169, 234),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '跳遠分析 隱私權政策',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Privacy Policy for Long Jump Analysis AI',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Divider(height: 40, thickness: 1),
                    ],
                  ),
                ),

                // Traditional Chinese Section
                _buildSectionTitle('一、 應用程式說明 (App Description)'),
                _buildBodyText(
                  '「跳遠分析」App 是一款專為跳遠助跑、起跳與落地姿態分析設計的專業運動力學系統。'
                  '本程式支援多個行動裝置進行接力式串聯錄影，並將錄影內容自動上傳進行 AI 骨架追蹤、'
                  '速度與關節角度分析，協助選手與教練提升訓練成效。',
                ),

                _buildSectionTitle('二、 收集之資料類型 (Collected Data)'),
                _buildBulletPoints([
                  '**上傳的影片 (Uploaded Videos)**：您拍攝並主動上傳的跑步過程影片。',
                  '**分析結果 (Analysis Results)**：系統經由影片計算產出的運動力學數據（如速度、加速度、步長）及 2D/3D 關節角度與骨架座標數據。',
                ]),

                _buildSectionTitle('三、 資料使用方式 (Data Usage)'),
                _buildBodyText(
                  '我們所收集的影片與數據僅用於：\n'
                  '1. 執行 AI 運動姿態與步態估算分析。\n'
                  '2. 產生視覺化的分析圖表與骨架標記疊加影片以提供訓練回饋。\n'
                  '我們不會將您的任何影片或資料用於其他分析或商業用途。',
                ),

                _buildSectionTitle('四、 資料儲存與安全 (Data Storage)'),
                _buildBodyText(
                  '您上傳的影片及計算產生的分析結果均安全地儲存於我們的後端伺服器中，'
                  '以便您可以在不同的授權裝置上隨時查看歷史分析紀錄與回放影片。我們採取了合理的安全措施以防止資料遭受未授權的存取、竄改或洩露。',
                ),

                _buildSectionTitle('五、 資料分享與第三方廣告 (Data Sharing & Ads)'),
                _buildBodyText(
                  '本 App **承諾不與任何第三方分享** 您的影片或分析數據。'
                  '本 App 中不含有任何廣告 SDK，亦無任何第三方廣告投放。',
                ),

                _buildSectionTitle('六、 使用者權利與資料刪除 (User Rights & Deletion)'),
                _buildBodyText(
                  '您擁有對自身資料的完全控制權。如果您希望刪除您已上傳的影片與分析數據，'
                  '您可以隨時透過下方的聯絡信箱與我們聯繫，我們將於收到請求後儘速刪除伺服器上對應的資料。',
                ),

                _buildSectionTitle('七、 聯絡信箱 (Contact Email)'),
                _buildContactInfo('catscats92a27@gmail.com'),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(thickness: 1),
                ),

                // English Section
                _buildSectionTitle('1. App Description'),
                _buildBodyText(
                  'Long Jump Analysis AI is a professional biomechanics app designed for long-jump approach, takeoff, and landing analysis. '
                  'It allows multiple mobile devices to perform sequential recording along the running track. '
                  'The uploaded footages are analyzed by AI to track velocity, step length, and joint angles to assist runners and coaches.',
                ),

                _buildSectionTitle('2. Collected Data'),
                _buildBulletPoints([
                  '**Uploaded Videos**: Running session videos recorded and uploaded by the user.',
                  '**Analysis Results**: Kinematic metrics (velocity, acceleration, step length) and 2D/3D joint coordinates & angles calculated by our AI engine.',
                ]),

                _buildSectionTitle('3. Data Usage'),
                _buildBodyText(
                  'The collected videos and results are used solely to:\n'
                  '• Execute AI-based gait and running posture analysis.\n'
                  '• Generate visual analytical charts and skeleton overlay videos for feedback.\n'
                  'No further profiling or marketing usage is conducted.',
                ),

                _buildSectionTitle('4. Data Storage and Security'),
                _buildBodyText(
                  'Your videos and analysis metrics are stored securely on our backend servers '
                  'so you can access your training history and video playback anytime. We implement appropriate technical safeguards to protect your information.',
                ),

                _buildSectionTitle('5. Data Sharing & Ads'),
                _buildBodyText(
                  'We **do not share** your videos or results with any third parties. '
                  'This app does not contain advertising SDKs or third-party tracking services.',
                ),

                _buildSectionTitle('6. User Rights & Data Deletion'),
                _buildBodyText(
                  'You retain complete ownership over your data. You have the right to request the deletion of your uploaded videos and analysis history at any time. '
                  'Please contact us using the email below, and we will process your deletion request promptly.',
                ),

                _buildSectionTitle('7. Contact Email'),
                _buildContactInfo('catscats92a27@gmail.com'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
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
      return Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5));
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
        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        children: spans,
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((p) {
          final parts = p.split('**');
          if (parts.length >= 3) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                        children: [
                          TextSpan(
                            text: parts[1],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: parts.sublist(2).join('')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: _buildBodyText(p)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactInfo(String email) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
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
