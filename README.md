# Automated System for Bearing Fault Detection in MATLAB

This repository contains the auxiliary files for the project **"Automated System for Bearing Fault Detection in MATLAB."** The project focuses on designing an automated system for detecting and classifying bearing faults using signal processing and machine learning techniques.

## Repository Structure

```
├── Code
│   ├── signal_analysis.m             % Initial exploration and signal analysis
│   ├── data_preprocessing.m         % Signal preprocessing and feature extraction
│   ├── model_training_and_validation.m % Machine learning model training and validation
├── Figures
│   ├── decission_tree_confusion_matrix.fig
│   ├── decission_tree_structure.fig
│   ├── feature_importance_random_forest.fig
│   ├── Inner_Race_envelope.fig
│   ├── Inner_Race_power_spectrum.fig
│   ├── outer_race_filtered_envelope.fig
│   ├── outer_race_kurtogram.fig
│   ├── outer_race_kurtosis_filtered.fig
│   ├── random_forest_confusion_tree.fig
├── Data
│   ├── baseline_signals.mat          % Healthy bearing signals
│   ├── inner_race_fault_signals.mat  % Inner race fault signals
│   ├── outer_race_fault_signals.mat  % Outer race fault signals
├── final_report.pdf                 % The final project report
├── README.md                        % Project documentation
```

## Description of Files

### Code
- **signal_analysis.m**: Performs initial exploration and visualization of vibration signals to identify patterns and noise characteristics.
- **data_preprocessing.m**: Implements preprocessing techniques including resampling, sliding window segmentation, and feature extraction.
- **model_training_and_validation.m**: Trains machine learning models (Decision Tree and Random Forest) and evaluates their performance.

### Figures
- MATLAB figure files generated during analysis and model validation.
  - Confusion matrices for both models
  - Kurtogram visualization
  - Filtered and unfiltered signal spectra
  - Feature importance and decision tree structure

### Data
- **baseline_signals.mat**: Contains vibration signals for healthy bearings.
- **inner_race_fault_signals.mat**: Vibration signals for inner race faults.
- **outer_race_fault_signals.mat**: Vibration signals for outer race faults.

### Final Report
- **final_report.pdf**: A comprehensive report documenting the methodology, analysis, and results of the project.

## Usage

1. **Signal Analysis**:
   - Open and run `signal_analysis.m` to visualize and explore raw vibration signals.

2. **Data Preprocessing**:
   - Use `data_preprocessing.m` to apply preprocessing steps such as resampling, sliding window segmentation, and feature extraction.

3. **Model Training and Validation**:
   - Execute `model_training_and_validation.m` to train Decision Tree and Random Forest models and validate their performance using confusion matrices.

4. **Figures**:
   - Load `.fig` files in MATLAB to visualize results such as confusion matrices and kurtograms.

5. **Data**:
   - The `Data` folder contains the necessary vibration signal datasets for running the code.

## Requirements
- MATLAB R2023a or later
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

## License
This project is for educational purposes and is not intended for commercial use.

---
For more details, refer to the **final_report.pdf**.

