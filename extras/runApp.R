 # Run the application
 shiny::shinyAppDir(appDir = "C:/Dropbox/Work/Software/Rshiny/Commons",
                    options = list(launch.browser=
                                         TRUE)
                                         #rstudioapi::viewer)
                    )

# Deploy the application to shinyapps.io
rsconnect::deployApp(appDir = "C:/Dropbox/Work/Software/Rshiny/Commons",
                     appName = "Commons", appId = "421556",
                     account = "iainmstott", upload = TRUE)
