import 'package:flutter/material.dart';
import 'dart:math';

// 卡片翻轉的主要 Widget
class CardFlip extends StatefulWidget {
  @override
  _CardFlipState createState() => _CardFlipState();
}

class _CardFlipState extends State<CardFlip> with TickerProviderStateMixin {
  late AnimationController _controller; // 卡片翻轉的動畫控制器
  late Animation<double> _animation; // 卡片翻轉的動畫
  bool _isFront = false; // 卡片是否正面朝上
  final List<String> _cardFaces = ['🐸', '🐶', '🐱', '🕷️']; // 卡片花色列表
  String _currentCardFace = ''; // 目前選擇的卡片花色
  bool _showButtons = true; // 是否顯示選擇花色的按鈕
  bool _isCardSelected = false; // 是否已選擇卡片花色
  late AnimationController _reminderController; // 提醒動畫的控制器
  late Animation<double> _reminderAnimation; // 提醒動畫

  @override
  void initState() {
    super.initState();
    // 初始化卡片翻轉的動畫控制器
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    // 設定卡片翻轉的動畫
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isFront = true;
          });
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isFront = false;
            _isCardSelected = false;
            _currentCardFace = '';
            _showButtons = true;
            _reminderController.repeat();
          });
        }
      });

    // 初始化提醒動畫的控制器
    _reminderController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    // 設定提醒動畫
    _reminderAnimation =
        Tween<double>(begin: 1.0, end: 0.5).animate(_reminderController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  // 切換卡片正反面
  void _toggleCard() {
    if (_isCardSelected) {
      if (_isFront) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  // 選擇卡片花色
  void _selectCardFace(String cardFace) {
    setState(() {
      _currentCardFace = cardFace;
      _showButtons = false;
      _isCardSelected = true;
      _reminderController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Text(
                  'FLIP THE CARD',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: GlowingTextPainter(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _toggleCard,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi *
                        (_isFront ? _animation.value : 1 - _animation.value)),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: CardPainter(
                        _isFront, _currentCardFace, _animation.value),
                    child: Container(
                      width: 200,
                      height: 300,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_showButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _cardFaces.map((face) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => _selectCardFace(face),
                      child: Text(face, style: TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            if (!_isCardSelected)
              FadeTransition(
                opacity: _reminderAnimation,
                child: Text(
                  '請選擇卡片花色',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 卡片繪製的自定義繪製器
class CardPainter extends CustomPainter {
  final bool isFront; // 卡片是否正面朝上
  final String cardFace; // 卡片花色
  final double angle; // 卡片翻轉的角度

  CardPainter(this.isFront, this.cardFace, this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final card = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
        stops: [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
        transform: GradientRotation(angle * 2 * pi),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(10),
      ));

    canvas.drawPath(path, card);
    canvas.drawPath(path, border);

    if (isFront) {
      final text = TextPainter(
        text: TextSpan(
          text: cardFace,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      text.layout();
      text.paint(
          canvas,
          Offset(
              (size.width - text.width) / 2, (size.height - text.height) / 2));
    } else {
      final text = TextPainter(
        text: TextSpan(
          text: 'FLEX',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      text.layout();
      text.paint(
          canvas,
          Offset(
              (size.width - text.width) / 2, (size.height - text.height) / 2));
    }
  }

  @override
  bool shouldRepaint(CardPainter oldDelegate) =>
      oldDelegate.isFront != isFront ||
      oldDelegate.cardFace != cardFace ||
      oldDelegate.angle != angle;
}

// 發光文字的自定義繪製器
class GlowingTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 10)
      ..style = PaintingStyle.fill;

    final glowPath = Path()
      ..addRect(Rect.fromLTWH(
        -10,
        0,
        size.width + 20,
        size.height,
      ));

    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
