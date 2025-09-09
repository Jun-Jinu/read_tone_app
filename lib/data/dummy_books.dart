import 'package:read_tone_app/domain/entities/book.dart';
import 'package:read_tone_app/domain/entities/reading_note.dart';

final List<Book> dummyBooks = [
  Book(
    id: '1',
    title: '불변의 법칙',
    author: '모건 하우절',
    coverImageUrl:
        'https://image.aladin.co.kr/product/32397/97/cover500/k012935430_1.jpg',
    totalPages: 320,
    currentPage: 320,
    status: BookStatus.completed,
    createdAt: DateTime(2024, 2, 1),
    startedAt: DateTime(2024, 2, 1),
    completedAt: DateTime(2024, 2, 15),
    readingSessions: [],
    memo: '세상을 바꾸는 17가지 불변의 법칙을 통해 성공의 원리를 배운다.',
    notes: [
      ReadingNote(
        id: '1-1',
        title: '성공의 비밀',
        content: '성공은 단순히 운이 아니라 꾸준한 노력과 올바른 원칙을 지키는 것에서 온다는 것을 깨달았다.',
        createdAt: DateTime(2024, 2, 10),
        updatedAt: DateTime(2024, 2, 10),
        pageNumber: 156,
      ),
      ReadingNote(
        id: '1-2',
        title: '투자의 지혜',
        content: '단기적인 수익보다는 장기적인 관점에서 투자해야 한다는 저자의 조언이 인상적이었다.',
        createdAt: DateTime(2024, 2, 12),
        updatedAt: DateTime(2024, 2, 12),
        pageNumber: 203,
      ),
    ],
    updatedAt: DateTime(2024, 3, 1),
  ),
  Book(
    id: '2',
    title: '아침에 일어나면 가장 먼저 하는 일',
    author: '할 엘로드',
    coverImageUrl:
        'https://image.aladin.co.kr/product/32397/97/cover500/k012935430_1.jpg',
    totalPages: 280,
    currentPage: 120,
    status: BookStatus.reading,
    createdAt: DateTime(2024, 2, 20),
    startedAt: DateTime(2024, 2, 20),
    readingSessions: [],
    memo: '하루를 성공적으로 시작하는 아침 루틴에 대해 다룬 책.',
    notes: [
      ReadingNote(
        id: '2-1',
        title: '미라클 모닝',
        content: '새벽 5시에 일어나서 6가지 활동을 하는 것이 생각보다 어렵지만 효과가 있다.',
        createdAt: DateTime(2024, 2, 25),
        updatedAt: DateTime(2024, 2, 25),
        pageNumber: 85,
      ),
    ],
    updatedAt: DateTime(2024, 3, 1),
  ),
  Book(
    id: '3',
    title: '미움받을 용기',
    author: '기시미 이치로',
    coverImageUrl:
        'https://image.aladin.co.kr/product/32397/97/cover500/k012935430_1.jpg',
    totalPages: 350,
    currentPage: 0,
    status: BookStatus.planned,
    createdAt: DateTime(2024, 3, 1),
    readingSessions: [],
    memo: '아들러 심리학을 통해 행복한 삶을 살아가는 방법을 제시한다.',
    notes: [],
    updatedAt: DateTime(2024, 3, 1),
  ),
];
