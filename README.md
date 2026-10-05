# QESDO: Q-learning Enhanced Self-adaptive Dandelion Optimizer

## Overview

QESDO is a hybrid metaheuristic algorithm that augments the Dandelion Optimizer (DO) with four synergistic mechanisms:

1. **Q-learning Adaptive Operator Selection**: Learns which search operator to apply based on the current search state
2. **Opposition-Based Learning (OBL)**: For population initialization and elite jumping
3. **Memetic Elite Local Search**: Gaussian refinement around the best solution
4. **Self-adaptive Parameter Control**: Success-history based adaptation of Lévy scale and step factors

## Files in This Package

### Main Scripts
- `main.m` - Main experimental comparison script (runs all experiments)
- `demo_QESDO.m` - Quick demonstration script
- `AblationStudy.m` - Component contribution analysis

### Algorithm Implementations
- `QESDO.m` - **Proposed Algorithm**: Q-learning Enhanced Self-adaptive Dandelion Optimizer
- `DO.m` - Dandelion Optimizer (Zhao et al., 2022)
- `GWO.m` - Grey Wolf Optimizer (Mirjalili et al., 2014)
- `PSO.m` - Particle Swarm Optimization (Kennedy & Eberhart, 1995)
- `DE.m` - Differential Evolution (Storn & Price, 1997)
- `GA.m` - Genetic Algorithm (Holland, 1992)

### Utility Functions
- `initialization.m` - Population initialization
- `Get_Functions_details.m` - Benchmark test functions (F1-F23)
- `StatisticalTests.m` - Friedman and Wilcoxon signed-rank tests
- `AdvancedStatistics.m` - Enhanced statistics with Holm correction
- `PlotResults.m` - Convergence curves and box plots generation
- `SaveResultsToExcel.m` - Export complete results to Excel
- `SaveConvergenceCurves.m` - Save individual convergence curves for each function
- `ExportResultsToLatex.m` - Export results to LaTeX tables

### Publication Template
- `QESDO_Paper.tex` - Complete LaTeX research article template for Overleaf

## Quick Start

### Run Quick Demo
```matlab
>> demo_QESDO
```

### Run Full Experiments
```matlab
>> main
```

### Run Ablation Study
```matlab
>> AblationStudy
```

## Usage

### Basic Usage
```matlab
% Define problem
dim = 30;
lb = -100 * ones(1, dim);
ub = 100 * ones(1, dim);
fobj = @(x) sum(x.^2);  % Sphere function

% Run QESDO
N = 50;  % Population size
MaxIter = 500;  % Maximum iterations
[bestX, bestF, curve] = QESDO(N, MaxIter, lb, ub, dim, fobj);

% Display results
fprintf('Best fitness: %.6e\n', bestF);
semilogy(curve);
```

### Using Benchmark Functions
```matlab
% Get function details
[lb, ub, dim, fobj] = Get_Functions_details(9);  % F9: Rastrigin

% Run QESDO
[bestX, bestF, curve] = QESDO(50, 500, lb, ub, dim, fobj);
```

## Benchmark Functions

| ID | Name | Type | Domain |
|----|------|------|--------|
| F1 | Sphere | Unimodal | [-100, 100] |
| F2 | Schwefel 2.22 | Unimodal | [-10, 10] |
| F3 | Schwefel 1.2 | Unimodal | [-100, 100] |
| F4 | Schwefel 2.21 | Unimodal | [-100, 100] |
| F5 | Rosenbrock | Unimodal | [-30, 30] |
| F6 | Step | Unimodal | [-100, 100] |
| F7 | Quartic with Noise | Unimodal | [-1.28, 1.28] |
| F8 | Schwefel 2.26 | Multimodal | [-500, 500] |
| F9 | Rastrigin | Multimodal | [-5.12, 5.12] |
| F10 | Ackley | Multimodal | [-32, 32] |
| F11 | Griewank | Multimodal | [-600, 600] |
| F12-F13 | Penalized | Multimodal | [-50, 50] |
| F14-F23 | Fixed-dim Multimodal | Various | Various |

## Algorithm Parameters

### QESDO Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| N | 50 | Population size |
| Max_iter | 500 | Maximum iterations |
| alphaQ | 0.6 | Q-learning rate |
| gammaQ | 0.9 | Q-learning discount factor |
| eps0 | 0.9 | Initial epsilon (exploration) |
| epsEnd | 0.05 | Final epsilon |
| Jr | 0.3 | OBL elite jump probability |
| sigma0 | 0.5 | Initial memetic LS sigma |
| smin | 0.001 | Minimum Lévy scale |
| smax | 0.5 | Maximum Lévy scale |

## Output Files

After running `main.m`, the following files are generated:

### Results Data
- `QESDO_Results.mat` - Complete experimental results (MATLAB format)

