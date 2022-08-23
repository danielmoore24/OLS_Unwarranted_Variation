library('tidyverse')
library('reshape2')

df_input<- read_csv(
    here::here("output", "input.csv"),
    col_types = cols(patient_id = col_integer(),age = col_double(), sex=col_factor(),imd=col_double(), ethnicity=col_factor(), region=col_factor(), Diabetes=col_integer(), VTE_AF=col_integer(), DOACs=col_integer(), Warfarin=col_integer(), SGLT2s=col_integer(), Diabetes_SOCs=col_integer())
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

plot_diabetes <- ggplot(data=df_input, aes(df_input$Diabetes)) + geom_bar()

ggsave(
    plot= plot_diabetes,
    filename="descriptive_diabetes.png", path=here::here("output")
)

plot_VTE_AF <- ggplot(data=df_input, aes(df_input$VTE_AF)) + geom_bar()

ggsave(
    plot= plot_VTE_AF,
    filename="descriptive_VTE_AF.png", path=here::here("output")
)

plot_DOACs <- ggplot(data=df_input, aes(df_input$DOACs)) + geom_bar()

ggsave(
    plot= plot_DOACs,
    filename="descriptive_DOACs.png", path=here::here("output")
)

plot_Warfarin <- ggplot(data=df_input, aes(df_input$Warfarin)) + geom_bar()

ggsave(
    plot= plot_Warfarin,
    filename="descriptive_Warfarin.png", path=here::here("output")
)

plot_SGLT2 <- ggplot(data=df_input, aes(df_input$SGLT2s)) + geom_bar()

ggsave(
    plot= plot_SGLT2,
    filename="descriptive_SGLT2.png", path=here::here("output")
)

plot_Diabetes_SOC <- ggplot(data=df_input, aes(df_input$Diabetes_SOCs)) + geom_bar()

ggsave(
    plot= plot_Diabetes_SOC,
    filename="descriptive_Diabetes_SOC.png", path=here::here("output")
)

# Test real outputs
diabetes_region_summary <- df_input %>%
    group_by(region) %>%
    summarise(diabetes_patients = sum(Diabetes)) %>%
    arrange(desc(diabetes_patients))

plot_diabetes_region_summary <- ggplot(data=diabetes_region_summary)+
    geom_bar(
        mapping=aes(x = reorder(region, +diabetes_patients), y = diabetes_patients), stat="identity"
    )

ggsave(
    plot= plot_diabetes_region_summary,
    filename="descriptive_Diabetes_by_Region.png", path=here::here("output")
)

###create table of SGLT2 users per eligible pop by region
diabetes_uptake_by_region <- df_input %>%
  group_by(region) %>%
  summarise(Total_Diabetes_Patients = sum(Diabetes), SGLT2_only_users = sum(SGLT2s[Diabetes_SOCs==0 & Diabetes==1]),
            SOC_only_users = sum(Diabetes_SOCs[SGLT2s==0 & Diabetes==1]),
            Both = sum(Diabetes_SOCs[SGLT2s==1 & Diabetes==1]), Neither = Total_Diabetes_Patients - SGLT2_only_users
            - SOC_only_users - Both)

dat<-melt(subset(diabetes_uptake_by_region, select=-Total_Diabetes_Patients), id="region")
###plot diabetes medicine spread by region
plot_diabetes_uptake_by_region <- ggplot(dat, aes(x=reorder(region, -value), y=value, fill=variable)) +
  geom_bar(stat="identity")

 ggsave(
    plot= plot_diabetes_uptake_by_region,
    filename="descriptive_SGLT2s_by_Region.png", path=here::here("output")
) 