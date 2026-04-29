import 'dart:io';
import 'package:flutter/material.dart';
import 'map_screen.dart';
import '../constants/treatments.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> predictionResult;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.predictionResult,
  });

  @override
  Widget build(BuildContext context) {
    final String disease = predictionResult['disease'];
    final double confidence = predictionResult['confidence'];
    final List<double> probabilities = predictionResult['probabilities'];
    final bool isValid = predictionResult['isValid'] ?? true;

    // If invalid prediction somehow reaches here, go back
    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final treatmentData = TreatmentRecommendations.getTreatment(disease);
    final String description = treatmentData?['description'] ?? '';
    final String causes = treatmentData?['causes'] ?? '';       // ← NEW
    final String treatment = treatmentData?['treatment'] ?? '';
    final String severity = treatmentData?['severity'] ?? 'Unknown';
    final Color severityColor = Color(treatmentData?['color'] ?? 0xFF9E9E9E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Display
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.black,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),

            // Results Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            severityColor.withOpacity(0.8),
                            severityColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.analytics,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Detected Condition',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            disease,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Severity: $severity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: severityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // All Probabilities
                  _buildSectionTitle(
                    'Detection Confidence',
                    Icons.bar_chart,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  _buildProbabilityBars(probabilities),

                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle(
                    'Description',
                    Icons.description,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Causes Section ← NEW
                  if (disease != 'Healthy') ...[
                    _buildSectionTitle(
                      'Causes',
                      Icons.warning_amber_rounded,
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        causes,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Healthy plant causes (different style)
                  if (disease == 'Healthy') ...[
                    _buildSectionTitle(
                      'Plant Status',
                      Icons.check_circle,
                      Colors.green.shade700,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        causes,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Treatment Recommendations
                  _buildSectionTitle(
                    'Treatment Recommendations',
                    Icons.medical_services,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      treatment,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Find Medicine Shop Button
                  if (disease != 'Healthy')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(disease: disease),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on, size: 28),
                        label: const Text('Find Nearby Medicine Shops'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // New Scan Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Another Leaf'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to accept color parameter
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityBars(List<double> probabilities) {
    final labels = ['Aphids', 'Healthy', 'Leaf Miner'];

    return Column(
      children: List.generate(probabilities.length, (index) {
        final prob = probabilities[index];
        final label = labels[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(prob * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: prob,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForProbability(prob),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getColorForProbability(double prob) {
    if (prob > 0.7) {
      return Colors.green;
    } else if (prob > 0.4) {
      return Colors.orange;
    } else {
      return Colors.red.shade300;
    }
  }
}