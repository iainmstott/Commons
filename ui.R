### ui


ui <- fluidPage(
    
    theme = shinytheme("cosmo"),

    tags$head(

        includeCSS("css/main.css")

    ),

        titlePanel("Tragedy of the Commons"),
        br(),
        div(id = "tagline",
        p("WELCOME TO THE FISHING GAME. The aim is to fish for 12 months, without 
        collapsing the fish stocks but catching enough to keep your family alive."),
        p("There are 2 levels: easy and hard. In the easy game there are always 5 
        fisherpeople every month (including yourself). In the hard game, you (and the other fisherpeople)
        each have a 25% random chance every month of not catching any fish (keep an eye
        on the graphs to make sure!)"),
        p("Start by choosing the easy game."),
        br(),
        p("STEPS:"),
        p("1. You know the current fish stocks."),
        p("2. Based on the current stocks, how much you expect the other fisherpeople
        may harvest (including their harvest history), and the need to keep your family alive,
        you must choose how many fish to harvest, then click the button... GO FISH!"),
        p("3. The fish reproduce after harvesting. The post-harvest fish population 
        grows on average by 20% every month, but with a range between a 
        20% decline and a 60% increase."),
        p("4. The minimum viable stock is 200, below which the population crashes."),
        p("5. The game ends either when the population crashes, or you reach the end of 12 months."),
        p("6. In order to support your family, you should aim to harvest 180 fish per year on average."),
        
        #You start with a fish stock every month, and you "),
        br()
    ),

    sidebarLayout(

    # Choose input
        sidebarPanel(width = 3,
            div(id = "Harvest", class = "inputs",
                numericInput (inputId = "myHarvest", label = "Amount to harvest this month:",
                                value = 36, min = 1, step = 1)
            ),
            tableOutput(outputId = "fishTab"),
            div(id = "updateButton",
                actionButton(inputId = "update", label = "GO FISH!")
            ),
            br(),
            conditionalPanel(condition = "input.update == '0'",
                radioButtons(inputId = "numActors", label = "Which game do you want to play?",
                                choices = list("EASIER: same number of fisherpeople every month" = "easy",
                                               "HARDER: different number of fisherpeople every month" = "hard"),
                                selected = "easy")
            ),
            br()
        ),
        mainPanel(width = 9,
            conditionalPanel(condition = 'output.extinctPanel',
                            "Oh dear. It looks like you've driven the fish population extinct already. That wasn't very 
                            clever, was it? Harvesting enough fish without collapsing the population is a delicate balance. 
                            Think a little about how much you harvested relative to the other fisherpeople, and what their 
                            harvesting patterns were. Think about how you might need to account for the randomness of population growth.
                            Then together think about the best strategy to maximise your take over the longer term, based on the 
                            number of fish available, potential population growth (or decline), and how the other fisherpeople are acting. Have another go by 
                            refreshing the page.",
                            br()),
            conditionalPanel(condition = 'output.extinctPanel',
                             tableOutput(outputId = "harvestTable1")),
            conditionalPanel(condition = 'output.congratsPanel',
                            "Congratulations! You managed to harvest continually without driving the fish population extinct. 
                            But did you manage to harvest enough to feed your family? How much did you harvest compared to the other fisherpeople?
                            Do you think you got lucky with the population growth values?
                            Think a little about how much you harvested relative to the other fisherpeople, and what their 
                            harvesting patterns were. Think about how you might need to account for the randomness of population growth.
                            Then together think about the best strategy to maximise your take over the longer term, based on the 
                            number of fish available, potential population growth (or decline), and how the other fisherpeople are acting. Have another go by 
                            refreshing the page.",
                            br()),
            conditionalPanel(condition = 'output.congratsPanel',
                             tableOutput(outputId = "harvestTable2")),
            plotOutput(outputId = "stockPlot"),
            div("The cycle is: population (time t) -> harvest -> reproduction -> population (time t+1). Therefore in the above graph, circles show the 
            population size at the start of the month (before harvest), and plus symbols show the population size in the middle 
            of the month (after harvest, before reproduction)."),
            plotOutput(outputId = "harvestPlot"),
            div("Each colour represents a fisherperson, and you're dark green.")
        )
    )
)
