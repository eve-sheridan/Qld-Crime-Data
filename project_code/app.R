#load the required libraries
library(tidyverse)
library(shiny)
library(rgdal)
library(ggplot2)
library(plotly)
library(dplyr)
library(rlang)
library(formattable)


#load the required datafiles
#wrangled crime data
crimedata <- read.csv("crimedata.csv")

#LGA geodatabase file
lgaogr <- readOGR(dsn="QldLGAs/data.gdb",
                  layer="Local_Government_Areas")
lgaogrf <- fortify(lgaogr)

#Qld Coastline geodatabase file
qldogrf <- fortify(readOGR(dsn="QldCoastline/data.gdb",
                           layer="Coastline_and_State_border"))

#define user interface
ui <- fluidPage(
    tabsetPanel(
        tabPanel("Choropleth Map", fluid = TRUE,
            sidebarLayout(
                sidebarPanel(
                    helpText(HTML("<h3>Visualising violent offences across Queensland</h3><br>
                                    This choropleth map displays the rates of violent offences (per 100,000 population) across all Local Government Areas in Qld for a selected year.<br>
                                    <ul>
                                    <li>The default year <b><em>9999</em></b> displays the <b><em>average</em></b> violent offence rates for all of Qld from 2001 - 2020.</li>
                                    <li>Select any year from the drop down list to view violent offence rates for that year.</li>
                                    <li>Hover over a Local Government Area to see more details.</li>
                                    <li>Hover over the modebar above the graph for other viewing options.</li>
                                    <li>The map may take a minute to load, please be patient!</li><br>")),
                             selectInput("Year",
                                         "Select Year:",
                                         choices = unique(crimedata$Year),
                                         selected = 9999)
                          
                              ),
                mainPanel(h1(""), plotlyOutput("chlmap"))
                            )
                 ),
        tabPanel("Line Plot", fluid = TRUE,
            sidebarLayout(
                sidebarPanel(
                    helpText(HTML("<h3>Visualising Queensland offence rates over time</h3><br>
                                    This line graph displays rates of offences (per 100,000 population) from 2001 - 2020.<br>
                                    <ul>
                                    <li>The default Local Government Area <b><em>All of Qld</em></b> displays the offence rates for all of Qld.</li>
                                    <li>There are 3 types of offences displayed. </li>
                                    <li>Select any Local Government Area from the drop down list to view offence rates for that area.</li>
                                    <li>Note that the scale and colors will change to match the data selected (red is always the highest).</li>
                                    <li>Hover over a point on any line to see more details.</li>
                                    <li>Hover over the modebar above the graph for other viewing options.</li><br>")),
                             selectInput("ABBREV_NAME",
                                         "Select Local Government Area:",
                                         choices = unique(crimedata$ABBREV_NAME),
                                         selected = "All of Qld")
                            ),
                mainPanel(h1(""), plotlyOutput("linePlot"))
                         )  
                   )
                )
                )
        
    
# Define server logic required to draw the plots
server <- function(input, output) {
    #Choroplet map
    output$chlmap <- renderPlotly({
        #filter crimedata with info required
        p <- crimedata %>%
            filter(offence == "Violent Offences", Year == input$Year)
            
        #make a copy of the lgaogr object
        pd <- duplicate(lgaogr)
            
        #get row names as id
        pd@data$id <- rownames(pd@data)
            
        #join in the crime data
        pd@data   <- right_join(pd@data, p, by = "ABBREV_NAME")
            
        #create a dataframe with location info for the plot
        pd.df     <- inner_join(lgaogrf, pd@data, by="id")

            
        #create plot
        pm <- ggplot() +
            geom_polygon(data = pd.df, aes(fill = rate, x = long, y = lat, group = group,
                                            text = paste("LGA Name:", ABBREV_NAME, "<br>",
                                                         "Population:", comma(pop, digits = 0), "<br>", 
                                                         "Rate per 100,000:", comma(rate, digits = 0), "<br>",
                                                         "Number of offences:", comma(num, digits = 0)))) +
            geom_polygon(data = qldogrf, aes(x = long, y = lat, group = group), 
                         fill = NA, color = 'black', size = 0.2)  +
            scale_fill_continuous(name="Violent crime rate <br> per 100,000 population", 
                                      trans = "log", low = "lightblue", high = "darkblue") + 
            labs(title = "Violent offence rates across Queensland by Year <br> Broken down by Local Govt Area") +
            theme_void() +
            coord_map()

            #plot it using ggplotly
            ggplotly(pm, tooltip = c("text"))

        })

    #lineplot
    output$linePlot <- renderPlotly({
        
        p <- crimedata %>%
            filter(ABBREV_NAME == input$ABBREV_NAME, Year != 9999) %>%
            mutate(offence = fct_reorder(offence, -rate)) %>%
            ggplot(aes(Year, rate, color = offence, group = 1,
                        text = paste("Year:", Year, "<br>",
                                     "Rate per 100,000 popn:", comma(rate, digits = 0), "<br>",
                                     "Number of offences:", comma(num, digits = 0), "<br>",
                                     "Population:", comma(pop, digits = 0)))) + 
                geom_line() +
                labs(title = "Queensland offence rates 2001 - 2020") +
                labs(color="Offence Type") +
                ylab("Offence rate per 100,000 population")

        #plot it
            ggplotly(p, tooltip = c("text")) 
        })    
        
    }
    
    # Run the application 
    shinyApp(ui = ui, server = server)