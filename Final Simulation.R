
suppressPackageStartupMessages({
  library(cmprsk)
  library(survival)
})

set.seed(123)

nsim          <- 1000
sample_sizes  <- c(100, 200, 500, 800, 1000)


h0_ltfu  <- function(t) 0.02
h0_death <- function(t) 0.007
beta_ltfu_gender  <- log(1.2)   
beta_death_gender <- log(0.8) 

true_cen_36 <- 1 - exp(-0.003 * 36)
metrics <- c("AMLE", "Bias", "SD", "RMSE", "CP_95")

run_one_sample_size <- function(n, nsim, seed_offset = 0L) {

  coef_ltfu_gender_vals  <- numeric(nsim)
  coef_death_gender_vals <- numeric(nsim)
  cif_censored_vals      <- numeric(nsim)

  cp_ltfu_gender <- numeric(nsim)
  cp_death_gender <- numeric(nsim)
  cp_censored     <- numeric(nsim)

  for (i in seq_len(nsim)) {

    gender <- rbinom(n, 1, 0.5)         
    ctime  <- rexp(n, rate = 0.003)   

    time_ltfu  <- (-log(runif(n))) / (h0_ltfu(1)  * exp(beta_ltfu_gender  * gender))
    time_death <- (-log(runif(n))) / (h0_death(1) * exp(beta_death_gender * gender))

    time_event   <- pmin(time_ltfu, time_death)
    status_event <- ifelse(time_ltfu < time_death, 1, 2)   

    time_obs <- pmin(time_event, ctime)
    status   <- ifelse(time_event <= ctime, status_event, 0)   

    mod_ltfu <- crr(ftime = time_obs, fstatus = status,
                     cov1 = data.frame(gender), failcode = 1, cencode = 0)
    coef_ltfu_gender_vals[i] <- mod_ltfu$coef[1]
    se_ltfu <- sqrt(mod_ltfu$var[1, 1])
    ci_low  <- mod_ltfu$coef[1] - 1.96 * se_ltfu
    ci_upp  <- mod_ltfu$coef[1] + 1.96 * se_ltfu
    cp_ltfu_gender[i] <- as.numeric(beta_ltfu_gender >= ci_low & beta_ltfu_gender <= ci_upp)

    mod_death <- crr(ftime = time_obs, fstatus = status,
                      cov1 = data.frame(gender), failcode = 2, cencode = 0)
    coef_death_gender_vals[i] <- mod_death$coef[1]
    se_death <- sqrt(mod_death$var[1, 1])
    ci_low   <- mod_death$coef[1] - 1.96 * se_death
    ci_upp   <- mod_death$coef[1] + 1.96 * se_death
    cp_death_gender[i] <- as.numeric(beta_death_gender >= ci_low & beta_death_gender <= ci_upp)

    cens_status <- ifelse(status == 0, 1, 0)
    km_cens <- survfit(Surv(time_obs, cens_status) ~ 1)
    t_eval  <- 36

    if (length(km_cens$time) >= 2) {
      cif_censored_at36 <- 1 - approx(km_cens$time, km_cens$surv,  xout = t_eval, rule = 2)$y
      ci0_low <- 1 - approx(km_cens$time, km_cens$upper, xout = t_eval, rule = 2)$y
      ci0_upp <- 1 - approx(km_cens$time, km_cens$lower, xout = t_eval, rule = 2)$y
      cp_censored[i] <- as.numeric(true_cen_36 >= ci0_low & true_cen_36 <= ci0_upp)
    } else {
      cif_censored_at36 <- 0
      cp_censored[i] <- 0
    }
    cif_censored_vals[i] <- cif_censored_at36
  }

  list(
    coef_ltfu_gender_vals  = coef_ltfu_gender_vals,
    coef_death_gender_vals = coef_death_gender_vals,
    cif_censored_vals      = cif_censored_vals,
    cp_ltfu_gender         = cp_ltfu_gender,
    cp_death_gender        = cp_death_gender,
    cp_censored            = cp_censored
  )
}

summarise_estimand <- function(estimates, true_value, coverage_indicator) {
  c(
    AMLE  = mean(estimates),
    Bias  = mean(estimates) - true_value,
    SD    = sd(estimates),
    RMSE  = sqrt(mean((estimates - true_value)^2)),
    CP_95 = mean(coverage_indicator)
  )
}

results_all_ltfu     <- list()
results_all_death    <- list()
results_all_censored <- list()

for (n in sample_sizes) {

  cat(sprintf("Running n = %d ... ", n))
  sim_out <- run_one_sample_size(n, nsim)
  cat("done\n")

  results_all_ltfu[[as.character(n)]] <- data.frame(
    Metric = metrics,
    LTFU_Gender = summarise_estimand(
      sim_out$coef_ltfu_gender_vals, beta_ltfu_gender, sim_out$cp_ltfu_gender
    )
  )

  results_all_death[[as.character(n)]] <- data.frame(
    Metric = metrics,
    Death_Gender = summarise_estimand(
      sim_out$coef_death_gender_vals, beta_death_gender, sim_out$cp_death_gender
    )
  )

  results_all_censored[[as.character(n)]] <- data.frame(
    Metric = metrics,
    Censoring_CIF = summarise_estimand(
      sim_out$cif_censored_vals, true_cen_36, sim_out$cp_censored
    )
  )
}

cat("\n========================================================\n")
cat("True Parameters Used in the Simulation\n")
cat("========================================================\n")
cat(sprintf("True log(SHR) for Gender (LTFU):   %.4f\n", beta_ltfu_gender))
cat(sprintf("True log(SHR) for Gender (Death):  %.4f\n", beta_death_gender))
cat(sprintf("True CIF for Censoring at 36mo:    %.4f\n", true_cen_36))

combined_results <- list()

for (n in sample_sizes) {

  cat("\n\n========================================================\n")
  cat(sprintf("Sample Size: %d\n", n))
  cat("========================================================\n")

  df_ltfu  <- results_all_ltfu[[as.character(n)]]
  df_death <- results_all_death[[as.character(n)]]
  df_cens  <- results_all_censored[[as.character(n)]]

  stopifnot(
    identical(df_ltfu$Metric, df_death$Metric),
    identical(df_ltfu$Metric, df_cens$Metric)
  )

  combined_df <- data.frame(
    n             = n,
    Metric        = df_ltfu$Metric,
    LTFU          = round(df_ltfu$LTFU_Gender, 4),
    Death         = round(df_death$Death_Gender, 4),
    Censoring_CIF = round(df_cens$Censoring_CIF, 4)
  )

  print(combined_df[, -1], row.names = FALSE)
  combined_results[[as.character(n)]] <- combined_df
}


results_dir <- file.path("results")
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)

final_table <- do.call(rbind, combined_results)
rownames(final_table) <- NULL

out_path <- file.path(results_dir, "finegray_coverage_results.csv")
write.csv(final_table, out_path, row.names = FALSE)
cat(sprintf("\nResults written to: %s\n", out_path))
