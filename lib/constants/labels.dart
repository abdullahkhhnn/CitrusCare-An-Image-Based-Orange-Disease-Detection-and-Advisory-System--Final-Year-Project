class DiseaseLabels {
  static const Map<int, String> labels = {
    0: 'Aphids',
    1: 'Healthy',
    2: 'Leaf Miner',
  };

  static String getLabel(int index) {
    return labels[index] ?? 'Unknown';
  }

  static int getTotalClasses() {
    return labels.length;
  }
}