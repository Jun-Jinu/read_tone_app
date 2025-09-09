import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/reading_note.dart';
import '../../providers/book_provider.dart';
import '../../widgets/common/index.dart';

class ReadingNoteScreen extends ConsumerStatefulWidget {
  final String bookId;
  final ReadingNote? note;

  const ReadingNoteScreen({
    super.key,
    required this.bookId,
    this.note,
  });

  @override
  ConsumerState<ReadingNoteScreen> createState() => _ReadingNoteScreenState();
}

class _ReadingNoteScreenState extends ConsumerState<ReadingNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _pageNumberController;

  bool _isLoading = false;
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _pageNumberController = TextEditingController(
      text: widget.note?.pageNumber?.toString() ?? '',
    );

    // 글자 수 실시간 업데이트를 위한 리스너 추가
    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pageNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final pageNumber = _pageNumberController.text.trim().isEmpty
          ? null
          : int.tryParse(_pageNumberController.text.trim());

      final note = _isEditing
          ? widget.note!.copyWith(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              updatedAt: now,
              pageNumber: pageNumber,
            )
          : ReadingNote(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              createdAt: now,
              updatedAt: now,
              pageNumber: pageNumber,
            );

      // TODO: Provider를 통해 노트 저장
      if (_isEditing) {
        await ref.read(updateReadingNoteProvider)(widget.bookId, note);
      } else {
        await ref.read(addReadingNoteProvider)(widget.bookId, note);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(_isEditing ? '노트가 수정되었습니다' : '노트가 저장되었습니다'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop(note);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('저장 실패: ${error.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '노트 수정' : '새 노트 작성'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveNote,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildContentSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '📝 기본 정보'),
          const SizedBox(height: 20),

          // 노트 제목
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '노트 제목',
              hintText: '노트 제목을 입력하세요',
              prefixIcon: const Icon(Icons.title_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '노트 제목을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 페이지 번호 (선택사항)
          TextFormField(
            controller: _pageNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '페이지 번호 (선택사항)',
              hintText: '관련 페이지 번호를 입력하세요',
              prefixIcon: const Icon(Icons.bookmark_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final page = int.tryParse(value.trim());
                if (page == null || page <= 0) {
                  return '올바른 페이지 번호를 입력해주세요';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '📄 내용'),
          const SizedBox(height: 20),

          TextFormField(
            controller: _contentController,
            maxLines: 15,
            decoration: InputDecoration(
              labelText: '노트 내용',
              hintText: '이 책에 대한 생각, 감상, 메모 등을 자유롭게 작성해보세요...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '노트 내용을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 글자 수 표시
          Row(
            children: [
              const Spacer(),
              Text(
                '${_contentController.text.length}자',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
