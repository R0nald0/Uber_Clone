part of '../home_page_passageiro.dart';

enum OptionIa {
  WORK(nameOption: 'Trabalho'),
  LEISURE(nameOption: 'Lazer'),
  HEALTH(nameOption: 'Saúde'),
  SHOPPING(nameOption: 'Compras'),
  NEAR_BY_MY(nameOption: 'Perto de mim'),
  NOTHING(nameOption: '');

  final String nameOption;
  const OptionIa({required this.nameOption});
}

class MessageIaWidget extends StatelessWidget {
  final String? messageIa;
  final VoidCallback onTap;
  final ValueChanged<OptionIa> onSelected;
  final bool isMe;
  const MessageIaWidget(
      {super.key,
      required this.messageIa,
      required this.onSelected,
      required this.onTap,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context) * .9;
    return Positioned(
      bottom: 90,
      right: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipPath(
              clipper: ChatBubbleClipper(isMe: isMe),
              child: AnimatedContainer(
                alignment: Alignment.topCenter,
                constraints: BoxConstraints(maxWidth: size.width * 1),
                padding: const EdgeInsets.only(
                    bottom: 28, left: 16, right: 16, top: 13),
                curve: Curves.easeInOut,
                duration: const Duration(seconds: 1),
                decoration: messageIa != null
                    ? const BoxDecoration(
                        color: Colors.white70,
                      )
                    : null,
                child: messageIa != null
                    ? Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  messageIa!,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.grey.withAlpha(100),
                                    padding: const EdgeInsets.all(2),
                                    
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () =>
                                      onSelected(OptionIa.NOTHING),
                                  icon: const Icon(Icons.close),
                                  iconSize: 18,
                                  )
                            ],
                          ),
                          SizedBox(
                            width: size.width * 1,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                OptionButton(
                                    icon: Icons.work,
                                    label: 'Trabalho',
                                    onTap: () => onSelected(OptionIa.WORK)),
                                OptionButton(
                                    icon: Icons.celebration,
                                    label: 'Lazer',
                                    onTap: () => onSelected(OptionIa.LEISURE)),
                                OptionButton(
                                    icon: Icons.fitness_center,
                                    label: 'Saúde',
                                    onTap: () => onSelected(OptionIa.HEALTH)),
                                OptionButton(
                                    icon: Icons.shopping_cart,
                                    label: 'Compras',
                                    onTap: () => onSelected(OptionIa.SHOPPING),),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              height: 80,
              width: messageIa != null ? 50 : 80,
              child: lottie.LottieBuilder.asset(
                  UberCloneConstants.LOTTI_ASSET_IA_ANIMATION),
            )
          ],
        ),
      ),
    );
  }
}

class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isMe;

  ChatBubbleClipper({required this.isMe});

  @override
  Path getClip(Size size) {
    const radius = 16.0;
    final path = Path();

    if (isMe) {
      // Balão do lado direito
      path.moveTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius - 10);

      path.lineTo(size.width, size.height - 30);
      path.lineTo(size.width - 1, size.height);
      path.lineTo(size.width - 10, size.height - 10);
      path.lineTo(size.width - 20, size.height - radius);
      path.lineTo(radius, size.height - radius);
      path.quadraticBezierTo(
          0, size.height - radius, 0, size.height - radius * 2);
      path.close();
    } else {
      // Balão do lado esquerdo
      path.moveTo(20, size.height - 5);
      path.lineTo(0, size.height);
      path.lineTo(10, size.height - 10);
      path.lineTo(10, size.height - radius);
      path.quadraticBezierTo(10, size.height - 10 - radius, radius + 10,
          size.height - 10 - radius);
      path.lineTo(size.width - radius, size.height - 10 - radius);
      path.quadraticBezierTo(size.width, size.height - 10 - radius, size.width,
          size.height - 10 - radius * 2);
      path.lineTo(size.width, radius);
      path.quadraticBezierTo(size.width, 0, size.width - radius, 0);
      path.lineTo(radius, 0);
      path.quadraticBezierTo(0, 0, 0, radius);
      path.lineTo(0, size.height - radius - 10);
      path.quadraticBezierTo(0, size.height - 10, radius, size.height - 10);
      path.lineTo(10, size.height - 10);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
