import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agent/presentation/agent_screen.dart';
import '../../dashboard/presentation/admin_dashboard_screen.dart';
import '../../parcels/presentation/parcels_providers.dart';
import '../../tracking/presentation/customer_tracking_screen.dart';

class RoleGateScreen extends ConsumerStatefulWidget {
  const RoleGateScreen({super.key});

  @override
  ConsumerState<RoleGateScreen> createState() => _RoleGateScreenState();
}

class _RoleGateScreenState extends ConsumerState<RoleGateScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationsServiceProvider).initialize();
    ref.read(syncServiceProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courier Control System')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roleButton(context, 'Admin', () => _push(context, const AdminDashboardScreen())),
              _roleButton(context, 'Agent', () => _push(context, const AgentScreen(agentId: 'agent-a'))),
              _roleButton(context, 'Customer Tracking', () => _push(context, const CustomerTrackingScreen())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onTap, child: Text(label)),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
