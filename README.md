# nhanes-cholesterol-analysis
Design-based statistical analysis of total cholesterol using 2015-2016 NHANES survey data in R.
Contains a design-based statistical analysis evaluating population-level total cholesterol in the U.S. using data from the 2015–2016 National Health and Nutrition Examination Survey (NHANES). 
The project accounts for complex multistage probability sampling (stratification, clustering, and Mobile Examination Center sample weights) using the `survey` package in R.

## Key Findings
* **Population Mean Total Cholesterol:** ~185.93 mg/dL (95% CI: 183.45–188.41)
* **High Cholesterol Prevalence:** ~10.43% of the target population
* **Design Effect Impact:** Incorporating the complex design increased standard error from 0.49 (naive SRS) to 1.27, demonstrating the critical importance of design-based inference.

## Repository Contents
* `nhanes_analysis.R`: Executable R code covering data ingestion, pre-processing, survey design setup, and statistical modeling.
* `NHANES_Cholesterol_Report.pdf`: Full written statistical report detailing methodology and inference.
* `Presentation_Slides.pdf`: Executive presentation summary.

## How to Run
1. Clone this repository.
2. Ensure `haven`, `survey`, and `dplyr` packages are installed in R.
3. Run `nhanes_analysis.R`. Data will be downloaded directly from the CDC servers.
