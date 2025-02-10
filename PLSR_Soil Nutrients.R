# Load required libraries
if (!require("pls")) install.packages("pls", dependencies = TRUE)
library(pls)
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
library(readxl)
if (!require("openxlsx")) install.packages("openxlsx", dependencies = TRUE)
library(openxlsx)
if (!require("caret")) install.packages("caret", dependencies = TRUE)
library(caret)
if (!require("factoextra")) install.packages("factoextra", dependencies = TRUE)
library(factoextra)
if (!require("gplots")) install.packages("gplots", dependencies = TRUE)
library(gplots)
library(ggplot2)

# Set seed for reproducibility
set.seed(123)

# Set the working directory
setwd("D:/Master_Tesis/DATA") # Update this path as needed

# Read the files from Excel
predictors <- read_excel("predictor_data.xlsx")
response <- read_excel("response_data.xlsx")

# Check dimensions of predictors and responses
cat("Dimensions of predictors:", dim(predictors), "\n")
cat("Dimensions of response:", dim(response), "\n")

# Ensure all columns are numeric
predictors <- predictors[, sapply(predictors, is.numeric)]
response <- response[, sapply(response, is.numeric)]

# Check the number of rows in predictors and response
if (nrow(predictors) != nrow(response)) {
  stop("The number of rows in predictors and response must be the same.")
}

# Standardize predictors
predictors_scaled <- as.data.frame(scale(predictors))

# Create Excel workbooks for VIP scores and loadings
wb_vip <- createWorkbook()
wb_loadings <- createWorkbook()

# Create a PDF file for the summary
pdf(file.path(getwd(), "PLSR_Summary.pdf"))

# Function to calculate VIP scores
calculate_vip <- function(plsr_model) {
  ncomp <- plsr_model$ncomp
  W <- plsr_model$loading.weights  # Predictor weights
  Yscores <- plsr_model$Yscores    # Response scores
  SS <- colSums(Yscores^2)         # Sum of squares of response scores
  
  # Square the weights
  W_squared <- W^2  # Dimensions: predictors x components
  
  # Create diagonal matrix from SS scaled by number of components
  SS_diag <- diag(SS / ncomp, nrow = ncomp, ncol = ncomp)  # Components x Components
  
  # Check dimensions before multiplication
  cat("Dimensions of W_squared:", dim(W_squared), "\n")
  cat("Dimensions of SS_diag:", dim(SS_diag), "\n")
  
  # Multiply and calculate VIP scores
  VIPs <- sqrt(rowSums(W_squared %*% SS_diag) / sum(SS))
  return(VIPs)
}

# Loop through each response column and perform PLSR analysis
for (response_col in colnames(response)) {
  # Create a folder for each response variable
  dir.create(file.path(getwd(), response_col), showWarnings = FALSE)
  
  # Standardize response data
  response_variable <- scale(response[[response_col]])
  
  # Combine scaled predictors and the standardized response for modeling
  input_scaled <- data.frame(predictors_scaled, Response = response_variable)
  
  # Perform Partial Least Squares Regression (PLSR)
  ncomp <- min(10, ncol(predictors_scaled), nrow(predictors_scaled))
  plsr_model <- plsr(Response ~ ., data = input_scaled, ncomp = ncomp, scale = FALSE, validation = "LOO")
  
  # Print the summary of the PLSR model
  summary_text <- capture.output(summary(plsr_model))
  writeLines(summary_text, file.path(getwd(), response_col, "Model_Summary.txt"))
  
  # Scree plot
  eigenvalues <- plsr_model$Xvar / sum(plsr_model$Xvar)
  plot(eigenvalues, type = "b", pch = 19, col = "blue", 
       xlab = "Component Number", ylab = "Proportion of Variance Explained", 
       main = paste("Scree Plot for", response_col))
  abline(h = 1 / length(eigenvalues), col = "red", lty = 2)
  
  # Cross-validation metrics
  cv_predictions <- predict(plsr_model, ncomp = ncomp, newdata = input_scaled)[, , 1]
  cv_rmse <- sqrt(mean((cv_predictions - as.vector(response_variable))^2))
  cv_r2 <- cor(cv_predictions, as.vector(response_variable))^2
  response_range <- max(response_variable) - min(response_variable)
  cv_nrmse <- cv_rmse / response_range
  
  # Save metrics to PDF
  metrics_text <- c(paste("Cross-Validation RMSE: ", round(cv_rmse, 4)),
                    paste("Cross-Validation NRMSE: ", round(cv_nrmse, 4)),
                    paste("Cross-Validation R²: ", round(cv_r2, 4)))
  textplot(metrics_text, valign = "top", halign = "left", cex = 0.7)
  
  # Observed vs Predicted plot
  plot(as.vector(response_variable), cv_predictions, 
       xlab = "Observed", ylab = "Predicted", 
       main = paste("Observed vs Predicted for", response_col))
  abline(0, 1, col = "red", lty = 2)
  
  # Calculate VIP scores
  vip_scores <- calculate_vip(plsr_model)
  vip_df <- data.frame(Variable = colnames(predictors_scaled), VIP = vip_scores)
  addWorksheet(wb_vip, response_col)
  writeData(wb_vip, sheet = response_col, vip_df)
  
  # Extract loadings
  loadings_list <- loadings(plsr_model)
  loadings_df <- as.data.frame(loadings_list)
  addWorksheet(wb_loadings, response_col)
  writeData(wb_loadings, sheet = response_col, loadings_df)
}

# Close the PDF file
dev.off()

# Save the workbooks
saveWorkbook(wb_vip, file.path(getwd(), "VIP_Scores.xlsx"), overwrite = TRUE)
saveWorkbook(wb_loadings, file.path(getwd(), "Loadings.xlsx"), overwrite = TRUE)

cat("PLSR analysis completed successfully. Check your output files.\n")
