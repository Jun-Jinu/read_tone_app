import 'package:flutter/material.dart';
import '../../layouts/legal_layout.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalLayout(
      title: '이용 약관',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제1조 (목적)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '이 약관은 리드톤(이하 "회사")이 제공하는 독서 기록 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
            ),
            const SizedBox(height: 24),
            Text(
              '제2조 (정의)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. "서비스"란 회사가 제공하는 독서 기록 및 관리 서비스를 말합니다.\n'
              '2. "이용자"란 회사의 서비스를 이용하는 회원을 말합니다.\n'
              '3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 서비스를 이용할 수 있는 자를 말합니다.',
            ),
            const SizedBox(height: 24),
            Text(
              '제3조 (서비스의 제공)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 회사는 다음과 같은 서비스를 제공합니다:\n'
              '   - 독서 기록 관리\n'
              '   - 독서 통계 제공\n'
              '   - 독서 목표 설정 및 관리\n'
              '   - 독서 감상문 작성 및 공유\n'
              '2. 회사는 서비스의 내용 및 제공일자를 이용자에게 사전 통지하고 서비스를 변경하여 제공할 수 있습니다.',
            ),
            const SizedBox(height: 24),
            Text(
              '제4조 (서비스 이용)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 서비스 이용은 회사의 업무상 또는 기술상 특별한 지장이 없는 한 연중무휴, 1일 24시간을 원칙으로 합니다.\n'
              '2. 회사는 시스템 정기점검, 증설 및 교체를 위해 서비스를 일시 중단할 수 있으며, 예정된 작업으로 인한 서비스 일시 중단은 서비스 내 공지사항을 통해 사전에 공지합니다.',
            ),
            const SizedBox(height: 24),
            Text(
              '제5조 (이용자의 의무)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 이용자는 다음 행위를 해서는 안 됩니다:\n'
              '   - 서비스의 정상적인 운영을 방해하는 행위\n'
              '   - 다른 이용자의 개인정보를 수집, 저장, 공개하는 행위\n'
              '   - 서비스를 통해 얻은 정보를 회사의 사전 승낙 없이 복제, 유통하는 행위\n'
              '2. 이용자는 관계법령, 이 약관의 규정, 이용안내 및 주의사항 등 회사가 통지하는 사항을 준수하여야 합니다.',
            ),
          ],
        ),
      ),
    );
  }
}
