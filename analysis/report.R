library('tidyverse')

df_input<- read_csv(
    here::here("output", "input.csv"),
    col_types = cols(patient_id = col_integer(),age = col_double(), sex=col_factor(),imd=col_double(), ethnicity=col_factor(), region=col_factor(), diabetes=col_factor(), VTE_or_AF=col_factor(), DOAC_users=col_factor(), Warfarin_users=col_factor(), SGLT2_users=col_factor(), Diabetes_SOC_users=col_factor())
)

# Plot basic variables

plot_age <- ggplot(data=df_input, aes(df_input$age)) + geom_histogram()

ggsave(
    plot= plot_age,
    filename="descriptive_age.png", path=here::here("output")
)

plot_sex <- ggplot(data=df_input, aes(df_input$sex)) + geom_bar()

ggsave(
    plot= plot_sex,
    filename="descriptive_sex.png", path=here::here("output")
)

plot_imd <- ggplot(data=df_input, aes(df_input$imd)) + geom_bar()

ggsave(
    plot= plot_imd,
    filename="descriptive_imd.png", path=here::here("output")
)

plot_ethnicity <- ggplot(data=df_input, aes(df_input$ethnicity)) + geom_bar()

ggsave(
    plot= plot_ethnicity,
    filename="descriptive_ethnicity.png", path=here::here("output")
)

plot_region <- ggplot(data=df_input, aes(df_input$region)) + geom_bar()

ggsave(
    plot= plot_region,
    filename="descriptive_region.png", path=here::here("output")
)

plot_diabetes <- ggplot(data=df_input, aes(df_input$diabetes)) + geom_bar()

ggsave(
    plot= plot_diabetes,
    filename="descriptive_diabetes.png", path=here::here("output")
)

plot_VTE_AF <- ggplot(data=df_input, aes(df_input$VTE_or_AF)) + geom_bar()

ggsave(
    plot= plot_VTE_AF,
    filename="descriptive_VTE_AF.png", path=here::here("output")
)

plot_DOACs <- ggplot(data=df_input, aes(df_input$DOAC_users)) + geom_bar()

ggsave(
    plot= plot_DOACs,
    filename="descriptive_DOACs.png", path=here::here("output")
)

plot_Warfarin <- ggplot(data=df_input, aes(df_input$Warfarin_users)) + geom_bar()

ggsave(
    plot= plot_Warfarin,
    filename="descriptive_Warfarin.png", path=here::here("output")
)

plot_SGLT2 <- ggplot(data=df_input, aes(df_input$SGLT2_users)) + geom_bar()

ggsave(
    plot= plot_SGLT2,
    filename="descriptive_SGLT2.png", path=here::here("output")
)

plot_Diabetes_SOC <- ggplot(data=df_input, aes(df_input$Diabetes_SOC_users)) + geom_bar()

ggsave(
    plot= plot_Diabetes_SOC,
    filename="descriptive_Diabetes_SOC.png", path=here::here("output")
)

# Plot measures

# create look-up table to iterate over
md_tbl <- tibble(
  measure = "DOACs",
  measure_label = "DOACs",
  by = "region",
  by_label = "by region",
  id = paste0(measure, "_", by),
  numerator = measure,
  denominator = VTE_AF,
  group_by = "region",
)

## import measures data from look-up
measures <- md_tbl %>%
  mutate(
    data = map(id, ~read_csv(here::here("output", "measures", glue::glue("measure_{.}.csv")))),
  )


## generate plots for each measure within the data frame
measures_plots <- measures %>%
    plot_by = pmap(lst( group_by, data, measure_label, by_label),
                  function(group_by, data, measure_label, by_label){
                    data %>% 
                    ggplot()+
                      geom_bar(aes_string(x=by, y=measure, group=group_by), alpha=0.2, colour='blue', size=0.25)
                  },
)
# create directory where output will be saved
fs::dir_create(here::here("output", "plots"))

## plot the charts (by variable)
measures_plots %>%
  transmute(
    plot = plot_by,
    units = "cm",
    height = 10,
    width = 15,
    limitsize=FALSE,
    filename = str_c("plot_each_", id, ".png"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)

