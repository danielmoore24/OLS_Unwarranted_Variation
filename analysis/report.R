library('tidyverse')

df_input<- read_csv(
    here::here("output", "input.csv"),
    col_types = cols(patient_id = col_integer(),age = col_double(), sex=col_factor(),imd=col_double(), ethnicity=col_factor())
)

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

