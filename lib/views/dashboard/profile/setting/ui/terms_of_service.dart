import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Terms of Service', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Acceptance of Terms',
              content: '''
By accessing and using Homenest Vendor app, you accept and agree to be bound by these Terms of Service. If you disagree with any part, you may not access our services.
              ''',
            ),
            _buildSection(
              context,
              title: 'Service Description',
              content: '''
Homenest Vendor connects service providers with customers. We provide a platform for vendors to showcase services, manage bookings, and process payments.
              ''',
            ),
            _buildSection(
              context,
              title: 'Vendor Responsibilities',
              content: '''
• Provide accurate business information
• Maintain professional conduct
• Honor booked appointments
• Provide quality services as described
• Maintain valid licenses and certifications
• Comply with all applicable laws
              ''',
            ),
            _buildSection(
              context,
              title: 'Payment Terms',
              content: '''
• Payments processed through secure gateways
• Commission fees apply as per agreement
• Payouts processed according to schedule
• Refunds handled per our refund policy
• Tax responsibilities remain with vendor
              ''',
            ),
            _buildSection(
              context,
              title: 'Prohibited Activities',
              content: '''
• Fraudulent or misleading practices
• Spamming or unauthorized marketing
• Violating intellectual property rights
• Harassing or abusive behavior
• Circumventing payment systems
• Illegal or prohibited services
              ''',
            ),
            _buildSection(
              context,
              title: 'Termination',
              content: '''
We may terminate or suspend access to our service immediately, without prior notice, for conduct that violates these Terms or is harmful to other users.
              ''',
            ),
            _buildSection(
              context,
              title: 'Limitation of Liability',
              content: '''
Homenest shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use of the service.
              ''',
            ),
            _buildSection(
              context,
              title: 'Changes to Terms',
              content: '''
We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use constitutes acceptance of modified terms.
              ''',
            ),
            const SizedBox(height: 24),
            Text(
              'Last updated: October 2024',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
        ],
      ),
    );
  }
}
