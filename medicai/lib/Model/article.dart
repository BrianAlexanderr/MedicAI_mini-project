class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String category;
  final String author;
  final String authorImageUrl;
  final String date;
  final int readTime;
  final int likes;
  final int comments;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.author,
    required this.authorImageUrl,
    required this.date,
    required this.readTime,
    required this.likes,
    required this.comments,
  });

  // Sample data for testing
  static List<Article> getSampleArticles() {
    return [
      Article(
        id: '1',
        title: 'Menjaga Kesehatan Jantung di Usia Muda',
        description: 'Tips dan trik untuk menjaga kesehatan jantung sejak dini',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'lib/Assets/download (1).jpeg',
        category: 'Kesehatan Jantung',
        author: 'Dr. Andi',
        authorImageUrl: 'lib/Assets/download (1).jpeg',
        date: '1 Juni 2023',
        readTime: 5,
        likes: 120,
        comments: 24,
      ),
      Article(
        id: '2',
        title: 'Nutrisi Penting untuk Ibu Hamil',
        description: 'Panduan lengkap nutrisi yang dibutuhkan selama kehamilan',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'lib/Assets/download (1).jpeg',
        category: 'Kehamilan',
        author: 'Dr. Siti',
        authorImageUrl: 'lib/Assets/download (1).jpeg',
        date: '3 Juni 2023',
        readTime: 7,
        likes: 85,
        comments: 12,
      ),
      Article(
        id: '3',
        title: 'Mengenal Diabetes Tipe 2 dan Pencegahannya',
        description: 'Informasi lengkap tentang diabetes tipe 2 dan cara mencegahnya',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'lib/Assets/download (1).jpeg',
        category: 'Penyakit',
        author: 'Dr. Budi',
        authorImageUrl: 'lib/Assets/download (1).jpeg',
        date: '5 Juni 2023',
        readTime: 6,
        likes: 95,
        comments: 18,
      ),
      Article(
        id: '4',
        title: 'Manfaat Olahraga Rutin untuk Kesehatan Mental',
        description: 'Bagaimana olahraga dapat membantu menjaga kesehatan mental Anda',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'lib/Assets/download (1).jpeg',
        category: 'Mental',
        author: 'Dr. Maya',
        authorImageUrl: 'lib/Assets/download (1).jpeg',
        date: '7 Juni 2023',
        readTime: 4,
        likes: 110,
        comments: 22,
      ),
      Article(
        id: '5',
        title: 'Panduan Pola Makan Sehat untuk Menurunkan Kolesterol',
        description: 'Tips diet sehat untuk menurunkan kadar kolesterol dalam darah',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        imageUrl: 'lib/Assets/download (1).jpeg',
        category: 'Nutrisi',
        author: 'Dr. Rini',
        authorImageUrl: 'lib/Assets/download (1).jpeg',
        date: '10 Juni 2023',
        readTime: 8,
        likes: 75,
        comments: 15,
      ),
    ];
  }
}