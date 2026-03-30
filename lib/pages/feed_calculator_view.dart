import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/feed_use_controller.dart';
import 'history_page.dart';

class FeedCalculatorView extends StatelessWidget {
  const FeedCalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedUseController>();
    // Responsif: gunakan LayoutBuilder untuk menyesuaikan padding dan ukuran tombol
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final horizontalPadding = isWide ? 48.0 : 20.0;
        final verticalPadding = isWide ? 32.0 : 18.0;
        final buttonHeight = isWide ? 72.0 : 64.0;
        final buttonFontSize = isWide ? 28.0 : 24.0;
        final minCardHeight = 520.0;
        return Center(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Container(
              width: isWide ? 420 : double.infinity,
              constraints: BoxConstraints(
                minHeight: minCardHeight,
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => Text(
                            "Feed Ke - ${controller.draftCount.value + 1}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "KILO",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            controller.kilo.value.isEmpty
                                ? '0'
                                : controller.kilo.value,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Obx(() {
                        final codes = controller.feedCodes;
                        final selected = controller.selectedFeedCode.value;
                        if (codes.isNotEmpty && selected.isEmpty) {
                          controller.selectedFeedCode.value = codes.first;
                        }
                        if (codes.isEmpty) {
                          return const Center(child: Text("No Feed Codes"));
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 16) / 3;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: codes.length,
                              separatorBuilder: (context, idx) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final isSelected = selected == codes[i];
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectFeedCode(codes[i]),
                                  child: Container(
                                    width: itemWidth,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF6B4AC3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF6B4AC3),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF6B4AC3,
                                                ).withOpacity(0.18),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      codes[i],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF6B4AC3),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: const Color(0xFF6B4AC3),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "KG",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (controller
                                  .selectedFeedCode
                                  .value
                                  .isNotEmpty) {
                                Get.to(() => const HistoryPage());
                              } else {
                                Get.snackbar(
                                  'Pilih FeedCode',
                                  'Silakan pilih feed code terlebih dahulu',
                                );
                              }
                            },
                            child: Container(
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B4AC3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ..._buildCalculatorRows(
                              controller,
                              buttonHeight,
                              buttonFontSize,
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Membuat deretan tombol kalkulator secara responsif
  List<Widget> _buildCalculatorRows(
    FeedUseController controller,
    double buttonHeight,
    double buttonFontSize,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: _buildButton(
              '7',
              onTap: () => controller.addKilo('7'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '8',
              onTap: () => controller.addKilo('8'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '9',
              onTap: () => controller.addKilo('9'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildIconButton(
              Icons.backspace_outlined,
              bgColor: const Color(0xFF6B4AC3),
              iconColor: Colors.white,
              onTap: controller.removeLast,
              height: buttonHeight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildButton(
              '4',
              onTap: () => controller.addKilo('4'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '5',
              onTap: () => controller.addKilo('5'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '6',
              onTap: () => controller.addKilo('6'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildIconButton(
              Icons.scale,
              bgColor: Colors.white,
              iconColor: Colors.black,
              withShadow: true,
              height: buttonHeight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildButton(
              '1',
              onTap: () => controller.addKilo('1'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '2',
              onTap: () => controller.addKilo('2'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '3',
              onTap: () => controller.addKilo('3'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              'GET\nSCALE',
              bgColor: Colors.grey.shade300,
              textColor: Colors.grey.shade500,
              fontSize: 12,
              height: buttonHeight,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _buildEmptyButton(height: buttonHeight)),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '0',
              onTap: () => controller.addKilo('0'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              '.',
              onTap: () => controller.addKilo('.'),
              outlined: true,
              height: buttonHeight,
              fontSize: buttonFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              'CONF',
              bgColor: Colors.green,
              textColor: Colors.white,
              fontSize: 14,
              height: buttonHeight,
              onTap: () async {
                showDialog(
                  context: Get.context!,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KILO : ${controller.kilo.value.isEmpty ? '0' : controller.kilo.value}\t\tPROD : ${controller.selectedFeedCode.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'Pastikan data yang diinput sudah benar !!!\nApabila sudah dikonfirmasi, maka ',
                                ),
                                TextSpan(
                                  text:
                                      'tidak bisa edit/revisi Timbang Feed ini kembali.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await controller.saveFeedUseDraft();
                                  controller.clear();
                                },
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildButton(
    String text, {
    Color? bgColor,
    Color? textColor,
    double fontSize = 24,
    VoidCallback? onTap,
    bool outlined = false,
    double height = 64,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 2, offset: Offset(0, 2)),
          ],
          border: outlined
              ? Border.all(color: Colors.grey.shade300, width: 1.2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color? bgColor,
    Color? iconColor,
    VoidCallback? onTap,
    bool withShadow = false,
    double height = 64,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: withShadow
              ? const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor ?? Colors.black, size: 28),
      ),
    );
  }

  Widget _buildEmptyButton({double height = 64}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.grey, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}
