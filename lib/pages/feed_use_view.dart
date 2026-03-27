import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/feed_use_controller.dart';
import '../controller/morta_controller.dart';
import 'feed_calculator_view.dart';
import 'morta_calculator_view.dart';
import 'summary_page.dart';

class FeedUseView extends StatefulWidget {
  final int initialTabIndex;
  const FeedUseView({super.key, this.initialTabIndex = 0});

  @override
  State<FeedUseView> createState() => _FeedUseViewState();
}

class _FeedUseViewState extends State<FeedUseView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedUseController controller = Get.put(FeedUseController());
  final MortaController mortaController = Get.put(MortaController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            final isMorta = _tabController.index == 1;
            Get.off(() => SummaryPage(isMorta: isMorta));
          },
        ),
        title: const Text(
          'FARM JONI HERMAN 1A_802CF00...',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        actions: const [
          Icon(Icons.bluetooth, color: Colors.black, size: 20),
          SizedBox(width: 16),
          Icon(Icons.refresh, color: Colors.black, size: 20),
          SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Color(0xFF6B4AC3),
          tabs: const [
            Tab(text: "Feed"),
            Tab(text: "Morta"),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildInfoRow('Organisasi', 'FARM JONI HERMAN - SMSJ'),
                  _buildInfoRow('Tgl. DOC In', 'Belum Doc In'),
                  _buildInfoRow('DOC In', '0 EKOR'),
                  _buildInfoRow('Umur', '1 HARI'),
                  _buildInfoRow('Email', 'itsjave18@gmail.com'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [FeedCalculatorView(), MortaCalculatorView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              ': $value',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
