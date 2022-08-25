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
cut_by <- c("region","ethnicity") #vector of variable names

###Rename ethnicity groupings
df_input$ethnicity <- as.character(df_input$ethnicity)
df_input['ethnicity'][df_input['ethnicity'] == '1'] <- 'White'
df_input['ethnicity'][df_input['ethnicity'] == '2'] <- 'Mixed'
df_input['ethnicity'][df_input['ethnicity'] == '3'] <- 'South Asian'
df_input['ethnicity'][df_input['ethnicity'] == '4'] <- 'Black'
df_input['ethnicity'][df_input['ethnicity'] == '5'] <- 'Other'

###Diabetes###

###Prepare total tables

for(i in cut_by) {
  assign(paste0("diabetes_uptake_by_",i), df_input %>%
           group_by(across(all_of(i))) %>%
           summarise(Total_Diabetes_Patients = sum(Diabetes), SGLT2_only_users = sum(SGLT2s[Diabetes_SOCs==0 & Diabetes==1]),
                     SOC_only_users = sum(Diabetes_SOCs[SGLT2s==0 & Diabetes==1]),
                     Both = sum(Diabetes_SOCs[SGLT2s==1 & Diabetes==1]), Neither = Total_Diabetes_Patients - SGLT2_only_users
                     - SOC_only_users - Both))
}

###Melt data to prepare for plot loop
diabetes_region<-mutate(melt(subset(diabetes_uptake_by_region, select=-Total_Diabetes_Patients), id="region"),indvar=region)
diabetes_ethnicity<-mutate(na.omit(melt(subset(diabetes_uptake_by_ethnicity, select=-Total_Diabetes_Patients), id="ethnicity")),indvar=ethnicity) # removed NA values

total_plot_list<-c("diabetes_region", "diabetes_ethnicity") # create vector of table names

###Function to plot total diabetes graphs
total_plotter <- function(data) {
  ggplot(data, aes(x=reorder(indvar, -value), y=value, fill=variable)) +
      geom_bar(stat="identity") +
      geom_text(aes(label=value), size=3, position = position_stack(vjust = 0.5)) +
      coord_flip() +
      scale_fill_manual('Medicine', values=c("#00ad93", "#D4DCFF", "#7D83FF","#cd66cc"), labels=c("SGLT2 only", "SOC only", "Both", "Neither")) +
      labs(
        title=paste("Uptake of SGLT2 inhibitors by", colnames(data[1]),"across England"),
        caption=paste("Source: OpenSafely"),
        x= str_to_title(colnames(data[1])),
        y= "Number of Patients"
      ) +
      theme(
      panel.background = element_rect(fill=NA),
      panel.grid.major = element_blank(),
      plot.title = element_text(hjust = 0.6),
      plot.caption = element_text(hjust = -1)
    )
}
###Loop over multiple variables and print output
for(i in seq_along(total_plot_list)){
  print(total_plotter(get(total_plot_list[i])))
  ggsave(
    plot=total_plotter(get(total_plot_list[i])),
    filename=paste0("descriptive_",total_plot_list[i],".png"),
    path=here::here("output"))
}

###By proportion of population

###Prepare proportion tables

for(i in cut_by) {
  assign(paste0("diabetes_proportion_by_",i), df_input %>%
           group_by(across(all_of(i))) %>%
           summarise(Total_Diabetes_Patients = sum(Diabetes), SGLT2_only_users = (sum(SGLT2s[Diabetes_SOCs==0 & Diabetes==1]))/sum(Diabetes),
                     SOC_only_users = (sum(Diabetes_SOCs[SGLT2s==0 & Diabetes==1]))/sum(Diabetes),
                     Both = (sum(Diabetes_SOCs[SGLT2s==1 & Diabetes==1]))/sum(Diabetes), Neither = (sum(Diabetes) - (sum(SGLT2s[Diabetes_SOCs==0 & Diabetes==1]))
                     - (sum(Diabetes_SOCs[SGLT2s==0 & Diabetes==1])) - (sum(Diabetes_SOCs[SGLT2s==1 & Diabetes==1])))/sum(Diabetes)))
}

###Melt data to prepare for plot loop
diabetes_prop_region<-mutate(melt(subset(diabetes_proportion_by_region, select=-Total_Diabetes_Patients), id="region"),indvar=region)
diabetes_prop_ethnicity<-mutate(na.omit(melt(subset(diabetes_proportion_by_ethnicity, select=-Total_Diabetes_Patients), id="ethnicity")),indvar=ethnicity) # removed NA values

prop_plot_list<-c("diabetes_prop_region", "diabetes_prop_ethnicity") # create vector of table names

###Function to plot diabetes proportion graphs
prop_plotter <- function(data) {
  ggplot(data, aes(x=reorder(indvar, -value), y=value, fill=variable)) +
    geom_bar(stat="identity") +
    geom_text(aes(label=scales::percent(value, accuracy=1)), size=3, position = position_stack(vjust = 0.5)) +
    coord_flip() +
    scale_fill_manual('Medicine', values=c("#00ad93", "#D4DCFF", "#7D83FF","#cd66cc"), labels=c("SGLT2 only", "SOC only", "Both", "Neither")) +
    scale_y_continuous(labels = scales::percent) +
    labs(
      title=paste("Uptake of SGLT2 inhibitors by", colnames(data[1]),"across England"),
      caption=paste("Source: OpenSafely"),
      x= str_to_title(colnames(data[1])),
      y= "Percentage of Patients"
    ) +
    theme(
      panel.background = element_rect(fill=NA),
      panel.grid.major = element_blank(),
      plot.title = element_text(hjust = 0.6),
      plot.caption = element_text(hjust = -1)
    )
}
###Loop over multiple variables and print output
for(i in seq_along(prop_plot_list)){
  print(prop_plotter(get(prop_plot_list[i])))
  ggsave(
    plot=prop_plotter(get(prop_plot_list[i])),
    filename=paste0("descriptive_",prop_plot_list[i],".png"),
    path=here::here("output"))
}
