import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Conversaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return buildMessageListTile(
                'Usuario ${1000 + index}',
                'Último mensaje...',
                getRandomStatus(),
                getRandomPriority(),
                index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildMessageListTile(String userId, String lastMessage, String status,
      String priority, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: getPriorityColor(priority).withOpacity(0.1),
        child: Text(
          userId.substring(userId.length - 2),
          style: TextStyle(color: getPriorityColor(priority)),
        ),
      ),
      title: Text(
        userId,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            lastMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 12, color: getStatusColor(status)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getPriorityColor(priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 12,
                    color: getPriorityColor(priority),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
        onPressed: () {},
      ),
    );
  }

  String getRandomStatus() {
    final statuses = ['Activo', 'Inactivo', 'Esperando'];
    return statuses[DateTime.now().microsecond % statuses.length];
  }

  String getRandomPriority() {
    final priorities = ['Alta', 'Media', 'Baja'];
    return priorities[DateTime.now().microsecond % priorities.length];
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return primaryColor;
      case 'media':
        return secondaryColor;
      case 'baja':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.red;
      case 'esperando':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
