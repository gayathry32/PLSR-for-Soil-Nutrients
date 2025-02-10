# PLSR-for-Soil-Nutrients
🔬 Partial Least Squares Regression (PLSR) Model for Soil Nutrient Estimation 📊 Statistical model in R for estimating soil macro &amp; micro nutrients (N, P, K, Mg, Zn, Fe) using VIS-SWIR spectroscopy. Computes VIP scores, loadings &amp; validation metrics.
# PLSR Model for Soil Nutrient Estimation using VIS-SWIR Spectroscopy

## **Overview**
This repository contains an **R-based Partial Least Squares Regression (PLSR) model** for estimating **soil macronutrients and micronutrients** using **Visible and Shortwave Infrared (VIS-SWIR) spectroscopy measurements**.

### **Nutrients Modeled:**
- **Macronutrients**: Nitrogen (**N**), Phosphorus (**P**), Potassium (**K**), Magnesium (**Mg**)
- **Micronutrients**: Zinc (**Zn**), Iron (**Fe**)

This **data-driven approach** utilizes spectral reflectance data as predictors and soil nutrient concentrations as response variables. The PLSR model reduces dimensionality and enhances predictive accuracy, making it a valuable tool for **precision agriculture** and **soil health assessment**.

---

## **How PLSR Works**
Partial Least Squares Regression (**PLSR**) is a machine learning technique used for **predicting dependent variables (soil nutrients)** from **highly collinear predictor variables (spectral data)**.

### **PLSR Modeling Steps**
1. **Feature Reduction:**  
   - Extracts latent components that explain variance in both predictor (X) and response (Y) variables.
2. **Model Fitting:**  
   - Constructs a regression model using these **new components**.
3. **Cross-Validation:**  
   - Uses **Leave-One-Out Cross-Validation (LOO-CV)** to prevent overfitting.
4. **Feature Importance:**  
   - Computes **VIP Scores** (Variable Importance in Projection) to identify the most influential spectral bands.

---

## **Repository Contents**
- **`PLSR_CODE-24-01-2025.R`** → The main R script implementing the PLSR model.
- **No datasets are provided in this repository.** Users must supply their own input files.

---
Expected Outputs
After execution, the script generates:

Model Summaries (Model_Summary.txt)
Observed vs. Predicted plots (saved in PLSR_Summary.pdf)
VIP Scores (Variable Importance in Projection) (VIP_Scores.xlsx)
PLSR Loadings (Loadings.xlsx)

## **How to Use the Code**

### **1. Clone the Repository**
```bash
git clone https://github.com/your-username/PLSR_Soil_Nutrients.git
cd PLSR_Soil_Nutrients
