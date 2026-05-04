# CitrusCare-An-Image-Based-Orange-Disease-Detection-and-Advisory-System--Final-Year-Project

#  CitrusCare – AI-Based Orange Disease Detection & Advisory System

CitrusCare is an AI-powered mobile application that detects diseases in orange plants using deep learning and provides instant treatment recommendations. It is designed to assist farmers in quickly identifying plant diseases using a smartphone, even in offline environments.

This project was developed as our **Final Year Project at FAST National University** and successfully defended.

---

##  Project Motivation

While working on our own citrus farms, we faced serious difficulties in identifying plant diseases early. There was no fast, accessible, and reliable solution for farmers.

To solve this real-world problem, we developed **CitrusCare**, combining computer vision and mobile technology to assist farmers in the field.

---

##  Key Features

-  Real-time plant disease detection from leaf images  
-  Deep learning-based classification (MobileNetV2)  
-  Cross-platform mobile application (Flutter)  
-  Offline disease prediction capability  
-  Treatment recommendations and advisory system  
-  Fast, lightweight, and user-friendly interface  

---

##  Tech Stack

- **Mobile App:** Flutter (Dart)  
- **Machine Learning:** TensorFlow / Keras  
- **Model Architecture:** MobileNetV2 (Transfer Learning)  
- **Deployment Format:** TensorFlow Lite (.tflite)  
- **Platform:** Android  

---

##  Model Performance

- **Accuracy:** 97.4%  
- **Model Type:** Convolutional Neural Network (CNN)  
- **Training Approach:** Transfer Learning (MobileNetV2)  

---

##  Dataset Information

The dataset was collected from real citrus farms under natural conditions, including variations in lighting, weather, and leaf health conditions.

### Dataset Classes:
- Healthy leaves  
- Leaves affected by aphids  
- Leaves affected by leaf miner disease  

 Dataset will be published on Kaggle:  https://www.kaggle.com/datasets/superlord/citrus-diseases


---

##  System Workflow

1. User captures or uploads a leaf image  
2. Image is preprocessed and resized  
3. TensorFlow Lite model runs inference  
4. Disease is classified with confidence score  
5. Treatment recommendations are displayed  
6. Works offline for field usability  

---

##  Project Architecture

- Flutter Mobile App (Frontend)  
- TensorFlow Lite Model (Edge AI)  
- Image Preprocessing Pipeline  
- Classification Engine  
- Recommendation System
- 
---

##  How to Run the Project

### 1. Clone Repository
```bash id="clone_cmd"
git clone https://github.com/your-username/citruscare.git

flutter pub get
flutter run

## Contributors
Abdullah Khan
Mian Misbah ur Rehman
Muhammad Hussam
