import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _readingReminderEnabled = true;
  bool _goalReminderEnabled = true;
  bool _weeklyReportEnabled = true;
  bool _newFeatureEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: ListView(
        children: [
          // 알림 수신 방식
          ListTile(
            title: const Text('푸시 알림'),
            subtitle: const Text('앱 푸시 알림을 받습니다'),
            trailing: Switch(
              value: _pushEnabled,
              onChanged: (bool value) {
                setState(() {
                  _pushEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('이메일 알림'),
            subtitle: const Text('이메일로 알림을 받습니다'),
            trailing: Switch(
              value: _emailEnabled,
              onChanged: (bool value) {
                setState(() {
                  _emailEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          // 알림 종류
          ListTile(
            title: const Text('독서 리마인더'),
            subtitle: const Text('설정한 시간에 독서 리마인더를 받습니다'),
            trailing: Switch(
              value: _readingReminderEnabled,
              onChanged: (bool value) {
                setState(() {
                  _readingReminderEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('목표 달성 알림'),
            subtitle: const Text('독서 목표 달성 시 알림을 받습니다'),
            trailing: Switch(
              value: _goalReminderEnabled,
              onChanged: (bool value) {
                setState(() {
                  _goalReminderEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('주간 독서 리포트'),
            subtitle: const Text('매주 독서 활동 요약을 받습니다'),
            trailing: Switch(
              value: _weeklyReportEnabled,
              onChanged: (bool value) {
                setState(() {
                  _weeklyReportEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('새로운 기능 소개'),
            subtitle: const Text('앱의 새로운 기능 소개를 받습니다'),
            trailing: Switch(
              value: _newFeatureEnabled,
              onChanged: (bool value) {
                setState(() {
                  _newFeatureEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          // 알림 시간 설정
          ListTile(
            title: const Text('알림 수신 시간'),
            subtitle: const Text('오전 9시 ~ 오후 9시'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 알림 시간 설정 페이지로 이동
            },
          ),
        ],
      ),
    );
  }
}
