### server

server <- function(input, output, session) {

    ### create reactive values to save data
    Hdata <- reactiveValues(
        stock = stock0,
        init = round((1/nActors) * take * (stock0[1, 1] - stockMin), 0),
        HB = matrix(0, nrow = t, ncol = nActors),
        HP1 = matrix(0, nrow = t, ncol = nActors),
        HP2 = matrix(0, nrow = t, ncol = nActors),
        HT = matrix(0, nrow = t, ncol = nActors),
        r = rep(0, t),
        endtime = 0
    )

    ts <- reactive({
        if(input$update < t) ts <- input$update
        if(input$update >= t) ts <- t
        if(Hdata$endtime > 0) ts <- Hdata$endtime
        ts
    })

    ### save the havest, stock and growth values
    observeEvent(input$update, {
        if(Hdata$endtime %in% 0){
            ### WHO HARVESTS
            # hard game (not everyone every timestep)
            Hdata$HB[ts(), ] <- 1
            if(input$numActors %in% "hard"){
                Hdata$HB[ts(), ] <- rbinom(nActors, 1, 0.75 )
            }
            if(ts() %in% 1) Hdata$HB[ts(), ] <- 1

            ### WHAT PROPORTIONS
            Hdata$HP1[ts(), ] <- Hdata$HB[ts(), ] * (1/sum(Hdata$HB[ts(), ]))
            Hdata$HP1[ts(), ] <- Hdata$HP1[ts(), ] * runif(nActors, 0.8, 1.2)

            ### HARVEST total
            # total harvest of timestep
            Hdata$HT[ts(), ] <- round(Hdata$HP1[ts(), ] * 
                                    (Hdata$stock[ts(), 1] - stockMin) *
                                    take, 0)
                                    
            # add player chosen harvest
            Hdata$HT[ts(), 1] <- Hdata$HB[ts(), 1] * isolate(input$myHarvest)
            # (comment above line out for fair harvest)

            ### HARVEST proportion
            # record chosen harvest as proportion of total population
            Hdata$HP2[ts(), ] <- Hdata$HT[ts(), ] * 
                                1/Hdata$stock[ts(), 1]

            # reset minus values to zero
            Hdata$HT[ts(), Hdata$HT[ts(), ] < 0] <- 0
            Hdata$HP2[ts(), Hdata$HP2[ts(), ] < 0] <- 0

            ### STOCK after harvest
            Hdata$stock[ts(), 2] <- Hdata$stock[ts(), 1] - sum(Hdata$HT[ts(), ])

            ### ENDTIME
            # if stock <= stockMin
            if(Hdata$stock[ts(), 2] < stockMin) Hdata$endtime <- ts()
            #if ts = t
            if(ts() == t) Hdata$endtime <- t

            ###BABIES
            # growth rate for timestep
            growth <- rnorm(1, 1.1, 0.1) 
            Hdata$r[ts()] <- growth

            ### STOCK at end of timestep
            Hdata$stock[ts() + 1, 1] <- round(Hdata$stock[ts(), 2] * growth, 0)
        }

        if(Hdata$endtime > 0){
            print("TIMESTEP")
            print(as.numeric(ts()))
            print("ACTORS")
            print(Hdata$HB)
            print("HARVEST (PER ACTOR)")
            print(Hdata$HT)
            print("HARVEST TOTAL (PER ACTOR)")
            print(matrix(colSums(Hdata$HT), nrow = 1))
            print("HARVEST PROPORTION (PER ACTOR)")
            print(Hdata$HP2)
            print("HARVEST PROPORTION (PER TIMESTEP)")
            print(as.matrix(rowSums(Hdata$HP2)))
            print("STOCK")
            print(Hdata$stock)
            print("POPULATION GROWTH")
            print(as.matrix(Hdata$r))
            print("MEAN POPULATION SIZE")
            print(mean(Hdata$stock[1:ts(), 1]))
            print("ENDTIME")
            print(Hdata$endtime)
        }
    })

    observeEvent(input$update, {
        if(Hdata$stock[ts(), 2] < stockMin){
            updateActionButton(session, "update",
                              label = "NO FISH :(")
        }
        if(input$update >= t & Hdata$stock[ts(), 2] > stockMin){
            updateActionButton(session, "update",
                              label = "FISH :)")
        }
    })

    ### UPDATE SHOW PANELS

    output$extinctPanel <- reactive({
        input$update
        if(Hdata$endtime %in% 1:11) show <- TRUE else(show <- FALSE)
        show
    })
    outputOptions(output, "extinctPanel", suspendWhenHidden = FALSE)

    output$congratsPanel <- reactive({
        input$update
        if(Hdata$endtime %in% 12) show <- TRUE else(show <- FALSE)
        show
    })
    outputOptions(output, "congratsPanel", suspendWhenHidden = FALSE)

    output$fishTab <- renderTable({
        captions <- c("Number of fish in the population:",
                      "Number of other fisherpeople:")
        if(ts() %in% 0) nAct <- 4
        if(ts() > 0) nAct <- sum(Hdata$HB[ts(), 2:5])
        nFish <- Hdata$stock[ts() + 1, 1]
        vals <- c(nFish, nAct)
        fT <- data.frame(captions, vals)
        fT
    }, rownames = FALSE, colnames = FALSE, align = "l", spacing = "s", digits = 0)

    output$harvestPlot <- renderPlot({
        xvals <- barplot(t(Hdata$HT), col = terrain.colors(nActors),
                         ylab = "Number fish harvested")
        axis(side = 1, at = xvals, labels = 1:12, lwd = 0)
    })

    output$stockPlot <- renderPlot({
        plot(0:ts(), Hdata$stock[1:(ts()+1), 1], type = "o", pch = 16, bty = "n",
             xlab = "Months", ylab = "Number fish in population",
             xlim = c(0, t), ylim = c(0, stock0[1,1]))
        axis(side = 1, at = 1:t, labels = 1:t)
        legend("topright", pch = c(16, 3), c("Stocks before harvest", "Stocks after harvest"))
        abline(h = 200, lty = 2)
        text(0, 20, "Growth:")
        if(ts() > 0){
            lines((0:ts() + 0.5)[-(ts()+1)], Hdata$stock[1:ts(), 2], type = "o", pch = 3)
            text((0:ts() + 0.75)[-(ts()+1)], 20, round(Hdata$r[1:ts()], 2))
        }

    })

    output$harvestTable1 <- renderTable({
        text <- paste("FISHERPERSON", 1:5); text[1] <- "YOU"
        nums <- as.matrix(colSums(Hdata$HT))
        row.names(nums) <- text
        t(nums)
    }, rownames = FALSE, align = "c", spacing = "s", digits = 0)

    output$harvestTable2 <- renderTable({
        text <- paste("FISHERPERSON", 1:5); text[1] <- "YOU"
        nums <- as.matrix(colSums(Hdata$HT))
        row.names(nums) <- text
        t(nums)
    }, rownames = FALSE, align = "c", spacing = "s", digits = 0)





}





