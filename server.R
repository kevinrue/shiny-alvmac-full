library(shiny)
library(GOexpress)

exprSet = readRDS(file = "data/alvmac.eSet.0h.rds")
gox.raw = readRDS(file = "data/gox.raw.rds")

# The gene score table has probeset identifiers in the row names
# however row names are not displayed/supported by shiny
# we need to move those row names into a proper column of the
# result table
genesScore = gox.raw$genes
genesScore$Ensembl_gene_id = rownames(genesScore)
genesScore = genesScore[,c(
    'Ensembl_gene_id','Score','Rank','external_gene_name','description')
    ]
# Add a column used in the expression profiles
exprSet$Animal.Infection = paste(exprSet$Animal, exprSet$Infection, sep='_')

shinyServer(
    function(input, output) {
        
        # Generate a plot of the requested gene symbol by individual sample series
        output$exprProfilesSymbol <- renderPlot({
            expression_profiles_symbol(
                gene_symbol = input$external_gene_name,
                result = gox.raw,
                eSet = exprSet,
                x_var = "Hours.post.infection",
                seriesF = "Animal.Infection",
                subset = list(
                    Animal=input$animals_symbol,
                    Time=input$hours_symbol,
                    Infection=input$infection_symbol
                ),
                colourF = "Infection",
                #linetypeF = "Infection",
                line.size = input$linesize,
                index = input$index,
                xlab="Hours post-infection",
            )
        })
        
        # Generate a plot of the requested gene symbol by sample groups
        output$exprPlotSymbol <- renderPlot({
            expression_plot_symbol(
                gene_symbol = input$external_gene_name,
                result = gox.raw,
                eSet = exprSet,
                x_var = "Hours.post.infection",
                subset = list(
                    Animal=input$animals_symbol,
                    Time=input$hours_symbol,
                    Infection=input$infection_symbol
                ),
                index = input$index,
                xlab="Hours post-infection",
            )
        })
        
        # Generate a plot of the requested gene symbol by individual sample series
        output$exprProfiles <- renderPlot({
            expression_profiles(
                gene_id = input$ensembl_gene_id,
                result = gox.raw,
                eSet = exprSet,
                x_var = "Hours.post.infection",
                seriesF = "Animal.Infection",
                subset = list(
                    Animal=input$animals,
                    Time=input$hours,
                    Infection=input$infection
                ),
                colourF = "Infection",
                #linetypeF = "Infection",
                line.size = input$linesize,
                xlab="Hours post-infection",
            )
        })
        
        # Generate a plot of the requested gene symbol by sample groups
        output$exprPlot <- renderPlot({
            expression_plot(
                gene_id = input$ensembl_gene_id,
                result = gox.raw,
                eSet = exprSet,
                x_var = "Hours.post.infection",
                subset = list(
                    Animal=input$animals,
                    Time=input$hours,
                    Infection=input$infection
                ),
                xlab="Hours post-infection",
            )
        })
        
        # Generate a heatmap of the requested GO identifier
        output$heatmap <- renderPlot({
            heatmap_GO(
                go_id = input$go_id,
                result = gox.raw,
                eSet = exprSet,
                subset=list(
                    Animal=input$animal.GO,
                    Time=input$hours.GO,
                    Infection=input$infection.GO
                    ),
                cexRow = input$cexRow.GO,
                margins = c(
                    input$margins.heatmap.bottom,
                    input$margins.heatmap.right
                    )
            )
        })
        
        # Turn the AnnotatedDataFrame into a data-table
        output$Adataframe <- renderDataTable(
            pData(exprSet),
            options = list(
                pageLength = 20)
        )
        
        output$GOscores <- renderDataTable(
            gox.raw$GO[which(gox.raw$GO$total_count >= input$min.total),],
            options = list(
                pageLength = 20)
        )
        
        output$genesScore <- renderDataTable(
            genesScore,
            options = list(
                pageLength = 20)
        )
    }
)
