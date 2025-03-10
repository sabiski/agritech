import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/stock_model.dart';
import '../../controllers/stock_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class StockItem extends StatelessWidget {
  final StockModel stock;
  final StockController controller = Get.find<StockController>();

  StockItem({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = stock.isExpired;
    final isNearExpiration = stock.isNearExpiration;
    final isLowStock = stock.isLowStock;

    Color statusColor = Colors.green;
    if (isExpired) {
      statusColor = Colors.red;
    } else if (isNearExpiration) {
      statusColor = Colors.orange;
    } else if (isLowStock) {
      statusColor = Colors.yellow;
    }

    return Card(
      child: InkWell(
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Catégorie : ${stock.category}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.inventory,
                      title: 'Quantité',
                      value: '${stock.quantity} ${stock.unit}',
                      color: isLowStock ? Colors.orange : Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today,
                      title: 'Date d\'expiration',
                      value: DateFormat('dd/MM/yyyy').format(stock.expirationDate),
                      color: isExpired ? Colors.red : (isNearExpiration ? Colors.orange : Colors.black87),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.attach_money,
                      title: 'Prix',
                      value: '${stock.price} FCFA',
                    ),
                  ),
                ],
              ),
              if (stock.description != null && stock.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stock.description!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stock.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.black87,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implémenter le formulaire d'édition
    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le stock'),
        content: const Text('Formulaire d\'édition à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${stock.name}" du stock ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStock(stock.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
} 