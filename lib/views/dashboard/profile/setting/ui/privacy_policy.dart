import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Privacy Policy', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
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
              title: 'Information We Collect',
              content: '''
• Personal Information: Name, email, phone number, business details
• Business Information: Company name, address, services offered
• Professional Details: Experience, skills, certifications
• Financial Information: Bank details for payment processing
• Documents: Identity proofs, business licenses, certificates
• Usage Data: App interactions, preferences, settings
              ''',
            ),
            _buildSection(
              context,
              title: 'How We Use Your Information',
              content: '''
• Provide and maintain our services
• Process payments and manage your account
• Verify your identity and business credentials
• Communicate with you about services and updates
• Improve our app and user experience
• Comply with legal obligations
              ''',
            ),
            _buildSection(
              context,
              title: 'Data Security',
              content: '''
We implement appropriate security measures to protect your personal information:
• Encryption of sensitive data
• Secure servers and databases
• Regular security assessments
• Limited access to personal information
• Secure payment processing
              ''',
            ),
            _buildSection(
              context,
              title: 'Data Sharing',
              content: '''
We do not sell your personal information. We may share data with:
• Payment processors for transaction completion
• Legal authorities when required by law
• Service providers who assist our operations
• Business partners with your consent
              ''',
            ),
            _buildSection(
              context,
              title: 'Your Rights',
              content: '''
You have the right to:
• Access your personal information
• Correct inaccurate data
• Delete your account and data
• Export your data
• Object to data processing
• Withdraw consent
              ''',
            ),
            _buildSection(
              context,
              title: 'Contact Us',
              content: '''
If you have questions about this Privacy Policy, contact us at:
Email: privacy@homenest.com
Phone: +1-555-0123
Address: 123 Business Street, City, State 12345
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
