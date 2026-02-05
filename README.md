# Adaptive PCM Audio Transmission System

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-Academic-blue.svg)]()
[![Project](https://img.shields.io/badge/Project-Digital%20Communications-green.svg)]()
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

> **A MATLAB-based End-to-End Digital Communication Chain Simulation with Adaptive Quantization and SNR-based Detection**

---

## 📋 Table of Contents

- [Overview](#-overview)
- [System Architecture](#-system-architecture)
- [Key Features](#-key-features)
- [Simulation Scenarios](#-simulation-scenarios)
- [Performance Metrics](#-performance-metrics)
- [Installation & Usage](#-installation--usage)
- [Results & Analysis](#-results--analysis)
- [Credits](#-credits)

---

## 🔍 Overview

This project implements a **complete End-to-End Digital Communication Chain** for audio transmission using **Pulse Code Modulation (PCM)** with advanced adaptive techniques. The system is designed to optimize audio quality under varying channel conditions by dynamically adjusting system parameters.

### Core Innovation: **Adaptive Quantization**

The system features **intelligent bit resolution ($l$) adaptation** based on available **Channel Bandwidth (BW)**:

- **Bandwidth Constraint**: $R_b \leq 2 \times BW$
- **Adaptive Resolution**: $l = \lfloor \frac{2 \times BW}{f_s} \rfloor$
- **Dynamic Levels**: $L = 2^l$ quantization levels

### SNR Adaptation

The receiver employs an **adaptive detection threshold** that automatically adjusts to channel noise conditions:

```matlab
adaptive_threshold = mean(rx_signal_noisy)  % Adapts to DC offset
rx_bits = rx_signal_noisy > adaptive_threshold
```

This ensures robust bit detection even in challenging SNR environments.

---

## 🏗️ System Architecture

![System Architecture](Report/System%20Architecture.png)

*Complete End-to-End Digital Communication Chain with 8 processing stages*

### Stage Breakdown

| Stage | Function | Purpose |
|-------|----------|---------|
| **1. A-law Compressor** | `x_comp = sign(x) * log(1 + A*|x|) / K` | Logarithmic compression to reduce dynamic range |
| **2. Uniform Quantizer** | $L = 2^l$ levels | Discretizes compressed signal into finite levels |
| **3. Binary Encoder** | Decimal → Binary (`dec2bin`) | Converts quantized indices to bit stream |
| **4. Polar NRZ Modulator** | $s(t) = 2b - 1$ | Maps bits: `0→-1V`, `1→+1V` |
| **5. AWGN Channel** | `awgn(signal, SNR_dB)` | Simulates real-world noise conditions |
| **6. Adaptive Detector** | Threshold-based decision | Recovers bits using adaptive threshold |
| **7. Binary Decoder** | Binary → Decimal | Reconstructs quantized indices |
| **8. A-law Expander** | Inverse compression | Restores original dynamic range |

---

## ✨ Key Features

- ✅ **Smart Bandwidth Adaptation**: Auto-calculates optimal bit depth ($l$) based on available BW
- ✅ **A-law Companding**: ITU-T G.711 standard with configurable parameter $A$ (default: 87.6)
- ✅ **Adaptive Threshold Detection**: Compensates for DC offset and noise variations
- ✅ **Real-time Performance Metrics**: SQNR, NMSE, BW Efficiency, Audio Quality Score
- ✅ **Comprehensive Visualization**: Plots for signal comparison, digital pulses, and error analysis
- ✅ **Audio Playback & Export**: Play and save reconstructed audio with quality indicators

---

## 🧪 Simulation Scenarios

The project validation includes **two extreme test cases** to demonstrate system adaptability:

### Scenario Comparison Table

| Parameter | **Scenario A: High Quality** | **Scenario B: Low Quality** |
|-----------|-------------------------------|------------------------------|
| **Bandwidth (BW)** | 270 kHz | 70 kHz |
| **Channel SNR** | 40 dB | 15 dB |
| **Sampling Rate ($f_s$)** | 44.1 kHz | 44.1 kHz |
| **Adaptive Bit Depth ($l$)** | **12 bits** | **3 bits** |
| **Quantization Levels ($L$)** | 4096 | 8 |
| **Transmission Rate ($R_b$)** | 529.2 kbps | 132.3 kbps |
| **BW Efficiency** | 1.96 bps/Hz | 1.89 bps/Hz |
| **SQNR** | ~50 dB | ~18 dB |

### Results Analysis

#### 📊 **Scenario A: Ideal Conditions**
- **Outcome**: Near-perfect reconstruction
- **Audio Quality**: ~100% (SQNR = 50 dB)
- **Distortion**: Minimal quantization noise
- **Use Case**: Professional audio broadcasting

#### 📉 **Scenario B: Constrained Environment**
- **Outcome**: Audible degradation present
- **Audio Quality**: ~36% (SQNR = 18 dB)
- **Distortion**: Noticeable "staircase effect" due to only 3 bits
- **Use Case**: Emergency communications, bandwidth-limited channels

> **Key Insight**: The system successfully **trades quality for bandwidth** while maintaining functional operation across extreme conditions.

---

## 📈 Performance Metrics

The system evaluates transmission quality using **six quantitative metrics**:

| Metric | Formula/Description | Interpretation |
|--------|---------------------|----------------|
| **Bit Resolution ($l$)** | $\lfloor 2 \times BW / f_s \rfloor$ | Adaptive bits per sample |
| **Transmission Rate ($R_b$)** | $l \times f_s$ | Data rate in bps |
| **BW Efficiency** | $R_b / BW$ | bps/Hz (max = 2 for Nyquist) |
| **BW Utilization** | $(Efficiency / 2) \times 100$ | % of theoretical maximum |
| **SQNR** | $10 \log_{10}(P_{signal} / P_{noise})$ | Signal quality in dB |
| **NMSE** | $\sum(x - \hat{x})^2 / \sum x^2$ | Normalized error measure |
| **Audio Quality** | $(SQNR / 50) \times 100$ | User-facing quality score (%) |

---

## 🚀 Installation & Usage

### Prerequisites

- **MATLAB** R2020a or later
- **Signal Processing Toolbox**
- **Audio Toolbox** (for `audioread`/`audiowrite`)

### Running the Simulation

1. **Clone or Download** the repository:
   ```bash
   git clone <repository-url>
   cd Kareem238253
   ```

2. **Navigate to Code folder**:
   ```bash
   cd Code
   ```

3. **Prepare Input Audio**:
   - Place your `.wav` audio file in the `Code` folder
   - Default file: `recording.wav`

4. **Run the Main Script**:
   ```matlab
   >> Kareem238253
   ```

5. **Provide System Parameters** (when prompted):
   ```
   Enter Audio file name (Default: recording.wav): <your_file.wav>
   Enter Available Transmission BW (in kHz) [Ex: 100]: 270
   Enter Channel SNR (in dB) [Ex: 20]: 40
   Enter A-law Parameter A [Standard is 87.6]: 87.6
   ```

6. **Review Output**:
   - ✅ Console displays calculated metrics
   - ✅ Plots show signal comparisons
   - ✅ Audio playback of reconstructed signal
   - ✅ Output file saved as `Received_Audio_<l>bits_SNR<SNR>.wav`

### Example Output

```
========================================
       >_< FINAL RESULTS REPORT >_<       
========================================
1. Bit Resolution (l)   : 12 bits
2. Transmission Rate    : 529.20 kbps
3. BW Efficiency        : 1.96 bps/Hz
   > BW Utilization     : 98.00 %
4. SQNR                 : 50.23 dB
5. NMSE                 : 0.000021
6. Audio Quality        : 100.00 % (Based on SQNR)
========================================
```

---

## 📊 Results & Analysis

### Visual Outputs

The system generates a **3-panel figure** for comprehensive analysis:

1. **Audio Signal Comparison**
   - Blue: Original transmitted signal
   - Red: Received reconstructed signal

2. **Digital Pulse Train**
   - Shows first 100 bits in Polar NRZ format
   - Demonstrates clean ±1V rectangular pulses

3. **Error Signal**
   - Difference between original and reconstructed
   - Highlights quantization and channel noise effects

### Sample Results

| Scenario | Input | Output | Quality Assessment |
|----------|-------|--------|--------------------|
| A (12-bit, 40dB) | [recording.wav](Code/recording.wav) | [Received_Audio_12bits_SNR40.wav](Code/Received_Audio_12bits_SNR40.wav) | Excellent (100%) |
| B (3-bit, 15dB) | [recording.wav](Code/recording.wav) | `Received_Audio_3bits_SNR15.wav` | Poor (36%) |

---

## 👥 Credits

### 🎓 Academic Supervision

- **Course Instructor**: Dr. Mohammad Abdellatif  
- **Teaching Assistant**: Eng. Mohamed Tameem

### 👨‍💻 Development

- **Student Name**: Kareem Mohammed  
- **Student ID**: 238253  
- **Course**: Digital Communications (1)  
- **Institution**: The British University in Egypt 
- **Academic Year**: 2025-2026

---

## 📄 License

This project is developed for **academic purposes** as part of the Digital Communications course curriculum.

---

## 📚 References

1. ITU-T Recommendation G.711: *Pulse code modulation (PCM) of voice frequencies*
2. Proakis, J. G., & Salehi, M. (2008). *Digital Communications* (5th ed.)
3. Haykin, S. (2013). *Communication Systems* (5th ed.)

---

<p align="center">
  <b>🎵 Adaptive PCM Audio Transmission System 🎵</b><br>
  <i>Intelligent Quality Adaptation for Varying Channel Conditions</i>
</p>