### Excel Files (in `Results_Excel/`)
- `QESDO_Complete_Results.xlsx` - Complete results with multiple sheets:
  - `D=30`, `D=50`, etc. - Results for each dimension (Mean, Std, Best, Worst, Median)
  - `Rankings` - Algorithm rankings for each function
  - `Mean_Comparison` - Mean values only (for easy comparison)
  - `Std_Comparison` - Standard deviation values only
  - `AllRuns_D*` - All 30 runs data for each dimension
- `Mean_Results_D*.csv` - Mean results in CSV format
- `Std_Results_D*.csv` - Std results in CSV format

### Individual Convergence Curves (in `Results_Convergence/D*/`)
- `F1_Convergence.png` - Individual curve for F1 (PNG, 300 DPI)
- `F1_Convergence.fig` - MATLAB figure file
- `F1_Convergence.eps` - EPS format for LaTeX
- `F2_Convergence.png`, `F3_Convergence.png`, ... (for all functions)
- `Combined_Unimodal.png` - Combined unimodal functions (F1-F7)
- `Combined_Multimodal.png` - Combined multimodal functions (F8-F13)
- `Combined_FixedDim.png` - Combined fixed-dimension functions (F14-F23)
- `Combined_All.png` - All functions combined

### Individual Box Plots (in `Results_BoxPlots/D*/`)
- `F1_BoxPlot.png` - Box plot for F1 comparing all algorithms
- `F1_BoxPlot.fig` - MATLAB figure file
- `F1_BoxPlot.eps` - EPS format for LaTeX
- `F2_BoxPlot.png`, `F3_BoxPlot.png`, ... (for all functions)
- `Combined_BoxPlot_Unimodal.png` - Combined unimodal box plots
- `Combined_BoxPlot_Multimodal.png` - Combined multimodal box plots
- `Combined_BoxPlot_FixedDim.png` - Combined fixed-dim box plots
- `Combined_BoxPlot_All.png` - All functions combined

### Ranking Images (in `Results_Rankings/D*/`)
- `Ranking_BarChart.png` - Average ranking bar chart
- `Ranking_BarChart.fig` - MATLAB figure file
- `Ranking_BarChart.eps` - EPS format for LaTeX
- `Ranking_Heatmap.png` - Ranking heatmap (functions × algorithms)
- `WinTieLoss_Chart.png` - QESDO win/tie/loss analysis
- `Ranking_ByType.png` - Rankings separated by function type
- `Ranking_Radar.png` - Radar/spider chart visualization
- `Ranking_Table.png` - Complete ranking table as image

### Combined Figures (in `Results_Figures/`)
- `Convergence_Curves_D*.png` - Combined convergence curves
- `BoxPlots_D*.png` - Combined box plots
- `Rankings_D*.png` - Algorithm ranking bar charts
- `RankingHeatmap_D*.png` - Ranking heatmaps

### LaTeX Tables (in `Results_Tables/`)
- `Results_D*.tex` - LaTeX tables for each dimension
- `Results_D*.csv` - CSV format results
- `Rankings_Summary.tex` - Rankings summary table

## Statistical Tests

### Friedman Test
- Tests if there are significant differences among all algorithms
- Uses Iman-Davenport F-statistic
- Includes Nemenyi post-hoc test with Critical Difference (CD)

### Wilcoxon Signed-Rank Test
- Pairwise comparison: QESDO vs. each competitor
- Tests for significant differences at α = 0.05
- Reports W+, W-, and p-values

## Citation

If you use this code in your research, please cite:

```bibtex
@article{QESDO2024,
  title={QESDO: A Q-learning-driven Self-adaptive Hybrid of the Dandelion Optimizer 
         with Opposition-based Learning and Memetic Local Search for Global Optimization},
  author={Your Name},
  journal={Journal Name},
  year={2024},
  volume={},
  pages={}
}
```

## References

1. Zhao, S., Zhang, T., Ma, S., & Chen, M. (2022). Dandelion Optimizer: A nature-inspired metaheuristic algorithm for engineering applications. *Engineering Applications of Artificial Intelligence*, 114, 105075.

2. Mirjalili, S., Mirjalili, S. M., & Lewis, A. (2014). Grey Wolf Optimizer. *Advances in Engineering Software*, 69, 46-61.

3. Storn, R., & Price, K. (1997). Differential evolution–a simple and efficient heuristic for global optimization over continuous spaces. *Journal of global optimization*, 11(4), 341-359.

5. Tizhoosh, H. R. (2005). Opposition-based learning: A new scheme for machine intelligence. *CIMCA-IAWTIC*, 695-701.

## License

This code is provided for academic and research purposes only.

## Contact

For questions or issues, please contact [your email].
#   Q E S D O  
 #   Q E S D O  
 