import 'package:flutter/material.dart';
import '../../layouts/legal_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalLayout(
      title: '개인정보 처리방침',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. 개인정보의 수집 및 이용 목적',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '회사는 다음의 목적을 위하여 개인정보를 처리하고 있으며, 다음의 목적 이외의 용도로는 이용하지 않습니다.\n\n'
              '- 회원 가입 및 관리\n'
              '- 독서 기록 및 통계 서비스 제공\n'
              '- 서비스 이용에 따른 본인확인, 연령확인\n'
              '- 고객 상담 및 불만처리',
            ),
            const SizedBox(height: 24),
            Text(
              '2. 수집하는 개인정보의 항목',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '회사는 회원가입, 상담, 서비스 신청 등을 위해 아래와 같은 개인정보를 수집하고 있습니다.\n\n'
              '- 필수항목: 이메일, 비밀번호, 닉네임\n'
              '- 선택항목: 프로필 이미지, 관심 분야\n'
              '- 서비스 이용 과정에서 생성되는 정보: 독서 기록, 감상문, 통계 데이터',
            ),
            const SizedBox(height: 24),
            Text(
              '3. 개인정보의 보유 및 이용기간',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '회사는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 단, 관계법령의 규정에 의하여 보존할 필요가 있는 경우 회사는 아래와 같이 관계법령에서 정한 일정한 기간 동안 회원정보를 보관합니다.\n\n'
              '- 계약 또는 청약철회 등에 관한 기록: 5년\n'
              '- 대금결제 및 재화 등의 공급에 관한 기록: 5년\n'
              '- 소비자의 불만 또는 분쟁처리에 관한 기록: 3년',
            ),
            const SizedBox(height: 24),
            Text(
              '4. 개인정보의 파기절차 및 방법',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '회사는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 파기절차 및 방법은 다음과 같습니다.\n\n'
              '1. 파기절차\n'
              '   - 회원이 서비스 가입 등을 위해 입력한 정보는 목적이 달성된 후 별도의 DB로 옮겨져 내부 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라 일정 기간 저장된 후 파기됩니다.\n\n'
              '2. 파기방법\n'
              '   - 전자적 파일 형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.',
            ),
            const SizedBox(height: 24),
            Text(
              '5. 이용자의 권리와 그 행사방법',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              '이용자는 언제든지 등록되어 있는 자신의 개인정보를 조회하거나 수정할 수 있으며, 회사의 개인정보 보호책임자에게 서면, 전화 또는 이메일로 연락하시면 지체 없이 조치하겠습니다.\n\n'
              '이용자가 개인정보의 오류에 대한 정정을 요청하신 경우에는 정정을 완료하기 전까지 당해 개인정보를 이용 또는 제공하지 않습니다. 또한 잘못된 개인정보를 제3자에게 이미 제공한 경우에는 정정 처리결과를 제3자에게 지체 없이 통지하여 정정이 이루어지도록 하겠습니다.',
            ),
          ],
        ),
      ),
    );
  }
}
