# ==============================================================================
# Project: NHANES 2015-2016 Complex Survey Analysis on Total Cholesterol
# Description: Design-based population inference, regression modeling, and 
#              design effect calculations using CDC NHANES data.
# Author: [Your Name]
# Packages Used: survey, haven, dplyr
# ==============================================================================

# ==========================================
# 1. Load Required Packages
# ==========================================
library(haven)   # For importing CDC SAS transport files (.XPT)
library(survey)  # For complex survey design analysis
library(dplyr)   # For data manipulation

# ==========================================
# 2. Download and Load Data (Section 9)
# ==========================================
# 2015-2016 NHANES Demographics (DEMO_I) and Total Cholesterol (TCHOL_I)
demo_url <- "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.XPT"
tchol_url <- "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/TCHOL_I.XPT"

download.file(demo_url, destfile = "DEMO_I.XPT", mode = "wb")
download.file(tchol_url, destfile = "TCHOL_I.XPT", mode = "wb")

demo_data <- read_xpt("DEMO_I.XPT")
tchol_data <- read_xpt("TCHOL_I.XPT")

# ==========================================
# 3. Data Pre-processing & Merging (Section 2.2 & 9)
# ==========================================
# Merge on SEQN and select key variables
analytic_data <- demo_data %>%
  inner_join(tchol_data, by = "SEQN") %>%
  select(
    SEQN, 
    WTMEC2YR,   # Mobile Examination Center weight
    SDMVPSU,    # Primary Sampling Unit
    SDMVSTRA,   # Stratification variable
    LBXTC,      # Total cholesterol (mg/dL)
    RIDAGEYR,   # Age in years
    RIAGENDR,   # Gender (1 = Male, 2 = Female)
    RIDRETH1    # Race/Ethnicity
  ) %>%
  # Filter complete cases for the variables used in analysis
  filter(!is.na(LBXTC), !is.na(WTMEC2YR), !is.na(RIDAGEYR), 
         !is.na(RIAGENDR), !is.na(RIDRETH1)) %>%
  mutate(
    gender = factor(RIAGENDR, levels = c(1, 2), labels = c("Male", "Female")),
    race_eth = factor(RIDRETH1, levels = 1:5, 
                      labels = c("Mexican American", "Other Hispanic", 
                                 "Non-Hispanic White", "Non-Hispanic Black", 
                                 "Other/Multi-Racial")),
    high_chol = ifelse(LBXTC >= 240, 1, 0) # Clinical cutoff indicator
  )

# ==========================================
# 4. Construct Survey Design Object (Section 5)
# ==========================================
nhanes_design <- svydesign(
  id = ~SDMVPSU,
  strata = ~SDMVSTRA,
  weights = ~WTMEC2YR,
  nest = TRUE,
  data = analytic_data
)

# ==========================================
# 5. Finite Population Inference (Section 6)
# ==========================================

# 6.1 Mean Cholesterol
mean_chol <- svymean(~LBXTC, nhanes_design)
mean_chol
confint(mean_chol)

# 6.2 Proportion with High Cholesterol (>= 240 mg/dL)
prop_high <- svymean(~high_chol, nhanes_design)
prop_high
confint(prop_high)

# 6.3 Ratio Estimator (Cholesterol to Age)
ratio_est <- svyratio(~LBXTC, ~RIDAGEYR, nhanes_design)
ratio_est
confint(ratio_est)

# 6.4 Regression Estimator
reg_model <- svyglm(LBXTC ~ RIDAGEYR + gender + race_eth, design = nhanes_design)
summary(reg_model)

# 6.5 Subgroup Analysis (Gender & Race)
svyby(~LBXTC, ~gender, nhanes_design, svymean)
svyby(~LBXTC, ~race_eth, nhanes_design, svymean)

# ==========================================
# 6. Design Effect & Efficiency (Section 7)
# ==========================================
# Compare Naive SRS Standard Error vs Design-Based Standard Error
svymean(~LBXTC, nhanes_design, deff = TRUE)
