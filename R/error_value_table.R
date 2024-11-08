#' @title error_value_table
#'
#' @description
#' This function will run through all observations and create a table by year and observation summarising type likelihood and error_values
#'
#' @author Craig Marsh
#' @param model <casal2MPD> object that are generated from one of the extract() functions. If list then we expect multiple mpd runs (should be a named list )
#' @importFrom tidyr pivot_wider expand
#' @return data.frame that can be used by kable or other table functions.
#' @rdname error_value_table
#' @export error_value_table
error_value_table <- function(model) {
  complete_df = NULL
  reports_labels = names(model)
  for(i in 1:length(model)) {
    if (reports_labels[i] == "header")
      next;
    this_report = model[[i]]
    if(any(names(this_report) == "type")) {
      if(this_report$type != "observation") {
        next;
      }
      ## found an observation
      ##
      obs_type = this_report$observation_type
      obs_likelihood = this_report$likelihood
      obs_label = reports_labels[i]
      obs_error = this_report$Values %>% group_by(year) %>% summarise(mean(adjusted_error))
      colnames(obs_error) = c("year", "error_value")
      temp_df = data.frame(label = obs_label, type = obs_type, likelihood = obs_likelihood, error_value = obs_error$error_value, year = obs_error$year)
      complete_df = rbind(complete_df, temp_df)
    }
  }
  chg_lab = grepl(complete_df$type, pattern = "process_removals_by")
  complete_df$type[chg_lab] = paste0("fishery_", substring(complete_df$type[chg_lab], first = 21))
  ## make year a factor so we can expand it
  complete_df$year = factor(complete_df$year, levels = seq(from = min(complete_df$year), to = max(complete_df$year), by = 1))
  ## now covert into a table somehow
  observation_error_tab = complete_df %>% group_by(year, label) %>%
    pivot_wider(names_from = year, names_expand = T, values_from = error_value, values_fill = NA)

  return(observation_error_tab);
}
