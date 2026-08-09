import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../services/quiz_data.dart';
import 'glassmorphic_card.dart';

class DailyQuizWidget extends StatefulWidget {
  const DailyQuizWidget({super.key});

  @override
  State<DailyQuizWidget> createState() => _DailyQuizWidgetState();
}

class _DailyQuizWidgetState extends State<DailyQuizWidget> {
  bool _isLoading = true;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;

  // Cấu trúc câu hỏi trắc nghiệm
  late final Map<String, dynamic> _currentQuestion;
  late final String _todayKey;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() async {
    final now = DateTime.now();
    final period = now.hour < 12 ? '1' : '2';
    _todayKey = '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_$period';
    
    // Tính toán chỉ số câu hỏi dựa trên số chu kỳ 12h từ Epoch để đổi câu hỏi liên tục mỗi 12 tiếng
    final periodIndex = now.millisecondsSinceEpoch ~/ (12 * 3600 * 1000);
    final questionIndex = periodIndex % quizQuestions.length;
    _currentQuestion = quizQuestions[questionIndex];

    final prefs = await SharedPreferences.getInstance();
    
    // Đọc trạng thái đã làm từ SharedPreferences
    final completed = prefs.getBool('quiz_completed_$_todayKey') ?? false;
    final savedAnswer = prefs.getInt('quiz_answer_$_todayKey');
    
    if (mounted) {
      setState(() {
        if (completed && savedAnswer != null) {
          _selectedAnswerIndex = savedAnswer;
          _isAnswerSubmitted = true;
          _isCorrect = savedAnswer == _currentQuestion['correct_index'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswerIndex == null || _isAnswerSubmitted) return;

    final provider = context.read<AppProvider>();
    final isCorrect = _selectedAnswerIndex == _currentQuestion['correct_index'];
    
    // Lưu cục bộ trước
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_completed_$_todayKey', true);
    await prefs.setInt('quiz_answer_$_todayKey', _selectedAnswerIndex!);

    setState(() {
      _isAnswerSubmitted = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect && provider.isLoggedIn) {
      // Gọi API cộng 20 điểm lên server
      final res = await provider.submitQuizPoints(20, 'quiz_$_todayKey');
      if (res['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('🎉 Chúc mừng! Bạn nhận được +20 điểm thưởng.', '🎉 Congratulations! You received +20 bonus points.'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox();
    final provider = Provider.of<AppProvider>(context);
    final isVi = !provider.isEnglish;

    final questionText = isVi ? _currentQuestion['question_vi'] : _currentQuestion['question_en'];
    final explanationText = isVi ? _currentQuestion['explanation_vi'] : _currentQuestion['explanation_en'];
    final List<String> options = List<String>.from(_currentQuestion['options']);
    final correctIdx = _currentQuestion['correct_index'] as int;

    return GlassmorphicCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 0,
      borderWidth: 0,
      backgroundColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Quiz
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: const Color(0xFFBF5AF2),
                  child: Text(
                    context.tr('ĐỐ VUI HÀNG NGÀY', 'DAILY TECH QUIZ'),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isAnswerSubmitted
                      ? (_isCorrect ? context.tr('ĐÚNG (+20 điểm)', 'CORRECT (+20 pts)') : context.tr('SAI (0 điểm)', 'INCORRECT (0 pt)'))
                      : context.tr('+20 ĐIỂM THƯỞNG', '+20 BONUS PTS'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _isAnswerSubmitted ? (_isCorrect ? const Color(0xFF30D158) : Colors.redAccent) : const Color(0xFFFF9F0A),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.psychology_outlined, size: 16, color: Colors.white38),
              ],
            ),
            const SizedBox(height: 12),
            // Question Content
            Text(
              questionText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.4),
            ),
            const SizedBox(height: 14),

            // Answers Options list
            Column(
              children: List.generate(options.length, (index) {
                final optionText = options[index];
                
                // Trạng thái hiển thị màu sắc Apple
                Color optionBgColor = Colors.white.withOpacity(0.03);
                Color optionBorderColor = Colors.white.withOpacity(0.08);
                Color textColor = Colors.white70;

                if (_isAnswerSubmitted) {
                  if (index == correctIdx) {
                    // Đáp án đúng hiển thị viền xanh lá mỏng
                    optionBgColor = const Color(0xFF30D158).withOpacity(0.08);
                    optionBorderColor = const Color(0xFF30D158).withOpacity(0.4);
                    textColor = const Color(0xFF30D158);
                  } else if (_selectedAnswerIndex == index && !_isCorrect) {
                    // Đáp án sai do người dùng chọn hiển thị viền đỏ mỏng
                    optionBgColor = Colors.redAccent.withOpacity(0.08);
                    optionBorderColor = Colors.redAccent.withOpacity(0.4);
                    textColor = Colors.redAccent;
                  }
                } else if (_selectedAnswerIndex == index) {
                  // Đang chọn chưa gửi: hiển thị màu xanh Apple
                  optionBgColor = const Color(0xFF0A84FF).withOpacity(0.08);
                  optionBorderColor = const Color(0xFF0A84FF).withOpacity(0.6);
                  textColor = const Color(0xFF0A84FF);
                }

                return GestureDetector(
                  onTap: _isAnswerSubmitted
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswerIndex = index;
                          });
                        },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: optionBgColor,
                      border: Border.all(color: optionBorderColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + index)}.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_isAnswerSubmitted && index == correctIdx)
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF30D158))
                        else if (_isAnswerSubmitted && _selectedAnswerIndex == index && !_isCorrect)
                          const Icon(Icons.cancel_rounded, size: 14, color: Colors.redAccent),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // Submit Button or Explanation
            if (!_isAnswerSubmitted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A84FF),
                        disabledBackgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white30,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        context.tr('GỬI ĐÁP ÁN', 'SUBMIT ANSWER'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              // Explanation Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.white.withOpacity(0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('GIẢI THÍCH CHUYÊN MÔN:', 'EXPERT EXPLANATION:'),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      explanationText,
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              if (!provider.isLoggedIn) ...[
                const SizedBox(height: 10),
                Text(
                  context.tr('* Đăng nhập để ghi nhận điểm thưởng lên Bảng xếp hạng!', '* Log in to sync your bonus points with the Leaderboard!'),
                  style: const TextStyle(fontSize: 10, color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ],
        ),
    );
  }
}
