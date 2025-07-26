import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class AgricultureFieldScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Agriculture Fields'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            SizedBox(height: 16),
            _buildFieldsList(),
            SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Field Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Fields', '12', Icons.landscape),
              ),
              Expanded(
                child: _buildStatItem('Active', '8', Icons.check_circle),
              ),
              Expanded(
                child: _buildStatItem('Harvesting', '3', Icons.agriculture),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsList() {
    final fields = [
      {
        'name': 'Rice Field Premium Plot R8',
        'location': '7°47\'44.1"S, 110°22\'10.2"E',
        'area': '6.2 ha',
        'status': 'Towards Harvest',
        'statusColor': AppColors.success,
        'activities': 12,
        'crop': 'Rice',
        'plantedDate': '2024-01-15',
        'expectedHarvest': '2024-06-15',
      },
      {
        'name': 'Maize Field Section M3',
        'location': '7°48\'12.3"S, 110°21\'45.7"E',
        'area': '4.8 ha',
        'status': 'Growing',
        'statusColor': AppColors.primary,
        'activities': 8,
        'crop': 'Maize',
        'plantedDate': '2024-02-01',
        'expectedHarvest': '2024-07-01',
      },
      {
        'name': 'Tomato Greenhouse T1',
        'location': '7°47\'55.2"S, 110°22\'30.8"E',
        'area': '0.5 ha',
        'status': 'Planting',
        'statusColor': AppColors.warning,
        'activities': 5,
        'crop': 'Tomato',
        'plantedDate': '2024-03-10',
        'expectedHarvest': '2024-06-10',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Fields',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...fields.map((field) => _buildFieldCard(field)).toList(),
      ],
    );
  }

  Widget _buildFieldCard(Map<String, dynamic> field) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  field['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: field['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  field['status'],
                  style: TextStyle(
                    color: field['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            field['location'],
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildFieldInfo(Icons.landscape, field['area']),
              SizedBox(width: 16),
              _buildFieldInfo(Icons.assignment, '${field['activities']} Activities'),
              SizedBox(width: 16),
              _buildFieldInfo(Icons.eco, field['crop']),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Planted: ${field['plantedDate']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.event, size: 14, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Harvest: ${field['expectedHarvest']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add Field',
                  onPressed: () {
                    // Show add field dialog
                    _showComingSoonDialog();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Field Report',
                  color: Colors.white,
                  textColor: AppColors.primary,
                  onPressed: () {
                    _showComingSoonDialog();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    // This would be implemented in the actual widget context
    // For now, just a placeholder
  }
}