import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/morta_controller.dart';
import 'history_page.dart';

class MortaCalculatorView extends StatelessWidget {
  const MortaCalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MortaController>();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade400, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Obx(() => Text(
                "Morta Ke - ${controller.draftCount.value + 1}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("EKOR", style: TextStyle(fontSize: 14, color: Colors.black)),
              const Spacer(),
              Obx(
                () => Text(
                  controller.ekor.value.isEmpty ? '0' : controller.ekor.value,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Obx(() {
              final codes = controller.mortaCodes;
              final selected = controller.selectedMortaCode.value;
              if (codes.isNotEmpty && selected.isEmpty) {
                controller.selectedMortaCode.value = codes.first;
              }
              if (codes.isEmpty) {
                return const Center(child: Text("No Feed Codes"));
              }
              return Row(
                children: [
                  for (int i = 0; i < codes.length; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectMortaCode(codes[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected == codes[i]
                                ? const Color(0xFF6B4AC3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6B4AC3),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            codes[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected == codes[i]
                                  ? Colors.white
                                  : const Color(0xFF6B4AC3),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (i < codes.length - 1) const SizedBox(width: 8),
                  ],
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 64,
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
                            "EKOR",
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
                    if (controller.selectedMortaCode.value.isNotEmpty) {
                      Get.to(() => const HistoryPage(isMorta: true));
                    } else {
                      Get.snackbar(
                        'Pilih MortaCode',
                        'Silakan pilih morta code terlebih dahulu',
                      );
                    }
                  },
                  child: Container(
                    height: 64,
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
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  '7',
                  onTap: () => controller.addEkor('7'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '8',
                  onTap: () => controller.addEkor('8'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '9',
                  onTap: () => controller.addEkor('9'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIconButton(
                  Icons.backspace_outlined,
                  bgColor: const Color(0xFF6B4AC3),
                  iconColor: Colors.white,
                  onTap: controller.removeLast,
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
                  onTap: () => controller.addEkor('4'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '5',
                  onTap: () => controller.addEkor('5'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '6',
                  onTap: () => controller.addEkor('6'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIconButton(
                  Icons.scale,
                  bgColor: Colors.white,
                  iconColor: Colors.black,
                  withShadow: true,
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
                  onTap: () => controller.addEkor('1'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '2',
                  onTap: () => controller.addEkor('2'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '3',
                  onTap: () => controller.addEkor('3'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  'GET\nSCALE',
                  bgColor: Colors.grey.shade300,
                  textColor: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEmptyButton()),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '0',
                  onTap: () => controller.addEkor('0'),
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildEmptyButton()),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  'CONF',
                  bgColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 14,
                  onTap: () async {
                    showDialog(
                      context: context,
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
                                'EKOR : ${controller.ekor.value.isEmpty ? '0' : controller.ekor.value}',
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
                                          'tidak bisa edit/revisi data Morta ini kembali.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                      await controller.saveMortaDraft();
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
        ],
      ),
    );
  }

  Widget _buildButton(
    String text, {
    Color? bgColor,
    Color? textColor,
    double fontSize = 24,
    VoidCallback? onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 2, offset: Offset(0, 2)),
          ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
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

  Widget _buildEmptyButton() {
    return Container(
      height: 64,
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
