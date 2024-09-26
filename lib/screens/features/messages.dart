import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/features/messages/graph_card.dart';
import 'package:vial_dashboard/screens/features/messages/message_list.dart';
import 'package:vial_dashboard/screens/features/messages/messaging_stats.dart';
import 'package:vial_dashboard/screens/utils/access_denied_page.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';

class MessagingDashboard extends StatelessWidget {
  const MessagingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return withAdminAccess(
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: kPadding),
                  _buildSubtitle(context),
                  const SizedBox(height: kPadding),
                  const SearchableUserList(),
                  const SizedBox(height: kPadding),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return _buildWideLayout();
                      } else {
                        return _buildNarrowLayout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: MessageList(),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              MessagingStats(),
              SizedBox(height: 20),
              GraphCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return const Column(
      children: [
        MessageList(),
        SizedBox(height: 20),
        MessagingStats(),
        SizedBox(height: 20),
        GraphCard(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Text(
      'Centro de Mensajería',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Gestión de conversaciones en tiempo real',
      style: TextStyle(color: Colors.grey[600]),
    );
  }
}
