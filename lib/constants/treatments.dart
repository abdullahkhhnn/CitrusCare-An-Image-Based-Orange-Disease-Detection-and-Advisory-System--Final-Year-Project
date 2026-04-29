class TreatmentRecommendations {
  static const Map<String, Map<String, dynamic>> treatments = {
    'Aphids': {
      'description': 'Aphids are small sap-sucking insects that can damage citrus leaves and transmit diseases.',
      'causes': '''
Common Causes:

- Warm and dry weather conditions that favor rapid aphid reproduction
- Presence of ant colonies that protect aphids from natural predators
- Over-fertilization with nitrogen causing excessive soft new growth
- Poor air circulation around plants encouraging colony buildup
- Nearby infested plants spreading aphids through wind or contact
- Lack of natural predators such as ladybugs and lacewings
- Stress conditions such as drought or waterlogging weakening plant defenses
- Introduction of new plants carrying aphid eggs or colonies
''',
      'treatment': '''
Treatment Recommendations:

1. Natural Control:
   • Spray neem oil solution (2-3 tablespoons per gallon of water)
   • Use insecticidal soap spray
   • Introduce natural predators (ladybugs, lacewings)

2. Chemical Control:
   • Apply imidacloprid-based systemic insecticide
   • Use pyrethrin-based contact sprays
   • Spray malathion (follow label instructions)

3. Prevention:
   • Remove heavily infested leaves
   • Maintain proper plant nutrition
   • Monitor plants regularly
   • Avoid over-fertilizing with nitrogen

4. Application Tips:
   • Spray early morning or late evening
   • Cover both upper and lower leaf surfaces
   • Repeat treatment every 7-10 days if needed
''',
      'severity': 'Moderate',
      'color': 0xFFFF9800,
    },
    'Healthy': {
      'description': 'Your citrus plant appears to be healthy with no visible signs of disease.',
      'causes': '''
Your Plant is Healthy!

- No disease or pest infestation detected
- Plant is receiving adequate nutrition and care
- Environmental conditions are favorable for growth
- Good farming practices are being followed
- Continue current maintenance routine to keep plant healthy
''',
      'treatment': '''
Maintenance Recommendations:

1. Regular Care:
   • Continue regular watering schedule
   • Maintain proper fertilization
   • Prune dead or damaged branches
   • Keep the area around plant clean

2. Prevention:
   • Monitor leaves regularly for pests
   • Ensure good air circulation
   • Avoid overwatering
   • Maintain proper soil pH (6.0-7.5)

3. Nutrition:
   • Apply citrus-specific fertilizer (NPK 6-4-6)
   • Fertilize every 4-6 weeks during growing season
   • Add compost or organic matter annually

4. General Tips:
   • Inspect new growth regularly
   • Remove fallen leaves promptly
   • Ensure adequate sunlight (6-8 hours daily)
   • Water deeply but infrequently
''',
      'severity': 'None',
      'color': 0xFF4CAF50,
    },
    'Leaf Miner': {
      'description': 'Leaf miners are larvae that tunnel between leaf surfaces, creating characteristic serpentine trails.',
      'causes': '''
Common Causes:

- Adult leaf miner flies (Liriomyza species) laying eggs inside leaf tissue
- Warm and humid weather conditions accelerating larval development
- Dense plant canopy reducing air circulation and visibility of infestation
- Excessive nitrogen fertilization producing soft succulent growth attractive to flies
- Lack of natural predators such as parasitic wasps in the area
- New leaf flush periods providing fresh tissue for egg-laying
- Nearby infested plants spreading adult flies to healthy plants
- Absence of pest monitoring allowing early infestations to go undetected
- Import of infested nursery stock or plant material
''',
      'treatment': '''
Treatment Recommendations:

1. Organic Control:
   • Apply spinosad-based pesticide
   • Use neem oil spray (every 7-14 days)
   • Remove and destroy affected leaves
   • Apply horticultural oil

2. Chemical Control:
   • Systemic insecticides (imidacloprid)
   • Abamectin spray for severe infestations
   • Cyromazine for preventive control

3. Cultural Practices:
   • Prune and dispose of infested leaves
   • Avoid excessive nitrogen fertilization
   • Use yellow sticky traps to catch adult flies
   • Protect new growth during flushing periods

4. Biological Control:
   • Encourage parasitic wasps
   • Avoid broad-spectrum insecticides that kill beneficials
   • Maintain diverse garden ecosystem

5. Application Schedule:
   • Treat during new leaf flush periods
   • Apply systemic treatments before spring growth
   • Monitor weekly during peak season
''',
      'severity': 'High',
      'color': 0xFFF44336,
    },
  };

  static Map<String, dynamic>? getTreatment(String disease) {
    return treatments[disease];
  }

  static String getDescription(String disease) {
    return treatments[disease]?['description'] ?? 'No information available';
  }

  static String getCauses(String disease) {
    return treatments[disease]?['causes'] ?? 'No causes information available';
  }

  static String getTreatmentText(String disease) {
    return treatments[disease]?['treatment'] ?? 'No treatment information available';
  }

  static String getSeverity(String disease) {
    return treatments[disease]?['severity'] ?? 'Unknown';
  }

  static int getColor(String disease) {
    return treatments[disease]?['color'] ?? 0xFF9E9E9E;
  }
}